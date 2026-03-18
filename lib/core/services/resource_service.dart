import 'package:flutter/foundation.dart';
import '../models/resource_model.dart';
import 'supabase_database_service.dart';
import 'auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class ResourceService {
  static Future<List<ResourceModel>> getResources({
    String? category,
    String? subject,
    String? course,
    String? searchQuery,
  }) async {
    try {
      final data = await SupabaseDatabaseService.getResources(
        category: category,
        subject: subject,
        course: course,
      );

      List<ResourceModel> resources = data.map((item) => ResourceModel.fromMap(item)).toList();

      // Apply search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        resources = resources.where((resource) =>
            resource.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            resource.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
            resource.tags.any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()))
        ).toList();
      }

      return resources;
    } catch (e) {
      debugPrint('❌ Error fetching resources: $e');
      return [];
    }
  }

  static Future<String> uploadResource({
    required String title,
    required String description,
    required String category,
    required String subject,
    required String course,
    required List<String> tags,
    required String filePath,
    required String fileName,
    bool isPublic = true,
  }) async {
    try {
      final authService = AuthService();
      final currentUser = await authService.getCurrentUser();
      
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Upload file to Supabase Storage
      final fileUrl = await _uploadFileToStorage(filePath, fileName);
      
      // Get file info
      final file = await _getFileInfo(filePath);
      
      // Create resource record in database
      final resourceData = {
        'title': title,
        'description': description,
        'category': category,
        'subject': subject,
        'course': course,
        'uploader_id': currentUser.uid,
        'uploader_name': currentUser.name,
        'file_url': fileUrl,
        'file_name': fileName,
        'file_size': file['size'],
        'file_type': file['type'],
        'uploaded_at': DateTime.now().toIso8601String(),
        'is_public': isPublic,
        'tags': tags,
        'download_count': 0,
        'view_count': 0,
      };

      return await SupabaseDatabaseService.createResource(resourceData);
    } catch (e) {
      debugPrint('❌ Error uploading resource: $e');
      rethrow;
    }
  }

  static Future<String> _uploadFileToStorage(String filePath, String fileName) async {
    try {
      final fileBytes = await File(filePath).readAsBytes();
      final storagePath = 'resources/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      await Supabase.instance.client.storage
          .from('resources')
          .uploadBinary(storagePath, fileBytes);
      
      final publicUrl = Supabase.instance.client.storage
          .from('resources')
          .getPublicUrl(storagePath);
      
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Error uploading file to storage: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> _getFileInfo(String filePath) async {
    final file = File(filePath);
    final stat = await file.stat();
    final fileName = file.path.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();
    
    return {
      'name': fileName,
      'size': stat.size,
      'type': _getFileType(extension),
      'extension': extension,
    };
  }

  static String _getFileType(String extension) {
    switch (extension) {
      case 'pdf':
        return 'pdf';
      case 'doc':
      case 'docx':
        return 'document';
      case 'ppt':
      case 'pptx':
        return 'presentation';
      case 'xls':
      case 'xlsx':
        return 'spreadsheet';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'image';
      case 'mp4':
      case 'avi':
      case 'mov':
        return 'video';
      case 'mp3':
      case 'wav':
        return 'audio';
      case 'zip':
      case 'rar':
        return 'archive';
      default:
        return 'other';
    }
  }

  static Future<void> incrementDownloadCount(String resourceId) async {
    try {
      // First get current count
      final response = await Supabase.instance.client
          .from('resources')
          .select('download_count')
          .eq('id', resourceId)
          .single();
      
      final currentCount = response['download_count'] as int? ?? 0;
      
      // Update with incremented count
      await Supabase.instance.client
          .from('resources')
          .update({'download_count': currentCount + 1})
          .eq('id', resourceId);
      
      debugPrint('📥 Incremented download count for resource: $resourceId');
    } catch (e) {
      debugPrint('❌ Error incrementing download count: $e');
    }
  }

  static Future<void> incrementViewCount(String resourceId) async {
    try {
      // First get current count
      final response = await Supabase.instance.client
          .from('resources')
          .select('view_count')
          .eq('id', resourceId)
          .single();
      
      final currentCount = response['view_count'] as int? ?? 0;
      
      // Update with incremented count
      await Supabase.instance.client
          .from('resources')
          .update({'view_count': currentCount + 1})
          .eq('id', resourceId);
      
      debugPrint('👁️ Incremented view count for resource: $resourceId');
    } catch (e) {
      debugPrint('❌ Error incrementing view count: $e');
    }
  }

  static Future<List<ResourceModel>> getUserResources() async {
    try {
      final authService = AuthService();
      final currentUser = await authService.getCurrentUser();
      
      if (currentUser == null) {
        return [];
      }

      final allResources = await getResources();
      
      return allResources.where((resource) {
        // Show public resources
        if (resource.isPublic) return true;
        
        // Show user's own resources
        if (resource.uploaderId == currentUser.uid) return true;
        
        return false;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error fetching user resources: $e');
      return [];
    }
  }

  static Future<void> deleteResource(String resourceId) async {
    try {
      // First get the resource to delete the file from storage
      final resource = await Supabase.instance.client
          .from('resources')
          .select('file_url')
          .eq('id', resourceId)
          .single();
      
      // Delete from database
      await Supabase.instance.client
          .from('resources')
          .delete()
          .eq('id', resourceId);
      
      // Delete file from storage if URL exists
      if (resource['file_url'] != null) {
        final fileUrl = resource['file_url'] as String;
        // Extract file path from URL
        final uri = Uri.parse(fileUrl);
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          final storagePath = pathSegments.last;
          await Supabase.instance.client.storage
              .from('resources')
              .remove([storagePath]);
          debugPrint('🗑️ Deleted file from storage: $storagePath');
        }
      }
      
      debugPrint('🗑️ Deleted resource: $resourceId');
    } catch (e) {
      debugPrint('❌ Error deleting resource: $e');
      rethrow;
    }
  }

  static Stream<List<ResourceModel>> getResourcesStream() {
    return SupabaseDatabaseService.getResourcesStream().map((dataList) {
      return dataList.map((item) => ResourceModel.fromMap(item)).toList();
    });
  }
}

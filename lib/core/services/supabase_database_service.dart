import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class SupabaseDatabaseService {
  static SupabaseClient? get _client => SupabaseService.client;

  /* ───────────────────── USERS ───────────────────── */

  static Future<Map<String, dynamic>?> getUser(String uid) async {
    if (_client == null) {
      debugPrint('❌ Supabase client not initialized');
      return null;
    }
    try {
      debugPrint('🔍 Querying Supabase for user with UID: $uid');
      final response = await _client!
          .from('users')
          .select()
          .eq('uid', uid)
          .single();
      debugPrint('✅ User data found: ${response.keys}');
      return response as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Error getting user: $e');
      if (e.toString().contains('PGRST116')) {
        debugPrint('💡 PGRST116 error means no rows found for the query');
        debugPrint('💡 Check if user with UID $uid exists in the users table');
      }
      return null;
    }
  }

  static Future<void> createUser(Map<String, dynamic> userData) async {
    if (_client == null) throw Exception('Supabase not initialized');
    await _client!.from('users').insert(userData);
  }

  static Future<void> updateUser(
      String uid, Map<String, dynamic> updates) async {
    if (_client == null) throw Exception('Supabase not initialized');
    await _client!.from('users').update(updates).eq('uid', uid);
  }

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    if (_client == null) {
      debugPrint('❌ Supabase client not initialized');
      return [];
    }
    try {
      debugPrint('🔍 Querying Supabase for all users');
      final currentUserId = _client!.auth.currentUser?.id ?? '';
      final response = await _client!
          .from('users')
          .select('uid, name, email, role, department, year, profile_image_url, created_at')
          .neq('uid', currentUserId) // Exclude current user
          .order('name');
      
      debugPrint('✅ Found ${response.length} users');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error getting all users: $e');
      return [];
    }
  }

  /* ───────────────────── EVENTS ───────────────────── */

  /// REALTIME STREAM (filters applied in Dart)
  static Stream<List<Map<String, dynamic>>> getEventsStream({
    bool? isPublic,
    String? category,
    bool upcomingOnly = false,
  }) {
    if (_client == null) return Stream.value([]);

    return _client!
        .from('events')
        .stream(primaryKey: ['id'])
        .map((data) {
      // Supabase stream returns List<Map<String, dynamic>> directly
      List<Map<String, dynamic>> events;
      try {
        if (data is List) {
          events = List<Map<String, dynamic>>.from(
            data.map((item) => item as Map<String, dynamic>),
          );
        } else {
          debugPrint('Unexpected data type in stream: ${data.runtimeType}');
          return <Map<String, dynamic>>[];
        }
      } catch (e) {
        debugPrint('Error processing stream data: $e');
        return <Map<String, dynamic>>[];
      }

      if (isPublic != null) {
        events =
            events.where((e) => e['is_public'] == isPublic).toList();
      }

      if (category != null) {
        events =
            events.where((e) => e['category'] == category).toList();
      }

      if (upcomingOnly) {
        final now = DateTime.now();
        events = events.where((e) {
          final start = DateTime.parse(e['start_date']);
          return start.isAfter(now);
        }).toList();
      }

      events.sort(
            (a, b) => DateTime.parse(a['start_date'])
            .compareTo(DateTime.parse(b['start_date'])),
      );

      return events;
    });
  }

  /// ONE-TIME FETCH
  static Future<List<Map<String, dynamic>>> getEvents({
    bool? isPublic,
    String? category,
    bool upcomingOnly = false,
  }) async {
    if (_client == null) return [];

    var query = _client!.from('events').select();

    if (isPublic != null) query = query.eq('is_public', isPublic);
    if (category != null) query = query.eq('category', category);
    if (upcomingOnly) {
      query =
          query.gt('start_date', DateTime.now().toIso8601String());
    }

    final response = await query.order('start_date');
    if (response is List) {
      return List<Map<String, dynamic>>.from(
        response.map((item) => item as Map<String, dynamic>),
      );
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getEvent(String id) async {
    if (_client == null) return null;
    try {
      final response =
      await _client!.from('events').select().eq('id', id).single();
      return response as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<String> createEvent(Map<String, dynamic> data) async {
    final response =
    await _client!.from('events').insert(data).select().single();
    return response['id'];
  }

  static Future<void> updateEvent(
      String id, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    await _client!.from('events').update(updates).eq('id', id);
  }

  static Future<void> deleteEvent(String id) async {
    await _client!.from('events').delete().eq('id', id);
  }

  /* ────────────────── ANNOUNCEMENTS ────────────────── */

  static Future<List<Map<String, dynamic>>> getAnnouncements({
    bool? isPublic,
    String? targetAudience,
  }) async {
    if (_client == null) return [];

    var query = _client!.from('announcements').select();
    if (isPublic != null) query = query.eq('is_public', isPublic);
    if (targetAudience != null) {
      query = query.eq('target_audience', targetAudience);
    }

    final response =
    await query.order('created_at', ascending: false);
    if (response is List) {
      return List<Map<String, dynamic>>.from(
        response.map((item) => item as Map<String, dynamic>),
      );
    }
    return [];
  }

  static Future<String> createAnnouncement(
      Map<String, dynamic> data) async {
    final response = await _client!
        .from('announcements')
        .insert(data)
        .select()
        .single();
    return response['id'];
  }

  /* ───────────────────── RESOURCES ──────────────────── */

  static Future<List<Map<String, dynamic>>> getResources({
    String? category,
    String? subject,
    String? course,
  }) async {
    if (_client == null) return [];

    var query = _client!.from('resources').select();
    if (category != null) query = query.eq('category', category);
    if (subject != null) query = query.eq('subject', subject);
    if (course != null) query = query.eq('course', course);

    final response =
    await query.order('uploaded_at', ascending: false);
    if (response is List) {
      return List<Map<String, dynamic>>.from(
        response.map((item) => item as Map<String, dynamic>),
      );
    }
    return [];
  }

  static Future<String> createResource(
      Map<String, dynamic> data) async {
    final response =
    await _client!.from('resources').insert(data).select().single();
    return response['id'];
  }

  static Stream<List<Map<String, dynamic>>> getResourcesStream() {
    if (_client == null) {
      return Stream.value([]);
    }
    
    return _client!
        .from('resources')
        .select()
        .order('created_at', ascending: false)
        .asStream();
  }

  /* ─────────────────── ACHIEVEMENTS ─────────────────── */

  static Future<List<Map<String, dynamic>>> getAchievements({
    String? studentId,
  }) async {
    if (_client == null) return [];

    var query = _client!.from('achievements').select();
    if (studentId != null) {
      query = query.eq('student_id', studentId);
    }

    final response =
    await query.order('awarded_at', ascending: false);
    if (response is List) {
      return List<Map<String, dynamic>>.from(
        response.map((item) => item as Map<String, dynamic>),
      );
    }
    return [];
  }

  static Future<String> createAchievement(
      Map<String, dynamic> data) async {
    final response =
    await _client!.from('achievements').insert(data).select().single();
    return response['id'];
  }

  /* ───────────────────── CAREERS ───────────────────── */

  static Future<List<Map<String, dynamic>>> getCareers({
    String? type,
    bool? isActive,
  }) async {
    if (_client == null) return [];

    var query = _client!.from('careers').select();
    if (type != null) query = query.eq('type', type);
    if (isActive != null) query = query.eq('is_active', isActive);

    final response =
    await query.order('posted_at', ascending: false);
    if (response is List) {
      return List<Map<String, dynamic>>.from(
        response.map((item) => item as Map<String, dynamic>),
      );
    }
    return [];
  }

  static Future<String> createCareer(
      Map<String, dynamic> data) async {
    final response =
    await _client!.from('careers').insert(data).select().single();
    return response['id'];
  }
}

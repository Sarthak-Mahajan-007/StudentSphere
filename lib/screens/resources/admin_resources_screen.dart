import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import '../../core/models/resource_model.dart';
import '../../core/services/resource_service.dart';
import '../../core/providers/auth_provider.dart';
import 'upload_resource_screen.dart';
import 'package:provider/provider.dart';

class AdminResourcesScreen extends StatefulWidget {
  const AdminResourcesScreen({super.key});

  @override
  State<AdminResourcesScreen> createState() => _AdminResourcesScreenState();
}

class _AdminResourcesScreenState extends State<AdminResourcesScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterCategory = 'all';
  String _filterSubject = 'all';

  final List<String> _categories = [
    'all',
    'notes',
    'videos',
    'pdfs',
    'slides',
    'other'
  ];

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  List<ResourceModel> _applyFilters(List<ResourceModel> resources) {
    var filtered = resources;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((resource) =>
          resource.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          resource.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          resource.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }

    // Apply category filter
    if (_filterCategory != 'all') {
      filtered = filtered.where((resource) =>
          resource.category == _filterCategory
      ).toList();
    }

    return filtered;
  }

  Future<void> _loadResources() async {
    setState(() => _isLoading = true);

    try {
      final resources = await ResourceService.getResources(
        category: _filterCategory == 'all' ? null : _filterCategory,
        subject: _filterSubject == 'all' ? null : _filterSubject,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading resources: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteResource(ResourceModel resource) async {
    try {
      setState(() => _isLoading = true);
      
      await ResourceService.deleteResource(resource.id);
      
      // Refresh the list
      await _loadResources();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resource deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting resource: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteConfirmation(ResourceModel resource) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resource'),
        content: Text('Are you sure you want to delete "${resource.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteResource(resource);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'document':
        return Icons.description;
      case 'presentation':
        return Icons.slideshow;
      case 'spreadsheet':
        return Icons.table_chart;
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.audiotrack;
      case 'archive':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'notes':
        return Colors.blue;
      case 'videos':
        return Colors.red;
      case 'pdfs':
        return Colors.orange;
      case 'slides':
        return Colors.green;
      case 'other':
        return Colors.grey;
      default:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser?.role.name == 'admin';

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          'Resource Management',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UploadResourceScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search resources...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Category Filter
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _filterCategory == category;
                      return FilterChip(
                        label: Text(
                          category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _filterCategory = category;
                          });
                          _loadResources();
                        },
                        backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        selectedColor: colorScheme.secondaryContainer,
                        side: BorderSide(
                          color: isSelected
                            ? colorScheme.secondary.withOpacity(0.3)
                            : Colors.transparent,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Resources List
          Expanded(
            child: StreamBuilder<List<ResourceModel>>(
              stream: ResourceService.getResourcesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 80,
                          color: colorScheme.error.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading resources',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final resources = snapshot.data ?? [];
                final filteredResources = _applyFilters(resources);

                if (filteredResources.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open_outlined,
                          size: 80,
                          color: colorScheme.onSurface.withOpacity(0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _filterCategory != 'all'
                              ? 'No resources found'
                              : 'No resources available',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty || _filterCategory != 'all'
                              ? 'Try adjusting your filters'
                              : 'Be the first to share a resource',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    // Trigger refresh
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredResources.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final resource = filteredResources[index];
                      return _AdminResourceCard(
                        resource: resource,
                        isAdmin: isAdmin,
                        onDelete: () => _showDeleteConfirmation(resource),
                        onTap: () => _showResourceDetails(resource),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showResourceDetails(ResourceModel resource) async {
    // Increment view count when opening details
    await ResourceService.incrementViewCount(resource.id);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(resource.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                resource.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text('By ${resource.uploaderName}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(DateFormat('MMM dd, yyyy - hh:mm a').format(resource.uploadedAt)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(resource.category.toUpperCase()),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.school, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(resource.subject),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.book, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(resource.course),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.storage, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(resource.fileSizeFormatted),
                ],
              ),
              const SizedBox(height: 8),
              if (resource.tags.isNotEmpty) ...[
                const Text('Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: resource.tags.map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.grey.shade200,
                  )).toList(),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Icon(Icons.visibility, color: Colors.blue.shade600),
                      const SizedBox(height: 4),
                      Text('${resource.viewCount}'),
                      const Text('Views', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.download, color: Colors.green.shade600),
                      const SizedBox(height: 4),
                      Text('${resource.downloadCount}'),
                      const Text('Downloads', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Download functionality
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }
}

class _AdminResourceCard extends StatelessWidget {
  final ResourceModel resource;
  final bool isAdmin;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _AdminResourceCard({
    required this.resource,
    required this.isAdmin,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(resource.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getFileIcon(resource.fileType),
                    color: _getCategoryColor(resource.category),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.uploaderName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            DateFormat('MMM dd, yyyy').format(resource.uploadedAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(resource.category).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              resource.category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _getCategoryColor(resource.category),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        resource.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: -0.3,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Actions Section
                Column(
                  children: [
                    if (isAdmin) ...[
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: onDelete,
                        tooltip: 'Delete Resource',
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Arrow indicator
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'notes':
        return Colors.blue;
      case 'videos':
        return Colors.red;
      case 'pdfs':
        return Colors.orange;
      case 'slides':
        return Colors.green;
      case 'other':
        return Colors.grey;
      default:
        return Colors.purple;
    }
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'document':
        return Icons.description;
      case 'presentation':
        return Icons.slideshow;
      case 'spreadsheet':
        return Icons.table_chart;
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.audiotrack;
      case 'archive':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }
}

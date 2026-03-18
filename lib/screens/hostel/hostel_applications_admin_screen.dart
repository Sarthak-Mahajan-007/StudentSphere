import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/hostel_application_model.dart';
import '../../core/models/room_allocation_model.dart';
import '../../core/services/hostel_service.dart';

class HostelApplicationsAdminScreen extends StatefulWidget {
  const HostelApplicationsAdminScreen({super.key});

  @override
  State<HostelApplicationsAdminScreen> createState() => _HostelApplicationsAdminScreenState();
}

class _HostelApplicationsAdminScreenState extends State<HostelApplicationsAdminScreen> {
  String _selectedFilter = 'all';
  bool _isLoading = false;

  final List<String> _filterOptions = ['all', 'pending', 'approved', 'rejected'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hostel Applications'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Applications',
            onSelected: (value) {
              setState(() => _selectedFilter = value);
            },
            itemBuilder: (context) => _filterOptions.map((filter) {
              return PopupMenuItem<String>(
                value: filter,
                child: Row(
                  children: [
                    Icon(_getFilterIcon(filter), size: 16),
                    const SizedBox(width: 8),
                    Text(_getFilterDisplay(filter)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: StreamBuilder<List<HostelApplication>>(
        stream: HostelService.getApplicationsStream(
          status: _selectedFilter == 'all' ? null : _selectedFilter,
        ),
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
                    'Error loading applications',
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

          final applications = snapshot.data ?? [];

          if (applications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _isLoading = true);
              setState(() => _isLoading = false);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: applications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final application = applications[index];
                return _ApplicationCard(
                  application: application,
                  onApprove: () => _showApprovalDialog(application, 'approved'),
                  onReject: () => _showApprovalDialog(application, 'rejected'),
                  onViewDetails: () => _showApplicationDetails(application),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _getEmptyMessage(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No applications found for the selected filter.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getEmptyMessage() {
    switch (_selectedFilter) {
      case 'pending':
        return 'No Pending Applications';
      case 'approved':
        return 'No Approved Applications';
      case 'rejected':
        return 'No Rejected Applications';
      default:
        return 'No Applications Found';
    }
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'pending':
        return Icons.pending;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.list;
    }
  }

  String _getFilterDisplay(String filter) {
    switch (filter) {
      case 'pending':
        return 'Pending Only';
      case 'approved':
        return 'Approved Only';
      case 'rejected':
        return 'Rejected Only';
      default:
        return 'All Applications';
    }
  }

  void _showApplicationDetails(HostelApplication application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Application Details - ${application.studentName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(
                icon: Icons.person,
                label: 'Student Name',
                value: application.studentName,
              ),
              _DetailRow(
                icon: Icons.badge,
                label: 'Student ID',
                value: application.studentId,
              ),
              _DetailRow(
                icon: Icons.school,
                label: 'Course',
                value: application.course,
              ),
              _DetailRow(
                icon: Icons.calendar_today,
                label: 'Year',
                value: application.year,
              ),
              _DetailRow(
                icon: Icons.phone,
                label: 'Phone',
                value: application.phone,
              ),
              _DetailRow(
                icon: Icons.apartment,
                label: 'Preferred Block',
                value: application.hostelBlock,
              ),
              _DetailRow(
                icon: Icons.bed,
                label: 'Room Type',
                value: application.roomType,
              ),
              _DetailRow(
                icon: Icons.schedule,
                label: 'Applied On',
                value: DateFormat('MMM dd, yyyy').format(application.createdAt),
              ),
              if (application.requestMessage.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Special Requests:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    application.requestMessage,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showApprovalDialog(HostelApplication application, String newStatus) {
    final isApprove = newStatus == 'approved';
    final roomController = TextEditingController();
    final blockController = TextEditingController();
    final bedController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApprove ? 'Approve Application' : 'Reject Application'),
        content: isApprove
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Please assign room details:'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: blockController,
                    decoration: const InputDecoration(
                      labelText: 'Hostel Block',
                      prefixIcon: Icon(Icons.apartment),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: roomController,
                    decoration: const InputDecoration(
                      labelText: 'Room Number',
                      prefixIcon: Icon(Icons.door_sliding),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: bedController,
                    decoration: const InputDecoration(
                      labelText: 'Bed Number',
                      prefixIcon: Icon(Icons.bed),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              )
            : const Text('Are you sure you want to reject this application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateApplicationStatus(application, newStatus, 
                block: blockController.text.trim(),
                room: roomController.text.trim(),
                bed: bedController.text.trim(),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: isApprove ? Colors.green : Colors.red,
            ),
            child: Text(isApprove ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateApplicationStatus(
    HostelApplication application, 
    String newStatus, {
    String? block,
    String? room,
    String? bed,
  }) async {
    try {
      final updates = {'status': newStatus};
      
      if (newStatus == 'approved' && block != null && room != null && bed != null) {
        updates['hostel_block'] = block;
        updates['room_number'] = room;
        updates['bed_number'] = bed;
        
        // Also create room allocation
        final allocation = RoomAllocation(
          id: '', // Will be generated
          studentId: application.studentId,
          hostelBlock: block!,
          roomNumber: room!,
          bedNumber: bed!,
          allocatedBy: 'Warden', // This would come from current user
          allocatedAt: DateTime.now(),
        );
        
        await HostelService.createRoomAllocation(allocation);
      }

      await HostelService.updateApplication(application.id, updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'approved' 
                  ? 'Application approved successfully!'
                  : 'Application rejected',
            ),
            backgroundColor: newStatus == 'approved' ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating application: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _ApplicationCard extends StatelessWidget {
  final HostelApplication application;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onViewDetails;

  const _ApplicationCard({
    required this.application,
    required this.onApprove,
    required this.onReject,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final statusColor = _getStatusColor(application.status);
    final statusIcon = _getStatusIcon(application.status);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            application.studentName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${application.course} • ${application.year}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 16, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            application.status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Details
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.phone,
                        label: 'Phone',
                        value: application.phone,
                      ),
                    ),
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.apartment,
                        label: 'Block',
                        value: application.hostelBlock,
                      ),
                    ),
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.bed,
                        label: 'Room Type',
                        value: application.roomType,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onViewDetails,
                        child: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (application.status == 'pending') ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onApprove,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Approve'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onReject,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

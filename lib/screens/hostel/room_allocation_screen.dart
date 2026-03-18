import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/room_allocation_model.dart';
import '../../core/services/hostel_service.dart';

class RoomAllocationScreen extends StatefulWidget {
  const RoomAllocationScreen({super.key});

  @override
  State<RoomAllocationScreen> createState() => _RoomAllocationScreenState();
}

class _RoomAllocationScreenState extends State<RoomAllocationScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Allocations'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddAllocationDialog,
            tooltip: 'Add New Allocation',
          ),
        ],
      ),
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: StreamBuilder<List<RoomAllocation>>(
        stream: HostelService.getRoomAllocationsStream(),
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
                    'Error loading room allocations',
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

          final allocations = snapshot.data ?? [];

          if (allocations.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh functionality
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: allocations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final allocation = allocations[index];
                return _AllocationCard(
                  allocation: allocation,
                  onEdit: () => _showEditAllocationDialog(allocation),
                  onDelete: () => _showDeleteConfirmation(allocation),
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
            Icons.bed_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Room Allocations',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No rooms have been allocated yet.\nTap the + button to add the first allocation.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddAllocationDialog() {
    _showAllocationDialog();
  }

  void _showEditAllocationDialog(RoomAllocation allocation) {
    _showAllocationDialog(allocation: allocation);
  }

  void _showAllocationDialog({RoomAllocation? allocation}) {
    final studentIdController = TextEditingController(text: allocation?.studentId ?? '');
    final blockController = TextEditingController(text: allocation?.hostelBlock ?? '');
    final roomController = TextEditingController(text: allocation?.roomNumber ?? '');
    final bedController = TextEditingController(text: allocation?.bedNumber ?? '');

    final isEdit = allocation != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Room Allocation' : 'Add Room Allocation'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: studentIdController,
                decoration: const InputDecoration(
                  labelText: 'Student ID',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
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
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (studentIdController.text.trim().isEmpty ||
                  blockController.text.trim().isEmpty ||
                  roomController.text.trim().isEmpty ||
                  bedController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              try {
                if (isEdit) {
                  final updatedAllocation = allocation.copyWith(
                    studentId: studentIdController.text.trim(),
                    hostelBlock: blockController.text.trim(),
                    roomNumber: roomController.text.trim(),
                    bedNumber: bedController.text.trim(),
                  );
                  await HostelService.updateRoomAllocation(allocation.id, updatedAllocation.toMap());
                } else {
                  final newAllocation = RoomAllocation(
                    id: '', // Will be generated
                    studentId: studentIdController.text.trim(),
                    hostelBlock: blockController.text.trim(),
                    roomNumber: roomController.text.trim(),
                    bedNumber: bedController.text.trim(),
                    allocatedBy: 'Warden', // This would come from current user
                    allocatedAt: DateTime.now(),
                  );
                  await HostelService.createRoomAllocation(newAllocation);
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEdit 
                            ? 'Room allocation updated successfully!'
                            : 'Room allocation added successfully!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error ${isEdit ? 'updating' : 'adding'} allocation: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                  );
                }
              }
            },
            child: Text(isEdit ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(RoomAllocation allocation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Room Allocation'),
        content: Text(
          'Are you sure you want to delete the room allocation for ${allocation.roomNumber}?\n\n'
          'Student: ${allocation.studentId}\n'
          'Block: ${allocation.hostelBlock}\n'
          'Room: ${allocation.roomNumber}\n'
          'Bed: ${allocation.bedNumber}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAllocation(allocation);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllocation(RoomAllocation allocation) async {
    try {
      await HostelService.deleteRoomAllocation(allocation.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Room allocation deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting allocation: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _AllocationCard extends StatelessWidget {
  final RoomAllocation allocation;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AllocationCard({
    required this.allocation,
    required this.onEdit,
    required this.onDelete,
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
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.bed,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${allocation.hostelBlock} - ${allocation.roomNumber}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bed: ${allocation.bedNumber}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
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
                        icon: Icons.badge,
                        label: 'Student ID',
                        value: allocation.studentId,
                      ),
                    ),
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.person,
                        label: 'Allocated By',
                        value: allocation.allocatedBy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Date
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Allocated on ${DateFormat('MMM dd, yyyy').format(allocation.allocatedAt)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/mess_menu_model.dart';
import '../../core/services/hostel_service.dart';

class MessManagementScreen extends StatefulWidget {
  const MessManagementScreen({super.key});

  @override
  State<MessManagementScreen> createState() => _MessManagementScreenState();
}

class _MessManagementScreenState extends State<MessManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mess Management'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddMenuDialog,
            tooltip: 'Add Menu',
          ),
        ],
      ),
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: StreamBuilder<List<MessMenu>>(
        stream: HostelService.getMessMenuStream(),
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
                    'Error loading mess menu',
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

          final menuItems = snapshot.data ?? [];

          if (menuItems.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh functionality
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: menuItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final menu = menuItems[index];
                return _MessMenuCard(
                  menu: menu,
                  onEdit: () => _showEditMenuDialog(menu),
                  onDelete: () => _showDeleteConfirmation(menu),
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
            Icons.restaurant_menu,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Mess Menu',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No mess menu has been created yet.\nTap the + button to add the first menu item.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddMenuDialog() {
    _showMenuDialog();
  }

  void _showEditMenuDialog(MessMenu menu) {
    _showMenuDialog(menu: menu);
  }

  void _showMenuDialog({MessMenu? menu}) {
    final dayController = TextEditingController(text: menu?.dayOfWeek ?? '');
    final breakfastController = TextEditingController(text: menu?.breakfast ?? '');
    final lunchController = TextEditingController(text: menu?.lunch ?? '');
    final dinnerController = TextEditingController(text: menu?.dinner ?? '');

    final isEdit = menu != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Menu' : 'Add Menu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: dayController.text.isEmpty ? 'Monday' : dayController.text,
                decoration: const InputDecoration(
                  labelText: 'Day of Week',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday',
                  'Sunday',
                ].map((day) {
                  return DropdownMenuItem(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (value) {
                  dayController.text = value!;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: breakfastController,
                decoration: const InputDecoration(
                  labelText: 'Breakfast',
                  prefixIcon: Icon(Icons.free_breakfast),
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Poha, Sandwich, etc.',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lunchController,
                decoration: const InputDecoration(
                  labelText: 'Lunch',
                  prefixIcon: Icon(Icons.lunch_dining),
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Rice, Dal, Sabzi, etc.',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dinnerController,
                decoration: const InputDecoration(
                  labelText: 'Dinner',
                  prefixIcon: Icon(Icons.dinner_dining),
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Roti, Sabzi, Dal, etc.',
                ),
                maxLines: 2,
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
              if (dayController.text.trim().isEmpty ||
                  breakfastController.text.trim().isEmpty ||
                  lunchController.text.trim().isEmpty ||
                  dinnerController.text.trim().isEmpty) {
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
                  final updatedMenu = menu.copyWith(
                    dayOfWeek: dayController.text.trim(),
                    breakfast: breakfastController.text.trim(),
                    lunch: lunchController.text.trim(),
                    dinner: dinnerController.text.trim(),
                  );
                  await HostelService.updateMessMenu(menu.id, updatedMenu.toMap());
                } else {
                  final newMenu = MessMenu(
                    id: '', // Will be generated
                    dayOfWeek: dayController.text.trim(),
                    breakfast: breakfastController.text.trim(),
                    lunch: lunchController.text.trim(),
                    dinner: dinnerController.text.trim(),
                    createdAt: DateTime.now(),
                  );
                  await HostelService.createMessMenu(newMenu);
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEdit 
                            ? 'Menu updated successfully!'
                            : 'Menu added successfully!',
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
                        'Error ${isEdit ? 'updating' : 'adding'} menu: ${e.toString()}'),
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

  void _showDeleteConfirmation(MessMenu menu) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Menu'),
        content: Text(
          'Are you sure you want to delete the menu for ${menu.dayOfWeek}?\n\n'
          'This will remove all meal items for this day.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteMenu(menu);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMenu(MessMenu menu) async {
    try {
      await HostelService.deleteMessMenu(menu.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menu deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting menu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _MessMenuCard extends StatelessWidget {
  final MessMenu menu;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MessMenuCard({
    required this.menu,
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
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            menu.dayOfWeek,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Added on ${DateFormat('MMM dd, yyyy').format(menu.createdAt)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Meal Items
                _MealSection(
                  title: '🌅 Breakfast',
                  meal: menu.breakfast,
                  icon: Icons.free_breakfast,
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                _MealSection(
                  title: '☀️ Lunch',
                  meal: menu.lunch,
                  icon: Icons.lunch_dining,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                _MealSection(
                  title: '🌙 Dinner',
                  meal: menu.dinner,
                  icon: Icons.dinner_dining,
                  color: Colors.purple,
                ),
                const SizedBox(height: 12),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Menu'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete Menu'),
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

class _MealSection extends StatelessWidget {
  final String title;
  final String meal;
  final IconData icon;
  final Color color;

  const _MealSection({
    required this.title,
    required this.meal,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            meal.isNotEmpty ? meal : 'Not specified',
            style: TextStyle(
              fontSize: 14,
              color: meal.isNotEmpty 
                  ? Colors.grey[800]
                  : Colors.grey[500],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

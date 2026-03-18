import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/mess_menu_model.dart';
import '../../core/services/hostel_service.dart';

class MessMenuScreen extends StatefulWidget {
  const MessMenuScreen({super.key});

  @override
  State<MessMenuScreen> createState() => _MessMenuScreenState();
}

class _MessMenuScreenState extends State<MessMenuScreen> {
  bool _isLoading = true;
  List<MessMenu> _messMenu = [];

  @override
  void initState() {
    super.initState();
    _loadMessMenu();
  }

  Future<void> _loadMessMenu() async {
    try {
      final menu = await HostelService.getMessMenu();
      setState(() {
        _messMenu = menu;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading mess menu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  String _getDayDisplay(String dayOfWeek) {
    final now = DateTime.now();
    final today = DateFormat('EEEE').format(now);
    
    if (dayOfWeek.toLowerCase() == today.toLowerCase()) {
      return '$dayOfWeek (Today)';
    }
    return dayOfWeek;
  }

  Color _getDayColor(String dayOfWeek) {
    final now = DateTime.now();
    final today = DateFormat('EEEE').format(now);
    
    if (dayOfWeek.toLowerCase() == today.toLowerCase()) {
      return Colors.green;
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mess Menu'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessMenu,
            tooltip: 'Refresh Menu',
          ),
        ],
      ),
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _messMenu.isEmpty
              ? _buildEmptyState()
              : _buildMessMenuList(),
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
            'No Mess Menu Available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mess menu will be updated by the hostel warden.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessMenuList() {
    return RefreshIndicator(
      onRefresh: _loadMessMenu,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _messMenu.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final menu = _messMenu[index];
          return _MessMenuCard(menu: menu);
        },
      ),
    );
  }
}

class _MessMenuCard extends StatelessWidget {
  final MessMenu menu;

  const _MessMenuCard({required this.menu});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final isToday = _isToday(menu.dayOfWeek);
    final dayColor = isToday ? Colors.green : Colors.blue;

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
        border: isToday
            ? Border.all(color: dayColor.withOpacity(0.3), width: 2)
            : null,
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
                // Day Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: dayColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getDayDisplay(menu.dayOfWeek),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: dayColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: dayColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'TODAY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isToday(String dayOfWeek) {
    final now = DateTime.now();
    final today = DateFormat('EEEE').format(now);
    return dayOfWeek.toLowerCase() == today.toLowerCase();
  }

  String _getDayDisplay(String dayOfWeek) {
    final now = DateTime.now();
    final today = DateFormat('EEEE').format(now);
    
    if (dayOfWeek.toLowerCase() == today.toLowerCase()) {
      return dayOfWeek;
    }
    return dayOfWeek;
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

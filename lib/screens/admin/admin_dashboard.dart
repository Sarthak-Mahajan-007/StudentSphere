import 'package:flutter/material.dart';
import 'package:student_sphere/screens/admin/create_admin_screen.dart';
import 'package:student_sphere/screens/events/events_screen.dart';
import 'package:student_sphere/screens/resources/resources_list_screen.dart';
import 'package:student_sphere/screens/chat/chat_list_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Portal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Administrator Dashboard',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Full system control and governance',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Management Modules',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _AdminCard(
              icon: Icons.people,
              title: 'User Management',
              subtitle: 'Manage users and roles',
              onTap: () {
                Navigator.pushNamed(context, '/create_admin');
              },
            ),
            _AdminCard(
              icon: Icons.event,
              title: 'Event Management',
              subtitle: 'View and manage all events',
              onTap: () {
                Navigator.pushNamed(context, '/events');
              },
            ),
            _AdminCard(
              icon: Icons.folder,
              title: 'Resource Management',
              subtitle: 'Manage all resources',
              onTap: () {
                Navigator.pushNamed(context, '/resources');
              },
            ),
            _AdminCard(
              icon: Icons.settings,
              title: 'System Settings',
              subtitle: 'Configure system settings',
              onTap: () {
                // TODO: Navigate to settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon!')),
                );
              },
            ),
            _AdminCard(
              icon: Icons.analytics,
              title: 'Analytics',
              subtitle: 'View platform usage statistics',
              onTap: () {
                // TODO: Navigate to analytics
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Analytics coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}


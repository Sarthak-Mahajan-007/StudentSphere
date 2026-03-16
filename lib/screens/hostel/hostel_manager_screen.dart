import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';
import '../../core/services/permission_service.dart';

class HostelManagerScreen extends StatefulWidget {
  const HostelManagerScreen({Key? key}) : super(key: key);

  @override
  State<HostelManagerScreen> createState() => _HostelManagerScreenState();
}

class _HostelManagerScreenState extends State<HostelManagerScreen> {
  int _selectedIndex = 0;
  
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard,
      title: 'Dashboard',
      permission: 'view_hostel_reports',
    ),
    NavigationItem(
      icon: Icons.bed,
      title: 'Room Applications',
      permission: 'review_hostel_applications',
    ),
    NavigationItem(
      icon: Icons.meeting_room,
      title: 'Room Allocation',
      permission: 'allocate_rooms',
    ),
    NavigationItem(
      icon: Icons.restaurant,
      title: 'Mess Management',
      permission: 'manage_mess_operations',
    ),
    NavigationItem(
      icon: Icons.people,
      title: 'Student Communication',
      permission: 'communicate_students_hostel',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hostel Management'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Show notifications
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Hostel Manager'),
            accountEmail: Text('warden@college.edu'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
          ..._navigationItems.map((item) => _buildDrawerItem(item)).toList(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Handle logout
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(NavigationItem item) {
    final hasPermission = PermissionService.hasPermission(
      UserRole.warden, 
      item.permission
    );
    
    return ListTile(
      leading: Icon(item.icon, color: hasPermission ? Colors.deepPurple : Colors.grey),
      title: Text(
        item.title,
        style: TextStyle(
          color: hasPermission ? Colors.black : Colors.grey,
          fontWeight: hasPermission ? FontWeight.normal : FontWeight.normal,
        ),
      ),
      enabled: hasPermission,
      onTap: hasPermission
          ? () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = _navigationItems.indexOf(item);
              });
            }
          : null,
    );
  }

  Widget _buildBody() {
    final selectedItem = _navigationItems[_selectedIndex];
    final hasPermission = PermissionService.hasPermission(
      UserRole.warden,
      selectedItem.permission
    );

    if (!hasPermission) {
      return _buildAccessDeniedScreen();
    }

    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildRoomApplications();
      case 2:
        return _buildRoomAllocation();
      case 3:
        return _buildMessManagement();
      case 4:
        return _buildStudentCommunication();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildAccessDeniedScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.block, size: 80, color: Colors.red),
          const SizedBox(height: 20),
          const Text(
            'Access Denied',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'You don\'t have permission to access this feature.',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCard(),
          const SizedBox(height: 20),
          _buildQuickActions(),
          const SizedBox(height: 20),
          _buildRecentActivities(),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hostel Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Total Rooms', '200', Colors.blue),
                ),
                Expanded(
                  child: _buildStatItem('Occupied', '180', Colors.green),
                ),
                Expanded(
                  child: _buildStatItem('Available', '20', Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Applications', '45', Colors.purple),
                ),
                Expanded(
                  child: _buildStatItem('Pending', '12', Colors.red),
                ),
                Expanded(
                  child: _buildStatItem('Allocated', '33', Colors.teal),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 1; // Navigate to applications
                      });
                    },
                    icon: const Icon(Icons.list),
                    label: const Text('Review Applications'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 2; // Navigate to allocation
                      });
                    },
                    icon: const Icon(Icons.bed),
                    label: const Text('Allocate Rooms'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildActivityItem(
              'New room application received',
              'John Doe - Room A-101',
              '2 hours ago',
              Icons.person_add,
            ),
            ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(time, style: TextStyle(color: Colors.grey[600])),
    );
  }

  Widget _buildRoomApplications() {
    return const Center(
      child: Text('Room Applications Screen - To be implemented'),
    );
  }

  Widget _buildRoomAllocation() {
    return const Center(
      child: Text('Room Allocation Screen - To be implemented'),
    );
  }

  Widget _buildMessManagement() {
    return const Center(
      child: Text('Mess Management Screen - To be implemented'),
    );
  }

  Widget _buildStudentCommunication() {
    return const Center(
      child: Text('Student Communication Screen - To be implemented'),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String title;
  final String permission;

  NavigationItem({
    required this.icon,
    required this.title,
    required this.permission,
  });
}

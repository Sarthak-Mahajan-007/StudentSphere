import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/permission_service.dart';
import '../../core/services/supabase_service.dart';

class CreateAdminScreen extends StatefulWidget {
  const CreateAdminScreen({super.key});

  @override
  State<CreateAdminScreen> createState() => _CreateAdminScreenState();
}

class _CreateAdminScreenState extends State<CreateAdminScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  UserRole _selectedRole = UserRole.student;
  bool _isLoading = false;
  bool _isLoadingUsers = true;
  List<UserModel> _users = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoadingUsers = true;
      _error = null;
    });

    try {
      final supabase = SupabaseService.client;
      if (supabase == null) {
        throw Exception('Supabase client not initialized');
      }
      
      // Fetch users from the database
      final response = await supabase
          .from('users')
          .select('*')
          .neq('role', 'admin') // Exclude admin users
          .order('created_at', ascending: false);

      final users = response.map((user) => UserModel.fromMap(user)).toList();

      setState(() {
        _users = users;
        _isLoadingUsers = false;
      });

      debugPrint('✅ Fetched ${users.length} users from database');
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingUsers = false;
      });
      debugPrint('❌ Error fetching users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateUserDialog,
            tooltip: 'Create New User',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsHeader(),
          Expanded(child: _buildUsersList()),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    if (_isLoadingUsers) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final studentCount = _users.where((u) => u.role == UserRole.student).length;
    final facultyCount = _users.where((u) => u.role == UserRole.faculty).length;
    final wardenCount = _users.where((u) => u.role == UserRole.warden).length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Students', studentCount.toString(), Colors.blue),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard('Faculty', facultyCount.toString(), Colors.green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard('Hostel Managers', wardenCount.toString(), Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
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
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    if (_isLoadingUsers) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading users',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No users found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Try creating new users or check your database connection',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.role),
          child: Icon(
            _getRoleIcon(user.role),
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            if (user.studentId != null) Text('ID: ${user.studentId}'),
            if (user.department != null) Text('Dept: ${user.department}'),
            Text('Role: ${PermissionService.getRoleDisplayName(user.role)}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditUserDialog(user);
                break;
              case 'delete':
                _showDeleteConfirmation(user);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Edit User'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete User'),
                ],
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Colors.blue;
      case UserRole.faculty:
        return Colors.green;
      case UserRole.warden:
        return Colors.orange;
      case UserRole.admin:
        return Colors.red;
      case UserRole.guest:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Icons.school;
      case UserRole.faculty:
        return Icons.person;
      case UserRole.warden:
        return Icons.home;
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.guest:
        return Icons.person;
    }
  }

  void _showCreateUserDialog() {
    _clearControllers();
    showDialog(
      context: context,
      builder: (context) => _buildUserDialog(isEdit: false),
    );
  }

  void _showEditUserDialog(UserModel user) {
    _populateControllers(user);
    showDialog(
      context: context,
      builder: (context) => _buildUserDialog(isEdit: true, user: user),
    );
  }

  void _showDeleteConfirmation(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(user);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDialog({required bool isEdit, UserModel? user}) {
    return AlertDialog(
      title: Text(isEdit ? 'Edit User' : 'Create New User'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<UserRole>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: UserRole.values
                  .where((role) => role != UserRole.admin) // Exclude admin role
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(PermissionService.getRoleDisplayName(role)),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
            if (_selectedRole == UserRole.student) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _studentIdController,
                decoration: const InputDecoration(
                  labelText: 'Student ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            if (_selectedRole == UserRole.faculty || _selectedRole == UserRole.warden) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
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
          onPressed: _isLoading ? null : () => _saveUser(isEdit, user),
          child: _isLoading
              ? const CircularProgressIndicator()
              : Text(isEdit ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  void _clearControllers() {
    _nameController.clear();
    _emailController.clear();
    _studentIdController.clear();
    _departmentController.clear();
    _yearController.clear();
    _phoneController.clear();
    _selectedRole = UserRole.student;
  }

  void _populateControllers(UserModel user) {
    _nameController.text = user.name;
    _emailController.text = user.email;
    _studentIdController.text = user.studentId ?? '';
    _departmentController.text = user.department ?? '';
    _yearController.text = user.year ?? '';
    _phoneController.text = user.phone ?? '';
    _selectedRole = user.role;
  }

  void _saveUser(bool isEdit, UserModel? user) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = SupabaseService.client;
      if (supabase == null) {
        throw Exception('Supabase client not initialized');
      }

      if (isEdit && user != null) {
        // Update existing user in database
        final updateData = {
          'name': _nameController.text,
          'email': _emailController.text,
          'role': _selectedRole.value,
          'phone': _phoneController.text.isEmpty ? null : _phoneController.text,
          'updated_at': DateTime.now().toIso8601String(),
        };

        // Add student-specific fields if role is student
        if (_selectedRole == UserRole.student) {
          updateData['student_id'] = _studentIdController.text.isEmpty ? null : _studentIdController.text;
          updateData['department'] = _departmentController.text.isEmpty ? null : _departmentController.text;
          updateData['year'] = _yearController.text.isEmpty ? null : _yearController.text;
        }

        await supabase
            .from('users')
            .update(updateData)
            .eq('uid', user.uid);

        // Update local list
        final updatedUser = UserModel(
          uid: user.uid,
          email: _emailController.text,
          name: _nameController.text,
          role: _selectedRole,
          studentId: _studentIdController.text.isEmpty ? null : _studentIdController.text,
          department: _departmentController.text.isEmpty ? null : _departmentController.text,
          year: _yearController.text.isEmpty ? null : _yearController.text,
          phone: _phoneController.text.isEmpty ? null : _phoneController.text,
          createdAt: user.createdAt,
          lastLogin: user.lastLogin,
        );

        setState(() {
          final index = _users.indexWhere((u) => u.uid == user.uid);
          if (index != -1) {
            _users[index] = updatedUser;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully!')),
        );
        debugPrint('✅ User updated: ${user.uid}');
      } else {
        // Create new user in database
        final newUserData = {
          'uid': DateTime.now().millisecondsSinceEpoch.toString(),
          'email': _emailController.text,
          'name': _nameController.text,
          'role': _selectedRole.value,
          'phone': _phoneController.text.isEmpty ? null : _phoneController.text,
          'created_at': DateTime.now().toIso8601String(),
        };

        // Add student-specific fields if role is student
        if (_selectedRole == UserRole.student) {
          newUserData['student_id'] = _studentIdController.text.isEmpty ? null : _studentIdController.text;
          newUserData['department'] = _departmentController.text.isEmpty ? null : _departmentController.text;
          newUserData['year'] = _yearController.text.isEmpty ? null : _yearController.text;
        }

        // Add faculty-specific fields if role is faculty
        if (_selectedRole == UserRole.faculty) {
          newUserData['department'] = _departmentController.text.isEmpty ? null : _departmentController.text;
        }

        debugPrint('📝 Creating user with data: $newUserData');

        await supabase.from('users').insert(newUserData);

        // Refresh users list
        await _fetchUsers();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User created successfully!')),
        );
        debugPrint('✅ User created: ${newUserData['uid']}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      debugPrint('❌ Error saving user: $e');
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _deleteUser(UserModel user) async {
    try {
      final supabase = SupabaseService.client;
      if (supabase == null) {
        throw Exception('Supabase client not initialized');
      }

      // Delete user from database
      await supabase.from('users').delete().eq('uid', user.uid);

      // Update local list
      setState(() {
        _users.removeWhere((u) => u.uid == user.uid);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully!')),
      );
      debugPrint('✅ User deleted: ${user.uid}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      debugPrint('❌ Error deleting user: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    _departmentController.dispose();
    _yearController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

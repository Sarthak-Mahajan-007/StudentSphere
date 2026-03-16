import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/user_model.dart';
import 'login_screen.dart';
import '../student/student_dashboard.dart';
import '../faculty/faculty_dashboard.dart';
import '../admin/admin_dashboard.dart';
import '../guest/guest_dashboard.dart';
import '../hostel/hostel_manager_screen.dart';
import '../hostel/hostel_manager_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        final user = authProvider.currentUser!;
        
        // Route to appropriate dashboard based on role
        switch (user.role) {
          case UserRole.student:
            return const StudentDashboard();
          case UserRole.faculty:
            return const FacultyDashboard();
          case UserRole.admin:
            return const AdminDashboard();
          case UserRole.warden:
            return const HostelManagerDashboard();
          case UserRole.guest:
            return const GuestDashboard();
        }
      },
    );
  }
}


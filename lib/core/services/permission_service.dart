import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class PermissionService {
  static const Map<UserRole, List<String>> _rolePermissions = {
    UserRole.student: [
      'view_content',
      'post_lost_found',
      'register_events',
      'view_own_account',
      'use_chat',
      'submit_hostel_application',
    ],
    UserRole.faculty: [
      'view_content',
      'create_events',
      'post_notices',
      'view_own_account',
      'upload_resources',
      'post_career_opportunities',
      'monitor_student_chat',
      'create_events_pending_approval',
      'post_notices_pending_approval',
    ],
    UserRole.admin: [
      'create_accounts',
      'grant_permissions',
      'view_all_data',
      'edit_department_data',
      'monitor_all_chat',
      'approve_events',
      'approve_notices',
      'view_content',
      'create_events',
      'post_notices',
      'view_own_account',
      'upload_resources',
      'post_career_opportunities',
      'monitor_student_chat',
    ],
    UserRole.warden: [
      'review_hostel_applications',
      'allocate_rooms',
      'manage_mess_operations',
      'view_hostel_reports',
      'communicate_students_hostel',
      'view_own_account',
    ],
    UserRole.guest: [
      'view_public_content',
    ],
  };

  static const Map<String, List<UserRole>> _featurePermissions = {
    'create_accounts': [UserRole.admin],
    'grant_permissions': [UserRole.admin],
    'view_all_data': [UserRole.admin],
    'edit_department_data': [UserRole.admin],
    'monitor_all_chat': [UserRole.admin, UserRole.faculty],
    'approve_events': [UserRole.admin],
    'approve_notices': [UserRole.admin],
    'create_events': [UserRole.admin, UserRole.faculty],
    'post_notices': [UserRole.admin, UserRole.faculty],
    'view_content': [UserRole.student, UserRole.faculty, UserRole.admin],
    'upload_resources': [UserRole.admin, UserRole.faculty],
    'post_career_opportunities': [UserRole.admin, UserRole.faculty],
    'monitor_student_chat': [UserRole.admin, UserRole.faculty],
    'create_events_pending_approval': [UserRole.faculty],
    'post_notices_pending_approval': [UserRole.faculty],
    'view_own_account': [UserRole.student, UserRole.faculty, UserRole.admin, UserRole.warden],
    'use_chat': [UserRole.student],
    'register_events': [UserRole.student],
    'post_lost_found': [UserRole.student],
    'submit_hostel_application': [UserRole.student],
    'review_hostel_applications': [UserRole.warden],
    'allocate_rooms': [UserRole.warden],
    'manage_mess_operations': [UserRole.warden],
    'view_hostel_reports': [UserRole.warden],
    'communicate_students_hostel': [UserRole.warden],
    'view_public_content': [UserRole.student, UserRole.faculty, UserRole.admin, UserRole.warden, UserRole.guest],
  };

  static bool hasPermission(UserRole role, String permission) {
    final permissions = _rolePermissions[role] ?? [];
    return permissions.contains(permission);
  }

  static bool canAccessFeature(UserRole role, String feature) {
    final allowedRoles = _featurePermissions[feature] ?? [];
    return allowedRoles.contains(role);
  }

  static List<String> getRolePermissions(UserRole role) {
    return _rolePermissions[role] ?? [];
  }

  static String getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.faculty:
        return 'Faculty';
      case UserRole.admin:
        return 'Administrator';
      case UserRole.warden:
        return 'Hostel Manager';
      case UserRole.guest:
        return 'Guest';
    }
  }

  static bool canCreateAccounts(UserRole role) {
    return role == UserRole.admin;
  }

  static bool canMonitorChat(UserRole role) {
    return [UserRole.admin, UserRole.faculty].contains(role);
  }

  static bool canManageHostel(UserRole role) {
    return role == UserRole.warden;
  }

  static bool requiresApproval(UserRole role) {
    if (role == UserRole.warden) return false;
    if (role == UserRole.admin) return false;
    return true;
  }

  static void logPermissionCheck(UserRole role, String feature, bool granted) {
    if (kDebugMode) {
      print('🔐 Permission Check: ${getRoleDisplayName(role)} -> $feature: ${granted ? "GRANTED" : "DENIED"}');
    }
  }
}

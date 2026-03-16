import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Initialize and load current user
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getCurrentUser();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? studentId,
    String? department,
    String? year,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
        studentId: studentId,
        department: department,
        year: year,
        phone: phone,
      );
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signIn(
        email: email,
        password: password,
      );
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // Update profile
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? department,
    String? year,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return;

    try {
      await _authService.updateProfile(
        name: name,
        phone: phone,
        department: department,
        year: year,
        profileImageUrl: profileImageUrl,
      );

      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phone: phone ?? _currentUser!.phone,
        department: department ?? _currentUser!.department,
        year: year ?? _currentUser!.year,
        profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
      );

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Check if user has permission for action
  bool hasPermission(String action) {
    if (_currentUser == null) return false;

    switch (_currentUser!.role) {
      case UserRole.admin:
        return true; // Admin has all permissions
      case UserRole.faculty:
        return action != 'system_config'; // Faculty can't modify system config
      case UserRole.student:
        return action == 'view' || action == 'register' || action == 'upload_notes';
      case UserRole.warden:
        return action == 'hostel_management' || action == 'view' || action == 'allocate_rooms';
      case UserRole.guest:
        return action == 'view_public';
    }
  }
}


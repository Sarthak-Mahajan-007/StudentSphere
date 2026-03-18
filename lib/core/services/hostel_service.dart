import 'package:flutter/foundation.dart';
import '../models/hostel_application_model.dart';
import '../models/room_allocation_model.dart';
import '../models/mess_menu_model.dart';
import '../models/mess_attendance_model.dart';
import 'supabase_database_service.dart';
import 'supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HostelService {
  static SupabaseClient? get _client => SupabaseService.client;

  // ==================== HOSTEL APPLICATIONS ===================

  static Future<List<HostelApplication>> getApplications({
    String? status,
  }) async {
    if (_client == null) return [];

    try {
      var query = _client!.from('hostel_applications').select();
      if (status != null) {
        query = query.eq('status', status);
      }
      
      final data = await query.order('created_at', ascending: false);
      return data.map((item) => HostelApplication.fromMap(item)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching applications: $e');
      return [];
    }
  }

  static Stream<List<HostelApplication>> getApplicationsStream({
    String? status,
  }) {
    if (_client == null) {
      return Stream.value([]);
    }

    var query = _client!.from('hostel_applications').select();
    if (status != null) {
      query = query.eq('status', status);
    }
    
    return query
        .order('created_at', ascending: false)
        .asStream()
        .map((data) => data.map((item) => HostelApplication.fromMap(item)).toList());
  }

  static Future<String> createApplication(HostelApplication application) async {
    if (_client == null) throw Exception('Supabase not initialized');
    
    try {
      final response = await _client!
          .from('hostel_applications')
          .insert(application.toMap())
          .select()
          .single();
      return response['id'];
    } catch (e) {
      debugPrint('❌ Error creating application: $e');
      rethrow;
    }
  }

  static Future<void> updateApplication(String id, Map<String, dynamic> updates) async {
    if (_client == null) throw Exception('Supabase not initialized');
    
    try {
      await _client!
          .from('hostel_applications')
          .update(updates)
          .eq('id', id);
    } catch (e) {
      debugPrint('❌ Error updating application: $e');
      rethrow;
    }
  }

  static Future<void> deleteApplication(String id) async {
    if (_client == null) throw Exception('Supabase not initialized');
    
    try {
      await _client!
          .from('hostel_applications')
          .delete()
          .eq('id', id);
    } catch (e) {
      debugPrint('❌ Error deleting application: $e');
      rethrow;
    }
  }

  // ==================== ROOM ALLOCATIONS ===================

  static Future<List<RoomAllocation>> getRoomAllocations() async {
    if (_client == null) return [];

    try {
      final data = await _client!
          .from('room_allocations')
          .select()
          .order('allocated_at', ascending: false);
      return data.map((item) => RoomAllocation.fromMap(item)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching room allocations: $e');
      return [];
    }
  }

  static Stream<List<RoomAllocation>> getRoomAllocationsStream() {
    if (_client == null) {
      return Stream.value([]);
    }

    return _client!
        .from('room_allocations')
        .select()
        .order('allocated_at', ascending: false)
        .asStream()
        .map((data) => data.map((item) => RoomAllocation.fromMap(item)).toList());
  }

  static Future<String> createRoomAllocation(RoomAllocation allocation) async {
    if (_client == null) throw Exception('Supabase not initialized');
    
    try {
      final response = await _client!
          .from('room_allocations')
          .insert(allocation.toMap())
          .select()
          .single();
      return response['id'];
    } catch (e) {
      debugPrint('❌ Error creating room allocation: $e');
      rethrow;
    }
  }

  static Future<void> updateRoomAllocation(String id, Map<String, dynamic> updates) async {
    if (_client == null) throw Exception('Supabase not initialized');
    
    try {
      await _client!
          .from('room_allocations')
          .update(updates)
          .eq('id', id);
    } catch (e) {
      debugPrint('❌ Error updating room allocation: $e');
      rethrow;
    }
  }

  static Future<void> deleteRoomAllocation(String id) async {
    if (_client == null) throw Exception('Supabase not initialized');
    
    try {
      await _client!
          .from('room_allocations')
          .delete()
          .eq('id', id);
    } catch (e) {
      debugPrint('❌ Error deleting room allocation: $e');
      rethrow;
    }
  }

  // ==================== MESS MENU ===================

  static Future<List<MessMenu>> getMessMenu() async {
    if (_client == null) return [];

    try {
      final data = await _client!
          .from('mess_menu')
          .select()
          .order('day_of_week');
      return data.map((item) => MessMenu.fromMap(item)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching mess menu: $e');
      return [];
    }
  }

  static Stream<List<MessMenu>> getMessMenuStream() {
    if (_client == null) {
      return Stream.value([]);
    }

    return _client!
        .from('mess_menu')
        .select()
        .order('day_of_week')
        .asStream()
        .map((data) => data.map((item) => MessMenu.fromMap(item)).toList());
  }

  static Future<String> createMessMenu(MessMenu menu) async {
    if (_client == null) throw Exception('Supabase not initialized');
    
    try {
      final response = await _client!
          .from('mess_menu')
          .insert(menu.toMap())
          .select()
          .single();
      return response['id'];
    } catch (e) {
      debugPrint('❌ Error creating mess menu: $e');
      rethrow;
    }
  }

  static Future<void> updateMessMenu(String id, Map<String, dynamic> updates) async {
    if (_client == null) throw Exception('Supabase not initialized');
    
    try {
      await _client!
          .from('mess_menu')
          .update(updates)
          .eq('id', id);
    } catch (e) {
      debugPrint('❌ Error updating mess menu: $e');
      rethrow;
    }
  }

  static Future<void> deleteMessMenu(String id) async {
    if (_client == null) throw Exception('Supabase not initialized');
    
    try {
      await _client!
          .from('mess_menu')
          .delete()
          .eq('id', id);
    } catch (e) {
      debugPrint('❌ Error deleting mess menu: $e');
      rethrow;
    }
  }

  // ==================== MESS ATTENDANCE ===================

  static Future<List<MessAttendance>> getMessAttendance({
    String? studentId,
    DateTime? date,
  }) async {
    if (_client == null) return [];

    try {
      var query = _client!.from('mess_attendance').select();
      if (studentId != null) {
        query = query.eq('student_id', studentId);
      }
      if (date != null) {
        query = query.eq('date', date!.toIso8601String());
      }
      
      final data = await query.order('date', ascending: false);
      return data.map((item) => MessAttendance.fromMap(item)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching mess attendance: $e');
      return [];
    }
  }

  static Stream<List<MessAttendance>> getMessAttendanceStream({
    String? studentId,
    DateTime? date,
  }) {
    if (_client == null) {
      return Stream.value([]);
    }

    var query = _client!.from('mess_attendance').select();
    if (studentId != null) {
      query = query.eq('student_id', studentId);
    }
    if (date != null) {
      query = query.eq('date', date!.toIso8601String());
    }
    
    return query
        .order('date', ascending: false)
        .asStream()
        .map((data) => data.map((item) => MessAttendance.fromMap(item)).toList());
  }

  static Future<String> createMessAttendance(MessAttendance attendance) async {
    if (_client == null) throw Exception('Supabase not initialized');
    
    try {
      final response = await _client!
          .from('mess_attendance')
          .insert(attendance.toMap())
          .select()
          .single();
      return response['id'];
    } catch (e) {
      debugPrint('❌ Error creating mess attendance: $e');
      rethrow;
    }
  }

  static Future<void> deleteMessAttendance(String id) async {
    if (_client == null) throw Exception('Supabase not initialized');
    
    try {
      await _client!
          .from('mess_attendance')
          .delete()
          .eq('id', id);
    } catch (e) {
      debugPrint('❌ Error deleting mess attendance: $e');
      rethrow;
    }
  }
}

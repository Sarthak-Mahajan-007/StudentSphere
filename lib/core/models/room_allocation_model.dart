class RoomAllocation {
  final String id;
  final String studentId;
  final String hostelBlock;
  final String roomNumber;
  final String bedNumber;
  final String allocatedBy;
  final DateTime allocatedAt;

  RoomAllocation({
    required this.id,
    required this.studentId,
    required this.hostelBlock,
    required this.roomNumber,
    required this.bedNumber,
    required this.allocatedBy,
    required this.allocatedAt,
  });

  factory RoomAllocation.fromMap(Map<String, dynamic> map) {
    return RoomAllocation(
      id: map['id']?.toString() ?? '',
      studentId: map['student_id']?.toString() ?? '',
      hostelBlock: map['hostel_block']?.toString() ?? '',
      roomNumber: map['room_number']?.toString() ?? '',
      bedNumber: map['bed_number']?.toString() ?? '',
      allocatedBy: map['allocated_by']?.toString() ?? '',
      allocatedAt: DateTime.parse(map['allocated_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'hostel_block': hostelBlock,
      'room_number': roomNumber,
      'bed_number': bedNumber,
      'allocated_by': allocatedBy,
      'allocated_at': allocatedAt.toIso8601String(),
    };
  }

  RoomAllocation copyWith({
    String? id,
    String? studentId,
    String? hostelBlock,
    String? roomNumber,
    String? bedNumber,
    String? allocatedBy,
    DateTime? allocatedAt,
  }) {
    return RoomAllocation(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      hostelBlock: hostelBlock ?? this.hostelBlock,
      roomNumber: roomNumber ?? this.roomNumber,
      bedNumber: bedNumber ?? this.bedNumber,
      allocatedBy: allocatedBy ?? this.allocatedBy,
      allocatedAt: allocatedAt ?? this.allocatedAt,
    );
  }

  @override
  String toString() {
    return 'RoomAllocation(id: $id, room: $roomNumber, bed: $bedNumber)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoomAllocation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

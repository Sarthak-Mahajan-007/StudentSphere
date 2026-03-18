class HostelApplication {
  final String id;
  final String studentId;
  final String studentName;
  final String course;
  final String year;
  final String phone;
  final String hostelBlock;
  final String roomType;
  final String requestMessage;
  final String status; // pending, approved, rejected
  final DateTime createdAt;
  final DateTime? updatedAt;

  HostelApplication({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.course,
    required this.year,
    required this.phone,
    required this.hostelBlock,
    required this.roomType,
    required this.requestMessage,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory HostelApplication.fromMap(Map<String, dynamic> map) {
    return HostelApplication(
      id: map['id']?.toString() ?? '',
      studentId: map['student_id']?.toString() ?? '',
      studentName: map['student_name']?.toString() ?? '',
      course: map['course']?.toString() ?? '',
      year: map['year']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      hostelBlock: map['hostel_block']?.toString() ?? '',
      roomType: map['room_type']?.toString() ?? '',
      requestMessage: map['request_message']?.toString() ?? '',
      status: map['status']?.toString() ?? 'pending',
      createdAt: DateTime.parse(map['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'course': course,
      'year': year,
      'phone': phone,
      'hostel_block': hostelBlock,
      'room_type': roomType,
      'request_message': requestMessage,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  HostelApplication copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? course,
    String? year,
    String? phone,
    String? hostelBlock,
    String? roomType,
    String? requestMessage,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HostelApplication(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      course: course ?? this.course,
      year: year ?? this.year,
      phone: phone ?? this.phone,
      hostelBlock: hostelBlock ?? this.hostelBlock,
      roomType: roomType ?? this.roomType,
      requestMessage: requestMessage ?? this.requestMessage,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'HostelApplication(id: $id, studentName: $studentName, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HostelApplication && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

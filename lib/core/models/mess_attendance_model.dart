class MessAttendance {
  final String id;
  final String studentId;
  final DateTime date;
  final String mealType; // breakfast, lunch, dinner

  MessAttendance({
    required this.id,
    required this.studentId,
    required this.date,
    required this.mealType,
  });

  factory MessAttendance.fromMap(Map<String, dynamic> map) {
    return MessAttendance(
      id: map['id']?.toString() ?? '',
      studentId: map['student_id']?.toString() ?? '',
      date: DateTime.parse(map['date']?.toString() ?? DateTime.now().toIso8601String()),
      mealType: map['meal_type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'date': date.toIso8601String(),
      'meal_type': mealType,
    };
  }

  MessAttendance copyWith({
    String? id,
    String? studentId,
    DateTime? date,
    String? mealType,
  }) {
    return MessAttendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
    );
  }

  @override
  String toString() {
    return 'MessAttendance(id: $id, student: $studentId, meal: $mealType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessAttendance && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

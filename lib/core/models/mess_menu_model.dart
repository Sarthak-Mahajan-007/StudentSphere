class MessMenu {
  final String id;
  final String dayOfWeek;
  final String breakfast;
  final String lunch;
  final String dinner;
  final DateTime createdAt;

  MessMenu({
    required this.id,
    required this.dayOfWeek,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.createdAt,
  });

  factory MessMenu.fromMap(Map<String, dynamic> map) {
    return MessMenu(
      id: map['id']?.toString() ?? '',
      dayOfWeek: map['day_of_week']?.toString() ?? '',
      breakfast: map['breakfast']?.toString() ?? '',
      lunch: map['lunch']?.toString() ?? '',
      dinner: map['dinner']?.toString() ?? '',
      createdAt: DateTime.parse(map['created_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day_of_week': dayOfWeek,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'created_at': createdAt.toIso8601String(),
    };
  }

  MessMenu copyWith({
    String? id,
    String? dayOfWeek,
    String? breakfast,
    String? lunch,
    String? dinner,
    DateTime? createdAt,
  }) {
    return MessMenu(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'MessMenu(id: $id, day: $dayOfWeek)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessMenu && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

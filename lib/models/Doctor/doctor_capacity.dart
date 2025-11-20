class DoctorCapacity {
  final String id;

  final int maxPatientsPerday;

  final int sessionDurationMinutes;
  final bool isActive;
  DoctorCapacity({
    required this.id,
    required this.isActive,
    required this.maxPatientsPerday,
    required this.sessionDurationMinutes,
  });

  factory DoctorCapacity.fromJson(Map<String, dynamic> json) {
    return DoctorCapacity(
      id: json['doctorId'],

      maxPatientsPerday: json['maxPatientsPerDay'],
      sessionDurationMinutes: json['sessionDurationMinutes'],
      isActive: json['isActive'],
    );
  }
  factory DoctorCapacity.empty() {
    return DoctorCapacity(
      id: '12312',
      isActive: true,
      maxPatientsPerday: 8,
      sessionDurationMinutes: 30,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'doctorId': id,

      'maxPatientsPerDay': maxPatientsPerday,
      'sessionDurationMinutes': sessionDurationMinutes,
      'isActive': isActive,
    };
  }
}

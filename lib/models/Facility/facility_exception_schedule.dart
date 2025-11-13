class FacilityExceptionSchedule {
  final String id;
  final String healthcareFacilityId;
  final DateTime date;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String status;
  final String reason;

 const  FacilityExceptionSchedule({
    required this.id,
    required this.healthcareFacilityId,
    required this.date,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.reason,
  });

  factory FacilityExceptionSchedule.fromJson(Map<String, dynamic> json) {
    return FacilityExceptionSchedule(
      id: json['id'],
      healthcareFacilityId: json['healthcareFacilityId'],
      date: DateTime.parse(json['date']),
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      status: json['status'],
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'healthcareFacilityId': healthcareFacilityId,
      'date': date.toIso8601String(),
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'reason': reason,
    };
  }
}

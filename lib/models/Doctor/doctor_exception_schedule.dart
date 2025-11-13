class DoctorExceptionSchedule {
  final String id;
  final String doctorId;
  final DateTime date;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String status;
  final String reason;

 const  DoctorExceptionSchedule({
    required this.id,
    required this.doctorId,
    required this.date,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.reason,
  });

  factory DoctorExceptionSchedule.fromJson(Map<String, dynamic> json) {
    return DoctorExceptionSchedule(
      id: json['id'],
      doctorId: json['doctorId'],
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
      'doctorId': doctorId,
      'date': date.toIso8601String(),
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'reason': reason,
    };
  }
}

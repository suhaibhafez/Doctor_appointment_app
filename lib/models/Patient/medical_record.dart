import 'package:doctor_appointment_app/models/Patient/prescription.dart';

class MedicalRecord {
  final String doctorFullName;
  final String facilityName;
  final DateTime recordDate;
  final String diagnosis;
  final String treatmentNotes;
  final String followUpInstructions;
  final List<Prescription> prescriptions;
  final DateTime scheduledDate;
  final String scheduledTime;

  MedicalRecord({
    required this.doctorFullName,
    required this.facilityName,
    required this.recordDate,
    required this.diagnosis,
    required this.treatmentNotes,
    required this.followUpInstructions,
    required this.prescriptions,
    required this.scheduledDate,
    required this.scheduledTime,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
   
    return MedicalRecord(
      doctorFullName: json['doctorFullName'],
      facilityName: json['facilityName'],
      recordDate: DateTime.parse(json['recordDate']),
      diagnosis: json['diagnosis'],
      treatmentNotes: json['treatmentNotes'],
      followUpInstructions: json['followUpInstructions'],
      prescriptions:
          (json['prescriptions'] as List<dynamic>?)
              ?.map((p) => Prescription.fromJson(p))
              .toList() ??
          [],
      scheduledDate: DateTime.parse(json['appointment']['scheduledDate']),
      scheduledTime: json['appointment']['scheduledTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctorFullName': doctorFullName,
      'facilityName': facilityName,
      'recordDate': recordDate.toIso8601String(),
      'diagnosis': diagnosis,
      'treatmentNotes': treatmentNotes,
      'followUpInstructions': followUpInstructions,
      'prescriptions': prescriptions.map((p) => p.toJson()).toList(),
      'scheduledDate': scheduledDate,
      'scheduledTime': scheduledTime,
    };
  }
}

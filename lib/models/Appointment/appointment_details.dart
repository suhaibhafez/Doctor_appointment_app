import 'package:doctor_appointment_app/models/Doctor/doctor.dart';
import 'package:doctor_appointment_app/models/Facility/facility.dart';
import 'package:doctor_appointment_app/models/Patient/billing.dart';
import 'package:doctor_appointment_app/models/Patient/patient.dart';
import 'package:doctor_appointment_app/models/Patient/prescription.dart';

class AppointmentDetails {
  final String id;
  final DateTime scheduledDate;
  final String scheduledTime;
  final int durationMinutes;
  final String status;
  final DateTime bookingDate;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;


  final Patient patient;
  final Doctor doctor;
  final Facility facility;
  final Billing? billing;
  final List<Prescription>? prescriptions;

  const AppointmentDetails({
    required this.id,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.durationMinutes,
    required this.status,
    required this.bookingDate,
    this.checkInTime,
    this.checkOutTime,

    required this.patient,
    required this.doctor,
    required this.facility,
    this.billing,
    this.prescriptions,
  });

  factory AppointmentDetails.fromJson(Map<String, dynamic> json) {
    return AppointmentDetails(
      id: json['id'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      scheduledTime: json['scheduledTime'],
      durationMinutes: json['durationMinutes'],
      status: json['status'],
      bookingDate: DateTime.parse(json['bookingDate']),
      checkInTime: json['checkInTime'] != null
          ? DateTime.parse(json['checkInTime'])
          : null,
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime'])
          : null,
      
      patient: Patient.fromAppointmentDetailsJson(json['patient']),
      doctor: Doctor.fromAppointmentDetailsApi(json['doctor']),
      facility: Facility.fromAppointmentDetailsApi(json['facility']),
      billing: json['billing'] != null
          ? Billing.fromJson(json['billing'])
          : null,
      prescriptions: json['prescriptions'] != null
          ? (json['prescriptions'] as List)
                .map((e) => Prescription.fromJson(e))
                .toList()
          : null,
    );
  }
}

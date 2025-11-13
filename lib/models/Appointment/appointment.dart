import 'package:doctor_appointment_app/models/Doctor/doctor.dart';
import 'package:doctor_appointment_app/models/Facility/facility.dart';
import 'package:doctor_appointment_app/models/Patient/patient.dart';

class Appointment {
  final String id;
  final DateTime scheduledDate;
  final String scheduledTime;
  final int durationMinutes;
  final String status;
  final DateTime bookingDate;
  final String notes;
  final Doctor doctor;
  final Facility facility;
  final Patient patient;

  Appointment({
    required this.id,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.durationMinutes,
    required this.status,
    required this.bookingDate,
    required this.notes,
    required this.doctor,
    required this.facility,
    required this.patient,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['Id'],
      scheduledDate: DateTime.parse(json['ScheduledDate']),
      scheduledTime: json['ScheduledTime'],
      durationMinutes: json['DurationMinutes'],
      status: json['Status'],
      bookingDate: DateTime.parse(json['BookingDate']),
      notes: json['Notes'] ?? '',
      doctor: Doctor.fromAppointmentApi(json['Doctor']),
      facility: Facility.fromAppointmentApi(json['Facility']),
      patient: Patient.fromAppointmentJson(json['Patient']),
    );
  }
}



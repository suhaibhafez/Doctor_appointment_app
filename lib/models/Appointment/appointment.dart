import 'package:doctor_appointment_app/models/Doctor/doctor.dart';
import 'package:doctor_appointment_app/models/Facility/facility.dart';
import 'package:doctor_appointment_app/models/Patient/patient.dart';
import 'package:doctor_appointment_app/utils/enums/specialitiez_facilities.dart';

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
    final normalized = {
      for (var key in json.keys) capitalizeFirst(key): json[key],
    };
    return Appointment(
      id: normalized['Id'],
      scheduledDate: DateTime.parse(normalized['ScheduledDate']),
      scheduledTime: normalized['ScheduledTime'],
      durationMinutes: normalized['DurationMinutes'],
      status: normalized['Status'],
      bookingDate: DateTime.parse(normalized['BookingDate']),
      notes: normalized['Notes'] ?? '',
      doctor: Doctor.fromAppointmentApi(normalized['Doctor']),
      facility: Facility.fromAppointmentApi(normalized['Facility']),
      patient: Patient.fromAppointmentJson(normalized['Patient']),
    );
  }
}

import 'package:doctor_appointment_app/models/Appointment/appointment.dart';
import 'package:doctor_appointment_app/services/appointment_services.dart';
import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appointmentstodayProvider = FutureProvider<List<Appointment>>(
  (ref) async {
    final token = LocalStorageService.getToken;
    final appointments = await AppointmentServices.getTodaysAppointments(
      ref: ref,
      token: token!,
    );
    final filteredAppointments = appointments.where(
      (element) => (element.status == "Pending")||(element.status=="Confirmed"),
    ).toList();
    return filteredAppointments;
  },
  retry: (retryCount, error) => const Duration(seconds: 2),
);

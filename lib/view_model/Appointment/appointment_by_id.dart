import 'package:doctor_appointment_app/models/Appointment/appointment_details.dart';
import 'package:doctor_appointment_app/services/appointment_services.dart';
import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appointmentByIdProvider =
    FutureProvider.autoDispose.family<AppointmentDetails, String>(
      (ref, id) {
        final token = LocalStorageService.getToken;
        return AppointmentServices.getAppointmentsById(
          ref: ref,
          token: token!,
          id: id,
        );
      },
    );

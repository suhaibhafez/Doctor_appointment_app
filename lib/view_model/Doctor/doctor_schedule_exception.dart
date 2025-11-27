import 'package:doctor_appointment_app/models/Doctor/doctor_exception_schedule.dart';

import 'package:doctor_appointment_app/services/doctor_services.dart';
import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final doctorScheduleExceptionProvider =
    FutureProvider.family<List<DoctorExceptionSchedule>, String>(
      (ref, doctorId) async {
        final token = LocalStorageService.getToken;
        return await DoctorService.getDoctorScheduleException(
          doctorId,
          ref,
          token!,
        );
      },
    retry: (retryCount, error) => const Duration(seconds: 2),

    );

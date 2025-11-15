import 'package:doctor_appointment_app/models/Doctor/doctor_capacity.dart';

import 'package:doctor_appointment_app/services/doctor_services.dart';
import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final doctorCapacityProvider =
    FutureProvider.family<DoctorCapacity, String>(
      (ref, doctorId) async {
        final token = LocalStorageService.getToken;
        return await DoctorService.getDoctorCapacity(
          doctorId,
          ref,
          token!,
        );
      },
    );

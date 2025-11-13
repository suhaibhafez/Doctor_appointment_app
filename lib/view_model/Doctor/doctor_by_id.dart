import 'package:doctor_appointment_app/models/Doctor/doctor.dart';

import 'package:doctor_appointment_app/services/doctor_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final doctorByIdProvider = FutureProvider.family<Doctor, String>(
  (ref, id) async {
    return await DoctorService.getDoctorByID(id, ref);
  },
);

import 'package:doctor_appointment_app/models/Doctor/doctor.dart';
import 'package:doctor_appointment_app/services/doctor_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final topDoctorsProvider = FutureProvider<List<Doctor>>(
  (ref) async {
    final all = await DoctorService.getTopDoctors(
      ref: ref,
      page: 1,
      pageSize: 1000,
    );
    return all.where(
      (element) => element.rating! >= 4.0,
    ).toList();
  },
);

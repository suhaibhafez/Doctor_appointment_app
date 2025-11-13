import 'package:doctor_appointment_app/models/Doctor/doctor.dart';
import 'package:doctor_appointment_app/services/facility_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final departmentDoctorsProvider =
    FutureProvider.family<
      List<Doctor>,
      (String facilityId, String departmentId)
    >((ref, args) async {
      final facilityId = args.$1;
      final departmentId = args.$2;

      // your logic here
      return await FacilityServices.getDoctorsInDepartment(ref,facilityId, departmentId);
    });

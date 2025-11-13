import 'package:doctor_appointment_app/models/Facility/department.dart';
import 'package:doctor_appointment_app/services/facility_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final departmentsProvider = FutureProvider.family<List<Department>, String>(
  (ref, facilityId) async {
   return await FacilityServices.getDepartmentsInFacility(ref, facilityId);
  },
);

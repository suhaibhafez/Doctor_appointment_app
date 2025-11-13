


import 'package:doctor_appointment_app/models/Facility/facility.dart';
import 'package:doctor_appointment_app/services/facility_services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final facilityByIdProvider = FutureProvider.family<Facility, String>(
  (ref, id) async {

    return await FacilityServices.getFacilityByID(ref,id);
  },
);

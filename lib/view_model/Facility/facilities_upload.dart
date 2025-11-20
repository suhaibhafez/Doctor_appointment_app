import 'package:doctor_appointment_app/models/Facility/facility_upload.dart';
import 'package:doctor_appointment_app/services/facility_services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final facilitiesUploadProvider =
    FutureProvider.family<List<FacilityUpload>, String>(
      (ref, param) async {
        return FacilityServices.getUploadsForAFacility(
          ref: ref,
          facilityId: param,
        );
      },
    );

import 'package:doctor_appointment_app/models/Patient/medical_record.dart';
import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:doctor_appointment_app/services/patient_services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final medicalRecordsProvider = FutureProvider.autoDispose<List<MedicalRecord>>(
  (ref) {
    final token=LocalStorageService.getToken;
  
    return PatientService.getMedicalRecord(token!, ref);

  },
);

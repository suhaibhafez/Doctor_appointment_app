import 'dart:async';

import 'package:doctor_appointment_app/models/Patient/chronic_disease.dart';
import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:doctor_appointment_app/services/patient_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chronicDiseaseProvider =
    AsyncNotifierProvider<ChronicDiseaseNotifier, List<ChronicDisease>>(
      ChronicDiseaseNotifier.new,
    );

class ChronicDiseaseNotifier extends AsyncNotifier<List<ChronicDisease>> {
  @override
  FutureOr<List<ChronicDisease>> build() async {
    state = const AsyncValue.loading();
    final token = LocalStorageService.getToken;
    return await PatientService.getChronicDiseases(ref, token!);
  }

  Future<void> addDisease(int allergyNumber) async {
    state = const AsyncValue.loading();
    try {
      
      final token = LocalStorageService.getToken;
      final ChronicDisease newDisease = await PatientService.addChronicDisease(
        ref,
        token!,
        allergyNumber,
      );
      state = AsyncValue.data([...state.value!, newDisease]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteDisease(String id) async {
    state = const AsyncValue.loading();
    try {
      final token = LocalStorageService.getToken;
      await PatientService.deleteChronicDisease(
        ref,
        token!,
        id,
      );
      state = AsyncValue.data(state.value!.where((e) => e.id != id).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

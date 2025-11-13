import 'dart:async';

import 'package:doctor_appointment_app/models/Patient/allergy.dart';
import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:doctor_appointment_app/services/patient_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final allergiesProvider =
    AsyncNotifierProvider<AllergiesNotifier, List<Allergy>>(
      AllergiesNotifier.new,
    );

class AllergiesNotifier extends AsyncNotifier<List<Allergy>> {
  @override
  FutureOr<List<Allergy>> build() async {
    state = const AsyncValue.loading();

    final token = LocalStorageService.getToken;
    return await PatientService.getAllergies(ref, token!);
  }

  Future<void> addAllergy(int allergyNumber) async {
    state = const AsyncValue.loading();
    try {
      final token = LocalStorageService.getToken;
      final Allergy newAllergy = await PatientService.addAllergy(
        ref,
        token!,
        allergyNumber,
      );
      state = AsyncValue.data([...state.value!, newAllergy]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  Future<void> deleteAllergy(String id) async {
    state = const AsyncValue.loading();
    try {
      final token = LocalStorageService.getToken;
      await PatientService.deleteAllergy(
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

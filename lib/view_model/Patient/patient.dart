import 'dart:async';

import 'package:doctor_appointment_app/models/Patient/patient.dart';

import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:doctor_appointment_app/services/patient_services.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final patientNotifier = AsyncNotifierProvider<PatientNotifier, Patient?>(
  PatientNotifier.new,
  retry: (retryCount, error) => const Duration(seconds: 2),
);

class PatientNotifier extends AsyncNotifier<Patient?> {
  @override
  FutureOr<Patient?> build() async {
    state = const AsyncValue.loading();

    final token = LocalStorageService.getToken;
    debugPrint(token);
    if (token == null) {
      return null; // 👈 User not logged in yet
    }
     return await getPatient(token);
  }

  Future<Patient> getPatient(String token) async {
    return PatientService.getPatient(token, ref);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final token = await PatientService.login(email, password, ref);
      await LocalStorageService.setToken(token);
      try {
        final patient = await getPatient(token);
        state = AsyncValue.data(patient);
      } catch (e, st) {
        // 👇 If fetching patient after login fails, clear token and show error
        await LocalStorageService.clearToken();
        state = AsyncValue.error(
          'Login failed: invalid token or server error',
          st,
        );
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await LocalStorageService.clearToken();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> registerPatient({
    required String nationaID,
    required String phoneNumber,
    required String password,
    required String email,
  }) async {
    state = const AsyncValue.loading();
    try {
      await PatientService.registerPatient(
        ref,
        nationaID: nationaID,
        phoneNumber: phoneNumber,
        password: password,
        email: email,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

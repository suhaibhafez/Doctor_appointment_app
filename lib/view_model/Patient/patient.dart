import 'dart:async';

import 'package:dio/dio.dart';
import 'package:doctor_appointment_app/models/Patient/patient.dart';

import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:doctor_appointment_app/services/log_service.dart';
import 'package:doctor_appointment_app/services/patient_services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final patientNotifier = AsyncNotifierProvider<PatientNotifier, Patient?>(
  PatientNotifier.new,
  // retry: (retryCount, error) {
  //   // Only retry on network errors, not authentication errors
  //   if (!((error as DioException).response?.statusCode == 401)) {
  //     return const Duration(seconds: 2);
  //   }
  //   return null;
  // },
);

class PatientNotifier extends AsyncNotifier<Patient?> {
  bool _shouldRetry = true;
  bool isLoggingOut = false;
  bool isSessionExpired = false;
  @override
  FutureOr<Patient?> build() async {
    state = const AsyncValue.loading();
    if (!_shouldRetry) {
       // Stop infinite retries
      return null;
    }

    final token = LocalStorageService.getToken;
    if (token == null) {
      _shouldRetry = false;
      return null;
    }

    try {
      final patient = await getPatient(token);
      LogService.i('Successfully loaded patient');
      _shouldRetry = true;
       // Reset for future retries
      return patient;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        LogService.i('Token expired, stopping retries');
        await LocalStorageService.clearToken();
        await LocalStorageService.clearUserId();
        _shouldRetry = false;
        isSessionExpired = true;
        ref.notifyListeners(); // Stop infinite retries
        return null;
      }

      LogService.e('Failed to load patient', error);
      rethrow;
    } catch (error) {
      LogService.e('Unexpected error loading patient', error);
      rethrow;
    }
  }

  Future<Patient> getPatient(String token) async {
    return PatientService.getPatient(token, ref);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final data = await PatientService.login(email, password, ref);
      final token = data['token'];
      final userId = data['userId'];

      await LocalStorageService.setToken(token);
      await LocalStorageService.setUserId(userId);
      _shouldRetry = true; // Reset for next login
      LogService.i('Setting local storage with token:$token');
      LogService.i('userId:$userId');

      try {
        final patient = await getPatient(token!);
        state = AsyncValue.data(patient);
      } catch (e, st) {
        LogService.e('Logging in Failed', e);

        // 👇 If fetching patient after login fails, clear token and show error
        await LocalStorageService.clearToken();
        await LocalStorageService.clearUserId();

        state = AsyncValue.error(
          'Login failed: invalid token or server error',
          st,
        );
      }
    } catch (error, stackTrace) {
      LogService.e('Setting local storage with token and userId failed', error);

      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> logout() async {
    isLoggingOut = false;
    state = const AsyncValue.loading();

    try {
      isLoggingOut = true;
      ref.notifyListeners();
      await LocalStorageService.clearToken();
      await LocalStorageService.clearUserId();

      state = const AsyncValue.data(null);

      LogService.i('Logging out Success');
    } catch (error, stackTrace) {
      LogService.e('Logging out Failed', error);

      state = AsyncValue.error(error, stackTrace);
    } finally {
      isLoggingOut = false;
      ref.notifyListeners();
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

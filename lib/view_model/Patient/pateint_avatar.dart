import 'dart:typed_data';

import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:doctor_appointment_app/services/log_service.dart';
import 'package:doctor_appointment_app/services/patient_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
// // Add this at the top of your providers file
final avatarRefreshProvider = StateProvider<int>((ref) => 0);

final patientAvatarProvider = FutureProvider<Uint8List?>((ref) async {
  // This will cause the provider to refresh when avatarRefreshProvider changes
  final refreshTrigger = ref.watch(avatarRefreshProvider);

  final token = LocalStorageService.getToken!;
  final id = LocalStorageService.getUserId!;

  LogService.i('Fetching patient avatar...');

  try {
    final avatarData = await PatientService.getPatientAvatar(
      id: id,
      token: token,
      ref: ref,
    );

    LogService.i(
      'Avatar fetched successfully: ${avatarData?.length ?? 0} bytes',
    );
    return avatarData;
  } catch (e) {
    LogService.e('Error fetching patient avatar:', e);
    return null;
  }
});

final uploadAvatarProvider = FutureProvider.family<bool, Uint8List?>((
  ref,
  imageBytes,
) async {
  if (imageBytes == null) return false;

  final token = LocalStorageService.getToken!;

  LogService.i('Uploading avatar...');

  try {
    final result = await PatientService.uploadPatientAvatar(
      token: token,
      imageBytes: imageBytes,
      fileName: 'avatar_${DateTime.now().millisecondsSinceEpoch}.png',
      ref: ref,
    );

    LogService.i('Avatar upload result: $result');

    // If upload successful, trigger refresh AFTER the upload is complete
    if (result) {
      // Use a small delay to ensure the server has processed the upload
      await Future.delayed(const Duration(milliseconds: 100));

      // Increment the refresh counter
      ref.read(avatarRefreshProvider.notifier).update((state) => state + 1);

      LogService.i('Avatar refresh triggered after upload');
    }

    return result;
  } catch (e) {
    LogService.e('Error uploading avatar:', e);
    return false;
  }
});

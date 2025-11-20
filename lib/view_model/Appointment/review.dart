import 'package:dio/dio.dart';
import 'package:doctor_appointment_app/models/Appointment/review.dart';
import 'package:doctor_appointment_app/services/appointment_services.dart';
import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reviewProvider = FutureProvider.autoDispose.family<Review?, String>((ref, id) async {
  final token = LocalStorageService.getToken;
  try {
    final review = await AppointmentServices.getReview(
      ref: ref,
      id: id,
      token: token!,
    );
   
    return review; // Found
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) {
      return null; // Not found, not an error
    }
    // Any other HTTP error
    rethrow; // Provider goes into error state
  } catch (e) {
    // Any other unexpected error
    rethrow; // Provider goes into error state
    // Provider goes into error state
  }
});

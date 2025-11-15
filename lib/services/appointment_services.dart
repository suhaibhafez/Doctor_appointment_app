import 'package:dio/dio.dart';
import 'package:doctor_appointment_app/models/Appointment/appointment.dart';
import 'package:doctor_appointment_app/models/Appointment/appointment_details.dart';
import 'package:doctor_appointment_app/view_model/dio.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppointmentServices {
  static Future<List<Appointment>> getAppointmentsByStatus({
    required int? status,
    required int page,
    required int pageSize,
    required Ref ref,
    required String token,
  }) async {
    final dio = ref.read(dioProvider);
    final response = await dio.get(
      '/patients/me/appointments',
      queryParameters: {
        if (status != null) 'status': status,
        if (status == null) 'Sort': 'status',
        'page': page,
        'pageSize': pageSize,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    return (response.data['data'] as List)
        .map((e) => Appointment.fromJson(e))
        .toList();
  }

  static Future<AppointmentDetails> getAppointmentsById({
    required Ref ref,
    required String token,
    required String id,
  }) async {
    final dio = ref.read(dioProvider);
    final response = await dio.get(
      "/patients/me/appointments/$id",
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    return AppointmentDetails.fromJson(response.data['data']);
  }

  static Future<List<Appointment>> getTodaysAppointments({
    required Ref ref,
    required String token,
  }) async {
    final dio = ref.read(dioProvider);
    final dateToday = DateTime.now().toIso8601String().split('T').first;
   

    final response = await dio.get(
      '/patients/me/appointments',
      queryParameters: {
        'StartDate': dateToday,
        'EndDate': dateToday,
        'pageSize': 10,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    return (response.data['data'] as List)
        .map((e) => Appointment.fromJson(e))
        .toList();
  }

  
  static Future<Appointment> bookAppointment(
    Ref ref,
    String token,
    String doctorId,
    String facilityId,
    String schduleDate,
    String schduleTime,
    int durationMinutes,
  ) async {
    final dio = ref.read(dioProvider);
    final response = await dio.post(
      '/appointments',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
      data: {
        "doctorId": doctorId,
        "facilityId": facilityId,
        "scheduledDate": schduleDate,
        "scheduledTime": schduleTime,
        "durationMinutes": durationMinutes,
      },
    );
    return Appointment.fromJson(response.data['data']);
  }

}

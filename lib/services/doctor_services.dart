import 'package:dio/dio.dart';
import 'package:doctor_appointment_app/models/Doctor/doctor.dart';
import 'package:doctor_appointment_app/models/Doctor/doctor_capacity.dart';
import 'package:doctor_appointment_app/models/Doctor/doctor_exception_schedule.dart';
import 'package:doctor_appointment_app/models/Doctor/doctor_schedule.dart';
import 'package:doctor_appointment_app/view_model/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DoctorService {
  static Future<Doctor> getDoctorByID(String id, Ref ref) async {
    final dio = ref.read(dioProvider);
    final response = await dio.get('/doctors/$id');
    return Doctor.fromDoctorApi(response.data['data']);
  }

  static Future<List<Doctor>> getDoctors(
    Ref ref,
    int page,
    int pageSize,
    int? specialization,
    String? q,
  ) async {
    final dio = ref.read(dioProvider);

    final response = await dio.get(
      '/doctors',
      queryParameters: {
        'page': page,
        'pagesize': pageSize,
        if (specialization != null &&
            specialization != 0 &&
            specialization != -1)
          'Specialization': specialization,
        if (q != null && q.isNotEmpty) 'q': q,
      },
    );

    // parse list
    final data = (response.data['data'] as List?) ?? <dynamic>[];
    final doctors = data.map((e) => Doctor.fromDoctorApi(e)).toList();
    return doctors;
  }

  static Future<DoctorCapacity> getDoctorCapacity(
    String id,
    Ref ref,
    String token,
  ) async {
    final dio = ref.read(dioProvider);
    try {
      final response = await dio.get(
        '/doctors/$id/treatment-capacity',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return DoctorCapacity.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return DoctorCapacity.empty();
      }
      rethrow;
    }
  }

  static Future<List<DoctorSchedule>> getDoctorSchedule(
    String id,
    Ref ref,
    String token,
  ) async {
    final dio = ref.read(dioProvider);
    final response = await dio.get(
      '/doctors/$id/schedules',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    final data = (response.data['data'] as List?) ?? <DoctorSchedule>[];
    final schedules = data.map((e) => DoctorSchedule.fromJson(e)).toList();
    return schedules;
  }

  static Future<List<DoctorExceptionSchedule>> getDoctorScheduleException(
    String id,
    Ref ref,
    String token,
  ) async {
    final dio = ref.read(dioProvider);
    final response = await dio.get(
      '/doctors/$id/schedule-exceptions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    final data =
        (response.data['data'] as List?) ?? <DoctorExceptionSchedule>[];
    final schedules = data
        .map((e) => DoctorExceptionSchedule.fromJson(e))
        .toList();
    return schedules;
  }
}

// adjust import to your app

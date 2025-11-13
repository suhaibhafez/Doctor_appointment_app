import 'package:doctor_appointment_app/models/Doctor/doctor.dart';
import 'package:doctor_appointment_app/view_model/dio.dart';
import 'package:flutter/widgets.dart';
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
    debugPrint(
        'Fetching doctors with specialization: $specialization,');
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
}

// adjust import to your app

import 'package:dio/dio.dart';
import 'package:doctor_appointment_app/models/Doctor/doctor.dart';
import 'package:doctor_appointment_app/models/Facility/department.dart';
import 'package:doctor_appointment_app/models/Facility/facility.dart';
import 'package:doctor_appointment_app/models/Facility/facility_upload.dart';
import 'package:doctor_appointment_app/view_model/dio.dart';
import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FacilityServices {
  static Future<Facility> getFacilityByID(
    Ref ref,

    String id,
  ) async {
    final dio = ref.read(dioProvider);
    final List<String> fields = [
      'Id',
      'Name',
      'Type',
      'Address',
      'Description',
      'Avatar',
      'GPSLatitude',
      'GPSLongitude',
      'Schedules',
      'ScheduleExceptions',
    ];

    final respone = await dio.get(
      '/health-care-facilities/$id',
      queryParameters: {'fields': fields.join(',')},
    );
    return Facility.fromFacilityApi(respone.data['data']);
  }

  static Future<List<Facility>> getFacilities(
    Ref ref,
    int page,
    int pageSize,
    String? type,
    String? q,
  ) async {
    final dio = ref.read(dioProvider);
    final List<String> fields = [
      'Id',
      'Name',
      'Type',
      'Address',
      'Description',
      'Avatar',
      'GPSLatitude',
      'GPSLongitude',
    ];

    final response = await dio.get(
      '/health-care-facilities',
      queryParameters: {
        'fields': fields.join(','),
        'page': page,
        'pagesize': pageSize,
        if (type != null) 'Type': type,
        if (q != null && q.isNotEmpty) 'q': q,
      },
    );
    // parse list
    final data = (response.data['data'] as List?) ?? <dynamic>[];
    final facilities = data.map((e) => Facility.fromFacilityApi(e)).toList();
    return facilities;
  }

  static Future<List<Department>> getDepartmentsInFacility(
    Ref ref,
    String facilityId,
  ) async {
    final dio = ref.read(dioProvider);
    final token = LocalStorageService.getToken;
    final response = await dio.get(
      '/health-care-facilities/$facilityId/departments',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    final data = (response.data['data'] as List?) ?? <dynamic>[];
    final departments = data.map((e) => Department.fromJson(e)).toList();
    return departments;
  }

  static Future<List<Doctor>> getDoctorsInDepartment(
    Ref ref,
    String facilityId,
    String departmentId,
  ) async {
    final dio = ref.read(dioProvider);
    final token = LocalStorageService.getToken;
    final response = await dio.get(
      '/health-care-facilities/$facilityId/departments/$departmentId/doctors',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    final data = (response.data['data'] as List?) ?? <dynamic>[];
    final doctors = data.map((e) {
    
      return Doctor.fromDoctorApi(e);
    }).toList();
    return doctors;
  }

  static Future<List<FacilityUpload>> getUploadsForAFacility({
    required Ref ref,
    required String facilityId,
  }) async {
    final dio = ref.read(dioProvider);
    final response = await dio.get(
      '/health-care-facilities/$facilityId/uploads',
    );
    final data = (response.data['data'] as List?) ?? <dynamic>[];
    final uploads = data.map((e) => FacilityUpload.fromJson(e)).toList();
    return uploads;
  }
}

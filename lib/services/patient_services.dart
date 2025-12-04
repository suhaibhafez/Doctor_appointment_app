import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:doctor_appointment_app/models/Appointment/review.dart';
import 'package:doctor_appointment_app/models/Patient/allergy.dart';
import 'package:doctor_appointment_app/models/Patient/billing.dart';
import 'package:doctor_appointment_app/models/Patient/chronic_disease.dart';
import 'package:doctor_appointment_app/models/Patient/medical_record.dart';
import 'package:doctor_appointment_app/models/Patient/patient.dart';
import 'package:doctor_appointment_app/services/log_service.dart';
import 'package:doctor_appointment_app/view_model/dio.dart';
import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientService {
  static Future<Map<String, String>> login(
    String email,
    String password,
    Ref ref,
  ) async {
    final dio = ref.read(dioProvider);
    final response = await dio.post(
      '/users/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final String token = response.data['accessToken'];
    final String userID = response.data['user']['id'];
    final Map<String, String> data = {'token': token, 'userId': userID};
    return data;
  }

  static Future<bool> logout() => LocalStorageService.clearToken();

  static Future<Patient> getPatient(String token, Ref ref) async {
    final dio = ref.read(dioProvider);
    final response = await dio.get(
      '/patients/me',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    return Patient.fromPatientJson(response.data['data']);
  }

  static Future<void> registerPatient(
    Ref ref, {
    required String nationaID,
    required String phoneNumber,
    required String password,
    required String email,
  }) async {
    final dio = ref.read(dioProvider);
    await dio.post(
      '/users/register-patient',
      data: {
        "phoneNumber": phoneNumber,
        "nationalId": int.parse(nationaID),
        "email": email,
        "password": password,
      },
    );
  }

  static Future<List<ChronicDisease>> getChronicDiseases(
    Ref ref,
    String token,
  ) async {
    final dio = ref.read(dioProvider);
    final response = await dio.get(
      '/patients/me/chronic-diseases',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    final data = (response.data['data'] as List?) ?? <ChronicDisease>[];
    final chronicDiseases = data
        .map((e) => ChronicDisease.fromJson(e))
        .toList();
    return chronicDiseases;
  }

  static Future<List<Allergy>> getAllergies(
    Ref ref,
    String token,
  ) async {
    final dio = ref.read(dioProvider);
    final response = await dio.get(
      '/patients/me/allergies',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    final data = (response.data['data'] as List?) ?? <ChronicDisease>[];
    final allergies = data.map((e) => Allergy.fromJson(e)).toList();
    return allergies;
  }

  static Future<void> deleteChronicDisease(
    Ref ref,
    String token,
    String chronicDiseaseId,
  ) async {
    final dio = ref.read(dioProvider);
    await dio.delete(
      '/patients/me/chronic-diseases/$chronicDiseaseId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  static Future<void> deleteAllergy(
    Ref ref,
    String token,
    String allergyId,
  ) async {
    final dio = ref.read(dioProvider);
    await dio.delete(
      '/patients/me/allergies/$allergyId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  static Future<ChronicDisease> addChronicDisease(
    Ref ref,
    String token,
    int chronicDiseaseNumber,
  ) async {
    final dio = ref.read(dioProvider);
    final response = await dio.post(
      '/patients/me/chronic-diseases',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
      data: {"chronicDisease": chronicDiseaseNumber},
    );
    return ChronicDisease.fromJson(response.data['data']);
  }

  static Future<Allergy> addAllergy(
    Ref ref,
    String token,
    int allergyNumber,
  ) async {
    final dio = ref.read(dioProvider);
    final response = await dio.post(
      '/patients/me/allergies',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
      data: {"allergy": allergyNumber},
    );
    return Allergy.fromJson(response.data['data']);
  }

  static Future<List<Billing>> getBillings(
    String token,
    Ref ref,
    int page,
    int pageSize,
  ) async {
    final dio = ref.read(dioProvider);
    final response = await dio.get(
      '/patients/me/billings',
      queryParameters: {
        'page': page,
        'pagesize': pageSize,
        'Sort': 'PaymentDate',
        'Status': 'Paid',
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    final data = (response.data['data'] as List?) ?? <Billing>[];
    final billings = data.map((e) => Billing.fromBillingAPi(e)).toList();
    return billings;
  }

  static Future<List<MedicalRecord>> getMedicalRecord(
    String token,
    Ref ref,
  ) async {
    final dio = ref.read(dioProvider);
    final response = await dio.get(
      '/patients/me/medical-records',

      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    final data =
        (response.data['data'][0]['medicalRecord'] as List?) ??
        <MedicalRecord>[];
    final medicalRecords = data.map((e) => MedicalRecord.fromJson(e)).toList();
    return medicalRecords;
  }

  static Future<Review> reviewAnAppointmnet({
    required String apId,
    required int rating,
    String? comment,
    required WidgetRef ref,
    required String token,
  }) async {
    final dio = ref.read(dioProvider);
    final response = await dio.post(
      '/patients/me/appointments/$apId/reviews',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
      data: {"rating": rating, "comment": comment},
    );
    return Review.fromJson(response.data['data']);
  }

static Future<Uint8List?> getPatientAvatar({
    required String id,
    required String token,
    required Ref ref,
  }) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        '/users/$id/avatar',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          responseType: ResponseType.bytes, // Important: receive as bytes
        ),
      );

      return response.data as Uint8List;
    } catch (e) {
     LogService.e('Error fetching avatar:',e);
      return null;
    }
  }
   static Future<bool> uploadPatientAvatar({
    required String token,
    required Uint8List imageBytes,
    required String fileName,
    required Ref ref,
  }) async {
    try {
      final dio = ref.read(dioProvider);

      final formData = FormData.fromMap({
        'File': MultipartFile.fromBytes(
          imageBytes,
          filename: fileName,
        ),
      });

      final response = await dio.put(
        '/users/me/avatar',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.statusCode == 204;
    } catch (e) {
      LogService.e('Error uploading avatar:', e);
      return false;
    }
  }
}

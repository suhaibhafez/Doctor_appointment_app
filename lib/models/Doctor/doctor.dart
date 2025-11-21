import 'package:doctor_appointment_app/models/email.dart';
import 'package:doctor_appointment_app/models/phone.dart';
import 'package:doctor_appointment_app/utils/enums/specialitiez_facilities.dart';

class Doctor {
  final String id;
  final String? healthCareFacilityId;
  final String firstName;
  final String lastName;
  final String? gender;
  final String specialization;
  final int? age;
  final String? licenseNumber;
  final String? avatar;
  final double? rating;
  final int? totalRatings;
  final String? primaryEmail;
  final String? primaryPhone;
  final List<Email>? emails;
  final List<Phone>? numbers;
  final String? description;
  const Doctor({
    required this.id,
    this.healthCareFacilityId,
    required this.firstName,
    required this.lastName,
    this.gender,
    required this.specialization,
    this.age,
    this.licenseNumber,
    this.avatar,
    this.rating,
    this.totalRatings,
    this.description,
    this.emails,
    this.numbers,
    this.primaryEmail,
    this.primaryPhone,
  });

  /// ------------------------
  /// Factory for main Doctor API
  /// ------------------------
  factory Doctor.fromDoctorApi(Map<String, dynamic> json) {
    final normalized = {
      for (var key in json.keys) capitalizeFirst(key): json[key],
    };
    return Doctor(
      id: normalized['Id'],
      healthCareFacilityId: normalized['HealthCareFacilityId'],
      firstName: normalized['FirstName'],
      lastName: normalized['LastName'],
      gender: normalized['Gender'],
      specialization: normalized['Specialization'],
      age: normalized['Age'],
      avatar: normalized['Avatar'],
      rating: (normalized["AverageRating"] as num?)?.toDouble() ?? 3.0,
      totalRatings: normalized["TotalReviews"] ?? 171,
      primaryEmail: normalized['PrimaryEmail'],
      primaryPhone: normalized['PrimaryPhone'],
      emails: (normalized['Emails'] as List<dynamic>?)
          ?.map(
            (e) => Email.fromJson(e),
          )
          .toList(),
      numbers: (normalized['Phones'] as List<dynamic>?)
          ?.map(
            (e) => Phone.fromJson(e),
          )
          .toList(),
      description: normalized['Description'],
    );
  }

  /// ------------------------
  /// Factory for AppointmentDoctor API
  /// ------------------------
  factory Doctor.fromAppointmentApi(Map<String, dynamic> json) {
    // Split fullName safely into first + last name
    final fullName = (json['fullName'] ?? '').toString().trim();
    final nameParts = fullName.split(' ');
    final first = nameParts.isNotEmpty ? nameParts.first : '';
    final last = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return Doctor(
      id: json['id'],
      firstName: first,
      lastName: last,
      specialization: json['specialization'],
    );
  }

  /// ------------------------
  /// Factory for AppointmentDetailsDoctor API
  /// ------------------------
  factory Doctor.fromAppointmentDetailsApi(Map<String, dynamic> json) {
    final fullName = (json['fullName'] ?? '').toString().trim();
    final nameParts = fullName.split(' ');
    final first = nameParts.isNotEmpty ? nameParts.first : '';
    final last = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return Doctor(
      id: json['id'],
      firstName: first,
      lastName: last,
      gender: json['gender'],
      specialization: json['specialization'],
      age: json['age'],
      licenseNumber: json['licenseNumber'],
    );
  }

  /// ------------------------
  /// Convert back to JSON (for internal use)
  /// ------------------------
  Map<String, dynamic> toJson() => {
    'Id': id,
    'HealthCareFacilityId': healthCareFacilityId,
    'FirstName': firstName,
    'LastName': lastName,
    'Gender': gender,
    'Specialization': specialization,
    'Age': age,
    'LicenseNumber': licenseNumber,
  };
}

class Patient {
  final String id;
  final String nationalId;
  final String? gender;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final int? age;
  final String? fullName;

  const Patient({
    required this.id,
    required this.nationalId,
    this.gender,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.age,
    this.fullName,
  });

  /// ✅ Factory for API 1: `/patient`
  factory Patient.fromPatientJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      nationalId: json['nationalID'],
      gender: json['gender'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth:
        DateTime.parse(json['dateOfBirth'])
          
    
    );
  }

  /// ✅ Factory for API 2: `/appointment`
  factory Patient.fromAppointmentJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      nationalId: json['nationalID'],
      fullName: json['fullName'],
    );
  }

  /// ✅ Factory for API 3: `/appointment_details`
  factory Patient.fromAppointmentDetailsJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      nationalId: json['nationalID'],
      gender: json['gender'],
      fullName: json['fullName'],
      age: json['age'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nationalID': nationalId,
      'gender': gender,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'age': age,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
    };
  }
}

class Prescription {
  final String id;
  final DateTime dateIssued;
  final String medicationList;
  final String dosageInstructions;

  const Prescription({
    required this.id,
    required this.dateIssued,
    required this.medicationList,
    required this.dosageInstructions,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      dateIssued: DateTime.parse(json['dateIssued']),
      medicationList: json['medicationList'],
      dosageInstructions: json['dosageInstructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateIssued': dateIssued.toIso8601String(),
      'medicationList': medicationList,
      'dosageInstructions': dosageInstructions,
    };
  }
}

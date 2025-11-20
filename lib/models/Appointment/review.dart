class Review {
  final String id;
  final String patientId;
  final String doctorId;
  final String facilityId;
  final String appointmentId;
  final int rating;
  final String? comment; // nullable
  final DateTime createdAt;

  Review({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.facilityId,
    required this.appointmentId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  // Factory to create from JSON
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      facilityId: json['facilityId'],
      appointmentId: json['appointmentId'],
      rating: json['rating'],
      comment: json['comment'], // nullable
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'facilityId': facilityId,
      'appointmentId': appointmentId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

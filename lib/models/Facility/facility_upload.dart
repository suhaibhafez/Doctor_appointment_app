import 'package:doctor_appointment_app/utils/config.dart';

class FacilityUpload {
  final String id;
  final String facilityId;
  final String fileType;
  final String fileURL;
  final String title;
  final String description;
  final String? localPath;

  FacilityUpload({
    required this.id,
    required this.facilityId,
    required this.fileType,
    required this.fileURL,
    required this.title,
    required this.description,
    this.localPath,
  });

  factory FacilityUpload.fromJson(Map<String, dynamic> json) {
    return FacilityUpload(
      id: json['id'] as String,
      facilityId: json['facilityId'] as String,
      fileType: json['fileType'] as String,
      fileURL: json['fileURL'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      localPath: json['localPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facilityId': facilityId,
      'fileType': fileType,
      'fileURL': fileURL,
      'title': title,
      'description': description,
      'localPath': localPath,
    };
  }

  String getUploadUrl() {
    return '${Config.baseUrl}/api/health-care-facilities/$facilityId/uploads/$id';
  }
}

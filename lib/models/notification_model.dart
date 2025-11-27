// lib/models/notification_model.dart
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;

  final DateTime createdAt;
  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']??json['appointmentId'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAtUtc']??json['timestamp']),
    );
  }
}

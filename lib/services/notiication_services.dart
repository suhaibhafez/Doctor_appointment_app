import 'package:dio/dio.dart';
import 'package:doctor_appointment_app/models/notification_model.dart';

class NotificationService {
  final Dio dio;
  

  NotificationService({required this.dio,})  ;

  Future<List<NotificationModel>> getNotifications(
    String token, {
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await dio.get(
      '/notifications',
      queryParameters: {'page': page, 'pageSize': pageSize},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final List data = response.data['data'] ?? [];
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<void> markAsRead(String notificationId, String token) async {
    await dio.put(
      '/notifications/$notificationId/read',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<void> markAllAsRead(String token) async {
    await dio.put(
      '/notifications/read-all',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<int> getUnreadCount(String token) async {
    
    final response = await dio.get(
      '/notifications/unread/count',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['data']['count'] ?? 0;
  }
}

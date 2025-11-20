import 'dart:async';

import 'package:doctor_appointment_app/models/notification_model.dart';
import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:doctor_appointment_app/services/notiication_services.dart';
import 'package:doctor_appointment_app/services/signal_r_service.dart';
import 'package:doctor_appointment_app/view_model/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final unreadCountProvider = FutureProvider<int>(
  (ref) {
    final token = LocalStorageService.getToken!;
    final service = ref.read(notificationServiceProvider);
    return service.getUnreadCount(token);
  },
);
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(
    dio: ref.read(dioProvider),
  ),
);

final signalRServiceProvider = Provider<SignalRService>(
  (ref) => SignalRService(),
);

/// NEW Riverpod 3 NotifierProvider
final notificationsProvider =
    AsyncNotifierProvider.autoDispose<
      NotificationsNotifier,
      List<NotificationModel>
    >(
      NotificationsNotifier.new,
    );

class NotificationsNotifier extends AsyncNotifier<List<NotificationModel>> {
  @override
  FutureOr<List<NotificationModel>> build() {
    state = const AsyncValue.loading();
    return fetchNotifications();
  }

  Future<List<NotificationModel>> fetchNotifications() async {
    final token = LocalStorageService.getToken;
    if (token == null) throw Exception('No authentication token');

    final service = ref.read(notificationServiceProvider);
    final notifications = await service.getNotifications(
      token,
      pageSize: 10000,
    );
    return notifications;
  }

  Future<void> markAsRead(String notificationId) async {
    state = const AsyncValue.loading();
    try {
      final token = LocalStorageService.getToken;
      if (token == null) throw Exception('No authentication token');

      final service = ref.read(notificationServiceProvider);
      await service.markAsRead(notificationId, token);

      state = AsyncValue.data(
        state.value!.where((e) => e.id != notificationId).toList(),
      );
    } catch (e, st) {
      print('Error marking notification as read: $e');
      state = AsyncValue.error(e, st);
      // You can show a snackbar or handle the error as needed
    }
  }

  Future<void> markAllAsRead() async {
    state = const AsyncValue.loading();

    try {
      final token = LocalStorageService.getToken;
      if (token == null) throw Exception('No authentication token');

      final service = ref.read(notificationServiceProvider);
      await service.markAllAsRead(token);

      state = const AsyncData([]);
    } catch (e, st) {
      print('Error marking all notifications as read: $e');
      state = AsyncValue.error(e, st);
    }
  }

  void addNotification(NotificationModel notification) {
    state = AsyncValue.data([notification, ...state.value ?? []]);
  }
}

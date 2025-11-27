// lib/view_model/notification.dart
import 'dart:async';
import 'package:doctor_appointment_app/models/notification_model.dart';
import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:doctor_appointment_app/services/log_service.dart';
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
    retry: (retryCount, error) => const Duration(seconds: 2),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(
    dio: ref.read(dioProvider),
  ),
);

final signalRServiceProvider = Provider<SignalRService>(
  (ref) {
    final service = SignalRService();

    ref.onDispose(() {
      LogService.i('🛑 Disposing SignalR service...');
      service.stopConnection();
      service.dispose();
    });

    return service;
  },
);

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
    return fetchNotifications();
  }

  Future<List<NotificationModel>> fetchNotifications() async {
    state = const AsyncValue.loading();
    try {
      final token = LocalStorageService.getToken;
      if (token == null) throw Exception('No authentication token');

      final service = ref.read(notificationServiceProvider);
      final notifications = await service.getNotifications(
        token,
        pageSize: 10000,
      );
      return notifications;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
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
      state = AsyncValue.error(e, st);
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
      state = AsyncValue.error(e, st);
    }
  }

  void addNotification(NotificationModel notification) {
    final currentList = state.value ?? [];
    state = AsyncValue.data([notification, ...currentList]);
  }
}

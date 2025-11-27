// lib/services/signal_r_service.dart
import 'dart:async';
import 'package:doctor_appointment_app/models/notification_model.dart';
import 'package:doctor_appointment_app/services/log_service.dart';
import 'package:signalr_netcore/ihub_protocol.dart';
import 'package:signalr_netcore/signalr_client.dart';

class SignalRService {
  HubConnection? _connection;
  bool isConnected = false;
  bool _isConnecting = false;
 final List<Function(NotificationModel)> _notificationCallbacks = [];
 final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;

  Future<void> startConnection(String token) async {
    if (_isConnecting) {
      LogService.i('⏳ Connection already in progress...');
      return;
    }

    try {
      _isConnecting = true;

      // إغلاق الاتصال القديم إذا كان موجوداً
      await _connection?.stop();

      final headers = MessageHeaders();
      headers.setHeaderValue('Authorization', 'Bearer $token');
      headers.setHeaderValue('ngrok-skip-browser-warning', '1');

      _connection = HubConnectionBuilder()
          .withUrl(
            'https://unlugubriously-balsamy-ward.ngrok-free.dev/notificationHub',
            options: HttpConnectionOptions(
              accessTokenFactory: ()  => Future.value(token),
              transport: HttpTransportType.WebSockets,
              requestTimeout: 30000,
              skipNegotiation: true,
              headers: headers,
              
            ),
          )
          .withAutomaticReconnect(retryDelays: [2000, 5000, 10000, 15000])
          .build();

      // إعداد الـ listeners قبل البدء
      _setupConnectionListeners();

      LogService.i('🚀 Starting SignalR connection...');
      await _connection!.start();

      isConnected = true;
      _isConnecting = false;
      _connectionController.add(true);

      LogService.i('✅ SignalR connected successfully');
    } on Exception catch (e) {
      _isConnecting = false;
      _connectionController.add(false);
      LogService.e('❌ SignalR connection failed', e);
      rethrow;
    }
  }

  void _setupConnectionListeners() {
    // listener للرسائل الواردة
    _connection?.on('ReceiveNotification', (arguments) {
      LogService.i('📨 Notification received - Arguments: $arguments');

      if (arguments != null && arguments.isNotEmpty) {
        try {
       

          final data = arguments[0] as Map<String, dynamic>;
          LogService.i('📊 Raw notification data: $data');

          final notification = NotificationModel.fromJson(data);
          LogService.i('✅ Parsed notification: ${notification.title}');

          // استدعاء جميع الـ callbacks المسجلة
          for (final callback in _notificationCallbacks) {
            callback(notification);
          }
        } catch (e,st) {
          LogService.e('❌ Error parsing notification', e,st);
          LogService.e('❌ Raw data that failed: $arguments');
        }
      }
    });

    // listener للانضمام الناجح للمجموعة
    _connection?.on('JoinedGroup', (arguments) {
      LogService.i('✅ Successfully joined group: $arguments');
    });

    // listener لإعادة الاتصال
    _connection?.onreconnecting(({Exception? error}) {
      LogService.e('🔄 SignalR reconnecting...', error);
      isConnected = false;
      _connectionController.add(false);
    });

    _connection?.onreconnected(({String? connectionId}) {
      LogService.i('✅ SignalR reconnected');
      isConnected = true;
      _connectionController.add(true);
    });

    _connection?.onclose(({Exception? error}) {
      LogService.e('🔴 SignalR connection closed', error);
      isConnected = false;
      _isConnecting = false;
      _connectionController.add(false);
    });
  }

  Future<void> stopConnection() async {
    try {
      _notificationCallbacks.clear();
      await _connection?.stop();
      _connection = null;
      isConnected = false;
      _isConnecting = false;
      _connectionController.add(false);
      LogService.i('✅ SignalR stopped successfully');
    } on Exception catch (e) {
      LogService.e('❌ Error stopping SignalR', e);
    }
  }

  void onReceiveNotification(Function(NotificationModel) callback) {
    // Prevent duplicate callbacks
    if (!_notificationCallbacks.contains(callback)) {
      _notificationCallbacks.add(callback);
      LogService.i(
        '📩 Registered notification callback. Total: ${_notificationCallbacks.length}',
      );
    }
  }

  void removeNotificationCallback(Function(NotificationModel) callback) {
    _notificationCallbacks.remove(callback);
    LogService.i(
      '🗑️ Removed notification callback. Total: ${_notificationCallbacks.length}',
    );
  }

  void clearAllNotificationCallbacks() {
    _notificationCallbacks.clear();
    LogService.i('🧹 Cleared all notification callbacks');
  }

  // Add a method to print current callback count for debugging
  void printCallbackStatus() {
    LogService.i(
      '📊 Current notification callbacks: ${_notificationCallbacks.length}',
    );
  }

  Future<void> joinUserGroup(String userId) async {
    if (_connection == null) {
      LogService.e('❌ Cannot join group - Connection is null');
      return;
    }

    // الانتظار إذا كان الاتصال قيد التأسيس
    if (_isConnecting) {
      LogService.i('⏳ Waiting for connection completion...');
      await connectionStream.firstWhere((connected) => connected);
    }

    if (!isConnected) {
      LogService.e('❌ Cannot join group - Not connected');
      return;
    }

    try {
      LogService.i('👤 Joining user group for userId: $userId');

      await _connection!.invoke(
        'JoinUserGroup',
        args: <Object>[userId],
      );

      LogService.i('✅ User $userId successfully joined group');
    } on Exception catch (e) {
      LogService.e('❌ Failed to join user group', e);
    }
  }

  // دالة للمساعدة في debugging
  void printConnectionStatus() {
    LogService.i('''
📊 SignalR Connection Status:
   - isConnected: $isConnected
   - isConnecting: $_isConnecting
   - Callbacks: ${_notificationCallbacks.length}
''');
  }

  void dispose() {
    _connectionController.close();
  }
}

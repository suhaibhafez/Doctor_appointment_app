// lib/services/signal_r_service.dart
import 'dart:async';
import 'package:doctor_appointment_app/models/notification_model.dart';
import 'package:doctor_appointment_app/services/log_service.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:signalr_netcore/ihub_protocol.dart';
import 'package:signalr_netcore/signalr_client.dart';

// lib/services/signal_r_service.dart

class SignalRService {
  HubConnection? _connection;
  bool isConnected = false;
  bool _isConnecting = false;
  final List<Function(NotificationModel)> _notificationCallbacks = [];
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  // Retry configuration
  int _retryCount = 0;
  static const int _maxRetries = 5;
  static const List<Duration> _retryDelays = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 3),
    Duration(seconds: 5),
    Duration(seconds: 8),
  ];
  String? _currentToken;
  Timer? _retryTimer;

  Stream<bool> get connectionStream => _connectionController.stream;

  Future<void> startConnection(String token) async {
    if (_isConnecting) {
      LogService.i('⏳ Connection already in progress...');
      return;
    }

    _currentToken = token;
    _retryCount = 0; // Reset retry count on new connection attempt

    await _startConnectionWithRetry();
  }

  Future<void> _startConnectionWithRetry() async {
    if (_isConnecting) return;

    try {
      _isConnecting = true;

      // Close old connection if exists
      await _connection?.stop();
      await Future.delayed(const Duration(milliseconds: 500));

      final headers = MessageHeaders();
      headers.setHeaderValue('Authorization', 'Bearer $_currentToken');
      headers.setHeaderValue('ngrok-skip-browser-warning', '1');

      _connection = HubConnectionBuilder()
          .withUrl(
            // 'https://unlugubriously-balsamy-ward.ngrok-free.dev/notificationHub',
            '${Config.baseUrl}/notificationHub',
            options: HttpConnectionOptions(
              accessTokenFactory: () => Future.value(_currentToken),
              transport: HttpTransportType.WebSockets,
              requestTimeout: 30000,
              skipNegotiation: true,
              headers: headers,
            ),
          )
          .withAutomaticReconnect(retryDelays: [2000, 5000, 10000, 15000])
          .build();

      // Set up listeners before starting
      _setupConnectionListeners();

      LogService.i(
        '🚀 Starting SignalR connection... (Attempt ${_retryCount + 1}/$_maxRetries)',
      );
      await _connection!.start();

      // Success - reset retry count
      _retryCount = 0;
      isConnected = true;
      _isConnecting = false;
      _connectionController.add(true);

      LogService.i('✅ SignalR connected successfully');
    } on Exception catch (e) {
      _isConnecting = false;
      _connectionController.add(false);

      // Check if we should retry
      if (_shouldRetry(e)) {
        await _scheduleRetry();
      } else {
        LogService.e('❌ SignalR connection failed - No more retries', e);
        rethrow;
      }
    }
  }

  bool _shouldRetry(Exception error) {
    // Retry on network-related errors (ngrok issues)
    final errorString = error.toString();
    return _retryCount < _maxRetries &&
        (errorString.contains('Connection closed') ||
            errorString.contains('header') ||
            errorString.contains('socket') ||
            errorString.contains('HttpException') ||
            errorString.contains('timeout'));
  }

  Future<void> _scheduleRetry() async {
    _retryCount++;

    if (_retryCount > _maxRetries) {
      LogService.e('💥 Max retry attempts ($_maxRetries) reached');
      return;
    }

    final delay =
        _retryDelays[(_retryCount - 1).clamp(0, _retryDelays.length - 1)];

    LogService.i(
      '🔄 Retrying connection in ${delay.inSeconds} seconds... (Attempt $_retryCount/$_maxRetries)',
    );

    _retryTimer = Timer(delay, () {
      if (_currentToken != null) {
        _startConnectionWithRetry();
      }
    });
  }

  void _setupConnectionListeners() {
    // listener for incoming messages
    _connection?.on('ReceiveNotification', (arguments) {
      LogService.i('📨 Notification received - Arguments: $arguments');

      if (arguments != null && arguments.isNotEmpty) {
        try {
          final data = arguments[0] as Map<String, dynamic>;
          LogService.i('📊 Raw notification data: $data');

          final notification = NotificationModel.fromJson(data);
          LogService.i('✅ Parsed notification: ${notification.title}');

          // Call all registered callbacks
          for (final callback in _notificationCallbacks) {
            callback(notification);
          }
        } catch (e, st) {
          LogService.e('❌ Error parsing notification', e, st);
          LogService.e('❌ Raw data that failed: $arguments');
        }
      }
    });

    // listener for successful group joining
    _connection?.on('JoinedGroup', (arguments) {
      LogService.i('✅ Successfully joined group: $arguments');
    });

    // listener for reconnection
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

      // Auto-retry on connection close (ngrok drops)
      if (_currentToken != null) {
        LogService.i('🔄 Connection closed, scheduling retry...');
        Future.delayed(const Duration(seconds: 2), () {
          if (_currentToken != null && !_isConnecting) {
            _startConnectionWithRetry();
          }
        });
      }
    });
  }

  Future<void> stopConnection() async {
    try {
      _retryTimer?.cancel();
      _retryTimer = null;
      _retryCount = 0;
      _currentToken = null;

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

    // Wait if connection is being established
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

  // Helper function for debugging
  void printConnectionStatus() {
    LogService.i('''
📊 SignalR Connection Status:
   - isConnected: $isConnected
   - isConnecting: $_isConnecting
   - Retry Count: $_retryCount/$_maxRetries
   - Callbacks: ${_notificationCallbacks.length}
''');
  }

  void dispose() {
    _retryTimer?.cancel();
    _connectionController.close();
  }
}

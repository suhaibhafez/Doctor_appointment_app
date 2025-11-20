import 'package:doctor_appointment_app/models/notification_model.dart';
import 'package:doctor_appointment_app/services/local_storage_services.dart';

import 'package:signalr_netcore/signalr_client.dart';

class SignalRService {
  HubConnection? _connection;
  bool isConnected = false;

  Future<void> startConnection() async {
    final token = LocalStorageService.getToken;
    _connection = HubConnectionBuilder()
        .withUrl(
          'https://unlugubriously-balsamy-ward.ngrok-free.dev/notificationHub',
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token!,
            transport: HttpTransportType.WebSockets,
            requestTimeout: 10000,
            skipNegotiation: true,
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection!.onclose(({Exception? error}) {
      isConnected = false;
      print("SignalR disconnected: $error");
    });

    await _connection!.start();
    isConnected = true;
    print('SignalR Connected!');
  }

  void stopConnection() {
    print("closing");
    _connection?.stop();
    _connection = null;
    isConnected = false;
  }

  void onReceiveNotification(Function(NotificationModel) callback) {
    _connection?.on('ReceiveNotification', (arguments) {
      print('called:with: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final data = arguments[0] as Map<String, dynamic>;
          final notification = NotificationModel.fromJson(data);
          callback(notification);
        } catch (e) {
          print("Error parsing notification: $e");
        }
      }
    });
  }

  Future<void> joinUserGroup(String userId) async {
    if (_connection != null && isConnected) {
      await _connection!.invoke('JoinUserGroup', args: <Object>[userId]);
      print('Successfully joined user group');
    }
  }
}

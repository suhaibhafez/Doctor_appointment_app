import 'package:doctor_appointment_app/models/notification_model.dart';
import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:doctor_appointment_app/services/log_service.dart';
import 'package:signalr_netcore/ihub_protocol.dart';

import 'package:signalr_netcore/signalr_client.dart';

class SignalRService {
  HubConnection? _connection;
  bool isConnected = false;

  Future<void> startConnection() async {
    final token = LocalStorageService.getToken;
    final headers = MessageHeaders();
    headers.setHeaderValue('ngrok-skip-browser-warning', '1');
    _connection = HubConnectionBuilder()
        .withUrl(
          'http://localhost:5001/notificationHub',
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token!,
            transport: HttpTransportType.WebSockets,
            requestTimeout: 10000,
            skipNegotiation: true,
            // headers: headers
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection!.onclose(({Exception? error}) {
      isConnected = false;
      LogService.e('Signalr disconected', error);
    });

    try {
  await _connection!.start();
  isConnected = true;
  LogService.i(' SignalR connected succefully');
} on Exception catch (e) {
  LogService.e(' SignalR connection exception',e);
  
}
  }

  void stopConnection()async {
    try {
  
     await _connection?.stop();
  _connection = null;
  isConnected = false;
  LogService.i(' SignalR disconected succefully');

} on Exception catch (e) {
    LogService.e('Errpr while trying to close signal r ',e);

}
  }

  void onReceiveNotification(Function(NotificationModel) callback) {
    _connection?.on('ReceiveNotification', (arguments) {
      LogService.i('Recieve with argument:$arguments');
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final data = arguments[0] as Map<String, dynamic>;
          final notification = NotificationModel.fromJson(data);
          callback(notification);
        } catch (e) {
          LogService.e('Error parsing from notification', e);
        }
      }
    });
  }

  Future<void> joinUserGroup(String userId) async {
    if (_connection != null && isConnected) {
      final object = await _connection!.invoke(
        'JoinUserGroup',
        args: <Object>[userId],
      );
      LogService.i('Successfully joined user group:\n $object');
    }
  }

  // Add this method to test if you can receive ANY messages
  
}

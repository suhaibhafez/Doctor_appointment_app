import 'package:dio/dio.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>(
  (ref) => Dio(
    BaseOptions(
      // baseUrl: 'https://unlugubriously-balsamy-ward.ngrok-free.dev/api',
      baseUrl: '${Config.baseUrl}/api',
      connectTimeout: const Duration(seconds: 10),
      headers: {
        // 'ngrok-skip-browser-warning':
        //     '1', // 👈 this line skips the warning page
        'Accept': 'application/json', // 👈 optional but recommended
      },
      receiveTimeout: const Duration(seconds: 30),
    ),
  ),
);

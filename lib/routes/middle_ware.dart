
import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:doctor_appointment_app/routes/routes.dart';
import 'package:flutter/widgets.dart';

import 'package:get/get.dart';
class AuthGuardMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
   
    final token =LocalStorageService.getToken;
 
    if (token == null || token.isEmpty) {
      return const RouteSettings(name: Sroutes.auth);
    }
    return null;
  }
}

class AuthRedirectMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
       final token = LocalStorageService.getToken;


    if (token != null && token.isNotEmpty) {
      return const RouteSettings(name: Sroutes.main);
    }
    return null;
  }
}

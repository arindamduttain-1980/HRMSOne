import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import 'app_routes.dart';

/// Middleware ensuring employees without registered face cannot access the dashboard
class FaceRegistrationMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthService>()) {
      return null;
    }
    final authService = Get.find<AuthService>();
    if (!authService.isLoggedIn.value) {
      return const RouteSettings(name: AppRoutes.login);
    }

    final user = authService.currentUser.value;
    if (user != null && user.face == 0) {
      return const RouteSettings(name: AppRoutes.faceRegistrationIntro);
    }

    return null;
  }
}


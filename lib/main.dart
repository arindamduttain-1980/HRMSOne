import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app.dart';
import 'core/network/api_client.dart';
import 'core/services/auth_service.dart';
import 'core/storage/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core services
  final storageService = await Get.putAsync<StorageService>(() => StorageService().init());
  Get.put<ApiClient>(ApiClient(storageService));
  Get.put<AuthService>(AuthService(storageService));

  runApp(const AavenzaOneApp());
}

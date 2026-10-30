import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app.dart';
import 'core/network/api_client.dart';
import 'core/security/face_storage_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/location_service.dart';
import 'core/storage/storage_service.dart';
import 'data/repositories/company_repository.dart';
import 'data/repositories/face_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core services
  final storageService = await Get.putAsync<StorageService>(() => StorageService().init());
  final apiClient = Get.put<ApiClient>(ApiClient(storageService));
  Get.put<AuthService>(AuthService(storageService));
  Get.put<LocationService>(LocationService());
  Get.put<CompanyRepository>(CompanyRepository());
  Get.put<FaceStorageService>(FaceStorageService());
  Get.put<FaceRepository>(FaceRepository(apiClient));

  runApp(const AavenzaOneApp());
}

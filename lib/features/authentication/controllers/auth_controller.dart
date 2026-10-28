import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final AuthService _authService;
  final StorageService _storageService;

  AuthController({
    required AuthRepository authRepository,
    required AuthService authService,
    required StorageService storageService,
  })  : _authRepository = authRepository,
        _authService = authService,
        _storageService = storageService;

  final formKey = GlobalKey<FormState>();

  final serverUrlController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isEditingServerUrl = false.obs;

  @override
  void onInit() {
    super.onInit();
    serverUrlController.text = _storageService.serverUrl;
    final remembered = _storageService.rememberEmail;
    if (remembered != null && remembered.isNotEmpty) {
      emailController.text = remembered;
    }
  }

  void toggleEditServerUrl() {
    isEditingServerUrl.value = !isEditingServerUrl.value;
  }

  Future<void> login() async {
    errorMessage.value = '';

    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      // Save server URL if modified
      await _storageService.setServerUrl(serverUrlController.text.trim());

      final email = emailController.text.trim();
      final password = passwordController.text;

      final result = await _authRepository.login(
        email: email,
        password: password,
      );

      // Save email for quick login
      await _storageService.setRememberEmail(email);

      // Set session in AuthService
      _authService.setSession(result.token, result.user);

      // Navigate to dashboard
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    serverUrlController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

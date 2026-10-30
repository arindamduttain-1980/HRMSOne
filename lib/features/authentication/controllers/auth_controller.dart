import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/security/face_storage_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/models/company_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/company_repository.dart';
import '../../../data/repositories/face_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final AuthService _authService;
  final StorageService _storageService;
  final CompanyRepository _companyRepository;
  final FaceStorageService _faceStorageService;
  final FaceRepository _faceRepository;

  AuthController({
    required AuthRepository authRepository,
    required AuthService authService,
    required StorageService storageService,
    CompanyRepository? companyRepository,
    FaceStorageService? faceStorageService,
    FaceRepository? faceRepository,
  })  : _authRepository = authRepository,
        _authService = authService,
        _storageService = storageService,
        _companyRepository = companyRepository ?? Get.find<CompanyRepository>(),
        _faceStorageService = faceStorageService ?? Get.find<FaceStorageService>(),
        _faceRepository = faceRepository ?? Get.find<FaceRepository>();

  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxList<CompanyModel> companies = <CompanyModel>[].obs;
  final Rx<CompanyModel?> selectedCompany = Rx<CompanyModel?>(null);
  final RxBool isCompaniesLoading = false.obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    isCompaniesLoading.value = true;
    try {
      final cached = _storageService.cachedCompanyList;
      if (cached.isNotEmpty) {
        companies.assignAll(cached);
      } else {
        final fetched = await _companyRepository.getCompanyList();
        if (fetched.isNotEmpty) {
          companies.assignAll(fetched);
          await _storageService.setCachedCompanyList(fetched);
        }
      }

      final savedCompany = _storageService.selectedCompany;
      CompanyModel? toSelect;
      if (savedCompany != null) {
        toSelect = companies.firstWhereOrNull((c) => c.id == savedCompany.id);
      }
      if (toSelect == null && companies.isNotEmpty) {
        toSelect = companies.first;
      }

      if (toSelect != null) {
        selectedCompany.value = toSelect;
        await _storageService.setSelectedCompany(toSelect);
      }
    } catch (_) {
      final cached = _storageService.cachedCompanyList;
      if (cached.isNotEmpty) {
        companies.assignAll(cached);
        selectedCompany.value = _storageService.selectedCompany ?? cached.first;
      }
    } finally {
      isCompaniesLoading.value = false;
    }
  }

  void selectCompany(CompanyModel? company) {
    if (company != null) {
      selectedCompany.value = company;
      _storageService.setSelectedCompany(company);
      errorMessage.value = '';
    }
  }

  Future<void> login() async {
    errorMessage.value = '';

    if (selectedCompany.value == null) {
      errorMessage.value = 'Please select your company to proceed.';
      return;
    }

    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      await _storageService.setSelectedCompany(selectedCompany.value!);

      final email = emailController.text.trim();
      final password = passwordController.text;

      final result = await _authRepository.login(
        email: email,
        password: password,
      );

      await _storageService.setRememberEmail(email);
      _authService.setSession(result.token, result.user);

      // Biometric Decision Flow:
      // face = 0: Face registration is mandatory
      // face = 1: Face is registered, verify local template presence
      if (result.face == 0) {
        Get.offAllNamed(AppRoutes.faceRegistrationIntro);
      } else {
        final hasLocalTemplate = await _faceStorageService.hasFaceTemplate(result.user.id);

        if (!hasLocalTemplate) {
          // Attempt remote recovery/synchronization
          final serverTemplate = await _faceRepository.getFaceTemplateFromServer();
          if (serverTemplate != null && serverTemplate.isNotEmpty) {
            await _faceStorageService.saveFaceTemplate(
              employeeId: result.user.id,
              embedding: serverTemplate,
              isSynced: true,
            );
            Get.offAllNamed(AppRoutes.dashboard);
          } else {
            // Template missing locally and remotely; redirect to enroll
            Get.offAllNamed(AppRoutes.faceRegistrationIntro);
          }
        } else {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

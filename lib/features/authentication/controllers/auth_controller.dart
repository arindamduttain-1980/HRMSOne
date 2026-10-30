import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/models/company_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/company_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final AuthService _authService;
  final StorageService _storageService;
  final CompanyRepository _companyRepository;

  AuthController({
    required AuthRepository authRepository,
    required AuthService authService,
    required StorageService storageService,
    CompanyRepository? companyRepository,
  })  : _authRepository = authRepository,
        _authService = authService,
        _storageService = storageService,
        _companyRepository = companyRepository ?? Get.find<CompanyRepository>();

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
    //_restoreRememberedEmail();
  }

  Future<void> _loadCompanies() async {
    isCompaniesLoading.value = true;
    try {
      // 1. First check cached companies
      final cached = _storageService.cachedCompanyList;
      if (cached.isNotEmpty) {
        companies.assignAll(cached);
      } else {
        // If empty, fetch from API
        final fetched = await _companyRepository.getCompanyList();
        if (fetched.isNotEmpty) {
          companies.assignAll(fetched);
          await _storageService.setCachedCompanyList(fetched);
        }
      }

      // 2. Determine initial selected company
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
      // If error occurs, ensure at least cached or fallback is available
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
      // Immediately updates the entire app's base URL and active company
      _storageService.setSelectedCompany(company);
      errorMessage.value = '';
    }
  }

  // void _restoreRememberedEmail() {
  //   final remembered = _storageService.rememberEmail;
  //   if (remembered != null && remembered.isNotEmpty) {
  //     emailController.text = remembered;
  //   }
  // }

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
      // Guarantee base URL is set to the selected company
      await _storageService.setSelectedCompany(selectedCompany.value!);

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
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

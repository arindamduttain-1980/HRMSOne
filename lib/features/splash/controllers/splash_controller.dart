import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/models/company_model.dart';
import '../../../data/repositories/company_repository.dart';

class SplashController extends GetxController {
  final CompanyRepository _companyRepository;
  final StorageService _storageService;
  final AuthService _authService;

  SplashController({
    required CompanyRepository companyRepository,
    required StorageService storageService,
    required AuthService authService,
  })  : _companyRepository = companyRepository,
        _storageService = storageService,
        _authService = authService;

  final RxBool isLoading = true.obs;
  final RxString statusMessage = 'Connecting to workspace...'.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initializeApp();
  }

  Future<void> initializeApp() async {
    isLoading.value = true;
    errorMessage.value = '';
    statusMessage.value = 'Connecting to workspace...';

    final stopwatch = Stopwatch()..start();

    try {
      final companies = await _companyRepository.getCompanyList();

      if (companies.isNotEmpty) {
        await _storageService.setCachedCompanyList(companies);

        // Keep previously selected company if still valid, otherwise default to first
        final previous = _storageService.selectedCompany;
        CompanyModel? toSelect;
        if (previous != null) {
          toSelect = companies.firstWhereOrNull((c) => c.id == previous.id);
        }
        toSelect ??= companies.first;

        await _storageService.setSelectedCompany(toSelect);
      }
    } catch (e) {
      // Offline fallback: check if we have cached companies
      final cached = _storageService.cachedCompanyList;
      if (cached.isEmpty) {
        errorMessage.value =
            'Unable to load company details. Please check your network connection and retry.';
        isLoading.value = false;
        return;
      }
    }

    // Keep splash animation smooth for at least 1500ms
    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed < 1500) {
      await Future.delayed(Duration(milliseconds: 1500 - elapsed));
    }

    // Navigate to Dashboard if logged in, otherwise Login
    if (_authService.isLoggedIn.value) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void retry() {
    initializeApp();
  }
}


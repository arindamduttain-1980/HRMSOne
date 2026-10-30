import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/security/face_storage_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/models/company_model.dart';
import '../../../data/repositories/company_repository.dart';
import '../../../data/repositories/face_repository.dart';

class SplashController extends GetxController {
  final CompanyRepository _companyRepository;
  final StorageService _storageService;
  final AuthService _authService;
  final FaceStorageService _faceStorageService;
  final FaceRepository _faceRepository;

  SplashController({
    required CompanyRepository companyRepository,
    required StorageService storageService,
    required AuthService authService,
    FaceStorageService? faceStorageService,
    FaceRepository? faceRepository,
  })  : _companyRepository = companyRepository,
        _storageService = storageService,
        _authService = authService,
        _faceStorageService = faceStorageService ?? Get.find<FaceStorageService>(),
        _faceRepository = faceRepository ?? Get.find<FaceRepository>();

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

    // Biometric Decision Flow on app launch / reopening:
    // Unless and until user registers their face, the dashboard must NOT be shown.
    if (_authService.isLoggedIn.value) {
      final user = _authService.currentUser.value;
      if (user == null) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      final hasLocalTemplate = await _faceStorageService.hasFaceTemplate(user.id);

      if (user.face == 1 && hasLocalTemplate) {
        Get.offAllNamed(AppRoutes.dashboard);
      } else if (user.face == 1 && !hasLocalTemplate) {
        // Attempt recovery from server
        try {
          final serverTemplate = await _faceRepository.getFaceTemplateFromServer();
          if (serverTemplate != null && serverTemplate.isNotEmpty) {
            await _faceStorageService.saveFaceTemplate(
              employeeId: user.id,
              embedding: serverTemplate,
              isSynced: true,
            );
            Get.offAllNamed(AppRoutes.dashboard);
            return;
          }
        } catch (_) {}
        // Template missing; face registration required before dashboard
        Get.offAllNamed(AppRoutes.faceRegistrationIntro);
      } else {
        // user.face == 0 or face not registered
        Get.offAllNamed(AppRoutes.faceRegistrationIntro);
      }
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void retry() {
    initializeApp();
  }
}

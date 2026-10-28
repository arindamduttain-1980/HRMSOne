import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/repositories/profile_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository _profileRepository;
  final AuthService _authService;
  final StorageService _storageService;

  ProfileController({
    required ProfileRepository profileRepository,
    required AuthService authService,
    required StorageService storageService,
  })  : _profileRepository = profileRepository,
        _authService = authService,
        _storageService = storageService;

  final RxBool isUploading = false.obs;

  String get serverUrl => _storageService.serverUrl;

  Future<void> removePhoto() async {
    isUploading.value = true;
    try {
      final msg = await _profileRepository.removePhoto();
      final current = _authService.currentUser.value;
      if (current != null) {
        _authService.updateUser(current.copyWith(photoUrl: ''));
      }
      Get.snackbar('Photo Removed', msg, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploading.value = false;
    }
  }

  void logout() {
    _authService.logout();
  }
}

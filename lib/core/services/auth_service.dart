import 'package:get/get.dart';
import '../storage/storage_service.dart';
import '../../data/models/user_model.dart';
import '../routes/app_routes.dart';

class AuthService extends GetxService {
  final StorageService _storageService;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoggedIn = false.obs;

  AuthService(this._storageService);

  @override
  void onInit() {
    super.onInit();
    _restoreSession();
  }

  void _restoreSession() {
    final token = _storageService.token;
    final user = _storageService.user;
    if (token != null && token.isNotEmpty && user != null) {
      currentUser.value = user;
      isLoggedIn.value = true;
    } else {
      currentUser.value = null;
      isLoggedIn.value = false;
    }
  }

  void setSession(String token, UserModel user) {
    _storageService.setToken(token);
    _storageService.setUser(user);
    currentUser.value = user;
    isLoggedIn.value = true;
  }

  Future<void> logout() async {
    await _storageService.clearSession();
    currentUser.value = null;
    isLoggedIn.value = false;
    Get.offAllNamed(AppRoutes.login);
  }

  void updateUser(UserModel user) {
    currentUser.value = user;
    _storageService.setUser(user);
  }

  // Role Checks
  bool get isSalesman => currentUser.value?.role.toLowerCase() == 'salesman';
  bool get isSalesManager => currentUser.value?.role.toLowerCase() == 'sales_manager';
  bool get hasSalesAccess => isSalesman || isSalesManager;
  bool get isAdmin => currentUser.value?.role.toLowerCase() == 'admin';
}


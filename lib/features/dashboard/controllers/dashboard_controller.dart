import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/security/face_storage_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/location_service.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/repositories/attendance_repository.dart';

class DashboardController extends GetxController {
  final AttendanceRepository _attendanceRepository;
  final AuthService _authService;
  final LocationService _locationService;
  final FaceStorageService _faceStorageService;

  DashboardController({
    required AttendanceRepository attendanceRepository,
    required AuthService authService,
    LocationService? locationService,
    FaceStorageService? faceStorageService,
  })  : _attendanceRepository = attendanceRepository,
        _authService = authService,
        _locationService = locationService ?? Get.find<LocationService>(),
        _faceStorageService = faceStorageService ?? Get.find<FaceStorageService>();

  // Real-time Clock
  final RxString currentTime = ''.obs;
  final RxString currentDate = ''.obs;
  Timer? _clockTimer;

  // Attendance State
  final RxBool isLoading = false.obs;
  final RxBool isActionLoading = false.obs;
  final RxString activeAction = ''.obs;
  final RxString errorMessage = ''.obs;

  final Rx<AttendanceRecord?> todayRecord = Rx<AttendanceRecord?>(null);
  final RxList<AttendanceRecord> history = <AttendanceRecord>[].obs;

  final noteController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _startLiveClock();
    _enforceFaceRegistrationGate();
    loadDashboardData();
  }

  Future<void> _enforceFaceRegistrationGate() async {
    final user = _authService.currentUser.value;
    if (user == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }
    final hasTemplate = await _faceStorageService.hasFaceTemplate(user.id);
    if (user.face == 0 || !hasTemplate) {
      Get.offAllNamed(AppRoutes.faceRegistrationIntro);
    }
  }

  void _startLiveClock() {
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());
  }

  void _updateClock() {
    final now = DateTime.now();
    currentTime.value = DateFormat('hh:mm:ss a').format(now);
    currentDate.value = DateFormat('EEEE, dd MMMM yyyy').format(now);
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _attendanceRepository.getStatus();
      todayRecord.value = result.today;
      history.assignAll(result.history);

      if (result.user != null) {
        _authService.updateUser(result.user!);
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _showOfflineSnackbar() {
    Get.snackbar(
      'Internet Connection Required',
      'An active network connection is strictly mandatory for attendance verification. Offline attendance is not supported.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.danger,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.wifi_off_rounded, color: Colors.white),
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
    );
  }

  Future<void> _showMissingTemplateDialog() async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.face_retouching_off_rounded, color: AppColors.warning),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Face Template Required',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'Your biometric face template has not been registered on this device. For security, attendance cannot be logged without face verification.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.faceRegistrationIntro);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Register Face Now'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  Future<void> checkIn() async {
    isActionLoading.value = true;
    activeAction.value = 'check_in';
    try {
      // 1. Mandatory Network Verification
      if (!await _isOnline()) {
        _showOfflineSnackbar();
        return;
      }

      // 2. Mandatory Face Template Verification
      final user = _authService.currentUser.value;
      if (user == null) return;
      final hasTemplate = await _faceStorageService.hasFaceTemplate(user.id);
      if (!hasTemplate) {
        await _showMissingTemplateDialog();
        return;
      }

      // 3. Mandatory GPS Location Capture
      final location = await _locationService.obtainLocationForPunch();
      if (location == null) {
        return;
      }

      // 4. Mandatory Live Face Biometric Verification Gate
      final note = noteController.text.trim();
      final result = await Get.toNamed(
        AppRoutes.faceVerification,
        arguments: {
          'action': 'check_in',
          'note': note.isNotEmpty ? note : null,
          'lat': location.latitude,
          'lng': location.longitude,
          'address': location.address,
        },
      );

      if (result is Map && result['success'] == true) {
        noteController.clear();
        Get.snackbar(
          'Checked In',
          result['message']?.toString() ?? 'Check-in recorded successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          icon: const Icon(Icons.verified_rounded, color: Colors.white),
        );
        await loadDashboardData();
      }
    } catch (e) {
      Get.snackbar(
        'Check-In Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isActionLoading.value = false;
      activeAction.value = '';
    }
  }

  Future<void> checkOut() async {
    isActionLoading.value = true;
    activeAction.value = 'check_out';
    try {
      // 1. Mandatory Network Verification
      if (!await _isOnline()) {
        _showOfflineSnackbar();
        return;
      }

      // 2. Mandatory Face Template Verification
      final user = _authService.currentUser.value;
      if (user == null) return;
      final hasTemplate = await _faceStorageService.hasFaceTemplate(user.id);
      if (!hasTemplate) {
        await _showMissingTemplateDialog();
        return;
      }

      // 3. Mandatory GPS Location Capture
      final location = await _locationService.obtainLocationForPunch();
      if (location == null) {
        return;
      }

      // 4. Mandatory Live Face Biometric Verification Gate
      final result = await Get.toNamed(
        AppRoutes.faceVerification,
        arguments: {
          'action': 'check_out',
          'lat': location.latitude,
          'lng': location.longitude,
          'address': location.address,
        },
      );

      if (result is Map && result['success'] == true) {
        Get.snackbar(
          'Checked Out',
          result['message']?.toString() ?? 'Check-out recorded successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.shade600,
          colorText: Colors.white,
          icon: const Icon(Icons.verified_rounded, color: Colors.white),
        );
        await loadDashboardData();
      }
    } catch (e) {
      Get.snackbar(
        'Check-Out Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isActionLoading.value = false;
      activeAction.value = '';
    }
  }

  Future<void> markStatus(String status) async {
    final note = noteController.text.trim();
    isActionLoading.value = true;
    try {
      final response = await _attendanceRepository.markStatus(
        status: status,
        note: note.isNotEmpty ? note : null,
      );
      noteController.clear();
      Get.snackbar(
        'Status Marked',
        response['message']?.toString() ?? 'Status marked successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.indigo.shade600,
        colorText: Colors.white,
      );
      await loadDashboardData();
    } catch (e) {
      Get.snackbar(
        'Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> earlyLeave() async {
    isActionLoading.value = true;
    activeAction.value = 'early_leave';
    try {
      if (!await _isOnline()) {
        _showOfflineSnackbar();
        return;
      }

      final user = _authService.currentUser.value;
      if (user == null) return;
      final hasTemplate = await _faceStorageService.hasFaceTemplate(user.id);
      if (!hasTemplate) {
        await _showMissingTemplateDialog();
        return;
      }

      final location = await _locationService.obtainLocationForPunch();
      if (location == null) return;

      final note = noteController.text.trim();
      final result = await Get.toNamed(
        AppRoutes.faceVerification,
        arguments: {
          'action': 'early_leave',
          'note': note.isNotEmpty ? note : 'Early Departure',
          'lat': location.latitude,
          'lng': location.longitude,
          'address': location.address,
        },
      );

      if (result is Map && result['success'] == true) {
        noteController.clear();
        Get.snackbar(
          'Early Leave Recorded',
          result['message']?.toString() ?? 'Early leave recorded successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
          icon: const Icon(Icons.verified_rounded, color: Colors.white),
        );
        await loadDashboardData();
      }
    } catch (e) {
      Get.snackbar(
        'Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isActionLoading.value = false;
      activeAction.value = '';
    }
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    noteController.dispose();
    super.onClose();
  }
}

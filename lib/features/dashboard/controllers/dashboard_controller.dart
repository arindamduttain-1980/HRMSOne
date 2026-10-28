import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/repositories/attendance_repository.dart';

class DashboardController extends GetxController {
  final AttendanceRepository _attendanceRepository;
  final AuthService _authService;

  DashboardController({
    required AttendanceRepository attendanceRepository,
    required AuthService authService,
  })  : _attendanceRepository = attendanceRepository,
        _authService = authService;

  // Real-time Clock
  final RxString currentTime = ''.obs;
  final RxString currentDate = ''.obs;
  Timer? _clockTimer;

  // Attendance State
  final RxBool isLoading = false.obs;
  final RxBool isActionLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final Rx<AttendanceRecord?> todayRecord = Rx<AttendanceRecord?>(null);
  final RxList<AttendanceRecord> history = <AttendanceRecord>[].obs;

  final noteController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _startLiveClock();
    loadDashboardData();
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

  Future<void> checkIn() async {
    final note = noteController.text.trim();
    isActionLoading.value = true;
    try {
      final response = await _attendanceRepository.checkIn(
        note: note.isNotEmpty ? note : null,
      );
      noteController.clear();
      Get.snackbar(
        'Checked In',
        response['message']?.toString() ?? 'Check-in recorded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
      await loadDashboardData();
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
    }
  }

  Future<void> checkOut() async {
    isActionLoading.value = true;
    try {
      final response = await _attendanceRepository.checkOut();
      Get.snackbar(
        'Checked Out',
        response['message']?.toString() ?? 'Check-out recorded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade600,
        colorText: Colors.white,
      );
      await loadDashboardData();
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
    final note = noteController.text.trim();
    isActionLoading.value = true;
    try {
      final response = await _attendanceRepository.earlyLeave(
        note: note.isNotEmpty ? note : 'Early Departure',
      );
      noteController.clear();
      Get.snackbar(
        'Early Leave Recorded',
        response['message']?.toString() ?? 'Early leave recorded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade700,
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

  @override
  void onClose() {
    _clockTimer?.cancel();
    noteController.dispose();
    super.onClose();
  }
}


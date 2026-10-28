import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/location_service.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/repositories/attendance_repository.dart';

class DashboardController extends GetxController {
  final AttendanceRepository _attendanceRepository;
  final AuthService _authService;
  final LocationService _locationService;

  DashboardController({
    required AttendanceRepository attendanceRepository,
    required AuthService authService,
    LocationService? locationService,
  })  : _attendanceRepository = attendanceRepository,
        _authService = authService,
        _locationService = locationService ?? Get.find<LocationService>();

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
    isActionLoading.value = true;
    activeAction.value = 'check_in';
    try {
      // 1. Mandatory Location Verification: must obtain valid GPS coordinates
      final location = await _locationService.obtainLocationForPunch();
      if (location == null) {
        // Location permission denied, GPS off, or coordinates unavailable.
        // Hard requirement: Attendance punch CANNOT proceed without GPS lat/lng.
        return;
      }

      final note = noteController.text.trim();
      final response = await _attendanceRepository.checkIn(
        note: note.isNotEmpty ? note : null,
        lat: location.latitude,
        lng: location.longitude,
        address: location.address,
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
      activeAction.value = '';
    }
  }

  Future<void> checkOut() async {
    isActionLoading.value = true;
    activeAction.value = 'check_out';
    try {
      // 1. Mandatory Location Verification: must obtain valid GPS coordinates
      final location = await _locationService.obtainLocationForPunch();
      if (location == null) {
        // Location permission denied, GPS off, or coordinates unavailable.
        // Hard requirement: Attendance punch CANNOT proceed without GPS lat/lng.
        return;
      }

      final response = await _attendanceRepository.checkOut(
        lat: location.latitude,
        lng: location.longitude,
        address: location.address,
      );
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
      // Mandatory Location Verification for early departure
      final location = await _locationService.obtainLocationForPunch();
      if (location == null) {
        return;
      }

      final note = noteController.text.trim();
      final response = await _attendanceRepository.earlyLeave(
        note: note.isNotEmpty ? note : 'Early Departure',
        lat: location.latitude,
        lng: location.longitude,
        address: location.address,
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


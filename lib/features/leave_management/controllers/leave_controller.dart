import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/leave_model.dart';
import '../../../data/repositories/leave_repository.dart';

class LeaveController extends GetxController {
  final LeaveRepository _leaveRepository;

  LeaveController({required LeaveRepository leaveRepository})
      : _leaveRepository = leaveRepository;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<LeaveTypeModel> leaveTypes = <LeaveTypeModel>[].obs;
  final RxList<LeaveApplicationModel> leaves = <LeaveApplicationModel>[].obs;

  // Application Form
  final reasonController = TextEditingController();
  final Rx<LeaveTypeModel?> selectedLeaveType = Rx<LeaveTypeModel?>(null);
  final RxString fromDate = ''.obs;
  final RxString toDate = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1)));
    fromDate.value = today;
    toDate.value = today;
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final types = await _leaveRepository.getLeaveTypes();
      leaveTypes.assignAll(types);
      if (types.isNotEmpty && selectedLeaveType.value == null) {
        selectedLeaveType.value = types.first;
      }

      final list = await _leaveRepository.getLeaves();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      leaves.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void openApplyModal() {
    reasonController.clear();
    final tomorrow = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1)));
    fromDate.value = tomorrow;
    toDate.value = tomorrow;
    if (leaveTypes.isNotEmpty) {
      selectedLeaveType.value = leaveTypes.first;
    }
  }

  Future<void> applyLeave() async {
    final reason = reasonController.text.trim();
    if (reason.isEmpty) {
      Get.snackbar('Required', 'Please enter a reason for your leave', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (selectedLeaveType.value == null) {
      Get.snackbar('Required', 'Please select a leave type', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      final response = await _leaveRepository.applyLeave(
        leaveTypeId: selectedLeaveType.value!.id,
        fromDate: fromDate.value,
        toDate: toDate.value,
        reason: reason,
      );

      Get.back(); // close modal
      Get.snackbar(
        'Leave Applied',
        response['message']?.toString() ?? 'Leave application submitted.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
      await loadData();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> cancelLeave(int id) async {
    try {
      final msg = await _leaveRepository.cancelLeave(id);
      Get.snackbar('Cancelled', msg, snackPosition: SnackPosition.BOTTOM);
      await loadData();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }
}


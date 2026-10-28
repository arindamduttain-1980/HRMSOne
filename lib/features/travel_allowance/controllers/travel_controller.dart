import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/travel_claim_model.dart';
import '../../../data/repositories/travel_repository.dart';

class TravelController extends GetxController {
  final TravelRepository _travelRepository;

  TravelController({required TravelRepository travelRepository})
      : _travelRepository = travelRepository;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<TravelClaimModel> claims = <TravelClaimModel>[].obs;

  // New Claim Form
  final fromPlaceController = TextEditingController();
  final toPlaceController = TextEditingController();
  final purposeController = TextEditingController();
  final distanceController = TextEditingController();
  final ticketExpenseController = TextEditingController();
  final otherExpenseController = TextEditingController();
  final hotelExpenseController = TextEditingController();
  final foodExpenseController = TextEditingController();
  final notesController = TextEditingController();

  final RxString travelDate = ''.obs;
  final RxString travelType = 'local'.obs;
  final RxString travelMode = 'own_vehicle'.obs;
  final RxBool isReturn = false.obs;

  final List<String> travelTypes = ['local', 'outstation'];
  final List<String> travelModes = ['own_vehicle', 'company_vehicle', 'bus', 'auto', 'taxi', 'train', 'flight'];

  @override
  void onInit() {
    super.onInit();
    travelDate.value = DateFormat('yyyy-MM-dd').format(DateTime.now());
    loadClaims();
  }

  Future<void> loadClaims() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final list = await _travelRepository.getClaims();
      list.sort((a, b) => b.travelDate.compareTo(a.travelDate));
      claims.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void openApplyModal() {
    fromPlaceController.clear();
    toPlaceController.clear();
    purposeController.clear();
    distanceController.clear();
    ticketExpenseController.clear();
    otherExpenseController.clear();
    hotelExpenseController.clear();
    foodExpenseController.clear();
    notesController.clear();
    travelDate.value = DateFormat('yyyy-MM-dd').format(DateTime.now());
    travelType.value = 'local';
    travelMode.value = 'own_vehicle';
    isReturn.value = false;
  }

  Future<void> applyClaim() async {
    final from = fromPlaceController.text.trim();
    final to = toPlaceController.text.trim();
    final purpose = purposeController.text.trim();

    if (from.isEmpty || to.isEmpty || purpose.isEmpty) {
      Get.snackbar('Required', 'Please fill in from, to, and purpose fields', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      final response = await _travelRepository.applyClaim(
        travelDate: travelDate.value,
        fromPlace: from,
        toPlace: to,
        purpose: purpose,
        travelType: travelType.value,
        mode: travelMode.value,
        distanceKm: double.tryParse(distanceController.text.trim()),
        ticketAmount: double.tryParse(ticketExpenseController.text.trim()),
        otherExpense: double.tryParse(otherExpenseController.text.trim()),
        isReturn: isReturn.value,
        hotelExpense: double.tryParse(hotelExpenseController.text.trim()),
        foodExpense: double.tryParse(foodExpenseController.text.trim()),
        notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
      );

      Get.back();
      Get.snackbar(
        'Claim Submitted',
        response['message']?.toString() ?? 'Travel claim submitted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
      await loadClaims();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> cancelClaim(int id) async {
    try {
      final msg = await _travelRepository.cancelClaim(id);
      Get.snackbar('Cancelled', msg, snackPosition: SnackPosition.BOTTOM);
      await loadClaims();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    fromPlaceController.dispose();
    toPlaceController.dispose();
    purposeController.dispose();
    distanceController.dispose();
    ticketExpenseController.dispose();
    otherExpenseController.dispose();
    hotelExpenseController.dispose();
    foodExpenseController.dispose();
    notesController.dispose();
    super.onClose();
  }
}


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/card_data_model.dart';
import '../../../data/repositories/card_repository.dart';

class CardController extends GetxController {
  final CardRepository _cardRepository;

  CardController({required CardRepository cardRepository})
      : _cardRepository = cardRepository;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<DigitalCardDataModel?> cardData = Rx<DigitalCardDataModel?>(null);
  final RxString selectedTab = 'id'.obs; // 'id' or 'visiting'

  // Edit Tagline
  final taglineController = TextEditingController();

  // Edit Safety Details
  final emergencyNameController = TextEditingController();
  final emergencyPhoneController = TextEditingController();
  final RxString selectedBloodGroup = 'B+'.obs;

  final List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void onInit() {
    super.onInit();
    loadCardData();
  }

  Future<void> loadCardData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final data = await _cardRepository.getCardData();
      cardData.value = data;

      taglineController.text = data.employee.tagline ?? '';
      emergencyNameController.text = data.employee.emergencyName ?? '';
      emergencyPhoneController.text = data.employee.emergencyContact ?? '';
      if (data.employee.bloodGroup != null && bloodGroups.contains(data.employee.bloodGroup)) {
        selectedBloodGroup.value = data.employee.bloodGroup!;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void switchTab(String tab) {
    selectedTab.value = tab;
  }

  Future<void> updateTagline() async {
    final tagline = taglineController.text.trim();
    try {
      await _cardRepository.updateTagline(tagline);
      Get.back();
      Get.snackbar('Success', 'Visiting card tagline updated', snackPosition: SnackPosition.BOTTOM);
      await loadCardData();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateSafetyDetails() async {
    try {
      await _cardRepository.updateSafetyDetails(
        bloodGroup: selectedBloodGroup.value,
        emergencyName: emergencyNameController.text.trim(),
        emergencyContact: emergencyPhoneController.text.trim(),
      );
      Get.back();
      Get.snackbar('Success', 'Safety details updated', snackPosition: SnackPosition.BOTTOM);
      await loadCardData();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    taglineController.dispose();
    emergencyNameController.dispose();
    emergencyPhoneController.dispose();
    super.onClose();
  }
}


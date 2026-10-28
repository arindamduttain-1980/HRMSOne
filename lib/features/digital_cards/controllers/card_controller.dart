import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/card_data_model.dart';
import '../../../data/repositories/card_repository.dart';

class CardController extends GetxController {
  final CardRepository _cardRepository;

  CardController({required CardRepository cardRepository})
      : _cardRepository = cardRepository;

  final RxBool isLoading = false.obs;
  final RxBool isExporting = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<DigitalCardDataModel?> cardData = Rx<DigitalCardDataModel?>(null);
  final RxString selectedTab = 'id'.obs; // 'id' or 'visiting'

  // GlobalKeys for capturing widgets to image
  final GlobalKey idCardKey = GlobalKey();
  final GlobalKey visitingCardKey = GlobalKey();

  // Edit Tagline
  final taglineController = TextEditingController();

  // Edit Safety Details
  final emergencyNameController = TextEditingController();
  final emergencyPhoneController = TextEditingController();
  final RxString selectedBloodGroup = 'Not set'.obs;

  final List<String> bloodGroups = [
    'Not set',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

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

      final bg = data.employee.bloodGroup?.trim();
      if (bg != null && bg.isNotEmpty && bloodGroups.contains(bg)) {
        selectedBloodGroup.value = bg;
      } else {
        selectedBloodGroup.value = 'Not set';
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

  /// Extracts initials from name (e.g. "HR Admin" -> "HA")
  String getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.map((p) => p.isNotEmpty ? p[0] : '').take(2).join('').toUpperCase();
  }

  /// Captures the specified card widget as high-resolution PNG bytes
  Future<Uint8List?> _captureCardBytes(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing card image: $e');
      return null;
    }
  }

  /// Shares the card image using native sharing (matching web panel Image 3)
  Future<void> shareCard(String mode) async {
    final key = mode == 'id' ? idCardKey : visitingCardKey;
    final fileName = mode == 'id' ? 'id-card.png' : 'visiting-card.png';
    final emp = cardData.value?.employee;
    final comp = cardData.value?.company;
    final shareText = '${emp?.name ?? ''}${emp?.designation != null ? ' - ${emp!.designation}' : ''}${comp?.name != null ? ' @ ${comp!.name}' : ''}\n${emp?.shareUrl ?? ''}'.trim();

    isExporting.value = true;
    try {
      final bytes = await _captureCardBytes(key);
      if (bytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(bytes);

        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'image/png')],
          text: shareText,
        );
      } else {
        await Share.share(shareText);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not share card: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isExporting.value = false;
    }
  }

  /// Downloads and saves the card image as a PNG file
  Future<void> downloadCard(String mode) async {
    final key = mode == 'id' ? idCardKey : visitingCardKey;
    final empName = (cardData.value?.employee.name ?? 'card').replaceAll(RegExp(r'\s+'), '_');
    final fileName = '${mode == 'id' ? 'ID-Card-' : 'Visiting-Card-'}$empName.png';

    isExporting.value = true;
    try {
      final bytes = await _captureCardBytes(key);
      if (bytes != null) {
        Directory? dir;
        if (Platform.isAndroid) {
          dir = await getExternalStorageDirectory();
        }
        dir ??= await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);

        Get.snackbar(
          'Download Complete',
          'Card saved to ${file.path}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar('Error', 'Could not export card image', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Download failed: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isExporting.value = false;
    }
  }

  /// Copies visiting card public share link to clipboard
  void copyCardLink() {
    final url = cardData.value?.employee.shareUrl;
    if (url != null && url.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: url));
      Get.snackbar(
        'Link Copied',
        'Link copied.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
      );
    } else {
      Get.snackbar(
        'Notice',
        'No shareable link yet — ask HR to link your employee record.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Saves updated tagline for visiting card
  Future<void> updateTagline() async {
    final tagline = taglineController.text.trim();
    isLoading.value = true;
    try {
      await _cardRepository.updateTagline(tagline);
      Get.snackbar('Success', 'Visiting card updated.', snackPosition: SnackPosition.BOTTOM);
      await loadCardData();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Saves updated safety & emergency details for ID card
  Future<void> updateSafetyDetails() async {
    isLoading.value = true;
    try {
      final bg = selectedBloodGroup.value == 'Not set' ? '' : selectedBloodGroup.value;
      await _cardRepository.updateSafetyDetails(
        bloodGroup: bg,
        emergencyName: emergencyNameController.text.trim(),
        emergencyContact: emergencyPhoneController.text.trim(),
      );
      Get.snackbar('Success', 'ID card updated.', snackPosition: SnackPosition.BOTTOM);
      await loadCardData();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
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

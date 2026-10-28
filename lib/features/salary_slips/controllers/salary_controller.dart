import 'package:get/get.dart';
import '../../../data/models/salary_slip_model.dart';
import '../../../data/repositories/salary_repository.dart';

class SalaryController extends GetxController {
  final SalaryRepository _salaryRepository;

  SalaryController({required SalaryRepository salaryRepository})
      : _salaryRepository = salaryRepository;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<SalarySlipSummaryModel> slips = <SalarySlipSummaryModel>[].obs;

  // Selected slip detail
  final Rx<SalarySlipDetailModel?> selectedSlipDetail = Rx<SalarySlipDetailModel?>(null);
  final RxBool isDetailLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSalarySlips();
  }

  Future<void> loadSalarySlips() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final list = await _salaryRepository.getSalarySlips();
      list.sort((a, b) {
        if (a.year != b.year) return b.year.compareTo(a.year);
        return b.month.compareTo(a.month);
      });
      slips.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSlipDetail(int id) async {
    isDetailLoading.value = true;
    selectedSlipDetail.value = null;

    try {
      final detail = await _salaryRepository.getSalarySlipDetail(id);
      selectedSlipDetail.value = detail;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load payslip details: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isDetailLoading.value = false;
    }
  }
}


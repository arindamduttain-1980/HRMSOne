import 'package:get/get.dart';
import '../../../data/models/sales_invoice_model.dart';
import '../../../data/repositories/sales_repository.dart';

class SalesInvoiceController extends GetxController {
  final SalesRepository _salesRepository;

  SalesInvoiceController({required SalesRepository salesRepository})
      : _salesRepository = salesRepository;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<SalesInvoiceSummaryModel> invoices = <SalesInvoiceSummaryModel>[].obs;
  final RxList<Map<String, int>> availableMonths = <Map<String, int>>[].obs;

  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxInt selectedYear = DateTime.now().year.obs;

  // Selected Invoice Detail
  final Rx<SalesInvoiceDetailModel?> selectedInvoice = Rx<SalesInvoiceDetailModel?>(null);
  final RxBool isDetailLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMonthsAndInvoices();
  }

  Future<void> loadMonthsAndInvoices() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final months = await _salesRepository.getInvoiceMonths();
      availableMonths.assignAll(months);
      if (months.isNotEmpty) {
        selectedYear.value = months.first['year']!;
        selectedMonth.value = months.first['month']!;
      }

      await loadInvoices();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadInvoices() async {
    isLoading.value = true;
    try {
      final list = await _salesRepository.getInvoices(
        month: selectedMonth.value,
        year: selectedYear.value,
      );
      invoices.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadInvoiceDetail(int id) async {
    isDetailLoading.value = true;
    selectedInvoice.value = null;

    try {
      final detail = await _salesRepository.getInvoiceDetail(id);
      selectedInvoice.value = detail;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load invoice: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isDetailLoading.value = false;
    }
  }
}


import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../data/repositories/sales_repository.dart';
import '../controllers/sales_invoice_controller.dart';

class SalesInvoiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SalesRepository>(() => SalesRepository(Get.find<ApiClient>()));
    Get.lazyPut<SalesInvoiceController>(
      () => SalesInvoiceController(salesRepository: Get.find<SalesRepository>()),
    );
  }
}


import 'package:get/get.dart';
import '../../../data/models/sales_target_model.dart';
import '../../../data/repositories/sales_repository.dart';

class SalesTargetController extends GetxController {
  final SalesRepository _salesRepository;

  SalesTargetController({required SalesRepository salesRepository})
      : _salesRepository = salesRepository;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<SalesTargetModel?> currentTarget = Rx<SalesTargetModel?>(null);
  final RxList<SalesTargetModel> history = <SalesTargetModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTargets();
  }

  Future<void> loadTargets() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final target = await _salesRepository.getSalesTarget();
      currentTarget.value = target;

      final hist = await _salesRepository.getSalesTargetHistory();
      history.assignAll(hist);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}


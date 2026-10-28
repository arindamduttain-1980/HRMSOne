import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../data/repositories/notes_repository.dart';
import '../controllers/notes_controller.dart';

class NotesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotesRepository>(() => NotesRepository(Get.find<ApiClient>()));
    Get.lazyPut<NotesController>(
      () => NotesController(notesRepository: Get.find<NotesRepository>()),
    );
  }
}


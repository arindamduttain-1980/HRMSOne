import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/repositories/messenger_repository.dart';

class MessengerController extends GetxController {
  final MessengerRepository _messengerRepository;
  final AuthService _authService;

  MessengerController({
    required MessengerRepository messengerRepository,
    required AuthService authService,
  })  : _messengerRepository = messengerRepository,
        _authService = authService;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<ChatGroupModel> groups = <ChatGroupModel>[].obs;

  // Active Chat Thread
  final Rx<ChatGroupModel?> activeGroup = Rx<ChatGroupModel?>(null);
  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxBool isMessagesLoading = false.obs;
  final messageInputController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  int get currentUserId => _authService.currentUser.value?.id ?? 0;

  @override
  void onInit() {
    super.onInit();
    loadGroups();
  }

  Future<void> loadGroups() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final list = await _messengerRepository.getGroups();
      groups.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openGroup(ChatGroupModel group) async {
    activeGroup.value = group;
    isMessagesLoading.value = true;

    try {
      final msgs = await _messengerRepository.getMessages(group.id);
      messages.assignAll(msgs);
      _scrollToBottom();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load messages: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isMessagesLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = messageInputController.text.trim();
    if (text.isEmpty || activeGroup.value == null) return;

    try {
      await _messengerRepository.sendMessage(activeGroup.value!.id, text);
      messageInputController.clear();
      // Reload messages
      final msgs = await _messengerRepository.getMessages(activeGroup.value!.id);
      messages.assignAll(msgs);
      _scrollToBottom();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    messageInputController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}


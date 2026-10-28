import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/ticket_model.dart';
import '../../../data/repositories/ticket_repository.dart';

class TicketController extends GetxController {
  final TicketRepository _ticketRepository;

  TicketController({required TicketRepository ticketRepository})
      : _ticketRepository = ticketRepository;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<TicketModel> tickets = <TicketModel>[].obs;
  final RxList<TicketCategoryModel> categories = <TicketCategoryModel>[].obs;

  // New Ticket Form
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final Rx<TicketCategoryModel?> selectedCategory = Rx<TicketCategoryModel?>(null);
  final RxString selectedPriority = 'medium'.obs;

  final List<String> priorities = ['low', 'medium', 'high', 'critical'];

  // Thread Discussion
  final Rx<TicketModel?> activeTicket = Rx<TicketModel?>(null);
  final RxList<TicketCommentModel> comments = <TicketCommentModel>[].obs;
  final RxBool isThreadLoading = false.obs;
  final commentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadTickets();
  }

  Future<void> loadTickets() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final cats = await _ticketRepository.getCategories();
      categories.assignAll(cats);
      if (cats.isNotEmpty && selectedCategory.value == null) {
        selectedCategory.value = cats.first;
      }

      final list = await _ticketRepository.getTickets();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      tickets.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void openCreateModal() {
    titleController.clear();
    descriptionController.clear();
    selectedPriority.value = 'medium';
    if (categories.isNotEmpty) {
      selectedCategory.value = categories.first;
    }
  }

  Future<void> createTicket() async {
    final title = titleController.text.trim();
    final desc = descriptionController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      Get.snackbar('Required', 'Please fill in both title and description', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      final response = await _ticketRepository.createTicket(
        title: title,
        description: desc,
        categoryId: selectedCategory.value?.id,
        priority: selectedPriority.value,
      );

      Get.back(); // close modal
      Get.snackbar(
        'Ticket Raised',
        response['message']?.toString() ?? 'Ticket submitted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
      await loadTickets();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> loadThread(TicketModel ticket) async {
    activeTicket.value = ticket;
    isThreadLoading.value = true;

    try {
      final result = await _ticketRepository.getComments(ticket.id);
      if (result.ticket != null) {
        activeTicket.value = result.ticket;
      }
      comments.assignAll(result.comments);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load comments: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isThreadLoading.value = false;
    }
  }

  Future<void> addComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty || activeTicket.value == null) return;

    try {
      await _ticketRepository.addComment(activeTicket.value!.id, text);
      commentController.clear();
      await loadThread(activeTicket.value!);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    commentController.dispose();
    super.onClose();
  }
}


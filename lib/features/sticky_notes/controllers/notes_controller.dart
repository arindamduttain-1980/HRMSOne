import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/note_model.dart';
import '../../../data/repositories/notes_repository.dart';

class NotesController extends GetxController {
  final NotesRepository _notesRepository;

  NotesController({required NotesRepository notesRepository})
      : _notesRepository = notesRepository;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<NoteModel> notes = <NoteModel>[].obs;

  // Selected note for editing/modal
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final RxString selectedColor = '#fef08a'.obs;
  final Rx<NoteModel?> editingNote = Rx<NoteModel?>(null);

  final List<String> availableColors = [
    '#fef08a', // Yellow
    '#fbcfe8', // Pink
    '#bae6fd', // Blue
    '#bbf7d0', // Green
    '#e9d5ff', // Purple
    '#fed7aa', // Orange
  ];

  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }

  Future<void> loadNotes() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final list = await _notesRepository.getNotes();
      // Pinned on top, then updated_at desc
      list.sort((a, b) {
        if (a.pinned && !b.pinned) return -1;
        if (!a.pinned && b.pinned) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
      notes.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void openCreateModal() {
    editingNote.value = null;
    titleController.clear();
    contentController.clear();
    selectedColor.value = '#fef08a';
  }

  void openEditModal(NoteModel note) {
    editingNote.value = note;
    titleController.text = note.title;
    contentController.text = note.content;
    selectedColor.value = note.color;
  }

  Future<void> saveNote() async {
    final content = contentController.text.trim();
    if (content.isEmpty) {
      Get.snackbar('Required', 'Note content cannot be empty', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final title = titleController.text.trim();
    final color = selectedColor.value;

    try {
      if (editingNote.value == null) {
        await _notesRepository.createNote(
          title: title.isNotEmpty ? title : null,
          content: content,
          color: color,
        );
      } else {
        await _notesRepository.updateNote(
          id: editingNote.value!.id,
          title: title,
          content: content,
          color: color,
        );
      }

      Get.back(); // close sheet/dialog
      await loadNotes();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> togglePin(NoteModel note) async {
    try {
      await _notesRepository.togglePin(note.id);
      await loadNotes();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      await _notesRepository.deleteNote(id);
      await loadNotes();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }
}


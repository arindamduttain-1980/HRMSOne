import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../data/models/note_model.dart';
import '../controllers/notes_controller.dart';

class StickyNotesView extends GetView<NotesController> {
  const StickyNotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sticky Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadNotes,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          controller.openCreateModal();
          _showNoteEditorSheet(context);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return ErrorStateView(
            error: controller.errorMessage.value,
            onRetry: controller.loadNotes,
          );
        }

        if (controller.notes.isEmpty) {
          return EmptyStateView(
            icon: Icons.note_alt_outlined,
            title: 'No Sticky Notes',
            message: 'Tap the + button to capture quick personal reminders.',
            buttonText: 'Add Note',
            onButtonPressed: () {
              controller.openCreateModal();
              _showNoteEditorSheet(context);
            },
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadNotes,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (ctx, i) {
              final note = controller.notes[i];
              return _buildNoteCard(context, note);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNoteCard(BuildContext context, NoteModel note) {
    final noteColor = _parseColor(note.color);

    return InkWell(
      onTap: () {
        controller.openEditModal(note);
        _showNoteEditorSheet(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: noteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    note.title.isNotEmpty ? note.title : 'Untitled',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.black.withOpacity(0.85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () => controller.togglePin(note),
                  child: Icon(
                    note.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 16,
                    color: note.pinned ? Colors.black87 : Colors.black38,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                note.content,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: Colors.black.withOpacity(0.75),
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteEditorSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                        controller.editingNote.value == null ? 'New Note' : 'Edit Note',
                        style: AppTextStyles.h3,
                      )),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title Field
              TextField(
                controller: controller.titleController,
                decoration: InputDecoration(
                  hintText: 'Title (optional)',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: AppColors.inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Content Field
              TextField(
                controller: controller.contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write your note here...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: AppColors.inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Color Selection Row
              Row(
                children: controller.availableColors.map((hex) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Obx(() {
                      final isSelected = controller.selectedColor.value == hex;
                      return InkWell(
                        onTap: () => controller.selectedColor.value = hex,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _parseColor(hex),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.black12,
                              width: isSelected ? 2.5 : 1,
                            ),
                          ),
                          child: isSelected
                              ? const Center(
                                  child: Icon(Icons.check, size: 16, color: Colors.black87),
                                )
                              : null,
                        ),
                      );
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Obx(() {
                    if (controller.editingNote.value == null) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.dangerLight,
                          padding: const EdgeInsets.all(14),
                        ),
                        icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                        onPressed: () {
                          final id = controller.editingNote.value!.id;
                          Navigator.pop(ctx);
                          controller.deleteNote(id);
                        },
                      ),
                    );
                  }),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.saveNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Note', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppColors.noteYellow;
    }
  }
}


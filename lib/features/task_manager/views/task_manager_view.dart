import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/task_model.dart';
import '../controllers/task_controller.dart';

class TaskManagerView extends GetView<TaskController> {
  const TaskManagerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadTasks,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          controller.openCreateModal();
          _showTaskEditorSheet(context);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _filterChip('all', 'All'),
                _filterChip('todo', 'To Do'),
                _filterChip('in_progress', 'In Progress'),
                _filterChip('review', 'Review'),
                _filterChip('done', 'Done'),
              ],
            ),
          ),
          const Divider(height: 1),

          // Tasks List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty) {
                return ErrorStateView(
                  error: controller.errorMessage.value,
                  onRetry: controller.loadTasks,
                );
              }

              final tasks = controller.filteredTasks;
              if (tasks.isEmpty) {
                return EmptyStateView(
                  icon: Icons.task_alt_outlined,
                  title: 'No Tasks',
                  message: 'No tasks found for the selected filter.',
                  buttonText: 'Create Task',
                  onButtonPressed: () {
                    controller.openCreateModal();
                    _showTaskEditorSheet(context);
                  },
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadTasks,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final task = tasks[i];
                    return _buildTaskCard(context, task);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String filterKey, String label) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == filterKey;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => controller.setFilter(filterKey),
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
          backgroundColor: Colors.white,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
      );
    });
  }

  Widget _buildTaskCard(BuildContext context, TaskModel task) {
    Color priorityColor;
    switch (task.priority.toLowerCase()) {
      case 'urgent':
      case 'high':
        priorityColor = AppColors.danger;
        break;
      case 'medium':
        priorityColor = AppColors.warning;
        break;
      default:
        priorityColor = AppColors.primary;
    }

    return InkWell(
      onTap: () {
        controller.openEditModal(task);
        _showTaskEditorSheet(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    task.taskNo,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    task.priority.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: priorityColor,
                    ),
                  ),
                ),
                const Spacer(),
                StatusBadge(status: task.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              task.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                decoration: task.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.description!,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (task.dueDate != null) ...[
                  const Icon(Icons.event_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    'Due ${DateFormatter.toDisplayDate(task.dueDate)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
                const Spacer(),
                if (task.assignedByName != null)
                  Text(
                    'By ${task.assignedByName}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskEditorSheet(BuildContext context) {
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
                        controller.editingTask.value == null ? 'New Task' : 'Edit Task',
                        style: AppTextStyles.h3,
                      )),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                controller: controller.titleController,
                decoration: InputDecoration(
                  hintText: 'Task Title',
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

              TextField(
                controller: controller.descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Requirements & description...',
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

              // Priority Dropdown (single line full width)
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.selectedPriority.value,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: controller.priorities.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(p.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.selectedPriority.value = val;
                    },
                  )),
              const SizedBox(height: 12),

              // Status Dropdown (single line full width)
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.selectedStatus.value,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: controller.statuses.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s.replaceAll('_', ' ').capitalizeFirst ?? s, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.selectedStatus.value = val;
                    },
                  )),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Obx(() {
                    if (controller.editingTask.value == null) {
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
                          final id = controller.editingTask.value!.id;
                          Navigator.pop(ctx);
                          controller.deleteTask(id);
                        },
                      ),
                    );
                  }),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.saveTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Task', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
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
}

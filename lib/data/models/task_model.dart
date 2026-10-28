class TaskModel {
  final int id;
  final String taskNo;
  final String title;
  final String? description;
  final String priority;
  final String status;
  final String? category;
  final int? assignedTo;
  final int? assignedBy;
  final String? assignedByName;
  final String? dueDate;
  final String? completedAt;

  TaskModel({
    required this.id,
    required this.taskNo,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    this.category,
    this.assignedTo,
    this.assignedBy,
    this.assignedByName,
    this.dueDate,
    this.completedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      taskNo: json['task_no']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      priority: json['priority']?.toString() ?? 'medium',
      status: json['status']?.toString() ?? 'todo',
      category: json['category']?.toString(),
      assignedTo: json['assigned_to'] != null ? int.tryParse(json['assigned_to'].toString()) : null,
      assignedBy: json['assigned_by'] != null ? int.tryParse(json['assigned_by'].toString()) : null,
      assignedByName: json['assigned_by_name']?.toString(),
      dueDate: json['due_date']?.toString(),
      completedAt: json['completed_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_no': taskNo,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'category': category,
      'assigned_to': assignedTo,
      'assigned_by': assignedBy,
      'assigned_by_name': assignedByName,
      'due_date': dueDate,
      'completed_at': completedAt,
    };
  }

  bool get isDone => status == 'done';
}


class TicketCategoryModel {
  final int id;
  final String name;
  final String? icon;
  final String? color;

  TicketCategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.color,
  });

  factory TicketCategoryModel.fromJson(Map<String, dynamic> json) {
    return TicketCategoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString(),
      color: json['color']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
    };
  }
}

class TicketModel {
  final int id;
  final String ticketNo;
  final String title;
  final String? description;
  final int? categoryId;
  final String? categoryName;
  final String priority;
  final String status;
  final String? assignedToName;
  final String createdAt;

  TicketModel({
    required this.id,
    required this.ticketNo,
    required this.title,
    this.description,
    this.categoryId,
    this.categoryName,
    required this.priority,
    required this.status,
    this.assignedToName,
    required this.createdAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      ticketNo: json['ticket_no']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      categoryId: json['category_id'] != null ? int.tryParse(json['category_id'].toString()) : null,
      categoryName: json['category_name']?.toString(),
      priority: json['priority']?.toString() ?? 'medium',
      status: json['status']?.toString() ?? 'open',
      assignedToName: json['assigned_to_name']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_no': ticketNo,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'category_name': categoryName,
      'priority': priority,
      'status': status,
      'assigned_to_name': assignedToName,
      'created_at': createdAt,
    };
  }

  bool get isOpen => status == 'open';
  bool get isInProgress => status == 'in_progress';
  bool get isResolved => status == 'resolved' || status == 'closed';
}

class TicketCommentModel {
  final int id;
  final int userId;
  final String userName;
  final String comment;
  final String createdAt;

  TicketCommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.createdAt,
  });

  factory TicketCommentModel.fromJson(Map<String, dynamic> json) {
    return TicketCommentModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      userName: json['user_name']?.toString() ?? 'User',
      comment: json['comment']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'comment': comment,
      'created_at': createdAt,
    };
  }
}


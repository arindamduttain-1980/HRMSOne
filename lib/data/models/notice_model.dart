class NoticeModel {
  final int id;
  final String title;
  final String content;
  final String priority;
  final bool isPinned;
  final String createdAt;
  final bool isRead;

  NoticeModel({
    required this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.isPinned,
    required this.createdAt,
    required this.isRead,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'medium',
      isPinned: json['is_pinned'] == 1 || json['is_pinned'] == true || json['is_pinned'] == '1',
      createdAt: json['created_at']?.toString() ?? '',
      isRead: json['is_read'] == true || json['is_read'] == 1 || json['is_read'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority,
      'is_pinned': isPinned ? 1 : 0,
      'created_at': createdAt,
      'is_read': isRead,
    };
  }

  NoticeModel copyWith({bool? isRead}) {
    return NoticeModel(
      id: id,
      title: title,
      content: content,
      priority: priority,
      isPinned: isPinned,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}


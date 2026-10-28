class NoteModel {
  final int id;
  final String title;
  final String content;
  final String color;
  final bool pinned;
  final String updatedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.pinned,
    required this.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      color: json['color']?.toString() ?? '#fef08a',
      pinned: json['pinned'] == 1 || json['pinned'] == true || json['pinned'] == '1',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color,
      'pinned': pinned ? 1 : 0,
      'updated_at': updatedAt,
    };
  }

  NoteModel copyWith({
    String? title,
    String? content,
    String? color,
    bool? pinned,
    String? updatedAt,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      pinned: pinned ?? this.pinned,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


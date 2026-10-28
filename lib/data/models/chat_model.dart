class ChatGroupModel {
  final int id;
  final String name;
  final String type; // direct, group
  final String? lastRead;
  final String? lastMessage;
  final String? lastMessageAt;
  final int unreadCount;

  ChatGroupModel({
    required this.id,
    required this.name,
    required this.type,
    this.lastRead,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
  });

  factory ChatGroupModel.fromJson(Map<String, dynamic> json) {
    return ChatGroupModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'direct',
      lastRead: json['last_read']?.toString(),
      lastMessage: json['last_message']?.toString(),
      lastMessageAt: json['last_message_at']?.toString(),
      unreadCount: json['unread_count'] != null ? (json['unread_count'] is int ? json['unread_count'] : int.tryParse(json['unread_count'].toString()) ?? 0) : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'last_read': lastRead,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt,
      'unread_count': unreadCount,
    };
  }

  bool get isGroup => type == 'group';
}

class ChatMessageModel {
  final int id;
  final int groupId;
  final int senderId;
  final String senderName;
  final String message;
  final String sentAt;

  ChatMessageModel({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.sentAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      groupId: json['group_id'] is int ? json['group_id'] : int.tryParse(json['group_id']?.toString() ?? '0') ?? 0,
      senderId: json['sender_id'] is int ? json['sender_id'] : int.tryParse(json['sender_id']?.toString() ?? '0') ?? 0,
      senderName: json['sender_name']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      sentAt: json['sent_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'sender_id': senderId,
      'sender_name': senderName,
      'message': message,
      'sent_at': sentAt,
    };
  }
}


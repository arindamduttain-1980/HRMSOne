class MeetingModel {
  final int id;
  final String title;
  final String? description;
  final String scheduledAt;
  final int durationMinutes;
  final String? location;
  final String organiserName;
  final String? myStatus;

  MeetingModel({
    required this.id,
    required this.title,
    this.description,
    required this.scheduledAt,
    required this.durationMinutes,
    this.location,
    required this.organiserName,
    this.myStatus,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      scheduledAt: json['scheduled_at']?.toString() ?? '',
      durationMinutes: json['duration_minutes'] != null ? (json['duration_minutes'] is int ? json['duration_minutes'] : int.tryParse(json['duration_minutes'].toString()) ?? 30) : 30,
      location: json['location']?.toString(),
      organiserName: json['organiser_name']?.toString() ?? 'Organiser',
      myStatus: json['my_status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'scheduled_at': scheduledAt,
      'duration_minutes': durationMinutes,
      'location': location,
      'organiser_name': organiserName,
      'my_status': myStatus,
    };
  }
}


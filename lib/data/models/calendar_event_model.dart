class CalendarEventModel {
  final int id;
  final String title;
  final String? description;
  final String eventDate;
  final String? startTime;
  final String? endTime;
  final String color;
  final String type;
  final bool allDay;

  CalendarEventModel({
    required this.id,
    required this.title,
    this.description,
    required this.eventDate,
    this.startTime,
    this.endTime,
    required this.color,
    required this.type,
    required this.allDay,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      eventDate: json['event_date']?.toString() ?? json['date']?.toString() ?? '',
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      color: json['color']?.toString() ?? '#1a56db',
      type: json['type']?.toString() ?? 'personal',
      allDay: json['all_day'] == 1 || json['all_day'] == true || json['all_day'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'event_date': eventDate,
      'start_time': startTime,
      'end_time': endTime,
      'color': color,
      'type': type,
      'all_day': allDay ? 1 : 0,
    };
  }
}


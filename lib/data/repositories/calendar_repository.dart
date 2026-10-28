import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/calendar_event_model.dart';

class CalendarRepository {
  final ApiClient _apiClient;

  CalendarRepository(this._apiClient);

  Future<List<CalendarEventModel>> getEvents({String? month}) async {
    final data = <String, dynamic>{};
    if (month != null && month.isNotEmpty) data['month'] = month;

    final response = await _apiClient.request(
      ApiConstants.actionCalendarList,
      data: data.isEmpty ? null : data,
    );
    final events = <CalendarEventModel>[];
    if (response['events'] is List) {
      for (final item in response['events']) {
        if (item is Map<String, dynamic>) {
          events.add(CalendarEventModel.fromJson(item));
        }
      }
    }
    return events;
  }

  Future<int> createEvent({
    required String title,
    String? description,
    required String eventDate,
    String? startTime,
    String? endTime,
    String? color,
    String? type,
    bool allDay = false,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'event_date': eventDate,
      'all_day': allDay ? 1 : 0,
    };
    if (description != null && description.isNotEmpty) data['description'] = description;
    if (!allDay && startTime != null && startTime.isNotEmpty) data['start_time'] = startTime;
    if (!allDay && endTime != null && endTime.isNotEmpty) data['end_time'] = endTime;
    if (color != null && color.isNotEmpty) data['color'] = color;
    if (type != null && type.isNotEmpty) data['type'] = type;

    final response = await _apiClient.request(ApiConstants.actionCalendarCreate, data: data);
    return response['id'] is int ? response['id'] : int.tryParse(response['id']?.toString() ?? '0') ?? 0;
  }

  Future<String> updateEvent({
    required int id,
    required String title,
    String? description,
    required String eventDate,
    String? startTime,
    String? endTime,
    String? color,
    String? type,
    bool allDay = false,
  }) async {
    final data = <String, dynamic>{
      'id': id,
      'title': title,
      'event_date': eventDate,
      'all_day': allDay ? 1 : 0,
    };
    if (description != null && description.isNotEmpty) data['description'] = description;
    if (!allDay && startTime != null && startTime.isNotEmpty) data['start_time'] = startTime;
    if (!allDay && endTime != null && endTime.isNotEmpty) data['end_time'] = endTime;
    if (color != null && color.isNotEmpty) data['color'] = color;
    if (type != null && type.isNotEmpty) data['type'] = type;

    final response = await _apiClient.request(ApiConstants.actionCalendarUpdate, data: data);
    return response['message']?.toString() ?? 'Event updated.';
  }

  Future<String> deleteEvent(int id) async {
    final response = await _apiClient.request(
      ApiConstants.actionCalendarDelete,
      data: {'id': id},
    );
    return response['message']?.toString() ?? 'Event deleted.';
  }
}


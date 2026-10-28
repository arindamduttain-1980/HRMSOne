import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/note_model.dart';

class NotesRepository {
  final ApiClient _apiClient;

  NotesRepository(this._apiClient);

  Future<List<NoteModel>> getNotes() async {
    final response = await _apiClient.request(ApiConstants.actionNotesList);
    final notes = <NoteModel>[];
    if (response['notes'] is List) {
      for (final item in response['notes']) {
        if (item is Map<String, dynamic>) {
          notes.add(NoteModel.fromJson(item));
        }
      }
    }
    return notes;
  }

  Future<int> createNote({
    String? title,
    required String content,
    String? color,
  }) async {
    final data = <String, dynamic>{'content': content};
    if (title != null && title.isNotEmpty) data['title'] = title;
    if (color != null && color.isNotEmpty) data['color'] = color;

    final response = await _apiClient.request(ApiConstants.actionNotesCreate, data: data);
    return response['id'] is int ? response['id'] : int.tryParse(response['id']?.toString() ?? '0') ?? 0;
  }

  Future<String> updateNote({
    required int id,
    String? title,
    required String content,
    String? color,
  }) async {
    final data = <String, dynamic>{'id': id, 'content': content};
    if (title != null) data['title'] = title;
    if (color != null && color.isNotEmpty) data['color'] = color;

    final response = await _apiClient.request(ApiConstants.actionNotesUpdate, data: data);
    return response['message']?.toString() ?? 'Note updated.';
  }

  Future<String> togglePin(int id) async {
    final response = await _apiClient.request(
      ApiConstants.actionNotesTogglePin,
      data: {'id': id},
    );
    return response['message']?.toString() ?? 'Note updated.';
  }

  Future<String> deleteNote(int id) async {
    final response = await _apiClient.request(
      ApiConstants.actionNotesDelete,
      data: {'id': id},
    );
    return response['message']?.toString() ?? 'Note deleted.';
  }
}


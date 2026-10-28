import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/ticket_model.dart';

class TicketThreadResult {
  final TicketModel? ticket;
  final List<TicketCommentModel> comments;

  TicketThreadResult({
    this.ticket,
    required this.comments,
  });
}

class TicketRepository {
  final ApiClient _apiClient;

  TicketRepository(this._apiClient);

  Future<List<TicketCategoryModel>> getCategories() async {
    final response = await _apiClient.request(ApiConstants.actionItCategoriesList);
    final list = <TicketCategoryModel>[];
    if (response['categories'] is List) {
      for (final item in response['categories']) {
        if (item is Map<String, dynamic>) {
          list.add(TicketCategoryModel.fromJson(item));
        }
      }
    }
    return list;
  }

  Future<List<TicketModel>> getTickets() async {
    final response = await _apiClient.request(ApiConstants.actionTicketsList);
    final list = <TicketModel>[];
    if (response['tickets'] is List) {
      for (final item in response['tickets']) {
        if (item is Map<String, dynamic>) {
          list.add(TicketModel.fromJson(item));
        }
      }
    }
    return list;
  }

  Future<Map<String, dynamic>> createTicket({
    required String title,
    required String description,
    int? categoryId,
    String priority = 'medium',
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'description': description,
      'priority': priority,
    };
    if (categoryId != null) data['category_id'] = categoryId;

    return await _apiClient.request(ApiConstants.actionTicketsCreate, data: data);
  }

  Future<TicketThreadResult> getComments(int ticketId) async {
    final response = await _apiClient.request(
      ApiConstants.actionTicketComments,
      data: {'ticket_id': ticketId},
    );

    TicketModel? ticket;
    if (response['ticket'] is Map<String, dynamic>) {
      ticket = TicketModel.fromJson(response['ticket'] as Map<String, dynamic>);
    }

    final comments = <TicketCommentModel>[];
    if (response['comments'] is List) {
      for (final item in response['comments']) {
        if (item is Map<String, dynamic>) {
          comments.add(TicketCommentModel.fromJson(item));
        }
      }
    }

    return TicketThreadResult(ticket: ticket, comments: comments);
  }

  Future<String> addComment(int ticketId, String comment) async {
    final response = await _apiClient.request(
      ApiConstants.actionTicketCommentAdd,
      data: {
        'ticket_id': ticketId,
        'comment': comment,
      },
    );
    return response['message']?.toString() ?? 'Comment added.';
  }
}


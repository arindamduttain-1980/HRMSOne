import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/crm_lead_model.dart';

class LeadDetailResult {
  final CrmLeadModel lead;
  final List<LeadHistoryModel> history;

  LeadDetailResult({
    required this.lead,
    required this.history,
  });
}

class CrmRepository {
  final ApiClient _apiClient;

  CrmRepository(this._apiClient);

  Future<List<CrmLeadModel>> getLeads({String? type, String? status}) async {
    final data = <String, dynamic>{};
    if (type != null && type.isNotEmpty && type != 'all') data['type'] = type;
    if (status != null && status.isNotEmpty && status != 'all') data['status'] = status;

    final response = await _apiClient.request(ApiConstants.actionLeadsList, data: data);
    final list = <CrmLeadModel>[];
    if (response['leads'] is List) {
      for (final item in response['leads']) {
        if (item is Map<String, dynamic>) {
          list.add(CrmLeadModel.fromJson(item));
        }
      }
    }
    return list;
  }

  Future<LeadDetailResult> getLeadDetail(int id) async {
    final response = await _apiClient.request(
      ApiConstants.actionLeadGet,
      data: {'id': id},
    );

    final leadJson = response['lead'] as Map<String, dynamic>? ?? {};
    final lead = CrmLeadModel.fromJson(leadJson);

    final history = <LeadHistoryModel>[];
    if (response['history'] is List) {
      for (final item in response['history']) {
        if (item is Map<String, dynamic>) {
          history.add(LeadHistoryModel.fromJson(item));
        }
      }
    }

    return LeadDetailResult(lead: lead, history: history);
  }

  Future<Map<String, dynamic>> createLead({
    required String name,
    String? company,
    String type = 'lead',
    String? email,
    String? phone,
    String? mobile,
    String? source,
    String priority = 'medium',
    double? dealValue,
    String? notes,
    int? assignedTo,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'type': type,
      'priority': priority,
    };
    if (company != null) data['company'] = company;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (mobile != null) data['mobile'] = mobile;
    if (source != null) data['source'] = source;
    if (dealValue != null) data['deal_value'] = dealValue;
    if (notes != null) data['notes'] = notes;
    if (assignedTo != null) data['assigned_to'] = assignedTo;

    return await _apiClient.request(ApiConstants.actionLeadCreate, data: data);
  }

  Future<String> updateLeadStatus({
    required int id,
    required String status,
    String? note,
  }) async {
    final data = <String, dynamic>{
      'id': id,
      'status': status,
    };
    if (note != null && note.isNotEmpty) data['note'] = note;

    final response = await _apiClient.request(ApiConstants.actionLeadUpdateStatus, data: data);
    return response['message']?.toString() ?? 'Status updated.';
  }

  Future<String> addLeadNote({
    required int id,
    required String note,
  }) async {
    final response = await _apiClient.request(
      ApiConstants.actionLeadNoteAdd,
      data: {
        'id': id,
        'note': note,
      },
    );
    return response['message']?.toString() ?? 'Note added.';
  }

  Future<List<SalesTeamMemberModel>> getSalesTeam() async {
    final response = await _apiClient.request(ApiConstants.actionSalesTeamList);
    final list = <SalesTeamMemberModel>[];
    if (response['team'] is List) {
      for (final item in response['team']) {
        if (item is Map<String, dynamic>) {
          list.add(SalesTeamMemberModel.fromJson(item));
        }
      }
    }
    return list;
  }
}


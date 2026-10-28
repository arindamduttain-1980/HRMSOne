class CrmLeadModel {
  final int id;
  final String leadNo;
  final String type; // lead, contact, opportunity
  final String name;
  final String? company;
  final String? email;
  final String? phone;
  final String? source;
  final String priority;
  final String status;
  final double dealValue;
  final int? assignedTo;
  final String? assignedName;
  final String updatedAt;

  CrmLeadModel({
    required this.id,
    required this.leadNo,
    required this.type,
    required this.name,
    this.company,
    this.email,
    this.phone,
    this.source,
    required this.priority,
    required this.status,
    required this.dealValue,
    this.assignedTo,
    this.assignedName,
    required this.updatedAt,
  });

  factory CrmLeadModel.fromJson(Map<String, dynamic> json) {
    return CrmLeadModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      leadNo: json['lead_no']?.toString() ?? '',
      type: json['type']?.toString() ?? 'lead',
      name: json['name']?.toString() ?? '',
      company: json['company']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      source: json['source']?.toString(),
      priority: json['priority']?.toString() ?? 'medium',
      status: json['status']?.toString() ?? 'new',
      dealValue: double.tryParse(json['deal_value']?.toString() ?? '0') ?? 0.0,
      assignedTo: json['assigned_to'] != null ? int.tryParse(json['assigned_to'].toString()) : null,
      assignedName: json['assigned_name']?.toString(),
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lead_no': leadNo,
      'type': type,
      'name': name,
      'company': company,
      'email': email,
      'phone': phone,
      'source': source,
      'priority': priority,
      'status': status,
      'deal_value': dealValue.toStringAsFixed(2),
      'assigned_to': assignedTo,
      'assigned_name': assignedName,
      'updated_at': updatedAt,
    };
  }
}

class LeadHistoryModel {
  final int id;
  final int leadId;
  final String action;
  final String? oldStatus;
  final String? newStatus;
  final String? note;
  final String doneByName;
  final String doneAt;

  LeadHistoryModel({
    required this.id,
    required this.leadId,
    required this.action,
    this.oldStatus,
    this.newStatus,
    this.note,
    required this.doneByName,
    required this.doneAt,
  });

  factory LeadHistoryModel.fromJson(Map<String, dynamic> json) {
    return LeadHistoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      leadId: json['lead_id'] is int ? json['lead_id'] : int.tryParse(json['lead_id']?.toString() ?? '0') ?? 0,
      action: json['action']?.toString() ?? '',
      oldStatus: json['old_status']?.toString(),
      newStatus: json['new_status']?.toString(),
      note: json['note']?.toString(),
      doneByName: json['done_by_name']?.toString() ?? 'User',
      doneAt: json['done_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lead_id': leadId,
      'action': action,
      'old_status': oldStatus,
      'new_status': newStatus,
      'note': note,
      'done_by_name': doneByName,
      'done_at': doneAt,
    };
  }
}

class SalesTeamMemberModel {
  final int id;
  final String name;

  SalesTeamMemberModel({
    required this.id,
    required this.name,
  });

  factory SalesTeamMemberModel.fromJson(Map<String, dynamic> json) {
    return SalesTeamMemberModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}


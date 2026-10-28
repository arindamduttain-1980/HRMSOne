class LeaveTypeModel {
  final int id;
  final String name;
  final String code;
  final int annualDays;
  final bool isPaid;
  final bool carryForward;

  LeaveTypeModel({
    required this.id,
    required this.name,
    required this.code,
    required this.annualDays,
    required this.isPaid,
    required this.carryForward,
  });

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      annualDays: json['annual_days'] != null ? (json['annual_days'] is int ? json['annual_days'] : int.tryParse(json['annual_days'].toString()) ?? 0) : 0,
      isPaid: json['is_paid'] == 1 || json['is_paid'] == true || json['is_paid'] == '1',
      carryForward: json['carry_forward'] == 1 || json['carry_forward'] == true || json['carry_forward'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'annual_days': annualDays,
      'is_paid': isPaid ? 1 : 0,
      'carry_forward': carryForward ? 1 : 0,
    };
  }
}

class LeaveApplicationModel {
  final int id;
  final int? employeeId;
  final int leaveTypeId;
  final String leaveTypeName;
  final String? leaveTypeCode;
  final String fromDate;
  final String toDate;
  final double days;
  final String reason;
  final String status;
  final String createdAt;

  LeaveApplicationModel({
    required this.id,
    this.employeeId,
    required this.leaveTypeId,
    required this.leaveTypeName,
    this.leaveTypeCode,
    required this.fromDate,
    required this.toDate,
    required this.days,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory LeaveApplicationModel.fromJson(Map<String, dynamic> json) {
    return LeaveApplicationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      employeeId: json['employee_id'] != null ? int.tryParse(json['employee_id'].toString()) : null,
      leaveTypeId: json['leave_type_id'] is int ? json['leave_type_id'] : int.tryParse(json['leave_type_id']?.toString() ?? '0') ?? 0,
      leaveTypeName: json['leave_type_name']?.toString() ?? 'Leave',
      leaveTypeCode: json['leave_type_code']?.toString(),
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      days: json['days'] != null ? (json['days'] is num ? (json['days'] as num).toDouble() : double.tryParse(json['days'].toString()) ?? 1.0) : 1.0,
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'leave_type_id': leaveTypeId,
      'leave_type_name': leaveTypeName,
      'leave_type_code': leaveTypeCode,
      'from_date': fromDate,
      'to_date': toDate,
      'days': days,
      'reason': reason,
      'status': status,
      'created_at': createdAt,
    };
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';
}


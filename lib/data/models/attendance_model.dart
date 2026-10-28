class AttendanceRecord {
  final int? id;
  final int? employeeId;
  final String date;
  final String? checkIn;
  final String? checkOut;
  final String status;
  final String? remarks;
  final double? hoursWorked;

  AttendanceRecord({
    this.id,
    this.employeeId,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.remarks,
    this.hoursWorked,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] != null ? (json['id'] is int ? json['id'] : int.tryParse(json['id'].toString())) : null,
      employeeId: json['employee_id'] != null ? (json['employee_id'] is int ? json['employee_id'] : int.tryParse(json['employee_id'].toString())) : null,
      date: json['date']?.toString() ?? '',
      checkIn: json['check_in']?.toString(),
      checkOut: json['check_out']?.toString(),
      status: json['status']?.toString() ?? 'not_checked_in',
      remarks: json['remarks']?.toString(),
      hoursWorked: json['hours_worked'] != null ? (json['hours_worked'] is num ? (json['hours_worked'] as num).toDouble() : double.tryParse(json['hours_worked'].toString())) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'date': date,
      'check_in': checkIn,
      'check_out': checkOut,
      'status': status,
      'remarks': remarks,
      'hours_worked': hoursWorked,
    };
  }

  bool get isCheckedIn => checkIn != null && checkIn!.isNotEmpty && (checkOut == null || checkOut!.isEmpty);
  bool get isCompleted => checkIn != null && checkIn!.isNotEmpty && checkOut != null && checkOut!.isNotEmpty;
  bool get isPresent => status == 'present';
  bool get isHalfDay => status == 'half_day';
  bool get isWFH => status == 'work_from_home';
}

class AttendanceStatusResponse {
  final AttendanceRecord? today;
  final List<AttendanceRecord> history;

  AttendanceStatusResponse({
    this.today,
    required this.history,
  });

  factory AttendanceStatusResponse.fromJson(Map<String, dynamic> json) {
    AttendanceRecord? todayRec;
    if (json['today'] is Map<String, dynamic>) {
      todayRec = AttendanceRecord.fromJson(json['today'] as Map<String, dynamic>);
    }

    final historyList = <AttendanceRecord>[];
    if (json['history'] is List) {
      for (final item in json['history']) {
        if (item is Map<String, dynamic>) {
          historyList.add(AttendanceRecord.fromJson(item));
        }
      }
    }

    return AttendanceStatusResponse(
      today: todayRec,
      history: historyList,
    );
  }
}


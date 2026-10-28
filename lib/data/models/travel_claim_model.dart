class TravelClaimModel {
  final int id;
  final int? employeeId;
  final String claimDate;
  final String travelDate;
  final String fromPlace;
  final String toPlace;
  final String purpose;
  final String travelType;
  final String mode;
  final double distanceKm;
  final double ratePerKm;
  final double kmAmount;
  final double ticketAmount;
  final double otherExpense;
  final double totalAmount;
  final String status;

  TravelClaimModel({
    required this.id,
    this.employeeId,
    required this.claimDate,
    required this.travelDate,
    required this.fromPlace,
    required this.toPlace,
    required this.purpose,
    required this.travelType,
    required this.mode,
    required this.distanceKm,
    required this.ratePerKm,
    required this.kmAmount,
    required this.ticketAmount,
    required this.otherExpense,
    required this.totalAmount,
    required this.status,
  });

  factory TravelClaimModel.fromJson(Map<String, dynamic> json) {
    return TravelClaimModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      employeeId: json['employee_id'] != null ? int.tryParse(json['employee_id'].toString()) : null,
      claimDate: json['claim_date']?.toString() ?? '',
      travelDate: json['travel_date']?.toString() ?? '',
      fromPlace: json['from_place']?.toString() ?? '',
      toPlace: json['to_place']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? '',
      travelType: json['travel_type']?.toString() ?? 'local',
      mode: json['mode']?.toString() ?? 'own_vehicle',
      distanceKm: double.tryParse(json['distance_km']?.toString() ?? '0') ?? 0.0,
      ratePerKm: double.tryParse(json['rate_per_km']?.toString() ?? '0') ?? 0.0,
      kmAmount: double.tryParse(json['km_amount']?.toString() ?? '0') ?? 0.0,
      ticketAmount: double.tryParse(json['ticket_amount']?.toString() ?? '0') ?? 0.0,
      otherExpense: double.tryParse(json['other_expense']?.toString() ?? '0') ?? 0.0,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'claim_date': claimDate,
      'travel_date': travelDate,
      'from_place': fromPlace,
      'to_place': toPlace,
      'purpose': purpose,
      'travel_type': travelType,
      'mode': mode,
      'distance_km': distanceKm,
      'rate_per_km': ratePerKm,
      'km_amount': kmAmount,
      'ticket_amount': ticketAmount,
      'other_expense': otherExpense,
      'total_amount': totalAmount,
      'status': status,
    };
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}


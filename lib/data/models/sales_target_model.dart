class SalesTargetModel {
  final int month;
  final int year;
  final double targetValue;
  final int targetQty;
  final String? assignedByName;
  final double achievedValue;
  final int achievedQty;

  SalesTargetModel({
    required this.month,
    required this.year,
    required this.targetValue,
    required this.targetQty,
    this.assignedByName,
    required this.achievedValue,
    required this.achievedQty,
  });

  factory SalesTargetModel.fromJson(Map<String, dynamic> json) {
    final targetMap = json['target'] is Map<String, dynamic> ? json['target'] as Map<String, dynamic> : {};
    final achievedMap = json['achieved'] is Map<String, dynamic> ? json['achieved'] as Map<String, dynamic> : {};

    return SalesTargetModel(
      month: json['month'] is int ? json['month'] : int.tryParse(json['month']?.toString() ?? '1') ?? 1,
      year: json['year'] is int ? json['year'] : int.tryParse(json['year']?.toString() ?? '2026') ?? 2026,
      targetValue: double.tryParse(targetMap['target_value']?.toString() ?? json['target_value']?.toString() ?? '0') ?? 0.0,
      targetQty: int.tryParse(targetMap['target_qty']?.toString() ?? json['target_qty']?.toString() ?? '0') ?? 0,
      assignedByName: targetMap['assigned_by_name']?.toString(),
      achievedValue: double.tryParse(achievedMap['val']?.toString() ?? json['achieved_value']?.toString() ?? '0') ?? 0.0,
      achievedQty: int.tryParse(achievedMap['qty']?.toString() ?? json['achieved_qty']?.toString() ?? '0') ?? 0,
    );
  }

  double get valueProgress => targetValue > 0 ? (achievedValue / targetValue).clamp(0.0, 1.0) : 0.0;
  double get qtyProgress => targetQty > 0 ? (achievedQty / targetQty).clamp(0.0, 1.0) : 0.0;
}


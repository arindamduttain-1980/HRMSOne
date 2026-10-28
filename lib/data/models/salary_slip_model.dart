class SalarySlipSummaryModel {
  final int id;
  final int month;
  final int year;
  final double grossSalary;
  final double totalDeductions;
  final double netSalary;
  final String status;
  final String? paidDate;

  SalarySlipSummaryModel({
    required this.id,
    required this.month,
    required this.year,
    required this.grossSalary,
    required this.totalDeductions,
    required this.netSalary,
    required this.status,
    this.paidDate,
  });

  factory SalarySlipSummaryModel.fromJson(Map<String, dynamic> json) {
    return SalarySlipSummaryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      month: json['month'] is int ? json['month'] : int.tryParse(json['month']?.toString() ?? '1') ?? 1,
      year: json['year'] is int ? json['year'] : int.tryParse(json['year']?.toString() ?? '2026') ?? 2026,
      grossSalary: double.tryParse(json['gross_salary']?.toString() ?? '0') ?? 0.0,
      totalDeductions: double.tryParse(json['total_deductions']?.toString() ?? '0') ?? 0.0,
      netSalary: double.tryParse(json['net_salary']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'paid',
      paidDate: json['paid_date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'month': month,
      'year': year,
      'gross_salary': grossSalary.toStringAsFixed(2),
      'total_deductions': totalDeductions.toStringAsFixed(2),
      'net_salary': netSalary.toStringAsFixed(2),
      'status': status,
      'paid_date': paidDate,
    };
  }
}

class SalarySlipDetailModel {
  final int id;
  final int? employeeId;
  final String name;
  final String empCode;
  final String designation;
  final int month;
  final int year;
  final double basicSalary;
  final double hra;
  final double specialAllowance;
  final double grossSalary;
  final double pfEmployee;
  final double esiEmployee;
  final double professionalTax;
  final double tds;
  final double totalDeductions;
  final double netSalary;
  final String? bankName;
  final String? bankAccount;
  final String? bankIfsc;
  final String? pan;

  SalarySlipDetailModel({
    required this.id,
    this.employeeId,
    required this.name,
    required this.empCode,
    required this.designation,
    required this.month,
    required this.year,
    required this.basicSalary,
    required this.hra,
    required this.specialAllowance,
    required this.grossSalary,
    required this.pfEmployee,
    required this.esiEmployee,
    required this.professionalTax,
    required this.tds,
    required this.totalDeductions,
    required this.netSalary,
    this.bankName,
    this.bankAccount,
    this.bankIfsc,
    this.pan,
  });

  factory SalarySlipDetailModel.fromJson(Map<String, dynamic> json) {
    return SalarySlipDetailModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      employeeId: json['employee_id'] != null ? int.tryParse(json['employee_id'].toString()) : null,
      name: json['name']?.toString() ?? '',
      empCode: json['emp_code']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      month: json['month'] is int ? json['month'] : int.tryParse(json['month']?.toString() ?? '1') ?? 1,
      year: json['year'] is int ? json['year'] : int.tryParse(json['year']?.toString() ?? '2026') ?? 2026,
      basicSalary: double.tryParse(json['basic_salary']?.toString() ?? '0') ?? 0.0,
      hra: double.tryParse(json['hra']?.toString() ?? '0') ?? 0.0,
      specialAllowance: double.tryParse(json['special_allowance']?.toString() ?? '0') ?? 0.0,
      grossSalary: double.tryParse(json['gross_salary']?.toString() ?? '0') ?? 0.0,
      pfEmployee: double.tryParse(json['pf_employee']?.toString() ?? '0') ?? 0.0,
      esiEmployee: double.tryParse(json['esi_employee']?.toString() ?? '0') ?? 0.0,
      professionalTax: double.tryParse(json['professional_tax']?.toString() ?? '0') ?? 0.0,
      tds: double.tryParse(json['tds']?.toString() ?? '0') ?? 0.0,
      totalDeductions: double.tryParse(json['total_deductions']?.toString() ?? '0') ?? 0.0,
      netSalary: double.tryParse(json['net_salary']?.toString() ?? '0') ?? 0.0,
      bankName: json['bank_name']?.toString(),
      bankAccount: json['bank_account']?.toString(),
      bankIfsc: json['bank_ifsc']?.toString(),
      pan: json['pan']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'name': name,
      'emp_code': empCode,
      'designation': designation,
      'month': month,
      'year': year,
      'basic_salary': basicSalary.toStringAsFixed(2),
      'hra': hra.toStringAsFixed(2),
      'special_allowance': specialAllowance.toStringAsFixed(2),
      'gross_salary': grossSalary.toStringAsFixed(2),
      'pf_employee': pfEmployee.toStringAsFixed(2),
      'esi_employee': esiEmployee.toStringAsFixed(2),
      'professional_tax': professionalTax.toStringAsFixed(2),
      'tds': tds.toStringAsFixed(2),
      'total_deductions': totalDeductions.toStringAsFixed(2),
      'net_salary': netSalary.toStringAsFixed(2),
      'bank_name': bankName,
      'bank_account': bankAccount,
      'bank_ifsc': bankIfsc,
      'pan': pan,
    };
  }
}


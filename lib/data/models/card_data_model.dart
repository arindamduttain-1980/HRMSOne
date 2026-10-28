class EmployeeCardModel {
  final String empCode;
  final String name;
  final String designation;
  final String? department;
  final String? phone;
  final String? email;
  final String? joinDate;
  final String? tagline;
  final String? bloodGroup;
  final String? emergencyContact;
  final String? emergencyName;
  final String? photoUrl;
  final String? shareUrl;

  EmployeeCardModel({
    required this.empCode,
    required this.name,
    required this.designation,
    this.department,
    this.phone,
    this.email,
    this.joinDate,
    this.tagline,
    this.bloodGroup,
    this.emergencyContact,
    this.emergencyName,
    this.photoUrl,
    this.shareUrl,
  });

  factory EmployeeCardModel.fromJson(Map<String, dynamic> json) {
    return EmployeeCardModel(
      empCode: json['emp_code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      department: json['department']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      joinDate: json['join_date']?.toString(),
      tagline: json['tagline']?.toString(),
      bloodGroup: json['blood_group']?.toString(),
      emergencyContact: json['emergency_contact']?.toString(),
      emergencyName: json['emergency_name']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      shareUrl: json['share_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emp_code': empCode,
      'name': name,
      'designation': designation,
      'department': department,
      'phone': phone,
      'email': email,
      'join_date': joinDate,
      'tagline': tagline,
      'blood_group': bloodGroup,
      'emergency_contact': emergencyContact,
      'emergency_name': emergencyName,
      'photo_url': photoUrl,
      'share_url': shareUrl,
    };
  }

  EmployeeCardModel copyWith({
    String? tagline,
    String? bloodGroup,
    String? emergencyContact,
    String? emergencyName,
  }) {
    return EmployeeCardModel(
      empCode: empCode,
      name: name,
      designation: designation,
      department: department,
      phone: phone,
      email: email,
      joinDate: joinDate,
      tagline: tagline ?? this.tagline,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyName: emergencyName ?? this.emergencyName,
      photoUrl: photoUrl,
      shareUrl: shareUrl,
    );
  }
}

class CompanyCardModel {
  final String name;
  final String? address;
  final String? phone;
  final String? email;
  final String? gstin;
  final String? logoUrl;

  CompanyCardModel({
    required this.name,
    this.address,
    this.phone,
    this.email,
    this.gstin,
    this.logoUrl,
  });

  factory CompanyCardModel.fromJson(Map<String, dynamic> json) {
    return CompanyCardModel(
      name: json['name']?.toString() ?? 'Aavenza Industries',
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      gstin: json['gstin']?.toString(),
      logoUrl: json['logo_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'gstin': gstin,
      'logo_url': logoUrl,
    };
  }
}

class DigitalCardDataModel {
  final EmployeeCardModel employee;
  final CompanyCardModel company;

  DigitalCardDataModel({
    required this.employee,
    required this.company,
  });

  factory DigitalCardDataModel.fromJson(Map<String, dynamic> json) {
    return DigitalCardDataModel(
      employee: EmployeeCardModel.fromJson(json['employee'] as Map<String, dynamic>? ?? {}),
      company: CompanyCardModel.fromJson(json['company'] as Map<String, dynamic>? ?? {}),
    );
  }
}


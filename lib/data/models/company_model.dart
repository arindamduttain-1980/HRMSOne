class CompanyModel {
  final int id;
  final String companyName;
  final String baseUrl;
  final String? companyLogo;

  const CompanyModel({
    required this.id,
    required this.companyName,
    required this.baseUrl,
    this.companyLogo,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      companyName: json['company_name']?.toString() ?? '',
      baseUrl: json['base_url']?.toString() ?? '',
      companyLogo: json['company_logo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_name': companyName,
        'base_url': baseUrl,
        'company_logo': companyLogo,
      };

  String get displayName {
    if (companyName.isEmpty) return 'Select Company';
    if (companyName.toLowerCase() == 'aavenzaone') return 'AavenzaOne';
    // Capitalize each word
    return companyName
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CompanyModel(id: $id, name: $companyName, baseUrl: $baseUrl)';
}


class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String designation;
  final String? photoUrl;
  final int face;
  final String userFace;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.designation,
    this.photoUrl,
    this.face = 0,
    this.userFace = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString(),
      face: json['face'] is int
          ? json['face'] as int
          : int.tryParse(json['face']?.toString() ?? '0') ?? 0,
      userFace: json['user_face']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'designation': designation,
      'photo_url': photoUrl,
      'face': face,
      'user_face': userFace,
    };
  }

  bool get isFaceRegistered => face == 1;

  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? designation,
    String? photoUrl,
    int? face,
    String? userFace,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      designation: designation ?? this.designation,
      photoUrl: photoUrl ?? this.photoUrl,
      face: face ?? this.face,
      userFace: userFace ?? this.userFace,
    );
  }
}

class UserModel {
  final int id;
  final String username;
  final String email;
  final bool isStaff;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.isStaff,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as int,
    username: json['username'] as String,
    email: json['email'] as String? ?? '',
    isStaff: json['is_staff'] as bool? ?? false,
    isActive: json['is_active'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'is_staff': isStaff,
    'is_active': isActive,
  };
}

class User {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String phone;
  final String profileImageUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.phone,
    required this.profileImageUrl,
    required this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      fullName: data['full_name'],
      email: data['email'],
      role: data['role'],
      phone: data['phone'],
      profileImageUrl: data['profile_image_url'],
      createdAt: DateTime.parse(data['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role,
      'phone': phone,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
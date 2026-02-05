class User {
  final int id;
  final String username;
  final String role;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.username,
    required this.role,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      username: json['username'],
      role: json['role'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  bool get isAdmin => role == 'admin';
}

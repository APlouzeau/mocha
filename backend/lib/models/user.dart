class User {
  final int? id;           
  final String username;
  final String email;
  final String passwordHash;
  final DateTime? createdAt;
  
  User({
    this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    this.createdAt,
  });
  
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      username: map['username'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'].toString())
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
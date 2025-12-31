class User {
  final int? id;           
  final String nickName;
  final String email;
  final String passwordHash;
  final int roleId;
  final DateTime? createdAt;
  
  User({
    this.id,
    required this.nickName,
    required this.email,
    required this.passwordHash,
    this.roleId = 1, // Par défaut: role 'user'
    this.createdAt,
  });
  
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      nickName: map['nick_name'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      roleId: map['role_id'] as int? ?? 1,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'].toString())
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickName': nickName,
      'email': email,
      'roleId': roleId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
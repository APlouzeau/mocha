class UserModel {
  final int id;
  final String nickName;
  final String email;
  final int roleId;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.nickName,
    required this.email,
    required this.roleId,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      nickName: json['nickName'] as String,
      email: json['email'] as String,
      roleId: json['roleId'] as int? ?? 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickName': nickName,
      'email': email,
      'roleId': roleId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

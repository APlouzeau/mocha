class ArticleModel {
  final int id;
  final String title;
  final String content;
  final int user_id;
  final DateTime created_At;

  UserModel({
    required this.id,
    required this.title,
    required this.content,
    required this.user_id,
    required this.created_at,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      user_id: json['user_id'] as int,
      created_at: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'user_id': user_id,
      'created_at': created_at.toIso8601String(),
    };
  }
}

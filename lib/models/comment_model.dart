class CommentModel {
  final int id;
  final String comment;
  final int article_id;
  final int user_id;
  final DateTime created_At;

  CommentModel({
    required this.id,
    required this.comment,
    required this.article_id,
    required this.user_id,
    required this.created_at,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as int,
      comment: json['comment'] as String,
      article_id: json['article_id'] as int,
      user_id: json['user_id'] as int,
      created_at: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comment': comment,
      'article_id': article_id,
      'user_id': user_id,
      'created_at': created_at.toIso8601String(),
    };
  }
}

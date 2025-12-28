class Article {
  final int id;
  final String title;
  final String content;
  final int user_id;
  final DateTime created_at;
  
  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.user_id,
    required this.created_at,
  });
  
  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'] as int,
      title: map['title'] as String,
      content: map['content'] as String,
      user_id: map['user_id'] as int,
      created_at: DateTime.parse(map['created_at'].toString()),
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
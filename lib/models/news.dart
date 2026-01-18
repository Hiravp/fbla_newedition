class News {
  final String id;
  final String title;
  final String content;
  final String category;
  final DateTime publishedDate;
  final String author;
  final String imageUrl;
  final int views;

  News({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.publishedDate,
    required this.author,
    this.imageUrl = '',
    this.views = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'publishedDate': publishedDate.toIso8601String(),
      'author': author,
      'imageUrl': imageUrl,
      'views': views,
    };
  }

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      publishedDate: DateTime.parse(json['publishedDate'] as String),
      author: json['author'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      views: json['views'] as int? ?? 0,
    );
  }
}

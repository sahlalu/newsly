class ArticleModel {
  final String? author;
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final String publishedAt;
  final String? content;

  ArticleModel({
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    this.content,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      author: json["author"],
      title: json["title"] ?? "",
      description: json["description"],
      url: json["url"] ?? "",
      urlToImage: json["urlToImage"],
      publishedAt: json["publishedAt"] ?? "",
      content: json["content"],
    );
  }
}

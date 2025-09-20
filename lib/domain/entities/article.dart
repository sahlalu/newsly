class Article {
  final String title;
  final String url;
  final String? imageUrl;
  final String? description;
  final String? content;
  final String? author;
  final String publishedAt;

  Article({
    required this.title,
    required this.url,
    this.imageUrl,
    this.description,
    this.content,
    this.author,
    required this.publishedAt,
  });

  // Helper method to get formatted published date
  DateTime? get publishedDateTime {
    try {
      return DateTime.parse(publishedAt);
    } catch (e) {
      return null;
    }
  }

  // Helper method to check if article has image
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  // Helper method to get clean content preview
  String get contentPreview {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }
    if (content != null && content!.isNotEmpty) {
      // Remove source attribution that usually appears at the end
      String cleanContent = content!;
      final sourceIndex = cleanContent.lastIndexOf('[');
      if (sourceIndex > 0) {
        cleanContent = cleanContent.substring(0, sourceIndex).trim();
      }
      return cleanContent.length > 200
          ? "${cleanContent.substring(0, 200)}..."
          : cleanContent;
    }
    return "";
  }
}
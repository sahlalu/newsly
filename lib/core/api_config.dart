class ApiConfig {
  static const String baseUrl = "https://newsapi.org/v2";
  static const String apiKey = "d998429edc534e09947e10b2513eba55";

  // Top Headlines endpoint
  static String topHeadlines({
    String category = "technology",
    int page = 1,
    int pageSize = 10
  }) {
    return "$baseUrl/top-headlines?country=us&category=$category&page=$page&pageSize=$pageSize&apiKey=$apiKey";
  }

  // Search Everything endpoint
  static String searchEverything({
    required String query,
    int page = 1,
    int pageSize = 20,
    String sortBy = "publishedAt",
    String language = "en",
  }) {
    final encodedQuery = Uri.encodeComponent(query);
    return "$baseUrl/everything?q=$encodedQuery&page=$page&pageSize=$pageSize&sortBy=$sortBy&language=$language&apiKey=$apiKey";
  }

  // Sources endpoint (for future use)
  static String sources({
    String? category,
    String language = "en",
    String country = "us",
  }) {
    String url = "$baseUrl/sources?language=$language&country=$country&apiKey=$apiKey";
    if (category != null) {
      url += "&category=$category";
    }
    return url;
  }

  // Category-specific headlines
  static String headlinesByCategory({
    required String category,
    int page = 1,
    int pageSize = 20,
  }) {
    return "$baseUrl/top-headlines?country=us&category=$category&page=$page&pageSize=$pageSize&apiKey=$apiKey";
  }
}
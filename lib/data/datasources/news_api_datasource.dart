import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import '../models/article_model.dart';


class NewsApiDataSource {
  // Fetch top headlines by category
  Future<List<ArticleModel>> fetchTopHeadlines({
    String category = "technology",
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await http.get(
      Uri.parse(ApiConfig.topHeadlines(
        category: category,
        page: page,
        pageSize: pageSize,
      )),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final articles = (body["articles"] as List)
          .map((json) => ArticleModel.fromJson(json))
          .where((article) => article.title != "[Removed]") // Filter removed articles
          .toList();
      return articles;
    } else {
      throw Exception("Failed to load news: ${response.statusCode}");
    }
  }

  // Search articles by query
  Future<List<ArticleModel>> searchArticles({
    required String query,
    int page = 1,
    int pageSize = 20,
    String sortBy = "publishedAt",
  }) async {
    final response = await http.get(
      Uri.parse(ApiConfig.searchEverything(
        query: query,
        page: page,
        pageSize: pageSize,
        sortBy: sortBy,
      )),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      if (body["status"] == "error") {
        throw Exception(body["message"] ?? "Search failed");
      }

      final articles = (body["articles"] as List)
          .map((json) => ArticleModel.fromJson(json))
          .where((article) =>
      article.title != "[Removed]" &&
          article.url.isNotEmpty &&
          !article.title.toLowerCase().contains("removed")
      )
          .toList();
      return articles;
    } else {
      throw Exception("Failed to search articles: ${response.statusCode}");
    }
  }

  // Fetch articles by specific category with pagination
  Future<List<ArticleModel>> fetchCategoryNews({
    required String category,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await http.get(
      Uri.parse(ApiConfig.headlinesByCategory(
        category: category,
        page: page,
        pageSize: pageSize,
      )),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final articles = (body["articles"] as List)
          .map((json) => ArticleModel.fromJson(json))
          .where((article) => article.title != "[Removed]")
          .toList();
      return articles;
    } else {
      throw Exception("Failed to load category news: ${response.statusCode}");
    }
  }

  // Fetch sources (for future features)
  Future<List<Map<String, dynamic>>> fetchSources({
    String? category,
  }) async {
    final response = await http.get(
      Uri.parse(ApiConfig.sources(category: category)),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return (body["sources"] as List).cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to load sources: ${response.statusCode}");
    }
  }
}
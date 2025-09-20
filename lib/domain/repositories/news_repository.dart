import '../entities/article.dart';

abstract class NewsRepository {
  Future<List<Article>> getTopHeadlines({String category});

  Future<List<Article>> searchArticles({
    required String query,
    int page = 1,
    int pageSize = 20,
  });

  Future<List<Article>> getCategoryNews({
    required String category,
    int page = 1,
    int pageSize = 20,
  });
}
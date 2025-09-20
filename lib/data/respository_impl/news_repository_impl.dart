import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_api_datasource.dart';
import '../models/article_model.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsApiDataSource dataSource;

  NewsRepositoryImpl(this.dataSource);

  @override
  Future<List<Article>> getTopHeadlines({String category = "technology"}) async {
    final models = await dataSource.fetchTopHeadlines(category: category);
    return models.map((m) => _mapToEntity(m)).toList();
  }

  @override
  Future<List<Article>> searchArticles({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    final models = await dataSource.searchArticles(
      query: query,
      page: page,
      pageSize: pageSize,
    );
    return models.map((m) => _mapToEntity(m)).toList();
  }

  @override
  Future<List<Article>> getCategoryNews({
    required String category,
    int page = 1,
    int pageSize = 20,
  }) async {
    final models = await dataSource.fetchCategoryNews(
      category: category,
      page: page,
      pageSize: pageSize,
    );
    return models.map((m) => _mapToEntity(m)).toList();
  }

  Article _mapToEntity(ArticleModel model) {
    return Article(
      title: model.title,
      url: model.url,
      imageUrl: model.urlToImage,
      description: model.description,
      content: model.content,
      author: model.author,
      publishedAt: model.publishedAt,
    );
  }
}
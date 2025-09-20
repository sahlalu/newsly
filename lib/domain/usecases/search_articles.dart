import '../entities/article.dart';
import '../repositories/news_repository.dart';

class SearchArticles {
  final NewsRepository repository;

  SearchArticles(this.repository);

  Future<List<Article>> call({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) {
    return repository.searchArticles(
      query: query,
      page: page,
      pageSize: pageSize,
    );
  }
}
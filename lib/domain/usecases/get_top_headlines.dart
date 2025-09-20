import '../entities/article.dart';
import '../repositories/news_repository.dart';

class GetTopHeadlines {
  final NewsRepository repository;

  GetTopHeadlines(this.repository);

  Future<List<Article>> call({String category = "technology"}) {
    return repository.getTopHeadlines(category: category);
  }
}

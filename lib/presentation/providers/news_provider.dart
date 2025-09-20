import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/news_api_datasource.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/usecases/get_top_headlines.dart';
import '../../data/respository_impl/news_repository_impl.dart';


final newsRepositoryProvider = Provider((ref) {
  return NewsRepositoryImpl(NewsApiDataSource());
});

final getTopHeadlinesProvider = Provider((ref) {
  return GetTopHeadlines(ref.read(newsRepositoryProvider));
});

// articles provider with Async state
final newsArticlesProvider = FutureProvider.autoDispose<List<Article>>((ref) async {
  final usecase = ref.read(getTopHeadlinesProvider);
  return usecase.call(category: "technology");
});

//category news provider
final categoryNewsProvider = FutureProvider.family<List<Article>, String>((ref, category) async {
  final usecase = ref.read(getTopHeadlinesProvider);
  return usecase.call(category: category);
});

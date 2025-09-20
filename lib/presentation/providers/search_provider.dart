import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:news_app/presentation/providers/news_provider.dart';
import '../../../domain/entities/article.dart';
import '../../domain/usecases/search_articles.dart';


// Search query state provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Search articles use case provider
final searchArticlesProvider = Provider((ref) {
  return SearchArticles(ref.read(newsRepositoryProvider));
});

// Search results provider
final searchResultsProvider = FutureProvider<List<Article>>((ref) async {
  final query = ref.watch(searchQueryProvider);

  if (query.isEmpty) {
    return <Article>[];
  }

  final searchUseCase = ref.read(searchArticlesProvider);
  return searchUseCase.call(query: query);
});

// Recent news provider for search screen initial state
final recentNewsProvider = FutureProvider<List<Article>>((ref) async {
  final usecase = ref.read(getTopHeadlinesProvider);
  return usecase.call(category: "general");
});
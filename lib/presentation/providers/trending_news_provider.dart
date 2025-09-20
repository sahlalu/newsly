import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/presentation/providers/news_provider.dart';
import '../../../domain/entities/article.dart';


// Top Stories Provider (Top Headlines)
final topStoriesProvider = FutureProvider<List<Article>>((ref) async {
  final usecase = ref.read(getTopHeadlinesProvider);
  return usecase.call(category: "general");
});

// Hot Topics Provider (Technology + Business combined)
final hotTopicsProvider = FutureProvider<List<Article>>((ref) async {
  final usecase = ref.read(getTopHeadlinesProvider);

  // Fetch from multiple categories for variety
  final techArticles = await usecase.call(category: "technology");
  final businessArticles = await usecase.call(category: "business");

  // Combine and shuffle for hot topics effect
  final combined = [...techArticles.take(5), ...businessArticles.take(5)];
  combined.shuffle();

  return combined;
});

// Most Read Provider (Sports + Entertainment)
final mostReadProvider = FutureProvider<List<Article>>((ref) async {
  final usecase = ref.read(getTopHeadlinesProvider);

  // Fetch popular categories for "most read" simulation
  final sportsArticles = await usecase.call(category: "sports");
  final entertainmentArticles = await usecase.call(category: "entertainment");

  // Combine for most read simulation
  final combined = [...sportsArticles.take(5), ...entertainmentArticles.take(5)];

  return combined;
});
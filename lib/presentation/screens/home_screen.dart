import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/widgets/card_shimmer.dart';
import 'package:news_app/widgets/category_card.dart';
import 'package:news_app/components/news_card.dart';
import 'package:news_app/presentation/providers/news_provider.dart';
import '../../domain/entities/article.dart';
import '../screens/article_screen.dart';
import 'category_page.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsArticlesProvider);
    final categoryNewsAsync = ref.watch(categoryNewsProvider('general'));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(newsArticlesProvider);
        ref.invalidate(categoryNewsProvider('general'));
      },
      child: CustomScrollView(
        slivers: [
          // Top Headlines Carousel
          SliverToBoxAdapter(
            child: _buildTopHeadlinesSection(context, newsAsync, ref),
          ),

          // Category Grid
          SliverToBoxAdapter(child: _buildCategoryGrid(context)),

          // Breaking News Badge
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Latest Updates',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Navigate to all news
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
          ),

          // News List
          categoryNewsAsync.when(
            data: (articles) {
              if (articles.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.newspaper, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No news available',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final article = articles[index];
                  return NewsCard(
                    article: article,
                    onTap: () => _navigateToArticle(context, article),
                  );
                }, childCount: articles.length > 10 ? 10 : articles.length),
              );
            },
            loading:
                () => SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const NewsCardShimmer(),
                    childCount: 5,
                  ),
                ),
            error:
                (err, _) => SliverFillRemaining(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Unable to load news',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please check your internet connection\nand try again',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed:
                                () => ref.invalidate(
                                  categoryNewsProvider('general'),
                                ),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildTopHeadlinesSection(
    BuildContext context,
    AsyncValue<List<Article>> newsAsync,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(Icons.trending_up, color: Colors.orange, size: 24),
              SizedBox(width: 8),
              Text(
                'Trending Headlines',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: newsAsync.when(
            data: (articles) {
              if (articles.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.newspaper_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No headlines available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              return PageView.builder(
                controller: PageController(viewportFraction: 0.9),
                itemCount: articles.length > 5 ? 5 : articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 8,
                    ),
                    child: NewsCard(
                      article: article,
                      isHorizontal: true,
                      onTap: () => _navigateToArticle(context, article),
                    ),
                  );
                },
              );
            },
            loading:
                () => PageView.builder(
                  controller: PageController(viewportFraction: 0.9),
                  itemCount: 3,
                  itemBuilder:
                      (context, index) => Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 8,
                        ),
                        child: const NewsCardShimmerHorizontal(),
                      ),
                ),
            error:
                (err, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade400,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Failed to load headlines',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          ref.invalidate(newsArticlesProvider);
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    final categories = [
      {
        'id': 'general',
        'name': 'General',
        'icon': Icons.public,
        'color': Colors.blue,
      },
      {
        'id': 'technology',
        'name': 'Technology',
        'icon': Icons.computer,
        'color': Colors.purple,
      },
      {
        'id': 'business',
        'name': 'Business',
        'icon': Icons.business,
        'color': Colors.green,
      },
      {
        'id': 'sports',
        'name': 'Sports',
        'icon': Icons.sports_soccer,
        'color': Colors.orange,
      },
      {
        'id': 'entertainment',
        'name': 'Movies',
        'icon': Icons.movie,
        'color': Colors.pink,
      },
      {
        'id': 'health',
        'name': 'Health',
        'icon': Icons.local_hospital,
        'color': Colors.red,
      },
      {
        'id': 'science',
        'name': 'Science',
        'icon': Icons.science,
        'color': Colors.teal,
      },
      {
        'id': 'world',
        'name': 'World',
        'icon': Icons.language,
        'color': Colors.indigo,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            children: [
              Icon(Icons.category, color: Colors.blue, size: 24),
              SizedBox(width: 8),
              Text(
                'Explore Categories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryCard(
                category: category,
                onTap: () => _navigateToCategory(context, category),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _navigateToArticle(BuildContext context, Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ArticleScreen(article: article)),
    );
  }

  void _navigateToCategory(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => CategoryScreen(
              categoryId: category['id'] as String,
              categoryName: category['name'] as String,
              categoryIcon: category['icon'] as IconData,
              categoryColor: category['color'] as Color,
            ),
      ),
    );
  }
}

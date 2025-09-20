import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/presentation/screens/article_screen.dart';
import '../../../domain/entities/article.dart';
import '../../widgets/card_shimmer.dart';
import '../providers/trending_news_provider.dart';

class TrendingScreen extends ConsumerStatefulWidget {
  const TrendingScreen({super.key});

  @override
  ConsumerState<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends ConsumerState<TrendingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme
                  .of(context)
                  .primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Theme
                  .of(context)
                  .primaryColor,
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  icon: Icon(Icons.trending_up),
                  text: 'Top Stories',
                ),
                Tab(
                  icon: Icon(Icons.local_fire_department),
                  text: 'Hot Topics',
                ),
                Tab(
                  icon: Icon(Icons.star),
                  text: 'Most Read',
                ),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Top Stories Tab
                _buildTopStoriesTab(),

                // Hot Topics Tab
                _buildHotTopicsTab(),

                // Most Read Tab
                _buildMostReadTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStoriesTab() {
    final topStoriesAsync = ref.watch(topStoriesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(topStoriesProvider);
      },
      child: topStoriesAsync.when(
        data: (articles) {
          if (articles.isEmpty) {
            return const EmptyStateWidget(
              title: "No Top Stories",
              subtitle: "There are no trending stories available right now.",
              icon: Icons.trending_up,
            );
          }

          return CustomScrollView(
            slivers: [
              // Featured Story (First Article)
              SliverToBoxAdapter(
                child: _buildFeaturedStory(articles.first),
              ),

              // Trending Numbers Section
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    "Top Stories Today",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Numbered List of Stories
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final article = articles[index + 1];
                    return _buildNumberedNewsCard(article, index + 2);
                  },
                  childCount: articles.length > 10 ? 9 : articles.length - 1,
                ),
              ),
            ],
          );
        },
        loading: () =>
            ListView.builder(
              itemCount: 8,
              itemBuilder: (context, index) => const NewsCardShimmer(),
            ),
        error: (error, stackTrace) =>
            EmptyStateWidget(
              title: "Failed to Load",
              subtitle: "Could not load top stories. Please try again.",
              icon: Icons.error_outline,
              onRetry: () => ref.invalidate(topStoriesProvider),
            ),
      ),
    );
  }

  Widget _buildHotTopicsTab() {
    final hotTopicsAsync = ref.watch(hotTopicsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(hotTopicsProvider);
      },
      child: hotTopicsAsync.when(
        data: (articles) {
          if (articles.isEmpty) {
            return const EmptyStateWidget(
              title: "No Hot Topics",
              subtitle: "There are no hot topics available right now.",
              icon: Icons.local_fire_department,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return _buildHotTopicCard(article, index);
            },
          );
        },
        loading: () =>
            ListView.builder(
              itemCount: 8,
              itemBuilder: (context, index) => const NewsCardShimmer(),
            ),
        error: (error, stackTrace) =>
            EmptyStateWidget(
              title: "Failed to Load",
              subtitle: "Could not load hot topics. Please try again.",
              icon: Icons.error_outline,
              onRetry: () => ref.invalidate(hotTopicsProvider),
            ),
      ),
    );
  }

  Widget _buildMostReadTab() {
    final mostReadAsync = ref.watch(mostReadProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(mostReadProvider);
      },
      child: mostReadAsync.when(
        data: (articles) {
          if (articles.isEmpty) {
            return const EmptyStateWidget(
              title: "No Articles",
              subtitle: "There are no most read articles available right now.",
              icon: Icons.star,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return _buildMostReadCard(article, index + 1);
            },
          );
        },
        loading: () =>
            ListView.builder(
              itemCount: 8,
              itemBuilder: (context, index) => const NewsCardShimmer(),
            ),
        error: (error, stackTrace) =>
            EmptyStateWidget(
              title: "Failed to Load",
              subtitle: "Could not load most read articles. Please try again.",
              icon: Icons.error_outline,
              onRetry: () => ref.invalidate(mostReadProvider),
            ),
      ),
    );
  }

  Widget _buildFeaturedStory(Article article) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: GestureDetector(
          onTap: () => _navigateToArticle(context, article),
          child: Stack(
            children: [
              Container(
                height: 250,
                width: double.infinity,
                child: article.imageUrl != null
                    ? Image.network(
                  article.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 60),
                    );
                  },
                )
                    : Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.article, size: 60),
                ),
              ),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '#1 TRENDING',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (article.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        article.description!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberedNewsCard(Article article, int number) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToArticle(context, article),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Number Badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getNumberColor(number),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (article.author != null)
                        Text(
                          article.author!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Trending Icon
                Icon(
                  Icons.trending_up,
                  color: _getNumberColor(number),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHotTopicCard(Article article, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToArticle(context, article),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Hot Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (article.description != null)
                        Text(
                          article.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMostReadCard(Article article, int rank) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToArticle(context, article),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Rank Badge
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.blue,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rank.toString(),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.visibility,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${(rank * 1000 + 500)} views", // Mock view count
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getNumberColor(int number) {
    switch (number) {
      case 2:
        return Colors.red;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.blue;
      case 5:
        return Colors.green;
      default:
        return Colors.purple;
    }
  }

  void _navigateToArticle(BuildContext context, Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleScreen(article: article),
      ),
    );
  }
}
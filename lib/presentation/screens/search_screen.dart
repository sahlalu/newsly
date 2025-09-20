import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/presentation/screens/article_screen.dart';
import '../../../domain/entities/article.dart';
import '../../widgets/card_shimmer.dart';
import '../../components/news_card.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _currentQuery = '';
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadSearchHistory() {
    // In a real app, load from SharedPreferences
    _searchHistory = [
      'Flutter development',
      'AI technology',
      'Climate change',
      'Space exploration',
    ];
  }

  void _addToSearchHistory(String query) {
    if (query.isNotEmpty && !_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.take(10).toList();
        }
      });
      // In a real app, save to SharedPreferences
    }
  }

  void _removeFromSearchHistory(String query) {
    setState(() {
      _searchHistory.remove(query);
    });
    // In a real app, save to SharedPreferences
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _currentQuery = query.trim();
    });
    _addToSearchHistory(query.trim());
    _focusNode.unfocus();

    // Trigger search through provider
    ref.read(searchQueryProvider.notifier).state = query.trim();
  }

  void _clearSearch() {
    setState(() {
      _currentQuery = '';
    });
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final recentNews = ref.watch(recentNewsProvider);

    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onSubmitted: _performSearch,
                      decoration: InputDecoration(
                        hintText: 'Search news...',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _currentQuery.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: _clearSearch,
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    onPressed: () => _performSearch(_searchController.text),
                    icon: const Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _currentQuery.isEmpty
                ? _buildInitialContent(recentNews)
                : _buildSearchResults(searchResults),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialContent(AsyncValue<List<Article>> recentNews) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search History
          if (_searchHistory.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Searches',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _searchHistory.clear();
                          });
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _searchHistory.map((query) {
                      return GestureDetector(
                        onTap: () {
                          _searchController.text = query;
                          _performSearch(query);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.history,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                query,
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _removeFromSearchHistory(query),
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],

          // Popular Topics
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Popular Topics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'Technology',
                    'Sports',
                    'Politics',
                    'Health',
                    'Science',
                    'Entertainment',
                  ].map((topic) {
                    return GestureDetector(
                      onTap: () {
                        _searchController.text = topic;
                        _performSearch(topic);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          topic,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const Divider(),

          // Recent News
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Latest News',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          recentNews.when(
            data: (articles) {
              if (articles.isEmpty) {
                return const EmptyStateWidget(
                  title: "No Recent News",
                  subtitle: "There are no recent articles available.",
                  icon: Icons.article_outlined,
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: articles.length > 10 ? 10 : articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return NewsCard(
                    article: article,
                    onTap: () => _navigateToArticle(context, article),
                  );
                },
              );
            },
            loading: () => const SearchResultShimmer(),
            error: (error, stackTrace) => EmptyStateWidget(
              title: "Failed to Load",
              subtitle: "Could not load recent news. Please try again.",
              icon: Icons.error_outline,
              onRetry: () => ref.invalidate(recentNewsProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(AsyncValue<List<Article>> searchResults) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Results for "$_currentQuery"',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _clearSearch,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Expanded(
          child: searchResults.when(
            data: (articles) {
              if (articles.isEmpty) {
                return EmptyStateWidget(
                  title: "No Results Found",
                  subtitle: "Try searching with different keywords.",
                  icon: Icons.search_off,
                  onRetry: () => ref.invalidate(searchResultsProvider),
                  retryText: "Search Again",
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(searchResultsProvider);
                },
                child: ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return NewsCard(
                      article: article,
                      onTap: () => _navigateToArticle(context, article),
                    );
                  },
                ),
              );
            },
            loading: () => const SearchResultShimmer(),
            error: (error, stackTrace) => EmptyStateWidget(
              title: "Search Failed",
              subtitle: "Could not search articles. Please check your connection.",
              icon: Icons.error_outline,
              onRetry: () => ref.invalidate(searchResultsProvider),
            ),
          ),
        ),
      ],
    );
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
import 'package:flutter/material.dart';
import '../components/header.dart';
import '../components/bottom_navbar.dart';
import '../presentation/screens/categories_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/search_screen.dart';
import '../presentation/screens/trending_screen.dart';

class MainScaffold extends StatefulWidget {
  final Widget? body; // 👈 optional custom body

  const MainScaffold({super.key, this.body});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<String> _pageTitles = [
    "Dashboard",
    "Categories",
    "Trending",
    "Search",
  ];

  final List<Widget> _pages = const [
    HomeScreen(),
    CategoriesScreen(),
    TrendingScreen(),
    SearchScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearchPage = _selectedIndex == 3;

    return Scaffold(
      appBar: Header(
        title:
            widget.body == null
                ? _pageTitles[_selectedIndex] // normal flow
                : "", // hide title when using custom body
        showSearch: widget.body == null && !isSearchPage,
        onSearchTap: () {
          setState(() {
            _selectedIndex = 3;
          });
        },
      ),
      body:
          widget.body ??
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _pages[_selectedIndex],
          ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: isSearchPage ? 0 : _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../constants/constant.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearch;
  final VoidCallback? onSearchTap;

  const Header({
    super.key,
    required this.title,
    this.showSearch = true,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                "Newsly",
                style: TextStyle(
                  fontSize: AppFontSizes.fontLarge,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: "Cursive",
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
        leadingWidth: 120,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: AppFontSizes.fontMedium,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          if (showSearch)
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.white, size: 22),
                onPressed: onSearchTap,
                tooltip: 'Search News',
                splashRadius: 22,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

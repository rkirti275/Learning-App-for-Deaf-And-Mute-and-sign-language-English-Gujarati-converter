import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/app_locale.dart';
import '../main.dart'; // To access themeNotifier
import 'profile_screen.dart';
import 'course_detail_screen.dart';
import 'syllabus_screen.dart';
import 'ai_model_screen.dart';
import '../data/mock_data.dart';

class HomeScreen extends StatefulWidget {
  final String lang;
  final String userName;
  const HomeScreen({super.key, required this.lang, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _searchQuery = "";

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _selectedIndex == 2
          ? ProfileScreen(userName: widget.userName, lang: widget.lang) // Show profile when tab 2 is selected
          : _selectedIndex == 1
              ? SyllabusScreen(lang: widget.lang) // Show syllabus when tab 1 is selected
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopSection(context),
                      
                      // Banner overlapping
                      Transform.translate(
                        offset: const Offset(0, -50),
                        child: _buildBannerCard(context, isDark),
                      ),
                      
                      Transform.translate(
                        offset: const Offset(0, -30),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocale.t("Learning Subjects", widget.lang),
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 20),
                              
                              // English Course
                              if ("english".contains(_searchQuery) || 
                                  AppLocale.t("English", widget.lang).toLowerCase().contains(_searchQuery))
                                _buildCourseCard(
                                  context: context,
                                  title: AppLocale.t("English", widget.lang),
                                  subtitle: "Basics of English",
                                  color: isDark ? const Color(0xFF2A3A2A) : const Color(0xFFE8F5E9),
                                  accentColor: AppColors.accentGreen,
                                  icon: Icons.abc,
                                  isDark: isDark,
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(courseName: "English", lang: widget.lang))),
                                ),
                                
                              if ("english".contains(_searchQuery) || 
                                  AppLocale.t("English", widget.lang).toLowerCase().contains(_searchQuery))
                                const SizedBox(height: 15),

                              // Gujarati Course
                              if ("gujarati".contains(_searchQuery) || 
                                  AppLocale.t("Gujarati", widget.lang).toLowerCase().contains(_searchQuery))
                                _buildCourseCard(
                                  context: context,
                                  title: AppLocale.t("Gujarati", widget.lang),
                                  subtitle: "Basics of Gujarati",
                                  color: isDark ? const Color(0xFF3A2A3A) : const Color(0xFFF3E5F5),
                                  accentColor: AppColors.accentPurple,
                                  icon: Icons.translate,
                                  isDark: isDark,
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(courseName: "Gujarati", lang: widget.lang))),
                                ),
                                
                              if ("ai".contains(_searchQuery) || "practice".contains(_searchQuery) || 
                                  AppLocale.t("AI Practice", widget.lang).toLowerCase().contains(_searchQuery))
                                const SizedBox(height: 15),

                              // AI Practice Model
                              if ("ai".contains(_searchQuery) || "practice".contains(_searchQuery) || 
                                  AppLocale.t("AI Practice", widget.lang).toLowerCase().contains(_searchQuery))
                                _buildCourseCard(
                                  context: context,
                                  title: AppLocale.t("AI Practice", widget.lang),
                                  subtitle: "Practice with AI Model",
                                  color: isDark ? const Color(0xFF2A3A4A) : const Color(0xFFE3F2FD),
                                  accentColor: AppColors.primaryLight,
                                  icon: Icons.smart_toy,
                                  isDark: isDark,
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AiModelScreen(lang: widget.lang))),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: theme.textTheme.bodyMedium?.color,
        backgroundColor: theme.colorScheme.surface,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: AppLocale.t("Home", widget.lang)),
          BottomNavigationBarItem(icon: const Icon(Icons.book), label: AppLocale.t("Course", widget.lang)),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: AppLocale.t("Profile", widget.lang)),
        ],
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 80),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ValueListenableBuilder<StudentProfile>(
                valueListenable: MockData.currentStudent,
                builder: (context, profile, _) {
                  return Text(
                    "Hi, ${profile.name}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              // Theme Toggle Button
              IconButton(
                icon: Icon(
                  theme.brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                ),
                onPressed: () {
                  themeNotifier.value = theme.brightness == Brightness.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                },
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            AppLocale.t("Pick a subject to explore and take tests.", widget.lang),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 30),
          
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark ? Colors.black54 : Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              onChanged: _onSearchChanged,
              style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "Search Here...",
                hintStyle: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white54 : AppColors.textLightLight),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocale.t("Let's Learn!", widget.lang),
                  style: theme.textTheme.displayMedium?.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Start",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : const Color(0xFFF4F5F9),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.school, size: 50, color: theme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color color,
    required Color accentColor,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : AppColors.surfaceLight, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: accentColor, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "BASICS",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(Icons.play_arrow, color: theme.primaryColor),
          ),
        ],
      ),
      ),
    );
  }
}

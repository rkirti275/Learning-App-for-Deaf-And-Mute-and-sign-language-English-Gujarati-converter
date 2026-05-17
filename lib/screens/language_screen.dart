import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'teacher_dashboard.dart';

class LanguageScreen extends StatelessWidget {
  final String role;
  final String userName;
  const LanguageScreen({super.key, required this.role, required this.userName});

  void _selectLanguage(BuildContext context, String lang) {
    if (role == 'Teacher') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TeacherDashboard(lang: lang)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(lang: lang, userName: userName)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Preferred Language", style: TextStyle(color: theme.colorScheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.language, size: 80, color: theme.primaryColor),
              const SizedBox(height: 30),
              Text(
                "Choose your language",
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 40),
              _buildLangButton(context, "English", "en"),
              const SizedBox(height: 20),
              _buildLangButton(context, "ગુજરાતી (Gujarati)", "gu"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangButton(BuildContext context, String text, String code) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          side: BorderSide(color: theme.primaryColor, width: 2),
        ),
        onPressed: () => _selectLanguage(context, code),
        child: Text(
          text,
          style: theme.textTheme.titleLarge?.copyWith(color: theme.primaryColor),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../utils/app_locale.dart';
import '../theme/app_colors.dart';
import 'mcq_test_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseName;
  final String lang;
  
  const CourseDetailScreen({super.key, required this.courseName, required this.lang});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modules = CourseContent.modules[courseName] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.t(courseName, lang), style: TextStyle(color: theme.colorScheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: modules.isEmpty 
        ? Center(child: Text("No content available", style: theme.textTheme.bodyMedium))
        : ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                shadowColor: theme.primaryColor.withValues(alpha: 0.2),
                color: theme.colorScheme.surface,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: module.hasTest ? AppColors.accentRed.withValues(alpha: 0.2) : theme.primaryColor.withValues(alpha: 0.2),
                    child: Icon(
                      module.hasTest ? Icons.quiz : Icons.image, 
                      color: module.hasTest ? AppColors.accentRed : theme.primaryColor
                    ),
                  ),
                  title: Text(module.title, style: theme.textTheme.titleLarge),
                  subtitle: Text(module.description, style: theme.textTheme.bodyMedium),
                  trailing: Icon(Icons.chevron_right, color: theme.textTheme.bodyMedium?.color),
                  onTap: () {
                    if (module.hasTest) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => McqTestScreen(courseName: courseName, lang: lang)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Opening ${module.title} images...")),
                      );
                    }
                  },
                ),
              );
            },
          ),
    );
  }
}

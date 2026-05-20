import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../utils/app_locale.dart';

class SyllabusScreen extends StatelessWidget {
  final String lang;
  const SyllabusScreen({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            AppLocale.t("Course Syllabus", lang),
            style: theme.textTheme.displayMedium,
          ),
          const SizedBox(height: 10),
          Text(
            AppLocale.t("Overview of all learning modules.", lang),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 30),
          ...CourseContent.modules.entries.map((entry) {
            final courseName = entry.key;
            final modules = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocale.t(courseName, lang),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: courseName == "English" ? AppColors.accentGreen : AppColors.accentPurple
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: isDark ? Colors.white12 : AppColors.surfaceLight),
                    ),
                    child: Column(
                      children: modules.asMap().entries.map((modEntry) {
                        final idx = modEntry.key;
                        final module = modEntry.value;
                        return Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.scaffoldBackgroundColor,
                                child: Text("${idx + 1}", style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(module.title, style: theme.textTheme.titleLarge?.copyWith(fontSize: 16)),
                              subtitle: Text(module.description, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
                            ),
                            if (idx < modules.length - 1)
                              Divider(color: isDark ? Colors.white12 : AppColors.surfaceLight, height: 1),
                          ],
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

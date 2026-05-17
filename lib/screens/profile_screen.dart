import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/mock_data.dart';
import '../widgets/custom_text_field.dart';
import '../utils/app_locale.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String lang;
  const ProfileScreen({super.key, required this.userName, required this.lang});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static final Map<String, IconData> avatarIcons = {
    'person': Icons.person,
    'boy': Icons.boy,
    'girl': Icons.girl,
    'face': Icons.face,
    'emoji_emotions': Icons.emoji_emotions,
  };

  void _showEditDialog(StudentProfile profile) {
    final nameController = TextEditingController(text: profile.name);
    final dobController = TextEditingController(text: profile.dob);
    final parentController = TextEditingController(text: profile.parentName);

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text(AppLocale.t("Edit Profile", widget.lang), style: theme.textTheme.displayMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: AppLocale.t("Full Name", widget.lang),
                hint: "",
                controller: nameController,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                label: AppLocale.t("Date of Birth", widget.lang),
                hint: "DD/MM/YYYY",
                controller: dobController,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                label: AppLocale.t("Parent Name", widget.lang),
                hint: "",
                controller: parentController,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocale.t("CANCEL", widget.lang), style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
            ),
            ElevatedButton(
              onPressed: () {
                MockData.setCurrentStudent(StudentProfile(
                  email: profile.email,
                  name: nameController.text,
                  dob: dobController.text,
                  parentName: parentController.text,
                  presentDays: profile.presentDays,
                  totalDays: profile.totalDays,
                  avatarIcon: profile.avatarIcon,
                  detailedMarks: Map.from(profile.detailedMarks),
                ));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
              child: Text(AppLocale.t("SAVE", widget.lang), style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAvatarSelector(StudentProfile profile) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocale.t("Choose an Avatar", widget.lang), style: theme.textTheme.displayMedium),
              const SizedBox(height: 20),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: avatarIcons.entries.map((entry) {
                  final isSelected = profile.avatarIcon == entry.key;
                  return GestureDetector(
                    onTap: () {
                      MockData.setCurrentStudent(StudentProfile(
                        email: profile.email,
                        name: profile.name,
                        dob: profile.dob,
                        parentName: profile.parentName,
                        presentDays: profile.presentDays,
                        totalDays: profile.totalDays,
                        avatarIcon: entry.key,
                        detailedMarks: Map.from(profile.detailedMarks),
                      ));
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: isSelected ? theme.primaryColor : theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: isSelected ? theme.primaryColor : theme.dividerColor, width: 2),
                      ),
                      child: Icon(entry.value, size: 40, color: isSelected ? Colors.white : theme.primaryColor),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showCourseBreakdown(String courseName, Map<String, int>? modules) {
    if (modules == null || modules.isEmpty) return;
    
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${AppLocale.t(courseName, widget.lang)} - ${AppLocale.t("Weak Areas", widget.lang)}", style: theme.textTheme.displayMedium),
              const SizedBox(height: 10),
              Text(AppLocale.t("Scores below 70% indicate weak areas.", widget.lang), style: theme.textTheme.bodyMedium),
              const SizedBox(height: 20),
              ...modules.entries.map((entry) {
                final isWeak = entry.value < 70;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isWeak ? Icons.warning_amber_rounded : Icons.check_circle,
                    color: isWeak ? AppColors.accentRed : AppColors.accentGreen,
                  ),
                  title: Text(entry.key, style: theme.textTheme.titleLarge?.copyWith(
                    color: isWeak ? AppColors.accentRed : theme.colorScheme.onSurface
                  )),
                  trailing: Text("${entry.value}%", style: theme.textTheme.displayMedium?.copyWith(
                    color: isWeak ? AppColors.accentRed : AppColors.accentGreen
                  )),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showAttendanceBreakdown(StudentProfile profile) {
    final theme = Theme.of(context);
    final absentDays = profile.totalDays - profile.presentDays;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocale.t("Attendance Details", widget.lang), style: theme.textTheme.displayMedium),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.check_circle, color: AppColors.accentGreen, size: 40),
                title: Text(AppLocale.t("Total Days Present", widget.lang), style: theme.textTheme.titleLarge),
                trailing: Text("${profile.presentDays}", style: theme.textTheme.displayMedium?.copyWith(color: AppColors.accentGreen)),
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: AppColors.accentRed, size: 40),
                title: Text(AppLocale.t("Total Days Absent", widget.lang), style: theme.textTheme.titleLarge),
                trailing: Text("$absentDays", style: theme.textTheme.displayMedium?.copyWith(color: AppColors.accentRed)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<StudentProfile>(
      valueListenable: MockData.currentStudent,
      builder: (context, profile, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: GestureDetector(
                  onTap: () => _showAvatarSelector(profile),
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(avatarIcons[profile.avatarIcon] ?? Icons.person, size: 50, color: theme.primaryColor),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  profile.name.toUpperCase(),
                  style: theme.textTheme.displayMedium,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  AppLocale.t("Student Account", widget.lang),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 40),

              // Student Info Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocale.t("Student Info", widget.lang), style: theme.textTheme.titleLarge),
                  IconButton(
                    icon: Icon(Icons.edit, color: theme.primaryColor),
                    onPressed: () => _showEditDialog(profile),
                  )
                ],
              ),
              _buildInfoCard(context, AppLocale.t("Date of Birth", widget.lang), profile.dob, Icons.cake),
              const SizedBox(height: 10),
              _buildInfoCard(context, AppLocale.t("Parent Name", widget.lang), profile.parentName, Icons.family_restroom),
              
              const SizedBox(height: 30),

              // Performance Dashboard Section
              Text(AppLocale.t("Performance Dashboard", widget.lang), style: theme.textTheme.titleLarge),
              const SizedBox(height: 10),
              Text(AppLocale.t("Tap any card for detailed insights.", widget.lang), style: theme.textTheme.bodyMedium),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(context, AppLocale.t("Overall", widget.lang), "${profile.overallMarks}%", AppColors.primaryLight, isDark, onTap: () {}),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildStatCard(context, AppLocale.t("Attendance", widget.lang), "${profile.attendancePercentage}%", AppColors.accentOrange, isDark, onTap: () => _showAttendanceBreakdown(profile)),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(context, AppLocale.t("English", widget.lang), "${profile.getCourseMark('English')}%", AppColors.accentGreen, isDark, onTap: () => _showCourseBreakdown('English', profile.detailedMarks['English'])),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildStatCard(context, AppLocale.t("Gujarati", widget.lang), "${profile.getCourseMark('Gujarati')}%", AppColors.accentPurple, isDark, onTap: () => _showCourseBreakdown('Gujarati', profile.detailedMarks['Gujarati'])),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(AppLocale.t("Log Out", widget.lang), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: theme.textTheme.titleLarge?.copyWith(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color color, bool isDark, {required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? color.withValues(alpha: 0.1) : color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(title, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 10),
            Text(value, style: theme.textTheme.displayMedium?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../utils/app_locale.dart';
import '../data/mock_data.dart';
import '../data/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_text_field.dart';

class TeacherDashboard extends StatefulWidget {
  final String lang;
  const TeacherDashboard({super.key, required this.lang});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;

  static final Map<String, IconData> avatarIcons = {
    'teacher': Icons.school,
    'person': Icons.person,
    'boy': Icons.boy,
    'girl': Icons.girl,
    'face': Icons.face,
  };

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() async {
    await ApiService.fetchAllStudents();
    setState(() {}); // refresh UI after loading
  }

  void _showAddStudentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final dobController = TextEditingController();
    final parentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text(AppLocale.t("Add Student", widget.lang), style: theme.textTheme.displayMedium),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(label: AppLocale.t("Student Name", widget.lang), hint: "", controller: nameController),
                const SizedBox(height: 15),
                CustomTextField(label: AppLocale.t("Date of Birth", widget.lang), hint: "DD/MM/YYYY", controller: dobController),
                const SizedBox(height: 15),
                CustomTextField(label: AppLocale.t("Parent Name", widget.lang), hint: "", controller: parentController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocale.t("CANCEL", widget.lang), style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
            ),
            ElevatedButton(
              onPressed: () async {
                String email = "${nameController.text.replaceAll(' ', '').toLowerCase()}@email.com";
                String name = nameController.text.isNotEmpty ? nameController.text : "New Student";
                bool success = await ApiService.register('student', name, email, 'password123'); // Register with dummy password
                
                if (success) {
                  // Reload the students list from the database
                  await ApiService.fetchAllStudents();
                  
                  setState(() {
                    // After registering, update profile details if the student is found
                    int index = MockData.allStudents.indexWhere((s) => s.email.toLowerCase() == email.toLowerCase());
                    if (index != -1) {
                      var s = MockData.allStudents[index];
                      s.dob = dobController.text.isNotEmpty ? dobController.text : "01/01/2010";
                      s.parentName = parentController.text.isNotEmpty ? parentController.text : "Unknown";
                      ApiService.updateProfile(s);
                    }
                  });
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to add student. Email '$email' might already exist or server is unreachable."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
                
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
              child: Text(AppLocale.t("SAVE", widget.lang), style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showEditStudentDialog(BuildContext context, StudentProfile student) {
    final nameController = TextEditingController(text: student.name);
    final presentController = TextEditingController(text: student.presentDays.toString());
    final engMarksController = TextEditingController(text: student.detailedMarks['English']?['MCQ Test']?.toString() ?? '0');
    final gujMarksController = TextEditingController(text: student.detailedMarks['Gujarati']?['MCQ ટેસ્ટ (Test)']?.toString() ?? '0');

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text("Edit ${student.name}", style: theme.textTheme.displayMedium),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(label: AppLocale.t("Student Name", widget.lang), hint: "", controller: nameController),
                const SizedBox(height: 15),
                CustomTextField(label: AppLocale.t("Present Days", widget.lang), hint: "0", controller: presentController),
                const SizedBox(height: 15),
                CustomTextField(label: "English MCQ Marks", hint: "0-100", controller: engMarksController),
                const SizedBox(height: 15),
                CustomTextField(label: "Gujarati MCQ Marks", hint: "0-100", controller: gujMarksController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocale.t("CANCEL", widget.lang), style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  student.name = nameController.text;
                  student.presentDays = int.tryParse(presentController.text) ?? student.presentDays;
                  
                  if (!student.detailedMarks.containsKey('English')) student.detailedMarks['English'] = {};
                  student.detailedMarks['English']!['MCQ Test'] = int.tryParse(engMarksController.text) ?? 0;
                  
                  if (!student.detailedMarks.containsKey('Gujarati')) student.detailedMarks['Gujarati'] = {};
                  student.detailedMarks['Gujarati']!['MCQ ટેસ્ટ (Test)'] = int.tryParse(gujMarksController.text) ?? 0;
                  
                  // Sync edits to backend
                  ApiService.updateProfile(student);
                  ApiService.updateScore('English', 'MCQ Test', student.detailedMarks['English']!['MCQ Test']!, studentEmail: student.email);
                  ApiService.updateScore('Gujarati', 'MCQ ટેસ્ટ (Test)', student.detailedMarks['Gujarati']!['MCQ ટેસ્ટ (Test)']!, studentEmail: student.email);
                  
                  // If we are editing the current logged in student (for demo persistence)
                  if (student == MockData.currentStudent.value) {
                    MockData.currentStudent.value = student;
                  }
                });
                Navigator.pop(context);
                Navigator.pop(context); // Close the details bottom sheet too
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
              child: Text(AppLocale.t("SAVE", widget.lang), style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showStudentDetails(BuildContext context, StudentProfile student) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 5, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30, 
                        backgroundColor: theme.primaryColor.withValues(alpha: 0.1), 
                        child: Icon(avatarIcons[student.avatarIcon] ?? Icons.person, color: theme.primaryColor, size: 30),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student.name, style: theme.textTheme.displayMedium),
                          Text("${AppLocale.t("Date of Birth", widget.lang)}: ${student.dob}", style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: theme.primaryColor),
                    onPressed: () => _showEditStudentDialog(context, student),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(AppLocale.t("Performance", widget.lang), style: theme.textTheme.titleLarge),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildStat(context, AppLocale.t("English", widget.lang), "${student.getCourseMark('English')}%", AppColors.accentGreen, isDark)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildStat(context, AppLocale.t("Gujarati", widget.lang), "${student.getCourseMark('Gujarati')}%", AppColors.accentPurple, isDark)),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildStat(context, AppLocale.t("Overall", widget.lang), "${student.overallMarks}%", AppColors.primaryLight, isDark)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildStat(context, AppLocale.t("Attendance", widget.lang), "${student.attendancePercentage}%", AppColors.accentOrange, isDark)),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(BuildContext context, String title, String value, Color color, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.1) : color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
          const SizedBox(height: 5),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(color: color)),
        ],
      ),
    );
  }

  void _showTeacherAvatarSelector(TeacherProfile profile) {
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
                      MockData.setCurrentTeacher(TeacherProfile(
                        email: profile.email,
                        name: profile.name,
                        subject: profile.subject,
                        avatarIcon: entry.key,
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

  void _showEditTeacherDialog(TeacherProfile profile) {
    final nameController = TextEditingController(text: profile.name);
    final subjectController = TextEditingController(text: profile.subject);

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
                label: AppLocale.t("Learning Subjects", widget.lang),
                hint: "",
                controller: subjectController,
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
                MockData.setCurrentTeacher(TeacherProfile(
                  email: profile.email,
                  name: nameController.text,
                  subject: subjectController.text,
                  avatarIcon: profile.avatarIcon,
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

  Widget _buildTeacherProfile() {
    final theme = Theme.of(context);
    return ValueListenableBuilder<TeacherProfile>(
      valueListenable: MockData.currentTeacher,
      builder: (context, profile, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () => _showTeacherAvatarSelector(profile),
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(avatarIcons[profile.avatarIcon] ?? Icons.school, size: 50, color: theme.primaryColor),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: theme.primaryColor, shape: BoxShape.circle),
                        child: const Icon(Icons.edit, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(profile.name.toUpperCase(), style: theme.textTheme.displayMedium),
                  IconButton(
                    icon: Icon(Icons.edit, color: theme.primaryColor, size: 20),
                    onPressed: () => _showEditTeacherDialog(profile),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(AppLocale.t("Teacher Account - ${profile.subject}", widget.lang), style: theme.textTheme.bodyMedium),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
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

  Widget _buildStudentsList() {
    final theme = Theme.of(context);
    final students = MockData.allStudents;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocale.t("Your Students", widget.lang), style: theme.textTheme.displayMedium),
          const SizedBox(height: 5),
          Text(AppLocale.t("Tap on a student to view and edit detailed performance.", widget.lang), style: theme.textTheme.bodyMedium),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  elevation: 4,
                  shadowColor: theme.primaryColor.withValues(alpha: 0.1),
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
                      child: Icon(avatarIcons[student.avatarIcon] ?? Icons.person, color: theme.primaryColor),
                    ),
                    title: Text(student.name, style: theme.textTheme.titleLarge),
                    subtitle: Text("${AppLocale.t("Attendance", widget.lang)}: ${student.attendancePercentage}%", style: theme.textTheme.bodyMedium),
                    trailing: Icon(Icons.chevron_right, color: theme.textTheme.bodyMedium?.color),
                    onTap: () => _showStudentDetails(context, student),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocale.t("Teacher Dashboard", widget.lang), style: TextStyle(color: theme.colorScheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _selectedIndex == 0 ? _buildStudentsList() : _buildTeacherProfile(),
      floatingActionButton: _selectedIndex == 0 
          ? FloatingActionButton.extended(
              onPressed: () => _showAddStudentDialog(context),
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: Text(AppLocale.t("Add Student", widget.lang), style: const TextStyle(color: Colors.white)),
              backgroundColor: theme.primaryColor,
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: theme.textTheme.bodyMedium?.color,
        backgroundColor: theme.colorScheme.surface,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.people), label: AppLocale.t("Students", widget.lang)),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: AppLocale.t("My Profile", widget.lang)),
        ],
      ),
    );
  }
}

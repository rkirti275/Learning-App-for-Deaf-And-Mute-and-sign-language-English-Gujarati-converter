import 'package:flutter/foundation.dart';

class StudentProfile {
  String email;
  String name;
  String dob;
  String parentName;
  int presentDays;
  int totalDays;
  String avatarIcon;
  Map<String, Map<String, int>> detailedMarks;

  StudentProfile({
    required this.email,
    required this.name,
    required this.dob,
    required this.parentName,
    required this.presentDays,
    required this.totalDays,
    this.avatarIcon = 'person',
    required this.detailedMarks,
  });

  int get attendancePercentage {
    if (totalDays == 0) return 0;
    return ((presentDays / totalDays) * 100).round();
  }

  int getCourseMark(String course) {
    if (!detailedMarks.containsKey(course) || detailedMarks[course]!.isEmpty) return 0;
    final modules = detailedMarks[course]!;
    int total = modules.values.fold(0, (sum, val) => sum + val);
    return (total / modules.length).round();
  }

  int get overallMarks {
    if (detailedMarks.isEmpty) return 0;
    int total = 0;
    int count = 0;
    for (var course in detailedMarks.keys) {
      total += getCourseMark(course);
      count++;
    }
    if (count == 0) return 0;
    return (total / count).round();
  }
}

class TeacherProfile {
  String email;
  String name;
  String subject;
  String avatarIcon;

  TeacherProfile({
    required this.email,
    required this.name,
    required this.subject,
    this.avatarIcon = 'teacher',
  });
}

class MockData {
  static ValueNotifier<TeacherProfile> currentTeacher = ValueNotifier(
    TeacherProfile(email: "mrdavis@email.com", name: "Mr. Davis", subject: "Special Education"),
  );

  static ValueNotifier<StudentProfile> currentStudent = ValueNotifier(
    StudentProfile(
      email: "lindasmith@email.com",
      name: "Linda Smith",
      dob: "12th May 2010",
      parentName: "Mr. & Mrs. Smith",
      presentDays: 184,
      totalDays: 200,
      detailedMarks: {
        "English": {
          "Alphabets": 95,
          "Basic Vocabulary": 75,
          "MCQ Test": 85,
        },
        "Gujarati": {
          "મૂળાક્ષરો (Alphabets)": 80,
          "શબ્દભંડોળ (Vocabulary)": 60,
          "MCQ ટેસ્ટ (Test)": 70,
        },
      },
    ),
  );

  static List<TeacherProfile> allTeachers = [
    currentTeacher.value,
  ];

  static List<StudentProfile> allStudents = [
    currentStudent.value,
    StudentProfile(
      email: "rahul@email.com",
      name: "Rahul Patel",
      dob: "5th Jan 2011",
      parentName: "Kiran Patel",
      presentDays: 196,
      totalDays: 200,
      detailedMarks: {
        "English": {"Alphabets": 100, "MCQ Test": 90},
        "Gujarati": {"મૂળાક્ષરો (Alphabets)": 95, "MCQ ટેસ્ટ (Test)": 95},
      },
    ),
    StudentProfile(
      email: "sarah@email.com",
      name: "Sarah Jones",
      dob: "20th Nov 2010",
      parentName: "David Jones",
      presentDays: 170,
      totalDays: 200,
      detailedMarks: {
        "English": {"Alphabets": 80, "MCQ Test": 75},
        "Gujarati": {"મૂળાક્ષરો (Alphabets)": 60, "MCQ ટેસ્ટ (Test)": 60},
      },
    ),
  ];

  static void setCurrentStudent(StudentProfile profile) {
    int index = allStudents.indexWhere((s) => s.email.toLowerCase() == currentStudent.value.email.toLowerCase());
    currentStudent.value = profile;
    if (index != -1) {
      allStudents[index] = profile;
    } else {
      allStudents.add(profile);
    }
  }

  static void setCurrentTeacher(TeacherProfile profile) {
    int index = allTeachers.indexWhere((t) => t.email.toLowerCase() == currentTeacher.value.email.toLowerCase());
    currentTeacher.value = profile;
    if (index != -1) {
      allTeachers[index] = profile;
    } else {
      allTeachers.add(profile);
    }
  }

  // Returns true if login successful, false if email not found
  static bool login(String role, String email) {
    if (role == 'student') {
      int index = allStudents.indexWhere((s) => s.email.toLowerCase() == email.toLowerCase());
      if (index != -1) {
        currentStudent.value = allStudents[index];
        return true;
      }
      return false;
    } else {
      int index = allTeachers.indexWhere((t) => t.email.toLowerCase() == email.toLowerCase());
      if (index != -1) {
        currentTeacher.value = allTeachers[index];
        return true;
      }
      return false;
    }
  }

  // Returns true if registration successful, false if email already exists
  static bool register(String role, String email, String name) {
    if (role == 'student') {
      int index = allStudents.indexWhere((s) => s.email.toLowerCase() == email.toLowerCase());
      if (index != -1) return false; // Already exists

      var profile = StudentProfile(
        email: email,
        name: name,
        dob: "01/01/2010",
        parentName: "Unknown",
        presentDays: 0,
        totalDays: 200,
        detailedMarks: {},
      );
      allStudents.add(profile);
      currentStudent.value = profile;
      return true;
    } else {
      int index = allTeachers.indexWhere((t) => t.email.toLowerCase() == email.toLowerCase());
      if (index != -1) return false; // Already exists

      var profile = TeacherProfile(
        email: email,
        name: name,
        subject: "General",
      );
      allTeachers.add(profile);
      currentTeacher.value = profile;
      return true;
    }
  }

  static void updateScore(String course, String module, int newScore) {
    var profile = currentStudent.value;
    if (!profile.detailedMarks.containsKey(course)) {
      profile.detailedMarks[course] = {};
    }
    profile.detailedMarks[course]![module] = newScore;
    
    // Trigger rebuilds and update allStudents list
    setCurrentStudent(StudentProfile(
      email: profile.email,
      name: profile.name,
      dob: profile.dob,
      parentName: profile.parentName,
      presentDays: profile.presentDays,
      totalDays: profile.totalDays,
      avatarIcon: profile.avatarIcon,
      detailedMarks: Map.from(profile.detailedMarks),
    ));
  }
}

// Mock Course Data
class CourseModule {
  final String title;
  final String description;
  final bool hasTest;

  CourseModule(this.title, this.description, {this.hasTest = false});
}

class CourseContent {
  static final Map<String, List<CourseModule>> modules = {
    "English": [
      CourseModule("Alphabets", "Learn the A-Z of English"),
      CourseModule("Basic Vocabulary", "Common daily words"),
      CourseModule("Simple Sentences", "Forming basic phrases"),
      CourseModule("MCQ Test", "Test your English skills", hasTest: true),
    ],
    "Gujarati": [
      CourseModule("મૂળાક્ષરો (Alphabets)", "ક ખ ગ શીખો"),
      CourseModule("શબ્દભંડોળ (Vocabulary)", "રોજબરોજના શબ્દો"),
      CourseModule("વાક્યરચના (Sentences)", "સરળ વાક્યો બનાવો"),
      CourseModule("MCQ ટેસ્ટ (Test)", "તમારું જ્ઞાન ચકાસો", hasTest: true),
    ]
  };
}

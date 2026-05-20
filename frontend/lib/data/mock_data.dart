import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'dob': dob,
      'parentName': parentName,
      'presentDays': presentDays,
      'totalDays': totalDays,
      'avatarIcon': avatarIcon,
      'detailedMarks': detailedMarks,
    };
  }

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    Map<String, Map<String, int>> detailedMarks = {};
    if (json['detailedMarks'] != null) {
      json['detailedMarks'].forEach((course, modules) {
        if (modules is Map) {
          detailedMarks[course] = Map<String, int>.from(
            modules.map((key, val) => MapEntry(key.toString(), val as int)),
          );
        }
      });
    }
    return StudentProfile(
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      dob: json['dob'] ?? '',
      parentName: json['parentName'] ?? '',
      presentDays: json['presentDays'] ?? 0,
      totalDays: json['totalDays'] ?? 200,
      avatarIcon: json['avatarIcon'] ?? 'person',
      detailedMarks: detailedMarks,
    );
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

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'subject': subject,
      'avatarIcon': avatarIcon,
    };
  }

  factory TeacherProfile.fromJson(Map<String, dynamic> json) {
    return TeacherProfile(
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      subject: json['subject'] ?? '',
      avatarIcon: json['avatarIcon'] ?? 'teacher',
    );
  }
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

  static Future<void> saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final studentsJson = allStudents.map((s) => s.toJson()).toList();
      await prefs.setString('all_students', jsonEncode(studentsJson));
      
      final teachersJson = allTeachers.map((t) => t.toJson()).toList();
      await prefs.setString('all_teachers', jsonEncode(teachersJson));
      
      await prefs.setString('current_student', jsonEncode(currentStudent.value.toJson()));
      await prefs.setString('current_teacher', jsonEncode(currentTeacher.value.toJson()));
      
      print('MockData successfully saved to SharedPreferences.');
    } catch (e) {
      print('Error saving MockData to SharedPreferences: $e');
    }
  }

  static Future<void> loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final currentStudentStr = prefs.getString('current_student');
      if (currentStudentStr != null) {
        currentStudent.value = StudentProfile.fromJson(jsonDecode(currentStudentStr));
      }
      
      final currentTeacherStr = prefs.getString('current_teacher');
      if (currentTeacherStr != null) {
        currentTeacher.value = TeacherProfile.fromJson(jsonDecode(currentTeacherStr));
      }
      
      final studentsStr = prefs.getString('all_students');
      if (studentsStr != null) {
        final List decoded = jsonDecode(studentsStr);
        allStudents = decoded.map((s) => StudentProfile.fromJson(s)).toList();
      }
      
      final teachersStr = prefs.getString('all_teachers');
      if (teachersStr != null) {
        final List decoded = jsonDecode(teachersStr);
        allTeachers = decoded.map((t) => TeacherProfile.fromJson(t)).toList();
      }
      
      print('MockData successfully loaded from SharedPreferences.');
    } catch (e) {
      print('Error loading MockData from SharedPreferences: $e');
    }
  }

  static void setCurrentStudent(StudentProfile profile) {
    int index = allStudents.indexWhere((s) => s.email.toLowerCase() == currentStudent.value.email.toLowerCase());
    currentStudent.value = profile;
    if (index != -1) {
      allStudents[index] = profile;
    } else {
      allStudents.add(profile);
    }
    saveToPreferences();
  }

  static void setCurrentTeacher(TeacherProfile profile) {
    int index = allTeachers.indexWhere((t) => t.email.toLowerCase() == currentTeacher.value.email.toLowerCase());
    currentTeacher.value = profile;
    if (index != -1) {
      allTeachers[index] = profile;
    } else {
      allTeachers.add(profile);
    }
    saveToPreferences();
  }

  // Returns true if login successful, false if email not found
  static bool login(String role, String email) {
    final normalizedRole = role.toLowerCase();
    if (normalizedRole == 'student') {
      int index = allStudents.indexWhere((s) => s.email.toLowerCase() == email.toLowerCase());
      if (index != -1) {
        currentStudent.value = allStudents[index];
        saveToPreferences();
        return true;
      }
      return false;
    } else {
      int index = allTeachers.indexWhere((t) => t.email.toLowerCase() == email.toLowerCase());
      if (index != -1) {
        currentTeacher.value = allTeachers[index];
        saveToPreferences();
        return true;
      }
      return false;
    }
  }

  // Returns true if registration successful, false if email already exists
  static bool register(String role, String email, String name) {
    final normalizedRole = role.toLowerCase();
    if (normalizedRole == 'student') {
      int index = allStudents.indexWhere((s) => s.email.toLowerCase() == email.toLowerCase());
      if (index != -1) return false; // Already exists

      var profile = StudentProfile(
        email: email,
        name: name,
        dob: "",
        parentName: "",
        presentDays: 0,
        totalDays: 200,
        detailedMarks: {},
      );
      allStudents.add(profile);
      currentStudent.value = profile;
      saveToPreferences();
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
      saveToPreferences();
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

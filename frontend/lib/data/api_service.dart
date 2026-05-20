import 'dart:convert';
import 'package:http/http.dart' as http;
import 'mock_data.dart';

class ApiService {
  // Use 127.0.0.1 along with `adb reverse tcp:5000 tcp:5000` for physical Android devices.
  static const String baseUrl = 'http://127.0.0.1:5000';

  /// Authenticate user via Flask Backend
  static Future<bool> login(String role, String email, String password) async {
    final normalizedRole = role.toLowerCase();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': normalizedRole,
        }),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final name = data['name'] ?? 'User';

        if (normalizedRole == 'student') {
          // Fetch real stats from backend
          await fetchProfile(email, name);
        } else {
          int index = MockData.allTeachers.indexWhere((t) => t.email.toLowerCase() == email.toLowerCase());
          if (index != -1) {
            MockData.currentTeacher.value = MockData.allTeachers[index];
          } else {
             var profile = TeacherProfile(
                email: email,
                name: name,
                subject: "General",
              );
              MockData.allTeachers.add(profile);
              MockData.currentTeacher.value = profile;
          }
        }
        return true;
      }
      return false; // 401 Unauthorized or other error
    } catch (e) {
      print('Login network error: $e. Falling back to local offline mock database.');
      // Attempt local mock login
      bool mockSuccess = MockData.login(normalizedRole, email);
      if (mockSuccess) {
        print('Offline mock login successful for $email as $normalizedRole.');
        return true;
      }
      print('Offline mock login failed: User $email not found in mock data.');
      return false;
    }
  }

  /// Register user via Flask Backend
  static Future<bool> register(String role, String name, String email, String password) async {
    final normalizedRole = role.toLowerCase();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': normalizedRole,
        }),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 201) {
        if (normalizedRole == 'student') {
          await fetchProfile(email, name);
        } else {
          var profile = TeacherProfile(
            email: email,
            name: name,
            subject: "General",
          );
          MockData.allTeachers.add(profile);
          MockData.currentTeacher.value = profile;
        }
        return true;
      }
      return false; // 400 Bad Request (e.g. Email already exists)
    } catch (e) {
      print('Register network error: $e. Falling back to local offline mock database.');
      // Attempt local mock register
      bool mockSuccess = MockData.register(normalizedRole, email, name);
      if (mockSuccess) {
        print('Offline mock registration successful for $email as $normalizedRole.');
        return true;
      }
      print('Offline mock registration failed: Email already exists in mock data.');
      return false;
    }
  }

  /// Fetch user profile and stats from Backend
  static Future<void> fetchProfile(String email, String defaultName) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/profile/$email'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var dm = data['detailed_marks'] ?? {};
        Map<String, Map<String, int>> detailedMarks = {};
        dm.forEach((k, v) {
          detailedMarks[k] = Map<String, int>.from(v);
        });

        var profile = StudentProfile(
          email: data['email'] ?? email,
          name: data['name'] ?? defaultName,
          dob: data['dob'] ?? '',
          parentName: data['parent_name'] ?? '',
          presentDays: data['present_days'] ?? 0,
          totalDays: data['total_days'] ?? 200,
          avatarIcon: data['avatar_icon'] ?? 'person',
          detailedMarks: detailedMarks,
        );
        MockData.setCurrentStudent(profile);
      }
    } catch (e) {
      print('Fetch profile backend sync failed: $e. Using local mock/cached profile.');
    }
  }

  /// Update Profile on Backend
  static Future<void> updateProfile(StudentProfile profile) async {
    try {
      // First update local state
      MockData.setCurrentStudent(profile);
      
      // Then sync to backend
      await http.post(
        Uri.parse('$baseUrl/api/profile/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': profile.email,
          'name': profile.name,
          'dob': profile.dob,
          'parent_name': profile.parentName,
          'present_days': profile.presentDays,
          'avatar_icon': profile.avatarIcon,
        }),
      ).timeout(const Duration(seconds: 3));
    } catch (e) {
      print('Update profile backend sync failed: $e. Saved locally.');
    }
  }

  /// Update Score on Backend
  static Future<void> updateScore(String courseName, String moduleName, int score, {String? studentEmail}) async {
    try {
      String email = studentEmail ?? MockData.currentStudent.value.email;
      
      // Update local state if it's the current student
      if (studentEmail == null || studentEmail == MockData.currentStudent.value.email) {
        MockData.updateScore(courseName, moduleName, score);
      }
      
      // Sync to backend
      await http.post(
        Uri.parse('$baseUrl/api/score/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'course_name': courseName,
          'module_name': moduleName,
          'score': score,
        }),
      ).timeout(const Duration(seconds: 3));
    } catch (e) {
      print('Update score backend sync failed: $e. Saved locally.');
    }
  }

  /// Fetch all students for Teacher Dashboard
  static Future<List<StudentProfile>> fetchAllStudents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/students'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List studentsData = data['students'] ?? [];
        List<StudentProfile> studentsList = [];
        
        for (var s in studentsData) {
          var dm = s['detailed_marks'] ?? {};
          Map<String, Map<String, int>> detailedMarks = {};
          dm.forEach((k, v) {
            detailedMarks[k] = Map<String, int>.from(v);
          });
          
          studentsList.add(StudentProfile(
            email: s['email'],
            name: s['name'],
            dob: s['dob'],
            parentName: s['parent_name'],
            presentDays: s['present_days'],
            totalDays: s['total_days'],
            avatarIcon: s['avatar_icon'],
            detailedMarks: detailedMarks,
          ));
        }
        
        // Update local cache
        MockData.allStudents = studentsList;
        return studentsList;
      }
    } catch (e) {
      print('Fetch all students backend query failed: $e. Using local mock/cached student list.');
    }
    return MockData.allStudents;
  }
}

class AppLocale {
  static String t(String text, String? lang) {
    if (lang != 'gu') return text;
    switch (text) {
      case "Sign Up as STUDENT": return "વિદ્યાર્થી તરીકે સાઇન અપ કરો";
      case "Sign Up as TEACHER": return "શિક્ષક તરીકે સાઇન અપ કરો";
      case "Login as STUDENT": return "વિદ્યાર્થી તરીકે લૉગિન કરો";
      case "Login as TEACHER": return "શિક્ષક તરીકે લૉગિન કરો";
      case "Full Name": return "પૂરું નામ";
      case "Email": return "ઇમેઇલ";
      case "Password": return "પાસવર્ડ";
      case "CREATE ACCOUNT": return "એકાઉન્ટ બનાવો";
      case "LOGIN": return "લૉગિન";
      case "Learning Subjects": return "શીખવાના વિષયો";
      case "Let's Learn!": return "ચાલો શીખીએ!";
      case "Pick a subject to explore and take tests.": return "શીખવા અને ટેસ્ટ આપવા માટે વિષય પસંદ કરો.";
      case "Mathematics": return "ગણિત";
      case "English": return "અંગ્રેજી";
      case "Science": return "વિજ્ઞાન";
      case "Gujarati": return "ગુજરાતી";
      case "Q": return "પ્ર";
      case "START MCQ TEST": return "MCQ ટેસ્ટ શરૂ કરો";
      case "Test Complete": return "ટેસ્ટ પૂર્ણ";
      case "Your test has been successfully submitted!": return "તમારી ટેસ્ટ સફળતાપૂર્વક સબમિટ થઈ ગઈ છે!";
      case "OK": return "બરાબર";
      case "Submit": return "સબમિટ કરો";
      case "My Performance": return "મારું પ્રદર્શન";
      case "Overall Score": return "કુલ ગુણ";
      case "Recent Tests": return "તાજેતરની પરીક્ષાઓ";
      case "Teacher Dashboard": return "શિક્ષક ડેશબોર્ડ";
      case "Student Leaderboard": return "વિદ્યાર્થી લીડરબોર્ડ";
      case "Total Marks": return "કુલ ગુણ";
      case "Today": return "આજે";
      case "Yesterday": return "ગઈકાલે";
      case "AI Practice": return "AI અભ્યાસ";
      
      // New Profile / Dashboard Translations
      case "Student Account": return "વિદ્યાર્થી એકાઉન્ટ";
      case "Teacher Account": return "શિક્ષક એકાઉન્ટ";
      case "Performance Dashboard": return "પ્રદર્શન ડેશબોર્ડ";
      case "Attendance": return "હાજરી";
      case "Overall": return "એકંદર";
      case "Edit Profile": return "પ્રોફાઇલ સંપાદિત કરો";
      case "Add Student": return "વિદ્યાર્થી ઉમેરો";
      case "Your Students": return "તમારા વિદ્યાર્થીઓ";
      case "Course Syllabus": return "અભ્યાસક્રમ";
      case "Home": return "હોમ";
      case "Course": return "કોર્સ";
      case "Profile": return "પ્રોફાઇલ";
      case "Log Out": return "લૉગ આઉટ";
      case "Student Info": return "વિદ્યાર્થી માહિતી";
      case "Date of Birth": return "જન્મ તારીખ";
      case "Parent Name": return "વાલીનું નામ";
      case "Tap any card for detailed insights.": return "વિગતવાર માહિતી માટે કોઈપણ કાર્ડને ટેપ કરો.";
      case "Choose an Avatar": return "અવતાર પસંદ કરો";
      case "Attendance Details": return "હાજરીની વિગતો";
      case "Total Days Present": return "કુલ હાજર દિવસો";
      case "Total Days Absent": return "કુલ ગેરહાજર દિવસો";
      case "Students": return "વિદ્યાર્થીઓ";
      case "My Profile": return "મારી પ્રોફાઇલ";
      case "Tap on a student to view and edit detailed performance.": return "વિગતવાર પ્રદર્શન જોવા અને સંપાદિત કરવા માટે વિદ્યાર્થી પર ટેપ કરો.";
      case "Performance": return "પ્રદર્શન";
      case "Overview of all learning modules.": return "તમામ શીખવાના મોડ્યુલોની ઝાંખી.";
      case "CANCEL": return "રદ કરો";
      case "SAVE": return "સાચવો";
      case "Student Name": return "વિદ્યાર્થીનું નામ";
      case "Present Days": return "હાજર દિવસો";
      case "Weak Areas": return "નબળા વિસ્તારો";
      case "Scores below 70% indicate weak areas.": return "70% થી ઓછા ગુણ નબળા વિસ્તારો સૂચવે છે.";
      
      default:
        if (text.contains("Teacher Account -")) {
          return text.replaceFirst("Teacher Account -", "શિક્ષક એકાઉન્ટ -");
        }
        return text
            .replaceAll("Ready for", "માટે તૈયાર છો")
            .replaceAll("Test", "ટેસ્ટ");
    }
  }
}

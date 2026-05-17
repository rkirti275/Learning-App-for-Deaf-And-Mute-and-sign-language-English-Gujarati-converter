import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../utils/app_locale.dart';

class McqTestScreen extends StatefulWidget {
  final String courseName;
  final String lang;
  
  const McqTestScreen({super.key, required this.courseName, required this.lang});

  @override
  State<McqTestScreen> createState() => _McqTestScreenState();
}

class _McqTestScreenState extends State<McqTestScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswer;

  final List<Map<String, dynamic>> _questions = [
    {
      "q": "What is the first letter of the English Alphabet?",
      "options": ["B", "Z", "A", "E"],
      "answer": 2
    },
    {
      "q": "Which of these is a vowel?",
      "options": ["X", "E", "M", "T"],
      "answer": 1
    },
    {
      "q": "What is the opposite of 'Good'?",
      "options": ["Bad", "Happy", "Tall", "Fast"],
      "answer": 0
    }
  ];

  void _submitAnswer() {
    if (_selectedAnswer == null) return;
    
    if (_selectedAnswer == _questions[_currentQuestionIndex]["answer"]) {
      _score += 100 ~/ _questions.length;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
      });
    } else {
      // Test finished
      String moduleName = widget.courseName == "English" ? "MCQ Test" : "MCQ ટેસ્ટ (Test)";
      MockData.updateScore(widget.courseName, moduleName, _score);
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(AppLocale.t("Test Complete", widget.lang)),
          content: Text("${AppLocale.t("Overall Score", widget.lang)}: $_score%"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // go back to course detail
              },
              child: Text(AppLocale.t("OK", widget.lang)),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("MCQ - ${widget.courseName}", style: TextStyle(color: theme.colorScheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Question ${_currentQuestionIndex + 1} of ${_questions.length}",
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Text(
              q["q"],
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(height: 30),
            
            ...List.generate(q["options"].length, (index) {
              final isSelected = _selectedAnswer == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedAnswer = index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.primaryColor.withValues(alpha: 0.1) : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected ? theme.primaryColor : theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
                      ),
                      const SizedBox(width: 15),
                      Text(
                        q["options"][index],
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedAnswer == null ? null : _submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  disabledBackgroundColor: theme.colorScheme.surface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _currentQuestionIndex < _questions.length - 1 ? "NEXT" : "SUBMIT",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _selectedAnswer == null ? theme.textTheme.bodyMedium?.color : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'language_screen.dart';

class TermsScreen extends StatefulWidget {
  final String role;
  final String userName;
  const TermsScreen({super.key, required this.role, required this.userName});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool accepted = false;

  void _continue() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LanguageScreen(role: widget.role, userName: widget.userName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Terms & Conditions", style: TextStyle(color: theme.colorScheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Usage Agreement",
                    style: theme.textTheme.displayMedium,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Welcome to Deaf and Mute Learning App. As a ${widget.role}, you agree to the following conditions:\n\n"
                    "1. Respectful Environment: You will maintain a positive and inclusive environment for all learners.\n\n"
                    "2. Academic Integrity: Tests must be taken independently.\n\n"
                    "3. Analytics: Your data may be collected to improve the application experience and provide better learning paths.\n\n"
                    "4. Data Security: Your personal information is kept secure and will not be shared without consent.\n\n"
                    "By continuing, you acknowledge that you have read and understood these terms.",
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: accepted,
                        activeColor: theme.primaryColor,
                        onChanged: (v) => setState(() => accepted = v ?? false),
                      ),
                      Expanded(
                        child: Text("I accept the terms and conditions", style: theme.textTheme.titleLarge?.copyWith(fontSize: 16)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: accepted ? _continue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        disabledBackgroundColor: theme.colorScheme.surface,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "CONTINUE",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: accepted ? Colors.white : theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

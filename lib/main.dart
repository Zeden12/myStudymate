import 'package:flutter/material.dart';
import 'package:mystudymate/screens/auth/login_screen.dart';
import 'package:mystudymate/db/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await DatabaseHelper.instance.database; // Initialize database
    runApp(const StudyMatePro());
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize database: $e'),
          ),
        ),
      ),
    );
  }
}

class StudyMatePro extends StatelessWidget {
  const StudyMatePro({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyMate Pro',
      theme: _buildAppTheme(),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      primarySwatch: Colors.green,
      colorScheme: ColorScheme.light(
        primary: Colors.green.shade700,
        secondary: Colors.green.shade500,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.green.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, 
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
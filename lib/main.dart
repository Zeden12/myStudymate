import 'package:flutter/material.dart';
import 'package:mystudymate/screens/auth/login_screen.dart';
import 'package:mystudymate/db/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database; // Initialize database
  runApp(const MyStudyMateApp());
}

class MyStudyMateApp extends StatelessWidget {
  const MyStudyMateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyMate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
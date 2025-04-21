import 'package:flutter/material.dart';
import 'package:mystudymate/models/user_model.dart';
import 'package:mystudymate/screens/auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyMate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${user.fullName}!', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            Text('Email: ${user.email}'),
            Text('School: ${user.school}'),
            Text('Department: ${user.department}'),
            Text('Level: ${user.level}'),
          ],
        ),
      ),
    );
  }
}
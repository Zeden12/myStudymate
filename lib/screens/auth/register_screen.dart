import 'package:flutter/material.dart';
import 'package:mystudymate/db/helpers/user_helper.dart';
import 'package:mystudymate/db/database.dart';
import 'package:mystudymate/models/user_model.dart';
import 'package:mystudymate/screens/auth/login_screen.dart';
import 'package:mystudymate/screens/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _schoolController = TextEditingController();
  final _departmentController = TextEditingController();
  final _levelController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dbHelper = DatabaseHelper.instance;
  late UserHelper _userHelper;
  String _selectedRole = 'student';
  bool _isLoading = false;

  final List<String> _schools = ['School of Engineering', 'School of Medicine', 'School of Arts'];
  final List<String> _departments = ['Computer Science', 'Electrical Engineering', 'Mechanical Engineering'];
  final List<String> _levels = ['100', '200', '300', '400'];

  @override
  void initState() {
    super.initState();
    _userHelper = UserHelper(_dbHelper);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('StudyMate Pro - Register'),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.green[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.green[50],
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone (optional)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.green[50],
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  items: const [
                    DropdownMenuItem(
                      value: 'student',
                      child: Text('Student'),
                    ),
                    DropdownMenuItem(
                      value: 'lecturer',
                      child: Text('Lecturer'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.green[50],
                  ),
                  onChanged: (value) => setState(() => _selectedRole = value!),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _schools.first,
                  items: _schools.map((school) {
                    return DropdownMenuItem(
                      value: school,
                      child: Text(school),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'School',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.green[50],
                  ),
                  onChanged: (value) => _schoolController.text = value!,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _departments.first,
                  items: _departments.map((dept) {
                    return DropdownMenuItem(
                      value: dept,
                      child: Text(dept),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.green[50],
                  ),
                  onChanged: (value) => _departmentController.text = value!,
                ),
                SizedBox(height: 16),
                if (_selectedRole == 'student')
                  DropdownButtonFormField<String>(
                    value: _levels.first,
                    items: _levels.map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text('Level $level'),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Level',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.green[50],
                    ),
                    onChanged: (value) => _levelController.text = value!,
                  ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.green[50],
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.green[50],
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                _isLoading
                    ? CircularProgressIndicator()
                    : SizedBox(height: 24),
_isLoading
    ? CircularProgressIndicator()
    : SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],  // Fixed color value
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _register,
          child: Text(
            'Register',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: Text(
                    'Already have an account? Login',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final user = User(
        fullName: _fullNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        school: _schoolController.text,
        department: _departmentController.text,
        level: _levelController.text,
        password: _passwordController.text,
        role: _selectedRole,
      );

      final existingUser = await _userHelper.getUserByEmail(user.email);
      if (existingUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email already registered'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      await _userHelper.insertUser(user);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration successful! Please login'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _schoolController.dispose();
    _departmentController.dispose();
    _levelController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
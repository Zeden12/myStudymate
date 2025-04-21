import 'package:flutter/material.dart';
import 'package:mystudymate/db/helpers/user_helper.dart';
import 'package:mystudymate/db/database.dart';
import 'package:mystudymate/models/user_model.dart';
import 'package:mystudymate/screens/auth/login_screen.dart';

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

  final List<String> _schools = ['school of ICT','School of Engineering', 'School of science', 'School of Mining & Geology', 'School of Architecture'];
  final List<String> _departments = ['IS','CS', 'IT', 'CSE', 'SE', 'CE', 'EE', 'ME', 'AE', 'CEG', 'CIVIL', 'ARCHITECTURE'];
  final List<String> _levels = ['1', '2', '3', '4'];

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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Create Your Account',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[800]),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionHeader('Personal Information'),
                _buildTextField(_fullNameController, 'Full Name', validator: _requiredValidator),
                const SizedBox(height: 16),
                _buildTextField(_emailController, 'Email', keyboardType: TextInputType.emailAddress, validator: _emailValidator),
                const SizedBox(height: 16),
                _buildTextField(_phoneController, 'Phone (optional)', keyboardType: TextInputType.phone),

                const SizedBox(height: 24),
                _buildSectionHeader('Education & Role'),
                _buildDropdownField(
                  label: 'Role',
                  value: _selectedRole,
                  items: ['student', 'lecturer'],
                  onChanged: (value) => setState(() => _selectedRole = value!),
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'School',
                  value: _schools.first,
                  items: _schools,
                  onChanged: (value) => _schoolController.text = value!,
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Department',
                  value: _departments.first,
                  items: _departments,
                  onChanged: (value) => _departmentController.text = value!,
                ),
                const SizedBox(height: 16),
                if (_selectedRole == 'student')
                  _buildDropdownField(
                    label: 'Level',
                    value: _levels.first,
                    items: _levels,
                    onChanged: (value) => _levelController.text = value!,
                    itemLabelBuilder: (val) => 'Level $val',
                  ),

                const SizedBox(height: 24),
                _buildSectionHeader('Security'),
                _buildTextField(_passwordController, 'Password', obscureText: true, validator: _passwordValidator),
                const SizedBox(height: 16),
                _buildTextField(_confirmPasswordController, 'Confirm Password', obscureText: true, validator: _confirmPasswordValidator),

                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _register,
                          child: const Text('Register', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: Text('Already have an account? Login', style: TextStyle(color: Colors.green[700])),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.green[800]),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.green[50],
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    String Function(String)? itemLabelBuilder,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(itemLabelBuilder?.call(item) ?? item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.green[50],
        border: const OutlineInputBorder(),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    return (value == null || value.isEmpty) ? 'This field is required' : null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!value.contains('@')) return 'Please enter a valid email';
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
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
          const SnackBar(
            content: Text('Email already registered'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      await _userHelper.insertUser(user);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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

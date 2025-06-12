import 'package:flutter/material.dart';
import 'package:lifelink/screens/dashboard/blood_bank_dashboard.dart';
import 'package:lifelink/screens/dashboard/donor_dashboard.dart';
import 'package:lifelink/services/auth_service.dart';

import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final authService = AuthService();

  String email = '';
  String password = '';
  bool isLoading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => isLoading = true);

    try {
      final response = await authService.signIn(email, password);
      final session = response.session;

      if (session != null) {
        final uid = session.user.id;
        final role = await authService.getUserRole(uid);

        if (role == 'donor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DonorDashboard()),
          );
        } else if (role == 'bloodbank') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BloodBankDashboard()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User role not found!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed: No session found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor = Color(0xFF8B0000); // same red as signup screen

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: accentColor,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => email = value ?? '',
                validator: (value) =>
                    value == null || value.isEmpty || !value.contains('@')
                        ? 'Enter a valid email'
                        : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                ),
                obscureText: true,
                onSaved: (value) => password = value ?? '',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter password' : null,
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor:
                              Colors.white, // button text color white
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Login'),
                      ),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  );
                },
                child: Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(color: Color(0xFF8B0000)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

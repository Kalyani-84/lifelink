import 'package:flutter/material.dart';
import 'package:lifelink/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifelink/screens/dashboard/donor_dashboard.dart';
import 'package:lifelink/screens/dashboard/blood_bank_dashboard.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final authService = AuthService();

  String role = 'donor';
  String email = '';
  String password = '';
  String name = '';
  String contact = '';
  String location = '';
  String imageUrl = '';
  String medicalHistory = '';
  String bloodType = '';
  String age = '';
  String licenseNo = '';
  bool isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => isLoading = true);

    Map<String, dynamic> data = {
      'name': name,
      'email': email,
      'password': password,
      'contact': int.tryParse(contact),
      'location': location,
      'image_url': imageUrl,
    };

    if (role == 'donor') {
      data.addAll({
        'medical_history': medicalHistory,
        'bloodtype': bloodType,
        'age': int.tryParse(age),
      });
    } else {
      data['license_no'] = licenseNo;
    }

    try {
      final response = await authService.signUp(
        email: email,
        password: password,
        role: role,
        data: data,
      );

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup successful!')),
        );

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
        }
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    }

    setState(() => isLoading = false);
  }

  Widget _buildRoleSpecificFields() {
    Color accentColor = Color(0xFF8B0000); // Always red

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: role == 'donor'
          ? Column(
              key: const ValueKey('donor'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Medical History',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: accentColor, width: 2),
                    ),
                  ),
                  onSaved: (value) => medicalHistory = value ?? '',
                  validator: (value) =>
                      value!.isEmpty ? 'Enter medical history' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Blood Type',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: accentColor, width: 2),
                    ),
                  ),
                  onSaved: (value) => bloodType = value ?? '',
                  validator: (value) =>
                      value!.isEmpty ? 'Enter blood type' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: accentColor, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => age = value ?? '',
                  validator: (value) => value!.isEmpty ? 'Enter age' : null,
                ),
              ],
            )
          : Column(
              key: const ValueKey('bloodbank'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'License No.',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: accentColor, width: 2),
                    ),
                  ),
                  onSaved: (value) => licenseNo = value ?? '',
                  validator: (value) =>
                      value!.isEmpty ? 'Enter license number' : null,
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor = Color(0xFF8B0000); // Always red

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: role,
                decoration: InputDecoration(
                  labelText: 'Select Role',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'donor', child: Text('Donor')),
                  DropdownMenuItem(
                      value: 'bloodbank', child: Text('Blood Bank')),
                ],
                onChanged: (value) => setState(() => role = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                ),
                onSaved: (value) => name = value ?? '',
                validator: (value) => value!.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
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
                validator: (value) => value!.isEmpty || !value.contains('@')
                    ? 'Enter valid email'
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
                    value!.length < 6 ? 'Min 6 characters' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Contact',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                ),
                keyboardType: TextInputType.phone,
                onSaved: (value) => contact = value ?? '',
                validator: (value) => value!.isEmpty ? 'Enter contact' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                ),
                onSaved: (value) => location = value ?? '',
                validator: (value) => value!.isEmpty ? 'Enter location' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Image URL (optional)',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                ),
                onSaved: (value) => imageUrl = value ?? '',
              ),
              const SizedBox(height: 16),
              _buildRoleSpecificFields(),
              const SizedBox(height: 24),
              isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor:
                              const Color(0xFFFDF4F4), // text color white
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Sign Up'),
                      ),
                    ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: Text(
                  "Already have an account? Login",
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

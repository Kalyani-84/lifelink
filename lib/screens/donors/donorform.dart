import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lifelink/screens/donors/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class DonorFormPage extends StatefulWidget {
  const DonorFormPage({super.key});

  @override
  State<DonorFormPage> createState() => _DonorFormPageState();
}

class _DonorFormPageState extends State<DonorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'name': '',
    'age': '',
    'gender': '',
    'weight': '',
    'blood_group': '',
    'location': '',
    'medical_history': '',
  };

  String? _resultMessage;
  bool? _eligible;
  bool _loading = false;

  Future<bool> submitDonorData(Map<String, dynamic> donorData) async {
    final response = await http.post(
      Uri.parse('https://lifelink-ml-api.onrender.com/predict'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(donorData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get prediction');
    }

    final json = jsonDecode(response.body);
    final eligible = json['eligible'] == true;

    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

    await supabase.from('donor_predictions').insert({
      ...donorData,
      'eligible': eligible,
      'user_id': user.id,
      'created_at': DateTime.now().toIso8601String(),
    });

    return eligible;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _loading = true;
      _resultMessage = null;
    });

    try {
      final eligible = await submitDonorData({
        'name': _formData['name'],
        'age': int.parse(_formData['age']),
        'gender': _formData['gender'],
        'weight': double.parse(_formData['weight']),
        'blood_group': _formData['blood_group'],
        'location': _formData['location'],
        'medical_history': _formData['medical_history'],
      });

      setState(() {
        _eligible = eligible;
      });
    } catch (e) {
      setState(() {
        _resultMessage = 'Error: $e';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red.shade100),
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      fillColor: Colors.red.shade100,
      filled: true,
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          ...[
            'Name',
            'Age',
            'Gender',
            'Weight',
            'Blood Group',
            'Location',
          ].map((field) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  decoration: _inputDecoration(field),
                  keyboardType: field == 'Age' || field == 'Weight'
                      ? TextInputType.number
                      : TextInputType.text,
                  onSaved: (v) =>
                      _formData[field.toLowerCase().replaceAll(' ', '_')] =
                          v ?? '',
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                ),
              )),
          TextFormField(
            decoration: _inputDecoration('Medical History (optional)'),
            onSaved: (v) => _formData['medical_history'] = v ?? '',
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: bloodRed,
                foregroundColor: Colors.white,
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _submit,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Check Eligibility'),
            ),
          ),
          if (_resultMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _resultMessage!,
              style:
                  const TextStyle(color: bloodRed, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResult() {
    final isEligible = _eligible == true;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isEligible ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: isEligible ? Colors.green : bloodRed,
            size: 96,
          ),
          const SizedBox(height: 20),
          Text(
            isEligible
                ? '✅ You are eligible to donate blood!'
                : '❌ You are not eligible to donate blood.',
            style: TextStyle(
              color: isEligible ? Colors.green[700] : bloodRed,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          ElevatedButton(
            onPressed: () => setState(() => _eligible = null),
            child: const Text('Check Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: bloodRed,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF4F4),
        elevation: 0,
        leading: BackButton(color: bloodRed),
        title: Text(
          'Donor Eligibility Check',
          style: TextStyle(
              color: bloodRed, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_eligible == null ? _buildForm() : _buildResult()),
      ),
    );
  }
}

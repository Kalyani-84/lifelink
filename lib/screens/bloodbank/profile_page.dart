import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifelink/screens/auth/login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? bloodBankData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchBloodBankData();
  }

  Future<void> fetchBloodBankData() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final response =
        await supabase.from('bloodbank').select().eq('bbid', userId).single();

    setState(() {
      bloodBankData = response;
      loading = false;
    });
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Do you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await supabase.auth.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showEditDialog() {
    final nameController = TextEditingController(text: bloodBankData!['name']);
    final contactController = TextEditingController(
      text: bloodBankData!['contact']?.toString(),
    );
    final locationController = TextEditingController(
      text: bloodBankData!['location'],
    );
    final licenseController = TextEditingController(
      text: bloodBankData!['license_no'],
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: contactController,
                decoration: const InputDecoration(labelText: 'Contact'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: licenseController,
                decoration: const InputDecoration(labelText: 'License No'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // close dialog
              final userId = supabase.auth.currentUser?.id;
              if (userId == null) return;
              await supabase.from('bloodbank').update({
                'name': nameController.text.trim(),
                'contact': int.tryParse(contactController.text.trim()),
                'location': locationController.text.trim(),
                'license_no': licenseController.text.trim(),
              }).eq('bbid', userId);

              fetchBloodBankData(); // refresh UI
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String? value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 20),
      child: Row(
        children: [
          if (icon != null)
            Icon(icon, color: const Color(0xFF8B0000), size: 20),
          if (icon != null) const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "$title: ",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 15,
                ),
                children: [
                  TextSpan(
                    text: value ?? '-',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.black87,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B0000),
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : bloodBankData == null
              ? const Center(child: Text('Failed to load profile data.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFFE0E0E0),
                        backgroundImage: bloodBankData!['image_url'] != null
                            ? NetworkImage(bloodBankData!['image_url'])
                            : null,
                        child: bloodBankData!['image_url'] == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Color(0xFF8B0000),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        bloodBankData!['name'] ?? 'Blood Bank',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B0000),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoRow(
                        'Email',
                        bloodBankData!['email'],
                        icon: Icons.email,
                      ),
                      _buildInfoRow(
                        'Contact',
                        bloodBankData!['contact']?.toString(),
                        icon: Icons.phone,
                      ),
                      _buildInfoRow(
                        'Location',
                        bloodBankData!['location'],
                        icon: Icons.location_on,
                      ),
                      _buildInfoRow(
                        'License No',
                        bloodBankData!['license_no'],
                        icon: Icons.badge,
                      ),
                      _buildInfoRow(
                        'Role',
                        bloodBankData!['role'],
                        icon: Icons.verified_user,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B0000),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: _showEditDialog,
                            icon: const Icon(Icons.edit, color: Colors.white),
                            label: const Text(
                              'Edit Profile',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B0000),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () => _logout(context),
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lifelink/screens/auth/login_screen.dart';
import 'package:lifelink/screens/donors/donor_profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../donors/PatientPage.dart';
import '../donors/homepage.dart';
import '../donors/checkeligible.dart';

class DonorDashboard extends StatefulWidget {
  const DonorDashboard({Key? key}) : super(key: key);

  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  final supabase = Supabase.instance.client;
  int _selectedIndex = 0;
  String username = 'User';
  Map<String, dynamic>? donorData;

  final List<Widget> _pages = [
    const HomePage(),
    const DonorRequestPage(),
    const PatientPage(),
  ];

  @override
  void initState() {
    super.initState();
    fetchDonorData();
  }

  Future<void> fetchDonorData() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final response =
          await supabase
              .from('donor')
              .select()
              .eq('uid', user.id)
              .maybeSingle();
      if (response != null) {
        setState(() {
          donorData = response;
          username = response['name'] ?? 'User';
        });
      }
    }
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Do you really want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await supabase.auth.signOut();
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  void _navigateToProfileScreen() {
    if (donorData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DonorProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF4F4),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: const Color(0xFFFDF4F4),
              elevation: 2,
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      '👋 Hello, $username',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8B0000),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Color(0xFF8B0000)),
                    onPressed: _showLogoutDialog,
                  ),
                  GestureDetector(
                    onTap: _navigateToProfileScreen,
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFF8B0000),
                      child: Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 2, color: const Color(0xFF8B0000)),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFDF4F4),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF8B0000),
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, color: Color(0xFF8B0000)),
            activeIcon: Icon(Icons.home, color: Color(0xFF8B0000)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.volunteer_activism_outlined,
              color: Color(0xFF8B0000),
            ),
            activeIcon: Icon(
              Icons.volunteer_activism,
              color: Color(0xFF8B0000),
            ),
            label: 'Donor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital_outlined, color: Color(0xFF8B0000)),
            activeIcon: Icon(Icons.local_hospital, color: Color(0xFF8B0000)),
            label: 'Patient',
          ),
        ],
      ),
    );
  }
}
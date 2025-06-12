import 'package:flutter/material.dart';
import 'package:lifelink/screens/bloodbank/donor_table_page.dart';
import 'package:lifelink/screens/bloodbank/request_history_page.dart';
import 'package:lifelink/screens/bloodbank/stock_management_page.dart';
import 'package:lifelink/screens/bloodbank/profile_page.dart';
import 'package:lifelink/screens/auth/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BloodBankDashboard extends StatefulWidget {
  const BloodBankDashboard({Key? key}) : super(key: key);

  @override
  State<BloodBankDashboard> createState() => _BloodBankDashboardState();
}

class _BloodBankDashboardState extends State<BloodBankDashboard> {
  final SupabaseClient supabase = Supabase.instance.client;
  int _selectedIndex = 0;

  String userName = 'User';
  String avatarUrl = '';

  final List<Widget> _pages = [
    const PendingRequestsPage(),
    const DonorListPage(),
    const StockManagementPage(),
  ];

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  void fetchUserDetails() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final response =
            await supabase
                .from('bloodbank')
                .select()
                .eq('bbid', user.id)
                .single();

        setState(() {
          userName = response['name'] ?? 'User';
          avatarUrl = response['avatar_url'] ?? '';
        });
      } catch (e) {
        print('❌ Failed to fetch blood bank user data: $e');
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLogoutDialog(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF4F4),
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hello! $userName 👋',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8B0000),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: Color(0xFF8B0000),
                        ),
                        onPressed: () => _showLogoutDialog(context),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfilePage(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xFF8B0000),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFF8B0000)),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFDF4F4),
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF8B0000),
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined, color: Color(0xFF8B0000)),
            activeIcon: Icon(Icons.assignment, color: Color(0xFF8B0000)),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline, color: Color(0xFF8B0000)),
            activeIcon: Icon(Icons.people, color: Color(0xFF8B0000)),
            label: 'Donors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined, color: Color(0xFF8B0000)),
            activeIcon: Icon(Icons.inventory_2, color: Color(0xFF8B0000)),
            label: 'Stock',
          ),
        ],
      ),
    );
  }
}
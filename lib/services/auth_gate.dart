import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifelink/screens/onboarding/onboarding_screen.dart';
import 'package:lifelink/screens/dashboard/donor_dashboard.dart';
import 'package:lifelink/screens/dashboard/blood_bank_dashboard.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _navigateFromSession();
  }

  Future<void> _navigateFromSession() async {
    await Future.delayed(const Duration(seconds: 2)); // splash delay

    final session = supabase.auth.currentSession;
    if (session == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
      return;
    }

    final userId = session.user.id;

    final donor =
        await supabase.from('donor').select().eq('uid', userId).maybeSingle();
    if (donor != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const DonorDashboard()));
      return;
    }

    final bank = await supabase
        .from('bloodbank')
        .select()
        .eq('bbid', userId)
        .maybeSingle();
    if (bank != null) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const BloodBankDashboard()));
      return;
    }

    // If user not found in any table
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

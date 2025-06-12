import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 🔐 Sign Up (Donor or Blood Bank)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String role, // 'donor' or 'bloodbank'
    required Map<String, dynamic> data,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final userId = response.user?.id;

    if (userId != null) {
      final Map<String, dynamic> completeData = {
        ...data,
        'role': role,
      };

      if (role == 'donor') {
        await _supabase.from('donor').insert({
          'uid': userId, // ✅ updated column name
          ...completeData,
        });
      } else if (role == 'bloodbank') {
        await _supabase.from('bloodbank').insert({
          'bbid': userId, // ✅ same as before
          ...completeData,
        });
      }
    }

    return response;
  }

  // 🔑 Login
  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // 🚪 Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // 📦 Get Current Session
  Session? getSession() => _supabase.auth.currentSession;

  // 🔍 Get User Role by UID
  Future<String?> getUserRole(String uid) async {
    final donor = await _supabase
        .from('donor')
        .select('uid') // ✅ updated
        .eq('uid', uid)
        .maybeSingle();

    if (donor != null) return 'donor';

    final bloodBank = await _supabase
        .from('bloodbank')
        .select('bbid') // ✅ unchanged
        .eq('bbid', uid)
        .maybeSingle();

    if (bloodBank != null) return 'bloodbank';

    return null;
  }
}

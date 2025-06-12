import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getUserById(String userId) async {
    final response = await supabase
        .from('users')
        .select()
        .eq('id', userId)
        .single();

    return response;
  }
}
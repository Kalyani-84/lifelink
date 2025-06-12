import 'package:flutter/material.dart';
import 'package:lifelink/screens/splash/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dexqhfuaujdltuprtxzt.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRleHFoZnVhdWpkbHR1cHJ0eHp0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY3MjE0NjYsImV4cCI6MjA2MjI5NzQ2Nn0.ZR259lBVw6oDkcEQTmfeWGoLxkDNa6GybWMf-TtCEFc',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeLink',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

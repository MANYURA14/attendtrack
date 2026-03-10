import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AttendTrackApp());
}

class AttendTrackApp extends StatelessWidget {
  const AttendTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AttendTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF00C8FF),
          surface: const Color(0xFF0D1220),
          background: const Color(0xFF07080F),
        ),
        scaffoldBackgroundColor: const Color(0xFF07080F),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

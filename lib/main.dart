import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'logic/presentation/screens/login_screen.dart';
import 'logic/presentation/screens/main_wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TigerApp());
}

class TigerApp extends StatelessWidget {
  const TigerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tiger Fitness',
      theme: AppTheme.darkTheme,
      // البداية من شاشة الفحص
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // التحقق من حالة الدخول
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    // انتظار بسيط لضمان استقرار الواجهة
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainWrapper()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFFD4FF00)),
      ),
    );
  }
}
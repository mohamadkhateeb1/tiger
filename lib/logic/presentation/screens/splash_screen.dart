import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _checkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // فحص القيمة المحفوظة في الهاتف
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // انتظر ثانيتين (اختياري لظهور اللوجو)
    await Future.delayed(const Duration(seconds: 2));

    if (isLoggedIn) {
      // إذا كان مسجلاً، اذهب لصفحة التمارين مباشرة
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // إذا لم يكن مسجلاً، اذهب لصفحة تسجيل الدخول
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black, // خلفية سوداء تناسب هوية النمر
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFFD4FF00)), // لودر فوسفوري
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ إضافة مكتبة url_launcher
import '../../../../core/theme.dart';
import 'main_wrapper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // --- دالة فتح الواتساب للتسجيل ---
  Future<void> _openWhatsAppRegistration() async {
    const String phoneNumber = "905347321137"; // رقم التواصل الخاص بالمدرب
    const String message = "مرحباً كوتش، أريد التسجيل والاشتراك في النادي 🐯";
    final Uri whatsappUri = Uri.parse("whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}");
    final Uri whatsappWebUri = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri);
      } else {
        await launchUrl(whatsappWebUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("خطأ في فتح واتساب: $e");
    }
  }

  // --- دالة الدخول كضيف ---
  void _handleGuestLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setBool('is_guest', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainWrapper()),
    );
  }

  // --- دالة معالجة تسجيل الدخول ---
  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final Map<String, String> allowedUsers = {
      "1": "1",
      "coach@tiger.com": "admin123",
      "test@test.com": "123456",
    };

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar("يرجى إدخال البريد وكلمة المرور");
      return;
    }

    if (allowedUsers.containsKey(email) && allowedUsers[email] == password) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setBool('is_guest', false);
      await prefs.setString('user_email', email);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainWrapper()),
      );
    } else {
      _showErrorSnackBar("بيانات الدخول غير صحيحة، راجع الكوتش 🐯");
    }
  }

  // ويدجت لعرض رسائل الخطأ
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              const Center(
                child: Icon(Icons.fitness_center, size: 80, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 30),
              const Text(
                "تسجيل الدخول",
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "أدخل بياناتك للمتابعة في تدريبك 🐯",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryColor),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  child: const Text("دخول الآن", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: _handleGuestLogin,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("الدخول كضيف 👁️", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: Wrap(
                  children: [
                    const Text("ليس لديك حساب؟ ", style: TextStyle(color: Colors.white)),
                    // ✅ تم ربط الدالة الجديدة بالزر هنا
                    GestureDetector(
                      onTap: _openWhatsAppRegistration,
                      child: const Text("اتصل بالمدرب للتسجيل", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30), // مساحة إضافية في الأسفل
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme.dart';
import 'api_service.dart';
import 'main_wrapper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // 🔄 حالة تحميل تظهر أثناء انتظار رد الخادم، وتمنع الضغط المتكرر على الزر
  bool _isLoading = false;

  final ApiService _apiService = ApiService();

  // --- دالة فتح الواتساب للتسجيل ---
  Future<void> _openWhatsAppRegistration() async {
    const String phoneNumber = "905347321137"; // رقم التواصل الخاص بالمدرب
    const String message = "مرحباً كوتش، أريد التسجيل والاشتراك في النادي";
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

  // --- دالة معالجة تسجيل الدخول الحقيقي عبر الـ API ---
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar("يرجى إدخال البريد وكلمة المرور");
      return;
    }

    setState(() => _isLoading = true);

    final result = await _apiService.login(email, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setBool('is_guest', false);
      await prefs.setString('auth_token', result.token!);
      await prefs.setInt('player_id', result.player!.id);
      await prefs.setString('player_name', result.player!.name);
      await prefs.setString('player_email', result.player!.email);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainWrapper()),
      );
    } else {
      _showErrorSnackBar(result.errorMessage ?? "حدث خطأ غير متوقع، حاول مجدداً");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.dangerColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 70),

                // ===== شعار Elite Club — نفس روح شعار الموقع =====
                Center(
                  child: Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.goldLight, AppTheme.primaryColor, AppTheme.goldDark],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.fitness_center_rounded, size: 38, color: Color(0xFF1A1305)),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "ELITE CLUB",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textColor, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Gym Management",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.mutedColor, fontSize: 12, letterSpacing: 1),
                ),

                const SizedBox(height: 44),

                const Text(
                  "تسجيل الدخول",
                  style: TextStyle(color: AppTheme.textColor, fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "أدخل بياناتك للمتابعة في برنامجك التدريبي",
                  style: TextStyle(color: AppTheme.mutedColor, fontSize: 14),
                ),
                const SizedBox(height: 32),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(height: 18),

                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.mutedColor,
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF1A1305)),
                          )
                        : const Text("دخول الآن", style: TextStyle(fontSize: 17)),
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  height: 55,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleGuestLogin,
                    child: const Text("الدخول كضيف", style: TextStyle(fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      const Text("ليس لديك حساب؟ ", style: TextStyle(color: AppTheme.textSoftColor)),
                      GestureDetector(
                        onTap: _openWhatsAppRegistration,
                        child: const Text(
                          "اتصل بالمدرب للتسجيل",
                          style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
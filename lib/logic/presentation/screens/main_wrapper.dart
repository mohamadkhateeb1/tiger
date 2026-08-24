import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme.dart';
import 'login_screen.dart';
import 'diet_screen.dart';
import 'workout_screen.dart';
import 'subscription_screen.dart';
import 'featured_players_screen.dart'; // استدعاء صفحة الأبطال الجديدة

class MainWrapper extends StatefulWidget {
  const MainWrapper({Key? key}) : super(key: key);

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  bool _isGuest = false; // متغير لمعرفة هل هو ضيف
  bool _isLoading = true; // متغير للانتظار حتى نجلب الحالة

  @override
  void initState() {
    super.initState();
    _checkGuestStatus();
  }

  // دالة لفحص حالة الضيف من الذاكرة
  Future<void> _checkGuestStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isGuest = prefs.getBool('is_guest') ?? false;
      _isLoading = false; // تم جلب البيانات بنجاح
    });
  }

  @override
  Widget build(BuildContext context) {
    // شاشة تحميل بسيطة ريثما يتم التحقق من الحالة
    if (_isLoading) {
      return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
      );
    }

    // تحديد قائمة الصفحات بناءً على نوع المستخدم (ضيف أم مشترك)
    final List<Widget> pages = [
      const DietScreen(),
      const WorkoutScreen(),
      _isGuest ? const FeaturedPlayersScreen() : const SubscriptionScreen(),
    ];

    return Container(
      // الطبقة الأساسية: صورة الخلفية
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/background/background2.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,

        floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: FloatingActionButton.small(
            backgroundColor: Colors.black.withOpacity(0.5),
            elevation: 0,
            child: const Icon(Icons.logout, color: Colors.redAccent, size: 25),
            onPressed: () => _showLogoutDialog(context),
          ),
        ),

        body: Stack(
          children: [
            // 1. طبقة خفض الإضاءة (التعتيم)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),

            // 2. عرض الصفحات فوق طبقة التعتيم
            IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
          ],
        ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.cardColor.withOpacity(0.85),
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.white54,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'التغذية'),
            const BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'التمارين'),
            // تغيير أيقونة واسم الزر بناءً على نوع المستخدم
            BottomNavigationBarItem(
              icon: Icon(_isGuest ? Icons.star : Icons.person),
              label: _isGuest ? 'الأبطال' : 'حسابي',
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("خروج", style: TextStyle(color: Colors.white)),
        content: const Text("هل تريد مغادرة التطبيق؟ 🐯", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // مسح جميع البيانات (بما فيها حالة الضيف)
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
            child: const Text("خروج"),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme.dart';
import 'login_screen.dart';
import 'diet_screen.dart';
import 'workout_screen.dart';
import 'subscription_screen.dart';
import 'featured_players_screen.dart'; // استدعاء صفحة الأبطال الجديدة

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

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
        backgroundColor: AppTheme.backgroundColor,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    // تحديد قائمة الصفحات بناءً على نوع المستخدم (ضيف أم مشترك)
    final List<Widget> pages = [
      const DietScreen(),
      const WorkoutScreen(),
      _isGuest ? const FeaturedPlayersScreen() : const SubscriptionScreen(),
    ];

    return Container(
      // ✅ خلفية Elite Club: توهّج ذهبي خفيف بالزاوية، بلا أي صورة أو شعار قديم
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.3,
          colors: [Color(0x1FC9A961), AppTheme.backgroundColor],
          stops: [0.0, 0.65],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,

        floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surfaceColor,
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppTheme.dangerColor, size: 22),
              onPressed: () => _showLogoutDialog(context),
            ),
          ),
        ),

        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.surfaceColor.withOpacity(0.96),
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.mutedColor,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.restaurant_outlined), activeIcon: Icon(Icons.restaurant), label: 'التغذية'),
            const BottomNavigationBarItem(icon: Icon(Icons.fitness_center_outlined), activeIcon: Icon(Icons.fitness_center), label: 'التمارين'),
            // تغيير أيقونة واسم الزر بناءً على نوع المستخدم
            BottomNavigationBarItem(
              icon: Icon(_isGuest ? Icons.star_outline : Icons.person_outline),
              activeIcon: Icon(_isGuest ? Icons.star : Icons.person),
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
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("خروج", style: TextStyle(color: AppTheme.textColor)),
        content: const Text("هل تريد مغادرة التطبيق؟", style: TextStyle(color: AppTheme.textSoftColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء", style: TextStyle(color: AppTheme.mutedColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor, foregroundColor: Colors.white),
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
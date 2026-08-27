import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme.dart';
import '../../../data/models/subscription_model.dart';
import 'api_service.dart';
import 'login_screen.dart';
import 'workout_screen.dart'; // ✅ استيراد صفحة التمارين للربط
import 'profile_screen.dart'; // ✅ استيراد صفحة الملف الشخصي

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final ApiService _apiService = ApiService();

  // 🔄 حالة الجلب: تحميل / خطأ / نجاح — بدل التاريخ الثابت السابق
  bool _isLoading = true;
  String? _errorMessage;
  SubscriptionModel? _subscription;

  // --- حالة التمارين المنجزة لهذا الأسبوع (محلية، مستقلة عن الاشتراك تماماً) ---
  int _completedWorkouts = 2;
  final int _totalWeeklyWorkouts = 5;

  // --- حالة تسجيل الحضور اليومي ---
  bool _isCheckedInToday = false;
  bool _isCheckingIn = false;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
    _loadTodayCheckinStatus();
  }

  String _todayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  /// يقرأ حالة تسجيل الحضور المحفوظة محلياً لتفادي طلب API إضافي عند فتح
  /// الشاشة فقط لمعرفة "هل سجّلت اليوم؟" — يُحدَّث فوراً بعد أي تسجيل ناجح.
  Future<void> _loadTodayCheckinStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckin = prefs.getString('last_checkin_date');
    if (mounted) {
      setState(() => _isCheckedInToday = lastCheckin == _todayDateString());
    }
  }

  Future<void> _handleCheckIn() async {
    setState(() => _isCheckingIn = true);

    final result = await _apiService.checkInAttendance();

    if (!mounted) return;

    if (result.isUnauthorized) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
      return;
    }

    setState(() => _isCheckingIn = false);

    if (result.success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_checkin_date', _todayDateString());

      if (!mounted) return;
      setState(() => _isCheckedInToday = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? "تم تسجيل حضورك بنجاح", style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? "تعذّر تسجيل حضورك، حاول مجدداً", style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  /// 📡 جلب حالة الاشتراك من الـ API. عند انتهاء صلاحية الجلسة (401)
  /// يُعاد توجيه اللاعب تلقائياً لشاشة تسجيل الدخول بدل مجرد عرض خطأ.
  Future<void> _loadSubscription() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _apiService.getSubscription();

    if (!mounted) return;

    if (result.isUnauthorized) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
      return;
    }

    setState(() {
      _isLoading = false;
      if (result.success) {
        _subscription = result.subscription;
      } else {
        _errorMessage = result.errorMessage;
      }
    });
  }

  int _calculateDaysLeft() {
    final difference = _subscription!.endDate.difference(DateTime.now()).inDays;
    return difference > 0 ? difference : 0;
  }

  int _calculateTotalDays() {
    final total = _subscription!.endDate.difference(_subscription!.startDate).inDays;
    return total > 0 ? total : 1; // تجنّب القسمة على صفر إن تطابق التاريخان
  }

  void _markWorkoutDone() {
    if (_completedWorkouts < _totalWeeklyWorkouts) {
      setState(() => _completedWorkouts++);

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("تم تسجيل إنجاز تمرين اليوم بنجاح", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _undoWorkoutDone() {
    if (_completedWorkouts > 0) {
      setState(() => _completedWorkouts--);

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("تم التراجع عن تسجيل التمرين", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('حالة الاشتراك',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppTheme.primaryColor),
            tooltip: 'الملف الشخصي',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    final int daysLeft = _calculateDaysLeft();
    final double progressValue = daysLeft / _calculateTotalDays();

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      backgroundColor: AppTheme.cardColor,
      onRefresh: _loadSubscription,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          children: [
            _buildDaysCounter(daysLeft, progressValue),
            const SizedBox(height: 16),

            _buildAttendanceCheckInBox(),
            const SizedBox(height: 20),

            _buildWeeklyProgressBox(),

            const SizedBox(height: 15),
            _buildFeatureTile(Icons.workspace_premium, "نوع الباقة", _subscription!.planName),
            _buildFeatureTile(Icons.history_toggle_off, "تاريخ انتهاء الاشتراك", _formatDate(_subscription!.endDate)),
            _buildFeatureTile(Icons.speed, "مستوى الالتزام العام", "${(progressValue * 100).clamp(0, 100).toInt()}%"),
            const SizedBox(height: 30),
            _buildSupportSection(),
            const SizedBox(height: 15),
            _buildRenewButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white38, size: 60),
            const SizedBox(height: 20),
            Text(
              _errorMessage ?? "حدث خطأ غير متوقع",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadSubscription,
              icon: const Icon(Icons.refresh, color: Colors.black),
              label: const Text("إعادة المحاولة", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// 🖐️ كرت تسجيل الحضور اليومي بالصالة — مرة واحدة فقط في اليوم.
  Widget _buildAttendanceCheckInBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isCheckedInToday
              ? Colors.greenAccent.withOpacity(0.4)
              : AppTheme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isCheckedInToday ? Icons.check_circle_rounded : Icons.fingerprint,
            color: _isCheckedInToday ? Colors.greenAccent : AppTheme.primaryColor,
            size: 30,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _isCheckedInToday ? "تم تسجيل حضورك اليوم" : "سجّل حضورك اليوم بالصالة",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          if (!_isCheckedInToday)
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: _isCheckingIn ? null : _handleCheckIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isCheckingIn
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Text("تسجيل", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppTheme.cardColor.withOpacity(0.85),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("إنجاز الأسبوع", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text("$_completedWorkouts / $_totalWeeklyWorkouts",
                    style: const TextStyle(color: AppTheme.primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_totalWeeklyWorkouts, (index) {
              bool isDone = index < _completedWorkouts;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutBack,
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: isDone ? AppTheme.primaryColor : Colors.black45,
                  shape: BoxShape.circle,
                  border: Border.all(color: isDone ? AppTheme.primaryColor : Colors.white24, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: isDone ? AppTheme.primaryColor.withOpacity(0.5) : Colors.transparent,
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Icon(
                  isDone ? Icons.check_rounded : Icons.fitness_center_rounded,
                  color: isDone ? Colors.black : Colors.white54,
                  size: 22,
                ),
              );
            }),
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            height: 45,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkoutScreen()),
                );
              },
              icon: const Icon(Icons.play_circle_fill, color: AppTheme.primaryColor),
              label: const Text("بدء تمارين اليوم", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _completedWorkouts < _totalWeeklyWorkouts ? _markWorkoutDone : null,
                    icon: Icon(
                        _completedWorkouts < _totalWeeklyWorkouts ? Icons.task_alt : Icons.emoji_events,
                        color: Colors.black
                    ),
                    label: Text(
                      _completedWorkouts < _totalWeeklyWorkouts ? "تسجيل إنهاء التمرين" : "أكملت الهدف",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      disabledBackgroundColor: Colors.grey.shade800,
                      disabledForegroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: _completedWorkouts < _totalWeeklyWorkouts ? 5 : 0,
                    ),
                  ),
                ),
              ),
              if (_completedWorkouts > 0) ...[
                const SizedBox(width: 10),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.6)),
                  ),
                  child: IconButton(
                    onPressed: _undoWorkoutDone,
                    icon: const Icon(Icons.undo, color: Colors.redAccent),
                    tooltip: "تراجع عن التسجيل",
                  ),
                ),
              ]
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDaysCounter(int daysLeft, double progress) {
    // ✅ الحالة المعروضة تعتمد على is_active القادم من الباك إند
    // (نفس منطق hasActiveSubscription في الموقع)، وليس فقط على الأيام المتبقية.
    final bool isActive = _subscription!.isActive;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 12,
                  color: !isActive || daysLeft <= 5 ? Colors.redAccent : AppTheme.primaryColor,
                  backgroundColor: Colors.black45,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("$daysLeft",
                      style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text("يوم متبقي",
                      style: TextStyle(color: AppTheme.primaryColor, fontSize: 16)),
                ],
              )
            ],
          ),
          const SizedBox(height: 25),
          Text(isActive ? "اشتراكك نشط الآن" : "انتهى الاشتراك",
              style: const TextStyle(fontSize: 18, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return InkWell(
      onTap: () => _openWhatsApp("0947690761", "مرحباً كوتش، أحتاج للمساعدة في نظامي الرياضي"),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF25D366).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF25D366).withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366)),
            SizedBox(width: 15),
            Text("طلب مساعدة من المدرب",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }

  /// ✅ زر التجديد: بما أن الدفع الإلكتروني غير مبني بعد، يفتح واتساب المدرب
  /// مباشرة برسالة جاهزة تتضمّن اسم الباقة الحالية — حل مرحلي عملي إلى
  /// حين بناء بوابة دفع فعلية.
  Widget _buildRenewButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        onPressed: () => _openWhatsApp(
          "0947690761",
          "مرحباً كوتش، أريد تجديد اشتراكي (${_subscription!.planName})",
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.primaryColor),
          backgroundColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text("تجديد الاشتراك عبر المدرب",
            style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _openWhatsApp(String phoneNumber, String message) async {
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
}
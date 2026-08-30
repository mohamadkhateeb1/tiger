import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme.dart';
import '../../../data/models/subscription_model.dart';
import 'api_service.dart';
import 'login_screen.dart';
import 'workout_screen.dart';
import 'profile_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _errorMessage;
  SubscriptionModel? _subscription;

  int _completedWorkouts = 2;
  final int _totalWeeklyWorkouts = 5;

  bool _isCheckedInToday = false;
  bool _isCheckingIn = false;

  // ✨ حركة دخول ناعمة للمحتوى بعد التحميل — بدل الظهور الجامد المفاجئ
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic));
    _loadSubscription();
    _loadTodayCheckinStatus();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String _todayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

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
      _showSnack(result.message ?? "تم تسجيل حضورك بنجاح", AppTheme.successColor);
    } else {
      _showSnack(result.errorMessage ?? "تعذّر تسجيل حضورك، حاول مجدداً", AppTheme.dangerColor);
    }
  }

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
        _fadeController.forward(from: 0);
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
    return total > 0 ? total : 1;
  }

  void _markWorkoutDone() {
    if (_completedWorkouts < _totalWeeklyWorkouts) {
      setState(() => _completedWorkouts++);
      _showSnack("تم تسجيل إنجاز تمرين اليوم بنجاح", AppTheme.successColor);
    }
  }

  void _undoWorkoutDone() {
    if (_completedWorkouts > 0) {
      setState(() => _completedWorkouts--);
      _showSnack("تم التراجع عن تسجيل التمرين", AppTheme.goldDark);
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('حسابي'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'الملف الشخصي',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
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
      backgroundColor: AppTheme.surfaceColor,
      onRefresh: _loadSubscription,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Column(
              children: [
                _buildDaysCounter(daysLeft, progressValue),
                const SizedBox(height: 16),
                _buildAttendanceCheckInBox(),
                const SizedBox(height: 18),
                _buildWeeklyProgressBox(),
                const SizedBox(height: 18),
                _buildFeatureTile(Icons.workspace_premium_outlined, "نوع الباقة", _subscription!.planName, AppTheme.primaryColor),
                _buildFeatureTile(Icons.event_busy_outlined, "تاريخ انتهاء الاشتراك", _formatDate(_subscription!.endDate), AppTheme.dangerColor),
                _buildFeatureTile(Icons.trending_up_rounded, "مستوى الالتزام العام", "${(progressValue * 100).clamp(0, 100).toInt()}%", AppTheme.successColor),
                const SizedBox(height: 26),
                _buildSupportSection(),
                const SizedBox(height: 14),
                _buildRenewButton(),
              ],
            ),
          ),
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
            const Icon(Icons.wifi_off_rounded, color: AppTheme.mutedColor, size: 60),
            const SizedBox(height: 20),
            Text(
              _errorMessage ?? "حدث خطأ غير متوقع",
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSoftColor, fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadSubscription,
              icon: const Icon(Icons.refresh),
              label: const Text("إعادة المحاولة"),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Widget _card({required Widget child, EdgeInsets? padding, Color? borderColor}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor ?? AppTheme.borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: child,
    );
  }

  /// 🖐️ كرت تسجيل الحضور اليومي
  Widget _buildAttendanceCheckInBox() {
    final Color accent = _isCheckedInToday ? AppTheme.successColor : AppTheme.primaryColor;
    return _card(
      padding: const EdgeInsets.all(18),
      borderColor: accent.withOpacity(0.35),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: accent.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(
              _isCheckedInToday ? Icons.check_circle_rounded : Icons.fingerprint,
              color: accent,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _isCheckedInToday ? "تم تسجيل حضورك اليوم" : "سجّل حضورك اليوم بالصالة",
              style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          if (!_isCheckedInToday)
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: _isCheckingIn ? null : _handleCheckIn,
                child: _isCheckingIn
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A1305)),
                      )
                    : const Text("تسجيل"),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressBox() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("إنجاز الأسبوع", style: TextStyle(color: AppTheme.textColor, fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("$_completedWorkouts / $_totalWeeklyWorkouts",
                    style: const TextStyle(color: AppTheme.primaryColor, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_totalWeeklyWorkouts, (index) {
              bool isDone = index < _completedWorkouts;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutBack,
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDone ? AppTheme.primaryColor : AppTheme.surface2Color,
                  shape: BoxShape.circle,
                  border: Border.all(color: isDone ? AppTheme.primaryColor : AppTheme.borderColor, width: 1.5),
                  boxShadow: [
                    if (isDone)
                      BoxShadow(color: AppTheme.primaryColor.withOpacity(0.45), blurRadius: 10, spreadRadius: 1),
                  ],
                ),
                child: Icon(
                  isDone ? Icons.check_rounded : Icons.fitness_center_rounded,
                  color: isDone ? const Color(0xFF1A1305) : AppTheme.mutedColor,
                  size: 20,
                ),
              );
            }),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkoutScreen()));
              },
              icon: const Icon(Icons.play_circle_fill_rounded),
              label: const Text("بدء تمارين اليوم"),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _completedWorkouts < _totalWeeklyWorkouts ? _markWorkoutDone : null,
                    icon: Icon(_completedWorkouts < _totalWeeklyWorkouts ? Icons.task_alt : Icons.emoji_events),
                    label: Text(_completedWorkouts < _totalWeeklyWorkouts ? "تسجيل إنهاء التمرين" : "أكملت الهدف"),
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: AppTheme.surface2Color,
                      disabledForegroundColor: AppTheme.mutedColor,
                    ),
                  ),
                ),
              ),
              if (_completedWorkouts > 0) ...[
                const SizedBox(width: 10),
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.dangerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.dangerColor.withOpacity(0.4)),
                  ),
                  child: IconButton(
                    onPressed: _undoWorkoutDone,
                    icon: const Icon(Icons.undo_rounded, color: AppTheme.dangerColor),
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
    final bool isActive = _subscription!.isActive;
    final Color ringColor = !isActive || daysLeft <= 5 ? AppTheme.dangerColor : AppTheme.primaryColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.surfaceColor, AppTheme.surface2Color],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: ringColor.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(color: ringColor.withOpacity(0.12), blurRadius: 30, spreadRadius: 2),
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 18, offset: const Offset(0, 10)),
        ],
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
                  strokeWidth: 11,
                  color: ringColor,
                  backgroundColor: AppTheme.surface2Color,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("$daysLeft",
                      style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                  const Text("يوم متبقي", style: TextStyle(color: AppTheme.primaryColor, fontSize: 15)),
                ],
              )
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: (isActive ? AppTheme.successColor : AppTheme.dangerColor).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isActive ? "اشتراكك نشط الآن" : "انتهى الاشتراك",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isActive ? AppTheme.successColor : AppTheme.dangerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, String title, String value, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: accent.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 14),
          Text(title, style: const TextStyle(color: AppTheme.mutedColor, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return InkWell(
      onTap: () => _openWhatsApp("0947690761", "مرحباً كوتش، أحتاج للمساعدة في نظامي الرياضي"),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF25D366).withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF25D366).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: const Color(0xFF25D366).withOpacity(0.15), shape: BoxShape.circle),
              child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF25D366), size: 20),
            ),
            const SizedBox(width: 14),
            const Text("طلب مساعدة من المدرب", style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.mutedColor, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildRenewButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: () => _openWhatsApp(
          "0947690761",
          "مرحباً كوتش، أريد تجديد اشتراكي (${_subscription!.planName})",
        ),
        child: const Text("تجديد الاشتراك عبر المدرب"),
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
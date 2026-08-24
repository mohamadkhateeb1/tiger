import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme.dart';
import 'workout_screen.dart'; // ✅ استيراد صفحة التمارين للربط

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // --- بيانات الاشتراك ---
  final String expiryDateString = "2026-06-15";
  final int totalSubscriptionDays = 30;

  // --- حالة التمارين المنجزة لهذا الأسبوع ---
  int _completedWorkouts = 2; // القيمة الحالية
  final int _totalWeeklyWorkouts = 5; // الهدف الأسبوعي

  // دالة لحساب الأيام المتبقية
  int _calculateDaysLeft() {
    DateTime expiryDate = DateTime.parse(expiryDateString);
    DateTime now = DateTime.now();
    int difference = expiryDate.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

// ✅ دالة تسجيل التمرين
  void _markWorkoutDone() {
    if (_completedWorkouts < _totalWeeklyWorkouts) {
      setState(() {
        _completedWorkouts++;
      });

      ScaffoldMessenger.of(context).clearSnackBars(); // يقوم بمسح الإشعار القديم فورا
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("عاش يا بطل! تم إنجاز تمرين اليوم بنجاح 🔥", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ✅ دالة التراجع عن إكمال التمرين
  void _undoWorkoutDone() {
    if (_completedWorkouts > 0) {
      setState(() {
        _completedWorkouts--;
      });

      ScaffoldMessenger.of(context).clearSnackBars(); // يقوم بمسح الإشعار القديم فورا
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("تم التراجع عن تسجيل التمرين ⏪", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
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
    final int daysLeft = _calculateDaysLeft();
    final double progressValue = daysLeft / totalSubscriptionDays;

    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text('حالة الاشتراك',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          children: [
            _buildDaysCounter(daysLeft, progressValue),
            const SizedBox(height: 30),

            // صندوق الإنجاز الأسبوعي المحدث
            _buildWeeklyProgressBox(),

            const SizedBox(height: 15),
            _buildFeatureTile(Icons.history_toggle_off, "تاريخ انتهاء الاشتراك", expiryDateString),
            _buildFeatureTile(Icons.speed, "مستوى الالتزام العام", "${(progressValue * 100).toInt()}%"),
            const SizedBox(height: 30),
            _buildSupportSection(),
            const SizedBox(height: 15),
            _buildRenewButton(),
          ],
        ),
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
              const Text("إنجاز الأسبوع 🔥", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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

          // دوائر الأيام التفاعلية
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
                  // ✅ التعديل الجوهري لحل مشكلة الشاشة الحمراء
                  boxShadow: [
                    BoxShadow(
                      // ننتقل من لون الفسفوري للون الشفاف بدلاً من حذف الظل بالكامل
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

          // ✅ زر الانتقال لتمارين اليوم
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

          // ✅ صف يحتوي على زر "التسجيل" وزر "التراجع"
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
                      _completedWorkouts < _totalWeeklyWorkouts ? "تسجيل إنهاء التمرين" : "أكملت الهدف 🏆",
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

              // ✅ ظهور زر التراجع فقط في حال وجود تمرين منجز
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
                  value: progress,
                  strokeWidth: 12,
                  color: daysLeft <= 5 ? Colors.redAccent : AppTheme.primaryColor,
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
          Text(daysLeft > 0 ? "اشتراكك نشط الآن 🔥" : "انتهى الاشتراك ⚠️",
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
      onTap: () => _openWhatsApp("0947690761"),
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
            const SizedBox(width: 15),
            Text("طلب مساعدة من المدرب",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRenewButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.primaryColor),
          backgroundColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text("تجديد الاشتراك المبكر",
            style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    const String message = "مرحباً كوتش، أحتاج للمساعدة في نظامي الرياضي 🐯";
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
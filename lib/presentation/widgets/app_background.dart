import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child; // المحتوى الذي سيكون فوق الخلفية (الصفحة الحالية)

  const AppBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. صورة الخلفية (تغطي الشاشة بالكامل)
        Positioned.fill(
          child: Image.asset(
            'assets/images/background.jpg', // المسار الذي عرفناه
            fit: BoxFit.cover, // لتغطية الشاشة بدون تمطيط
          ),
        ),

        // 2. طبقة تظليل سوداء (خفيفة جداً)
        // هذه الطبقة ضرورية لضمان وضوح النصوص البيضاء فوق أي صورة خلفية
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.6), // تظليل بنسبة 60%
          ),
        ),

        // 3. محتوى الصفحة الحقيقي
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}
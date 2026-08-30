import 'package:flutter/material.dart';

/// 🎨 هوية "Elite Club" الموحّدة — نفس عائلة الألوان المعتمدة بالضبط
/// بلوحتي الأدمن والموظف بالموقع (الذهبي، الأخضر، الأحمر)، بس على خلفية
/// غامقة راقية تناسب طبيعة تطبيق نادي رياضي يُستخدم أثناء التمرين،
/// بدل الفوسفوري النيون القديم أو الأبيض الكامل غير المناسب لهالسياق.
class AppTheme {
  // ── الألوان الأساسية ──
  static const Color primaryColor = Color(0xFFC9A961); // ذهبي (نفس قيمة الموقع بالضبط)
  static const Color goldLight = Color(0xFFDFC57E);
  static const Color goldDark = Color(0xFFA7833E);

  static const Color backgroundColor = Color(0xFF13151A); // كحلي-رمادي غامق دافئ
  static const Color surfaceColor = Color(0xFF1C1F27);    // سطح الكروت
  static const Color surface2Color = Color(0xFF232733);   // سطح ثانوي (حقول الإدخال..)

  static const Color textColor = Color(0xFFF2F3F5);       // نص أساسي فاتح
  static const Color textSoftColor = Color(0xFFB4B9C2);   // نص ثانوي
  static const Color mutedColor = Color(0xFF8A929D);      // نص خافت جداً

  static const Color borderColor = Color(0x29C9A961);     // حدود ذهبية شفافة خفيفة

  // نفس قيم النجاح/الخطر المعتمدة بالضبط بالموقع — اتساق كامل بين المنصتين
  static const Color successColor = Color(0xFF36B37E);
  static const Color dangerColor = Color(0xFFE85D5D);

  // ── بقية الملف — للتوافق الخلفي مع أي كود قديم يستخدم الأسماء القديمة ──
  static const Color cardColor = surfaceColor;
  static const Color secondaryTextColor = mutedColor;

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,
    fontFamily: 'Tajawal', // نفس خط الموقع — لازم تُضاف الخطوط لمجلد fonts (خطوة تالية)

    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: primaryColor,
      surface: surfaceColor,
      error: dangerColor,
      onPrimary: Color(0xFF1A1305),
      onSurface: textColor,
    ),

    cardTheme: CardThemeData(
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: borderColor, width: 1),
      ),
      elevation: 0,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: const Color(0xFF1A1305), // نص غامق فوق الذهبي (تباين واضح)
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Tajawal'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface2Color,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryColor, width: 1.6),
      ),
      labelStyle: const TextStyle(color: mutedColor, fontFamily: 'Tajawal'),
      hintStyle: const TextStyle(color: mutedColor, fontFamily: 'Tajawal'),
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 24, fontFamily: 'Tajawal'),
      bodyLarge: TextStyle(color: textColor, fontSize: 16, fontFamily: 'Tajawal'),
      bodyMedium: TextStyle(color: textSoftColor, fontSize: 14, fontFamily: 'Tajawal'),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryColor),
      titleTextStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Tajawal'),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: mutedColor,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold, fontSize: 11),
      unselectedLabelStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 11),
    ),

    dividerTheme: const DividerThemeData(color: borderColor, thickness: 1),
  );
}
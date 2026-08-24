import 'package:flutter/material.dart';
class AppTheme {
  // الألوان الأساسية الخاصة بـ "هوية النمر"
  static const Color primaryColor = Color(0xFFD4FF00); // الفوسفوري الأساسي
  static const Color backgroundColor = Color(0xFF0F0F0F); // أسود داكن جداً للخلفية
  static const Color cardColor = Color(0xFF1E1E1E); // أسود فاتح قليلاً للكروت
  static const Color secondaryTextColor = Colors.grey;

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,

    // تخصيص الألوان الثانوية (Accent Color)
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      surface: cardColor,
      background: backgroundColor,
    ),

    // تخصيص شكل الكروت في كل التطبيق لتكون بحواف دائرية 20
// داخل ThemeData
    cardTheme: CardThemeData( // أضف كلمة Data هنا
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
    ),

    // تخصيص الأزرار (ElevatedButton)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black, // نص الزر أسود للتباين
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5, // إعطاء عمق بسيط للزر
      ),
    ),

    // تخصيص النصوص
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 24),
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
      bodyMedium: TextStyle(color: secondaryTextColor, fontSize: 14),
    ),

    // تخصيص شريط التنقل السفلي
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: secondaryTextColor,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),
  );
}
/// يمثّل وجبة واحدة ضمن خطة اللاعب الغذائية، بأسماء حقول متطابقة مع
/// أعمدة جدول diet_plans في الموقع (snake_case).
class MealModel {
  final int id;
  final String mealName;
  final int calories;
  final double? protein;
  final double? carbs;
  final double? fats;
  final String planDetails;
  final String? imageUrl;

  MealModel({
    required this.id,
    required this.mealName,
    required this.calories,
    this.protein,
    this.carbs,
    this.fats,
    required this.planDetails,
    this.imageUrl,
  });

  /// 🛡️ تحويل آمن لأي قيمة رقمية قادمة من الـ API، بغضّ النظر عن نوعها
  /// الفعلي بالـ JSON (رقم صريح أو نص) — يحمي من انهيار التطبيق لو
  /// رجع الخادم رقماً كنص بالغلط (مثل حقول decimal بلا cast صريح بلارافيل).
  static double? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? (double.tryParse(value)?.toInt() ?? fallback);
    return fallback;
  }

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: _parseInt(json['id']),
      mealName: json['meal_name'] as String? ?? '',
      calories: _parseInt(json['calories']),
      protein: _parseNum(json['protein']),
      carbs: _parseNum(json['carbs']),
      fats: _parseNum(json['fats']),
      planDetails: json['plan_details'] as String? ?? '',
      // 📸 يصل رابطاً كاملاً جاهزاً من الـ API (وليس مساراً نسبياً)،
      // حتى لا يحتاج التطبيق لمعرفة دومين التخزين أو بنائه بنفسه.
      imageUrl: json['image_url'] as String?,
    );
  }

  /// هل تحتوي هذه الوجبة على أي بيانات ماكروز مُدخَلة من المدرب؟
  bool get hasMacros => protein != null || carbs != null || fats != null;
}
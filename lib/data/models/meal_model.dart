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

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'] as int,
      mealName: json['meal_name'] as String? ?? '',
      calories: json['calories'] as int? ?? 0,
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fats: (json['fats'] as num?)?.toDouble(),
      planDetails: json['plan_details'] as String? ?? '',
      // 📸 يصل رابطاً كاملاً جاهزاً من الـ API (وليس مساراً نسبياً)،
      // حتى لا يحتاج التطبيق لمعرفة دومين التخزين أو بنائه بنفسه.
      imageUrl: json['image_url'] as String?,
    );
  }

  /// هل تحتوي هذه الوجبة على أي بيانات ماكروز مُدخَلة من المدرب؟
  bool get hasMacros => protein != null || carbs != null || fats != null;
}
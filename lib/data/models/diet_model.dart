class DietModel {
  final String id;
  final String name;
  final String imageUrl; // هنا سنضع روابط الصور الخارجية (Pexels/Unsplash)
  final String calories;
  final String description;
  // إضافات ضرورية للأنظمة الرياضية الاحترافية
  final String protein;
  final String carbs;
  final String fats;
  final bool isSelectedByCoach;

  DietModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.calories,
    required this.description,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.isSelectedByCoach = false,
  });

  // تحويل البيانات القادمة من API (Laravel) إلى كائن Dart
  factory DietModel.fromJson(Map<String, dynamic> json) {
    return DietModel(
      id: json['id'].toString(), // تحويل لـ String لضمان عدم حدوث خطأ
      name: json['name'],
      imageUrl: json['image_url'], // تأكد أن الاسم يطابق ما يرسله الباكند
      calories: json['calories'],
      description: json['description'] ?? "",
      protein: json['protein'] ?? "0g",
      carbs: json['carbs'] ?? "0g",
      fats: json['fats'] ?? "0g",
      isSelectedByCoach: json['is_selected_by_coach'] ?? false,
    );
  }

  // تحويل الكائن إلى JSON لإرساله للسيرفر إذا قام اللاعب بتعديل شيء
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'calories': calories,
      'description': description,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'is_selected_by_coach': isSelectedByCoach,
    };
  }
}
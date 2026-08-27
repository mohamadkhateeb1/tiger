/// يمثّل بيانات اللاعب المسجَّل دخوله (هويته الأساسية فقط).
/// بيانات الاشتراك (تاريخ الانتهاء، الحالة...) ستُجلب لاحقاً من نقطة
/// نهاية منفصلة (خطوة قادمة)، وليست جزءاً من رد تسجيل الدخول.
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? level;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.level,
  });

  /// تحويل رد الـ API (JSON) إلى كائن Dart.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      level: json['level'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'level': level,
    };
  }
}
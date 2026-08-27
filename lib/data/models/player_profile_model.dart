/// يمثّل الملف الشخصي الكامل للاعب — أشمل من UserModel المستخدَم عند
/// تسجيل الدخول فقط (يحمل بيانات إضافية: الطول، الوزن، المدرب، تاريخ الانضمام).
class PlayerProfileModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? level;
  final double? height;
  final double? weight;
  final String? dateOfBirth;
  final String? coachName;
  final String joinedAt;

  PlayerProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.level,
    this.height,
    this.weight,
    this.dateOfBirth,
    this.coachName,
    required this.joinedAt,
  });

  factory PlayerProfileModel.fromJson(Map<String, dynamic> json) {
    return PlayerProfileModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      level: json['level'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      dateOfBirth: json['date_of_birth'] as String?,
      coachName: json['coach_name'] as String?,
      joinedAt: json['joined_at'] as String,
    );
  }
}
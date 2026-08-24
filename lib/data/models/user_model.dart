class UserModel {
  final String name;
  final String expiryDate;
  final int totalDays;
  final bool isActive;

  UserModel({required this.name, required this.expiryDate, required this.totalDays, required this.isActive});

  // هذه الدالة ستحول رد السيرفر (JSON) إلى كائن يفهمه Flutter لاحقاً
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      expiryDate: json['expiry_date'],
      totalDays: json['total_days'],
      isActive: json['is_active'],
    );
  }
}
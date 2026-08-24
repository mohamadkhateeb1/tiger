import '../../../data/models/user_model.dart';

class ApiService {
  Future<UserModel> fetchUserProfile() async {
    // محاكاة تأخير الشبكة
    await Future.delayed(const Duration(seconds: 2));

    // بيانات وهمية كأنها قادمة من لوحة تحكم المدير
    return UserModel(
      name: "أحمد محمد",
      expiryDate: "2026-06-20",
      totalDays: 30,
      isActive: true,
    );
  }
}
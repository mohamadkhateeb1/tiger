/// يمثّل رد الـ API لحالة اشتراك اللاعب الحالية.
/// `isActive` يصل جاهزاً من الباك إند (نفس منطق hasActiveSubscription()
/// في الموقع: الحالة + التاريخ معاً)، بدل أن يُحسب محلياً داخل التطبيق.
class SubscriptionModel {
  final String planName;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // active | expired | pending
  final bool isActive;

  SubscriptionModel({
    required this.planName,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.isActive,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      planName: json['plan_name'] as String? ?? 'غير محدد',
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: json['status'] as String? ?? 'expired',
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}
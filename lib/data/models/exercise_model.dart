/// يمثّل تمريناً واحداً ضمن خطة اللاعب، بأسماء حقول متطابقة تماماً مع
/// أعمدة جدول plans في الموقع، لتفادي أي تعارض تسمية عند بناء الـ API.
class ExerciseModel {
  final int id;
  final String name;
  final int sets;
  final int reps;
  final String? restTime;
  final int? dayOfWeek; // 1=السبت ... 7=الجمعة، أو null إذا لم يُجدوَل ليوم محدد
  final int order;
  final String? videoUrl;
  final String? imageUrl;
  final String? instructions;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    this.restTime,
    this.dayOfWeek,
    this.order = 0,
    this.videoUrl,
    this.imageUrl,
    this.instructions,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      sets: json['sets'] as int? ?? 0,
      reps: json['reps'] as int? ?? 0,
      restTime: json['rest_time'] as String?,
      dayOfWeek: json['day_of_week'] as int?,
      order: json['order'] as int? ?? 0,
      videoUrl: json['video_url'] as String?,
      imageUrl: json['image_url'] as String?,
      instructions: json['instructions'] as String?,
    );
  }

  /// أسماء أيام الأسبوع بالعربي، مطابقة تماماً لثابت Plan::DAYS في الموقع
  /// (الأسبوع يبدأ بالسبت وينتهي بالجمعة).
  static const Map<int, String> dayNames = {
    1: 'السبت',
    2: 'الأحد',
    3: 'الإثنين',
    4: 'الثلاثاء',
    5: 'الأربعاء',
    6: 'الخميس',
    7: 'الجمعة',
  };

  String get dayName => dayOfWeek != null ? (dayNames[dayOfWeek] ?? 'غير محدد') : 'غير مجدول';
}
class WorkoutModel {
  final String id;
  final String name;
  final String videoUrl;
  final int sets;
  final int reps;
  final bool isSelected;

  WorkoutModel({
    required this.id,
    required this.name,
    required this.videoUrl,
    required this.sets,
    required this.reps,
    this.isSelected = false,
  });

  // تحويل البيانات من JSON (القادمة من السيرفر أو موقع التحكم) إلى Model
  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'],
      name: json['name'],
      videoUrl: json['videoUrl'],
      sets: json['sets'],
      reps: json['reps'],
      isSelected: json['isSelected'] ?? false,
    );
  }

  // تحويل الـ Model إلى JSON (لإرساله إلى قاعدة البيانات إذا لزم الأمر)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'videoUrl': videoUrl,
      'sets': sets,
      'reps': reps,
      'isSelected': isSelected,
    };
  }
}
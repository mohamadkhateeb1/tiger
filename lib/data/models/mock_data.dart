import 'package:tiger/data/models/workout_model.dart';

class MockData {
  static List<WorkoutModel> allWorkouts = [
    // --- تمارين الصدر (Chest) ---
    WorkoutModel(
        id: '1',
        name: 'Dumbbell Bench Press',
        // رابط مباشر من MuscleWiki (تمرين الصدر بالدمبل)
        videoUrl: 'https://media.musclewiki.com/media/uploads/videos/branded/male-dumbbell-bench-press-front.mp4',
        sets: 3,
        reps: 15,
        isSelected: true
    ),
    WorkoutModel(
        id: '2',
        name: 'Push-ups',
        // رابط تمرين الضغط
        videoUrl: 'https://media.musclewiki.com/media/uploads/videos/branded/male-dumbbell-incline-chest-flys-front.mp4',
        sets: 4,
        reps: 10,
        isSelected: true
    ),
    WorkoutModel(
        id: '3',
        name: 'Chest Fly',
        videoUrl: 'https://media.musclewiki.com/media/uploads/videos/branded/male-dumbbell-flys-front.mp4',
        sets: 3,
        reps: 12,
        isSelected: false
    ),

    // --- تمارين الظهر (Back) ---
    WorkoutModel(
        id: '4',
        name: 'Lat Pulldown',
        videoUrl: 'https://media.musclewiki.com/media/uploads/videos/branded/male-cable-lat-pulldown-front.mp4',
        sets: 3,
        reps: 8,
        isSelected: true
    ),
    WorkoutModel(
        id: '5',
        name: 'Dumbbell Row',
        videoUrl: 'https://media.musclewiki.com/media/uploads/videos/branded/male-dumbbell-row-side.mp4',
        sets: 4,
        reps: 12,
        isSelected: false
    ),

    // --- تمارين الأرجل (Legs) ---
    WorkoutModel(
        id: '6',
        name: 'Bodyweight Squats',
        videoUrl: 'https://media.musclewiki.com/media/uploads/videos/branded/male-bodyweight-squat-front.mp4',
        sets: 4,
        reps: 12,
        isSelected: true
    ),
    WorkoutModel(
        id: '7',
        name: 'Dumbbell Goblet Squat',
        videoUrl: 'https://media.musclewiki.com/media/uploads/videos/branded/male-dumbbell-goblet-squat-front.mp4',
        sets: 3,
        reps: 15,
        isSelected: false
    ),

    // --- تمارين الأكتاف (Shoulders) ---
    WorkoutModel(
        id: '8',
        name: 'Dumbbell Lateral Raise',
        videoUrl: 'https://media.musclewiki.com/media/uploads/videos/branded/male-dumbbell-lateral-raise-front.mp4',
        sets: 3,
        reps: 10,
        isSelected: false
    ),

    // --- تمارين الأذرع (Arms) ---
    WorkoutModel(
        id: '9',
        name: 'Dumbbell Bicep Curl',
        videoUrl: 'https://media.musclewiki.com/media/uploads/videos/branded/male-dumbbell-curl-front.mp4',
        sets: 3,
        reps: 12,
        isSelected: false
    ),

    // --- تمارين البطن (Abs) ---
    WorkoutModel(
        id: '10',
        name: 'Plank',
        videoUrl: 'https://media.musclewiki.com/media/uploads/videos/branded/male-bodyweight-plank-side.mp4',
        sets: 3,
        reps: 60,
        isSelected: true
    ),
  ];
}
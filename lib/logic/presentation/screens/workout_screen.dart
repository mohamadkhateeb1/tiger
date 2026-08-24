import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/models/mock_data.dart';
import '../../../data/models/workout_model.dart';
import '../../../presentation/widgets/workout_video_player.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تصفية التمارين بناءً على بيانات الموديل
    final selectedWorkouts = MockData.allWorkouts.where((w) => w.isSelected).toList();
    final otherWorkouts = MockData.allWorkouts.where((w) => !w.isSelected).toList();

    return Scaffold(
      // ✅ جعل الخلفية شفافة لتظهر صورة الخلفية العالمية من MainWrapper
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text('نادي الأبطال',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text("تمارينك لليوم 🔥",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ),

            // قسم التمارين المختارة (التمرير الأفقي)
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: selectedWorkouts.length,
                itemBuilder: (context, index) => _buildSelectedCard(selectedWorkouts[index]),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Text("مكتبة التمارين",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ),

            // قائمة مكتبة التمارين (التمرير العمودي)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: otherWorkouts.length,
              itemBuilder: (context, index) => _buildSlimListCard(otherWorkouts[index]),
            ),

            // حشو سفلي لضمان عدم اختفاء التمارين خلف البار السفلي
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // بطاقات تمارين اليوم المخصصة
  Widget _buildSelectedCard(WorkoutModel workout) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.4), width: 1),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: WorkoutVideoPlayer(videoUrl: workout.videoUrl),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text(workout.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center),
                const SizedBox(height: 5),
                Text("${workout.sets} جولات × ${workout.reps}",
                    style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // بطاقات مكتبة التمارين النحيفة
  Widget _buildSlimListCard(WorkoutModel workout) {
    return Container(
      height: 90,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.75),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 90,
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(15)), // التغيير لليمين لأن التطبيق عربي
              child: WorkoutVideoPlayer(videoUrl: workout.videoUrl),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${workout.sets} جولات × ${workout.reps}",
                    style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 15),
            child: Icon(Icons.play_arrow_rounded, color: AppTheme.primaryColor, size: 30),
          ),
        ],
      ),
    );
  }
}
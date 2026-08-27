import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme.dart';
import '../../../data/models/exercise_model.dart';
import '../../../presentation/widgets/workout_video_player.dart';
import 'api_service.dart';
import 'login_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<ExerciseModel> _exercises = [];

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  /// 📅 تحويل يوم الأسبوع من ترقيم Dart (1=الاثنين ... 7=الأحد) إلى نفس
  /// ترقيم الموقع (1=السبت ... 7=الجمعة، Plan::DAYS في الموقع بالضبط).
  int _todayAsWeekdayNumber() {
    final dartWeekday = DateTime.now().weekday; // 1=Mon ... 7=Sun
    return ((dartWeekday + 1) % 7) + 1;
  }

  Future<void> _loadWorkouts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _apiService.getWorkouts();

    if (!mounted) return;

    if (result.isUnauthorized) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
      return;
    }

    setState(() {
      _isLoading = false;
      if (result.success) {
        _exercises = result.exercises ?? [];
      } else {
        _errorMessage = result.errorMessage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('برنامجك التدريبي',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_exercises.isEmpty) {
      return _buildEmptyState();
    }

    final int todayNumber = _todayAsWeekdayNumber();
    final todayExercises = _exercises.where((e) => e.dayOfWeek == todayNumber).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    // باقي الأسبوع مجمّع حسب اليوم، بدون تكرار تمارين اليوم الحالي
    final Map<int, List<ExerciseModel>> restOfWeek = {};
    final List<ExerciseModel> unscheduled = [];

    for (final exercise in _exercises) {
      if (exercise.dayOfWeek == todayNumber) continue;

      if (exercise.dayOfWeek == null) {
        unscheduled.add(exercise);
      } else {
        restOfWeek.putIfAbsent(exercise.dayOfWeek!, () => []).add(exercise);
      }
    }

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      backgroundColor: AppTheme.cardColor,
      onRefresh: _loadWorkouts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text("تمارين اليوم — ${ExerciseModel.dayNames[todayNumber]}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ),

            if (todayExercises.isEmpty)
              _buildNoTodayWorkoutsNotice()
            else
              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16),
                  itemCount: todayExercises.length,
                  itemBuilder: (context, index) => _buildSelectedCard(todayExercises[index]),
                ),
              ),

            if (restOfWeek.isNotEmpty || unscheduled.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Text("باقي أسبوعك",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              ...(() {
                final sortedDays = restOfWeek.keys.toList()..sort();
                return sortedDays.map((day) => _buildDayGroup(ExerciseModel.dayNames[day]!, restOfWeek[day]!));
              })(),
              if (unscheduled.isNotEmpty) _buildDayGroup("تمارين حرة", unscheduled),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white38, size: 60),
            const SizedBox(height: 20),
            Text(
              _errorMessage ?? "حدث خطأ غير متوقع",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadWorkouts,
              icon: const Icon(Icons.refresh, color: Colors.black),
              label: const Text("إعادة المحاولة", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.fitness_center, color: Colors.white24, size: 60),
            SizedBox(height: 20),
            Text(
              "لا توجد لديك خطة تدريبية بعد.\nتواصل مع مدربك لإسناد برنامجك.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTodayWorkoutsNotice() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.primaryColor),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "لا توجد تمارين مجدولة لهذا اليوم.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayGroup(String dayLabel, List<ExerciseModel> exercises) {
    exercises.sort((a, b) => a.order.compareTo(b.order));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(dayLabel,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: exercises.length,
            itemBuilder: (context, index) => _buildSlimListCard(exercises[index]),
          ),
        ],
      ),
    );
  }

  /// 🖼️ يعرض فيديو التمرين إن وُجد، وإلا صورته إن وُجدت، وإلا أيقونة افتراضية.
  /// الفيديو له الأولوية لأنه أكثر إفادة، لكن الصورة لا يجب أن تُتجاهل
  /// إذا كانت هي الوسيلة الوحيدة التي أضافها المدرب لهذا التمرين.
  Widget _buildExerciseMedia(ExerciseModel exercise, {required double iconSize}) {
    if (exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty) {
      return WorkoutVideoPlayer(videoUrl: exercise.videoUrl!);
    }

    if (exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty) {
      return Image.network(
        exercise.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            Center(child: Icon(Icons.fitness_center, color: Colors.white24, size: iconSize)),
      );
    }

    return Center(child: Icon(Icons.fitness_center, color: Colors.white24, size: iconSize));
  }

  // بطاقات تمارين اليوم المميّزة
  Widget _buildSelectedCard(ExerciseModel exercise) {
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
              child: _buildExerciseMedia(exercise, iconSize: 40),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text(exercise.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center),
                const SizedBox(height: 5),
                Text(
                  exercise.restTime != null
                      ? "${exercise.sets} جولات × ${exercise.reps} — راحة ${exercise.restTime}"
                      : "${exercise.sets} جولات × ${exercise.reps}",
                  style: const TextStyle(color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // بطاقات باقي الأسبوع النحيفة
  Widget _buildSlimListCard(ExerciseModel exercise) {
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
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(15)),
              child: _buildExerciseMedia(exercise, iconSize: 28),
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
                    exercise.name,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${exercise.sets} جولات × ${exercise.reps}",
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
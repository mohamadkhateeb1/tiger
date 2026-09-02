import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme.dart';
import '../../../data/models/exercise_model.dart';
import '../../../presentation/widgets/workout_video_player.dart';
import 'api_service.dart';
import 'login_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

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

  int _todayAsWeekdayNumber() {
    final dartWeekday = DateTime.now().weekday;
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
        title: const Text('برنامجك التدريبي'),
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
      backgroundColor: AppTheme.surfaceColor,
      onRefresh: _loadWorkouts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("تمارين اليوم — ${ExerciseModel.dayNames[todayNumber]}"),

            if (todayExercises.isEmpty)
              _buildNoTodayWorkoutsNotice()
            else
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  itemCount: todayExercises.length,
                  itemBuilder: (context, index) => TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 350 + index * 80),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(offset: Offset(20 * (1 - value), 0), child: child),
                    ),
                    child: _buildSelectedCard(todayExercises[index]),
                  ),
                ),
              ),

            if (restOfWeek.isNotEmpty || unscheduled.isNotEmpty) ...[
              _sectionTitle("باقي أسبوعك", topPadding: 24),
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

  Widget _sectionTitle(String text, {double topPadding = 6}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, topPadding, 16, 12),
      child: Row(
        children: [
          Container(width: 4, height: 20, decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.goldLight, AppTheme.goldDark]),
            borderRadius: BorderRadius.circular(3),
          )),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
        ],
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
            const Icon(Icons.wifi_off_rounded, color: AppTheme.mutedColor, size: 60),
            const SizedBox(height: 20),
            Text(
              _errorMessage ?? "حدث خطأ غير متوقع",
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSoftColor, fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadWorkouts,
              icon: const Icon(Icons.refresh),
              label: const Text("إعادة المحاولة"),
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
            Icon(Icons.fitness_center_outlined, color: AppTheme.mutedColor, size: 60),
            SizedBox(height: 20),
            Text(
              "لا توجد لديك خطة تدريبية بعد.\nتواصل مع مدربك لإسناد برنامجك.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSoftColor, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTodayWorkoutsNotice() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppTheme.primaryColor),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "لا توجد تمارين مجدولة لهذا اليوم.",
              style: TextStyle(color: AppTheme.textSoftColor, fontSize: 14),
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
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(dayLabel,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            ),
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

  Widget _buildExerciseMedia(ExerciseModel exercise, {required double iconSize}) {
    if (exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty) {
      // 🆕 نمرّر رابط الصورة كبديل احتياطي دايماً — لو الفيديو فشل (رابط
      // يوتيوب أو ملف تالف)، بتظهر الصورة تلقائياً بدل أيقونة عطل فارغة.
      return WorkoutVideoPlayer(
        videoUrl: exercise.videoUrl!,
        fallbackImageUrl: exercise.imageUrl,
      );
    }

    if (exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty) {
      return Image.network(
        exercise.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            Center(child: Icon(Icons.fitness_center_rounded, color: AppTheme.mutedColor, size: iconSize)),
      );
    }

    return Center(child: Icon(Icons.fitness_center_rounded, color: AppTheme.mutedColor, size: iconSize));
  }

  Widget _buildSelectedCard(ExerciseModel exercise) {
    return Container(
      width: 185,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 14, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                color: AppTheme.surface2Color,
                child: _buildExerciseMedia(exercise, iconSize: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(exercise.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textColor, fontSize: 14),
                    textAlign: TextAlign.center),
                const SizedBox(height: 6),
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

  Widget _buildSlimListCard(ExerciseModel exercise) {
    return Container(
      height: 92,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 92,
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
              child: Container(
                color: AppTheme.surface2Color,
                child: _buildExerciseMedia(exercise, iconSize: 28),
              ),
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
                    style: const TextStyle(color: AppTheme.textColor, fontSize: 15.5, fontWeight: FontWeight.bold),
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
          Container(
            margin: const EdgeInsets.only(left: 12),
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.12), shape: BoxShape.circle),
            child: const Icon(Icons.play_arrow_rounded, color: AppTheme.primaryColor, size: 22),
          ),
        ],
      ),
    );
  }
}
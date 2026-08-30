import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme.dart';
import '../../../data/models/meal_model.dart';
import 'api_service.dart';
import 'login_screen.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<MealModel> _meals = [];

  @override
  void initState() {
    super.initState();
    _loadDiet();
  }

  Future<void> _loadDiet() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _apiService.getDiet();

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
        _meals = result.meals ?? [];
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
        title: const Text('نظامك الغذائي'),
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

    if (_meals.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      backgroundColor: AppTheme.surfaceColor,
      onRefresh: _loadDiet,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.72,
        ),
        itemCount: _meals.length,
        itemBuilder: (context, index) => TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index % 6) * 70),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(offset: Offset(0, 16 * (1 - value)), child: child),
          ),
          child: _buildMealCard(context, _meals[index]),
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
            const Icon(Icons.wifi_off_rounded, color: AppTheme.mutedColor, size: 60),
            const SizedBox(height: 20),
            Text(
              _errorMessage ?? "حدث خطأ غير متوقع",
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSoftColor, fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDiet,
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
            Icon(Icons.restaurant_menu_rounded, color: AppTheme.mutedColor, size: 60),
            SizedBox(height: 20),
            Text(
              "لا توجد لديك خطة غذائية بعد.\nتواصل مع مدربك لإسناد وجباتك.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSoftColor, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, MealModel meal) {
    return InkWell(
      onTap: () => _showMealDetails(context, meal),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.borderColor),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Container(
                  color: AppTheme.surface2Color,
                  width: double.infinity,
                  child: meal.imageUrl != null && meal.imageUrl!.isNotEmpty
                      ? Image.network(
                          meal.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.fastfood_rounded, color: AppTheme.mutedColor)),
                        )
                      : const Center(child: Icon(Icons.fastfood_rounded, color: AppTheme.mutedColor)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal.mealName,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textColor, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text("${meal.calories} سعرة",
                        style: const TextStyle(color: AppTheme.primaryColor, fontSize: 11.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMealDetails(BuildContext context, MealModel meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(meal.mealName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text("${meal.calories} سعرة",
                      style: const TextStyle(color: Color(0xFF1A1305), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (meal.hasMacros)
              Row(
                children: [
                  if (meal.protein != null) Expanded(child: _buildMacroInfo("بروتين", meal.protein, const Color(0xFF60A5FA))),
                  if (meal.carbs != null) Expanded(child: _buildMacroInfo("كارب", meal.carbs, const Color(0xFFEAB308))),
                  if (meal.fats != null) Expanded(child: _buildMacroInfo("دهون", meal.fats, const Color(0xFFF87171))),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.surface2Color, borderRadius: BorderRadius.circular(12)),
                child: const Text("لم يحدّد المدرب تفاصيل الماكروز لهذه الوجبة بعد.",
                    style: TextStyle(color: AppTheme.mutedColor, fontSize: 13)),
              ),

            const SizedBox(height: 20),
            const Divider(color: AppTheme.borderColor, height: 1),
            const SizedBox(height: 18),
            const Text("المكونات والتفاصيل",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            const SizedBox(height: 10),
            Text(meal.planDetails,
                style: const TextStyle(fontSize: 14.5, color: AppTheme.textSoftColor, height: 1.6)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroInfo(String label, double? value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text(value != null ? "${value.toStringAsFixed(0)}غ" : "—",
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppTheme.mutedColor, fontSize: 11.5)),
        ],
      ),
    );
  }
} 
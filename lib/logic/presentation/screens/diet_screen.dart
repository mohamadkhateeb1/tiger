import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/models/diet_model.dart';
import '../../../data/models/mock_diet_data.dart';

class DietScreen extends StatelessWidget {
  const DietScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedDiets = MockDietData.allDiets.where((d) => d.isSelectedByCoach).toList();
    final otherDiets = MockDietData.allDiets.where((d) => !d.isSelectedByCoach).toList();

    return Scaffold(
      // ✅ تغيير هام: جعل الخلفية شفافة لتظهر صورة الخلفية من MainWrapper
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text('نظامك الغذائي',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        // ✅ جعل الـ AppBar شفافاً تماماً
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("وجبات اليوم المقترحة 🔥"),

            SizedBox(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: selectedDiets.length,
                itemBuilder: (context, index) => _buildSelectedDietCard(context, selectedDiets[index]),
              ),
            ),

            _buildSectionTitle("مكتبة الوجبات الصحية"),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), // زيادة الحشو السفلي لعدم تداخل المحتوى مع الشريط السفلي
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: otherDiets.length,
              itemBuilder: (context, index) => _buildGridDietCard(context, otherDiets[index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Text(title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildSelectedDietCard(BuildContext context, DietModel diet) {
    return InkWell(
      onTap: () => _showDietDescription(context, diet),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          // ✅ استخدام لون البطاقة من الثيم مع شفافية بسيطة لتعطي تأثيراً زجاجياً
          color: AppTheme.cardColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  diet.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  },
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.fastfood, color: AppTheme.primaryColor, size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(diet.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                      maxLines: 1),
                  const SizedBox(height: 5),
                  Text("${diet.calories} سعرة",
                      style: const TextStyle(color: AppTheme.primaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGridDietCard(BuildContext context, DietModel diet) {
    return InkWell(
      onTap: () => _showDietDescription(context, diet),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  diet.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.fastfood, color: Colors.white24)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(diet.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text("${diet.calories} سعرة",
                      style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة الـ BottomSheet تبقى كما هي لأنها تغطي الشاشة بشكل متعمد عند عرض التفاصيل
  void _showDietDescription(BuildContext context, DietModel diet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(diet.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text("${diet.calories} سعرة",
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroInfo("بروتين", diet.protein),
                _buildMacroInfo("كارب", diet.carbs),
                _buildMacroInfo("دهون", diet.fats),
              ],
            ),
            const SizedBox(height: 15),
            const Divider(color: Colors.white10),
            const SizedBox(height: 15),
            const Text("لماذا هذه الوجبة؟",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            const SizedBox(height: 10),
            Text(diet.description,
                style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.9), height: 1.6)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('إغلاق', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroInfo(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class FeaturedPlayersScreen extends StatelessWidget {
  const FeaturedPlayersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // بيانات وهمية (Mock Data) جاهزة للربط مع API المدير لاحقاً
    final List<Map<String, String>> featuredPlayers = [
      {
        "name": "محمود أحمد",
        "achievement": "خسر 15 كيلو في 3 أشهر 🔥",
        "description": "التزم بخطة الكارب سايكل وتمارين المقاومة العالية.",
        "imageUrl": "https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg" // صورة افتراضية
      },
      {
        "name": "عمر خالد",
        "achievement": "زيادة كتلة عضلية صافية 5 كيلو 🦍",
        "description": "برنامج تضخيم صافي مع التزام تام بالوجبات.",
        "imageUrl": "https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg"
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('أبطال النادي 🏆',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
        itemCount: featuredPlayers.length,
        itemBuilder: (context, index) {
          final player = featuredPlayers[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppTheme.cardColor.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    player["imageUrl"]!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(player["name"]!,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      Text(player["achievement"]!,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                      const SizedBox(height: 8),
                      Text(player["description"]!,
                          style: const TextStyle(color: Colors.white70, height: 1.5)),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
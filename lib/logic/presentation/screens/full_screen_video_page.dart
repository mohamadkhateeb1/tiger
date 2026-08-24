import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
class FullScreenVideoPage extends StatefulWidget {
  final String assetPath;
  const FullScreenVideoPage({Key? key, required this.assetPath}) : super(key: key);

  @override
  State<FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<FullScreenVideoPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // خلفية سوداء بالكامل للتركيز
      body: Stack(
        children: [
          // عرض الفيديو في المنتصف
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
                : const CircularProgressIndicator(color: Color(0xFFD4FF00)),
          ),

          // زر الإغلاق العلوي
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Color(0xFFD4FF00), size: 35),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme.dart';

class WorkoutVideoPlayer extends StatefulWidget {
  // تم تغيير الاسم ليكون عاماً لروابط الإنترنت
  final String videoUrl;
  const WorkoutVideoPlayer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _WorkoutVideoPlayerState createState() => _WorkoutVideoPlayerState();
}

class _WorkoutVideoPlayerState extends State<WorkoutVideoPlayer> {
  late VideoPlayerController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    // التحديث الجوهري: استخدام networkUrl بدلاً من asset
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0); // كتم الصوت في القائمة الرئيسية
        _controller.play();
        if (mounted) setState(() {});
      }).catchError((error) {
        debugPrint("خطأ في تحميل فيديو التمرين: $error");
        if (mounted) {
          setState(() => _hasError = true);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenVideoPage(videoUrl: widget.videoUrl),
          ),
        );
      },
      child: _controller.value.isInitialized
          ? Hero(
        tag: widget.videoUrl, // استخدام الرابط كمعرف فريد
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
      )
          : const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// صفحة الشاشة الكاملة (FullScreenVideoPage)
// -------------------------------------------------------------
class FullScreenVideoPage extends StatefulWidget {
  final String videoUrl;
  const FullScreenVideoPage({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<FullScreenVideoPage> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(1.0); // تشغيل الصوت في العرض الكامل
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // الفيديو في المنتصف مع إمكانية التشغيل والإيقاف بالضغط
          GestureDetector(
            onTap: () {
              setState(() {
                _controller.value.isPlaying ? _controller.pause() : _controller.play();
                _isPlaying = _controller.value.isPlaying;
              });
            },
            child: Center(
              child: _controller.value.isInitialized
                  ? Hero(
                tag: widget.videoUrl,
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
                  : const CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          ),

          // أيقونة حالة التشغيل تظهر مؤقتاً عند الضغط
          if (!_isPlaying)
            const Center(
              child: Icon(Icons.play_arrow, color: AppTheme.primaryColor, size: 80),
            ),

          // أزرار التحكم العلوية
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // زر الرجوع
                CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // زر الإغلاق
                CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.primaryColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
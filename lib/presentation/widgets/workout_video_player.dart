import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../core/theme.dart';

bool _isYoutubeLink(String url) {
  final lower = url.toLowerCase();
  return lower.contains('youtube.com') || lower.contains('youtu.be');
}

/// 🆔 يستخرج معرّف فيديو يوتيوب من أي صيغة رابط شائعة
/// (watch?v=، youtu.be/، shorts/...).
String? _extractYoutubeId(String url) {
  return YoutubePlayerController.convertUrlToId(url);
}

class WorkoutVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? fallbackImageUrl;

  const WorkoutVideoPlayer({Key? key, required this.videoUrl, this.fallbackImageUrl}) : super(key: key);

  @override
  _WorkoutVideoPlayerState createState() => _WorkoutVideoPlayerState();
}

class _WorkoutVideoPlayerState extends State<WorkoutVideoPlayer> {
  VideoPlayerController? _controller;
  bool _hasError = false;
  bool get _isYoutube => _isYoutubeLink(widget.videoUrl);

  @override
  void initState() {
    super.initState();
    if (!_isYoutube) {
      _initializePlayer();
    }
  }

  void _initializePlayer() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        _controller!.setLooping(true);
        _controller!.setVolume(0);
        _controller!.play();
        if (mounted) setState(() {});
      }).catchError((error) {
        debugPrint("خطأ في تحميل فيديو التمرين: $error");
        if (mounted) setState(() => _hasError = true);
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildFallbackVisual({bool showPlayOverlay = false}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.fallbackImageUrl != null && widget.fallbackImageUrl!.isNotEmpty)
          Image.network(
            widget.fallbackImageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const ColoredBox(color: AppTheme.surface2Color),
          )
        else
          const ColoredBox(color: AppTheme.surface2Color),
        if (showPlayOverlay)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF1A1305), size: 28),
              ),
            ),
          )
        else if (widget.fallbackImageUrl == null || widget.fallbackImageUrl!.isEmpty)
          const Center(child: Icon(Icons.fitness_center_rounded, color: AppTheme.mutedColor, size: 36)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // ═══════ رابط يوتيوب: عرض مصغّر + الضغط يفتح مشغّلاً حقيقياً مدمجاً بالتطبيق ═══════
    if (_isYoutube) {
      final videoId = _extractYoutubeId(widget.videoUrl);

      if (videoId == null) {
        // رابط يوتيوب لكن ما قدرنا نطلع منه معرّف صالح (صيغة غير متوقعة)
        return _buildFallbackVisual();
      }

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => YoutubeFullScreenPage(videoId: videoId)),
          );
        },
        child: _buildFallbackVisual(showPlayOverlay: true),
      );
    }

    // ═══════ فيديو مباشر فشل التحميل: رجوع للصورة الاحتياطية ═══════
    if (_hasError) {
      return _buildFallbackVisual();
    }

    // ═══════ فيديو مباشر يعمل بشكل طبيعي ═══════
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FullScreenVideoPage(videoUrl: widget.videoUrl)),
        );
      },
      child: _controller != null && _controller!.value.isInitialized
          ? Hero(
              tag: widget.videoUrl,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor, strokeWidth: 2)),
    );
  }
}

// -------------------------------------------------------------
// 🆕 مشغّل يوتيوب مدمج حقيقي، بشاشة كاملة — يعمل فعلياً جوا التطبيق
// -------------------------------------------------------------
class YoutubeFullScreenPage extends StatefulWidget {
  final String videoId;
  const YoutubeFullScreenPage({Key? key, required this.videoId}) : super(key: key);

  @override
  State<YoutubeFullScreenPage> createState() => _YoutubeFullScreenPageState();
}

class _YoutubeFullScreenPageState extends State<YoutubeFullScreenPage> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        showControls: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        title: const Text('فيديو التمرين', style: TextStyle(color: AppTheme.textColor)),
      ),
      body: Center(
        child: YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
      ),
    );
  }
}

// -------------------------------------------------------------
// صفحة الفيديو المباشر (ملف .mp4 حقيقي) — بلا تغيير جوهري
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
        _controller.setVolume(1.0);
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
          if (!_isPlaying)
            const Center(child: Icon(Icons.play_arrow, color: AppTheme.primaryColor, size: 80)),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
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
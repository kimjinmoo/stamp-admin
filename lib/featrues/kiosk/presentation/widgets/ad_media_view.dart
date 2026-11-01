import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../admin/domain/ad_item.dart';

/// 끊김 없는(Seamless) 광고 롤링 플레이어 위젯
/// - 다음 미디어 사전 캐싱(Pre-caching) 및 백그라운드 프리로딩(Pre-warming)
/// - 이전 미디어와 다음 미디어 간 부드러운 크로스페이드(Cross-fade) 전환
/// - 광고 전환 중 로딩 스피너 깜빡임 원천 차단
class AdMediaView extends StatefulWidget {
  final List<AdItem> ads;
  final int currentIndex;
  final bool isPaused;
  final VoidCallback onMediaFinished;

  const AdMediaView({
    super.key,
    required this.ads,
    required this.currentIndex,
    required this.isPaused,
    required this.onMediaFinished,
  });

  /// 단일 광고 항목과의 레거시 호환을 위한 생성자
  factory AdMediaView.single({
    Key? key,
    required AdItem adItem,
    required bool isPaused,
    required VoidCallback onMediaFinished,
  }) {
    return AdMediaView(
      key: key,
      ads: [adItem],
      currentIndex: 0,
      isPaused: isPaused,
      onMediaFinished: onMediaFinished,
    );
  }

  @override
  State<AdMediaView> createState() => _AdMediaViewState();
}

class _AdMediaViewState extends State<AdMediaView> {
  Timer? _imageTimer;
  VideoPlayerController? _currentVideoController;

  // 다음 비디오를 백그라운드에서 미리 로드해두는 컨트롤러 캐시
  final Map<String, VideoPlayerController> _videoCache = {};

  // 초기화 진행 중인 비디오 ID 집합
  final Set<String> _initializingVideoIds = {};

  bool _hasError = false;
  String _errorMessage = '';

  AdItem? get _currentAd {
    if (widget.ads.isEmpty) return null;
    final index = widget.currentIndex.clamp(0, widget.ads.length - 1);
    return widget.ads[index];
  }

  AdItem? get _nextAd {
    if (widget.ads.length <= 1) return null;
    final nextIndex = (widget.currentIndex + 1) % widget.ads.length;
    return widget.ads[nextIndex];
  }

  @override
  void initState() {
    super.initState();
    _startCurrentMedia();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 1. 모든 이미지 광고를 사전에 메모리에 미리 캐싱 (디코딩 지연 제거)
    _precacheAllImages();
    // 2. 다음 비디오가 있다면 백그라운드에서 미리 초기화
    _preloadNextVideo();
  }

  @override
  void didUpdateWidget(covariant AdMediaView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldAd = oldWidget.ads.isNotEmpty && oldWidget.currentIndex < oldWidget.ads.length
        ? oldWidget.ads[oldWidget.currentIndex]
        : null;
    final newAd = _currentAd;

    // 광고가 바뀌었을 때
    if (oldAd?.id != newAd?.id || oldWidget.currentIndex != widget.currentIndex) {
      _stopCurrentMediaTimer();
      _startCurrentMedia();
      _precacheAllImages();
      _preloadNextVideo();
    } else if (oldWidget.isPaused != widget.isPaused) {
      if (widget.isPaused) {
        _pauseMedia();
      } else {
        _resumeMedia();
      }
    }
  }

  @override
  void dispose() {
    _stopCurrentMediaTimer();
    _currentVideoController?.removeListener(_onVideoStatusChanged);
    _currentVideoController = null;

    // 캐시된 비디오 컨트롤러 전체 안전 해제
    for (final controller in _videoCache.values) {
      controller.dispose();
    }
    _videoCache.clear();
    super.dispose();
  }

  /// 모든 이미지 광고를 Flutter 메모리 캐시에 백그라운드 사전 탑재
  void _precacheAllImages() {
    for (final ad in widget.ads) {
      if (ad.type == AdMediaType.image && ad.path.isNotEmpty) {
        try {
          final ImageProvider provider = ad.sourceType == AdSourceType.network
              ? NetworkImage(ad.path)
              : FileImage(File(ad.path)) as ImageProvider;

          precacheImage(
            provider,
            context,
            onError: (exception, stackTrace) {
              // 네트워크 오프라인 또는 테스트 환경 예외 흡수
            },
          );
        } catch (_) {}
      }
    }
  }

  /// 다음 광고가 비디오일 경우 백그라운드에서 컨트롤러를 미리 생성하고 초기화(Pre-warming)
  void _preloadNextVideo() {
    final next = _nextAd;
    if (next == null || next.type != AdMediaType.video || next.path.isEmpty) {
      return;
    }

    if (_videoCache.containsKey(next.id) || _initializingVideoIds.contains(next.id)) {
      return;
    }

    _initializingVideoIds.add(next.id);
    _createVideoController(next).then((controller) async {
      try {
        await controller.initialize();
        if (mounted) {
          _videoCache[next.id] = controller;
        } else {
          controller.dispose();
        }
      } catch (_) {
        controller.dispose();
      } finally {
        _initializingVideoIds.remove(next.id);
      }
    }).catchError((_) {
      _initializingVideoIds.remove(next.id);
    });
  }

  Future<VideoPlayerController> _createVideoController(AdItem item) async {
    if (item.sourceType == AdSourceType.network) {
      final uri = Uri.parse(item.path);
      return VideoPlayerController.networkUrl(uri);
    } else {
      if (kIsWeb) {
        throw UnsupportedError('웹 환경에서는 로컬 파일 비디오 직접 재생이 제한됩니다.');
      }
      return VideoPlayerController.file(File(item.path));
    }
  }

  void _stopCurrentMediaTimer() {
    _imageTimer?.cancel();
    _imageTimer = null;
    _currentVideoController?.removeListener(_onVideoStatusChanged);
    _hasError = false;
  }

  void _scheduleFallbackTimer() {
    if (_imageTimer != null) return;
    _imageTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !widget.isPaused) {
        widget.onMediaFinished();
      }
    });
  }

  void _startCurrentMedia() {
    final ad = _currentAd;
    if (ad == null) return;

    if (ad.type == AdMediaType.image) {
      _startImageTimer(ad);
    } else {
      _playVideoMedia(ad);
    }
  }

  void _startImageTimer(AdItem ad) {
    _imageTimer?.cancel();
    if (widget.isPaused) return;

    final duration = Duration(
      seconds: ad.durationSeconds > 0 ? ad.durationSeconds : 5,
    );

    _imageTimer = Timer(duration, () {
      if (mounted && !widget.isPaused) {
        widget.onMediaFinished();
      }
    });
  }

  Future<void> _playVideoMedia(AdItem ad) async {
    // 1. 이미 프리워밍(Pre-warmed)된 컨트롤러가 캐시에 있는지 확인
    VideoPlayerController? controller = _videoCache.remove(ad.id);

    if (controller != null && controller.value.isInitialized) {
      _currentVideoController = controller;
      _currentVideoController!.addListener(_onVideoStatusChanged);
      await _currentVideoController!.seekTo(Duration.zero);
      if (!widget.isPaused && mounted) {
        await _currentVideoController!.play();
      }
      if (mounted) setState(() {});
      return;
    }

    // 2. 캐시에 없으면 새로 생성 후 초기화
    try {
      controller = await _createVideoController(ad);
      await controller.initialize();

      if (mounted) {
        _currentVideoController = controller;
        _currentVideoController!.addListener(_onVideoStatusChanged);
        if (!widget.isPaused) {
          await _currentVideoController!.play();
        }
        setState(() {});
      } else {
        controller.dispose();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
        // 비디오 재생 실패 시 3초 후 다음 미디어로 자동 스킵
        _imageTimer = Timer(const Duration(seconds: 3), () {
          if (mounted && !widget.isPaused) {
            widget.onMediaFinished();
          }
        });
      }
    }
  }

  void _onVideoStatusChanged() {
    if (_currentVideoController == null ||
        !_currentVideoController!.value.isInitialized) {
      return;
    }

    final pos = _currentVideoController!.value.position;
    final dur = _currentVideoController!.value.duration;

    if (dur > Duration.zero && pos >= dur) {
      if (mounted && !widget.isPaused) {
        widget.onMediaFinished();
      }
    }
  }

  void _pauseMedia() {
    _imageTimer?.cancel();
    if (_currentVideoController != null &&
        _currentVideoController!.value.isInitialized) {
      _currentVideoController!.pause();
    }
  }

  void _resumeMedia() {
    final ad = _currentAd;
    if (ad == null) return;

    if (ad.type == AdMediaType.image) {
      _startImageTimer(ad);
    } else {
      if (_currentVideoController != null &&
          _currentVideoController!.value.isInitialized) {
        _currentVideoController!.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentAd = _currentAd;

    if (currentAd == null) {
      return Container(color: Colors.black);
    }

    // 부드러운 무한 롤링 크로스페이드 (Cross-fade)
    // 이전 위젯을 아래에 유지한 상태로 새 위젯을 부드럽게 페이드인하여 화면 끊김 및 깜빡임 완전 제거
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 550),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ...previousChildren,
            ?currentChild,
          ],
        );
      },
      child: KeyedSubtree(
        key: ValueKey('${currentAd.id}_${widget.currentIndex}'),
        child: _buildMediaContent(currentAd),
      ),
    );
  }

  Widget _buildMediaContent(AdItem ad) {
    if (_hasError) {
      return _buildErrorPlaceholder(ad, message: _errorMessage);
    }

    if (ad.type == AdMediaType.image) {
      return _buildImageView(ad);
    } else {
      return _buildVideoView(ad);
    }
  }

  Widget _buildImageView(AdItem ad) {
    Widget imageWidget;

    if (ad.sourceType == AdSourceType.network) {
      imageWidget = Image.network(
        ad.path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          _scheduleFallbackTimer();
          return _buildErrorPlaceholder(ad);
        },
      );
    } else {
      if (kIsWeb) {
        imageWidget = _buildErrorPlaceholder(
          ad,
          message: '웹 브라우저에서는 네트워크 URL 이미지를 권장합니다.',
        );
      } else {
        imageWidget = Image.file(
          File(ad.path),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              child: child,
            );
          },
          errorBuilder: (context, error, stackTrace) {
            _scheduleFallbackTimer();
            return _buildErrorPlaceholder(ad);
          },
        );
      }
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildMediaBasePlaceholder(ad),
        imageWidget,
        _buildBottomGradientTitle(ad),
      ],
    );
  }

  Widget _buildVideoView(AdItem ad) {
    final controller = _currentVideoController;

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildMediaBasePlaceholder(ad, isVideo: true),
        if (controller != null && controller.value.isInitialized)
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          )
        else
          const Center(
            child: SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white38,
              ),
            ),
          ),
        _buildBottomGradientTitle(ad),
      ],
    );
  }

  Widget _buildMediaBasePlaceholder(AdItem ad, {bool isVideo = false}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: 0.12,
          child: Icon(
            isVideo ? Icons.videocam_rounded : Icons.image_rounded,
            size: 96,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder(AdItem ad, {String? message}) {
    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Center(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.broken_image_rounded,
                color: AppColors.mutedSoft,
                size: 40,
              ),
              const SizedBox(height: 10),
              Text(
                ad.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                message ?? '미디어를 불러오지 못했습니다. 잠시 후 다음 화면으로 이동합니다.',
                style: const TextStyle(
                  color: AppColors.mutedSoft,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomGradientTitle(AdItem ad) {
    if (ad.title.isEmpty) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(32, 48, 32, 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ad.type == AdMediaType.video
                    ? AppColors.primary
                    : AppColors.secondary,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                ad.type.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ad.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      offset: Offset(0, 1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

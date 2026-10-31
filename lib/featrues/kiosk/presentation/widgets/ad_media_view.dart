import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../admin/domain/ad_item.dart';

/// 이미지 및 동영상 광고를 통합 재생하는 미디어 뷰어 위젯
class AdMediaView extends StatefulWidget {
  final AdItem adItem;
  final bool isPaused;
  final VoidCallback onMediaFinished;

  const AdMediaView({
    super.key,
    required this.adItem,
    required this.isPaused,
    required this.onMediaFinished,
  });

  @override
  State<AdMediaView> createState() => _AdMediaViewState();
}

class _AdMediaViewState extends State<AdMediaView> {
  Timer? _imageTimer;
  VideoPlayerController? _videoController;
  bool _isVideoLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _startMedia();
  }

  @override
  void didUpdateWidget(covariant AdMediaView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.adItem.id != widget.adItem.id ||
        oldWidget.adItem.path != widget.adItem.path) {
      _stopMedia();
      _startMedia();
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
    _stopMedia();
    super.dispose();
  }

  void _stopMedia() {
    _imageTimer?.cancel();
    _imageTimer = null;
    _videoController?.removeListener(_onVideoStatusChanged);
    _videoController?.dispose();
    _videoController = null;
    _hasError = false;
  }

  void _startMedia() {
    if (widget.adItem.type == AdMediaType.image) {
      _startImageTimer();
    } else {
      _initVideoPlayer();
    }
  }

  void _pauseMedia() {
    _imageTimer?.cancel();
    if (_videoController != null && _videoController!.value.isInitialized) {
      _videoController!.pause();
    }
  }

  void _resumeMedia() {
    if (widget.adItem.type == AdMediaType.image) {
      _startImageTimer();
    } else {
      if (_videoController != null && _videoController!.value.isInitialized) {
        _videoController!.play();
      }
    }
  }

  void _startImageTimer() {
    _imageTimer?.cancel();
    if (widget.isPaused) return;

    final duration = Duration(
      seconds: widget.adItem.durationSeconds > 0
          ? widget.adItem.durationSeconds
          : 5,
    );

    _imageTimer = Timer(duration, () {
      if (mounted && !widget.isPaused) {
        widget.onMediaFinished();
      }
    });
  }

  Future<void> _initVideoPlayer() async {
    setState(() {
      _isVideoLoading = true;
      _hasError = false;
    });

    try {
      if (widget.adItem.sourceType == AdSourceType.network) {
        final uri = Uri.parse(widget.adItem.path);
        _videoController = VideoPlayerController.networkUrl(uri);
      } else {
        if (kIsWeb) {
          throw UnsupportedError('웹 환경에서는 로컬 파일 비디오 직접 재생이 제한됩니다.');
        }
        final file = File(widget.adItem.path);
        _videoController = VideoPlayerController.file(file);
      }

      await _videoController!.initialize();
      _videoController!.addListener(_onVideoStatusChanged);

      if (!widget.isPaused && mounted) {
        await _videoController!.play();
      }

      if (mounted) {
        setState(() {
          _isVideoLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
        // 에러 발생 시 3초 후 다음 미디어로 자동 스킵
        _imageTimer = Timer(const Duration(seconds: 3), () {
          if (mounted && !widget.isPaused) {
            widget.onMediaFinished();
          }
        });
      }
    }
  }

  void _onVideoStatusChanged() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return;
    }

    final pos = _videoController!.value.position;
    final dur = _videoController!.value.duration;

    // 재생이 끝에 도달했거나 에러 상태일 때
    if (dur > Duration.zero && pos >= dur) {
      if (mounted && !widget.isPaused) {
        widget.onMediaFinished();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorPlaceholder(
        message: _errorMessage.isNotEmpty ? _errorMessage : null,
      );
    }

    if (widget.adItem.type == AdMediaType.image) {
      return _buildImageView();
    } else {
      return _buildVideoView();
    }
  }

  Widget _buildImageView() {
    Widget imageWidget;

    if (widget.adItem.sourceType == AdSourceType.network) {
      imageWidget = Image.network(
        widget.adItem.path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _buildLoadingPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
      );
    } else {
      if (kIsWeb) {
        imageWidget = _buildErrorPlaceholder(message: '웹 브라우저에서는 네트워크 URL 이미지를 권장합니다.');
      } else {
        imageWidget = Image.file(
          File(widget.adItem.path),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorPlaceholder();
          },
        );
      }
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        imageWidget,
        _buildBottomGradientTitle(),
      ],
    );
  }

  Widget _buildVideoView() {
    if (_isVideoLoading) {
      return _buildLoadingPlaceholder();
    }

    if (_videoController == null || !_videoController!.value.isInitialized) {
      return _buildLoadingPlaceholder();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        ),
        _buildBottomGradientTitle(),
      ],
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: AppColors.ink,
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder({String? message}) {
    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: minAxisSize(),
          children: [
            const Icon(
              Icons.broken_image_rounded,
              color: AppColors.mutedSoft,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              widget.adItem.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message ?? '미디어를 불러오지 못했습니다. 잠시 후 다음 화면으로 이동합니다.',
              style: const TextStyle(
                color: AppColors.mutedSoft,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  MainAxisSize minAxisSize() => MainAxisSize.min;

  Widget _buildBottomGradientTitle() {
    if (widget.adItem.title.isEmpty) return const SizedBox.shrink();

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
                color: widget.adItem.type == AdMediaType.video
                    ? AppColors.primary
                    : AppColors.secondary,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                widget.adItem.type.displayName,
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
                widget.adItem.title,
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

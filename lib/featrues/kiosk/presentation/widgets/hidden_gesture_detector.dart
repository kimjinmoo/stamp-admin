import 'package:flutter/material.dart';
import '../../../../core/constants/kiosk_constants.dart';

/// 화면 모서리(우측 상단) 히든 제스처 감지 위젯
/// 5회 연속 탭 또는 2초 길게 누르기 시 관리자 설정 모드로 전환
class HiddenGestureDetector extends StatefulWidget {
  final VoidCallback onTrigger;
  final Widget? child;
  final double size;

  const HiddenGestureDetector({
    super.key,
    required this.onTrigger,
    this.child,
    this.size = 100.0,
  });

  @override
  State<HiddenGestureDetector> createState() => _HiddenGestureDetectorState();
}

class _HiddenGestureDetectorState extends State<HiddenGestureDetector> {
  int _tapCount = 0;
  DateTime? _firstTapTime;

  void _handleTap() {
    final now = DateTime.now();

    if (_firstTapTime == null ||
        now.difference(_firstTapTime!).inMilliseconds >
            KioskConstants.adminGestureTimeLimitMs) {
      _firstTapTime = now;
      _tapCount = 1;
    } else {
      _tapCount++;
      if (_tapCount >= KioskConstants.adminGestureTapCount) {
        _tapCount = 0;
        _firstTapTime = null;
        widget.onTrigger();
      }
    }
  }

  void _handleLongPress() {
    _tapCount = 0;
    _firstTapTime = null;
    widget.onTrigger();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: widget.child,
      ),
    );
  }
}

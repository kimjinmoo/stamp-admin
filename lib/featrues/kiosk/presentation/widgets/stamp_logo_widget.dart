import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// 심플하고 세련된 모던 스탬프 엠블럼 위젯 (밝은 배경 및 스플래시용)
class StampLogoWidget extends StatelessWidget {
  final double size;
  final bool showGlow;
  final bool isLightMode;

  const StampLogoWidget({
    super.key,
    this.size = 100.0,
    this.showGlow = true,
    this.isLightMode = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: isLightMode ? 0.35 : 0.45),
                  blurRadius: size * 0.35,
                  spreadRadius: size * 0.04,
                  offset: const Offset(0, 8),
                ),
                if (isLightMode)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: size * 0.15,
                    offset: const Offset(0, 3),
                  ),
              ]
            : null,
      ),
      child: CustomPaint(
        painter: _SimpleStampPainter(isLightMode: isLightMode),
        size: Size(size, size),
      ),
    );
  }
}

class _SimpleStampPainter extends CustomPainter {
  final bool isLightMode;

  _SimpleStampPainter({this.isLightMode = true});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. 도장 베이스 (선명하고 상큼한 제스티 코랄 그라데이션)
    final sealPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFF7276), // 밝고 상큼한 코랄
          AppColors.primary,  // #FF5A5F
          Color(0xFFE84248), // 깊이감 있는 코랄 섀도우
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, sealPaint);

    // 2. 도장 내부 엠보싱 원형 링 라인 (화이트 반투명 링)
    final innerRingPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.038;
    canvas.drawCircle(center, radius * 0.82, innerRingPaint);

    // 3. 미세 점선/점 데코레이션 링
    final dashedRingPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02;
    canvas.drawCircle(center, radius * 0.72, dashedRingPaint);

    // 4. 중앙 심플한 스탬프 각인 (순백색 별 / 체크 심볼)
    final symbolPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 중앙 별 마크 (5꼭지점 심플 스타)
    final path = Path();
    const numPoints = 5;
    final outerR = radius * 0.40;
    final innerR = radius * 0.19;

    for (int i = 0; i < numPoints * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = (i * math.pi / numPoints) - (math.pi / 2);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, symbolPaint);

    // 5. 우측 상단 미니멀 프레시 민트 인증 점
    final mintDot = Paint()..color = const Color(0xFF00D19A);
    canvas.drawCircle(
      Offset(center.dx + radius * 0.45, center.dy - radius * 0.45),
      size.width * 0.065,
      mintDot,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

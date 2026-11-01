import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/kiosk_constants.dart';

/// 30초 동적 QR 갱신 게이지 및 카운트다운 표시 위젯
class QrCountdownTimer extends StatelessWidget {
  final int remainingSeconds;
  final int totalWindowSeconds;

  const QrCountdownTimer({
    super.key,
    required this.remainingSeconds,
    this.totalWindowSeconds = KioskConstants.totpTimeWindowSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (remainingSeconds / totalWindowSeconds).clamp(0.0, 1.0);
    // 5초 이하로 남으면 긴급 경고 컬러(Zesty Coral), 평상시는 Fresh Mint
    final isUrgent = remainingSeconds <= 5;
    final accentColor = isUrgent ? AppColors.primary : AppColors.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.security_rounded,
                    size: 18,
                    color: accentColor,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '동적 보안 인증',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.body,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '남은 시간 ',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                  Text(
                    '$remainingSeconds초',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceStrong,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// 대기 모드로 돌아가는 15초 카운트다운 배지
class AutoDismissBadge extends StatelessWidget {
  final int remainingSeconds;

  const AutoDismissBadge({
    super.key,
    required this.remainingSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.timer_outlined,
              size: 16,
              color: AppColors.muted,
            ),
            const SizedBox(width: 6),
            Text(
              '$remainingSeconds초 후 대기 화면으로 복귀',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.body,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

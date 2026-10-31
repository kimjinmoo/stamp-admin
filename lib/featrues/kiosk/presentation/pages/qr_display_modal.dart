import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stamp_admin/core/constants/app_colors.dart';
import 'package:stamp_admin/featrues/admin/provider/kiosk_config_provider.dart';
import 'package:stamp_admin/featrues/kiosk/presentation/widgets/qr_countdown_timer.dart';
import 'package:stamp_admin/featrues/kiosk/provider/kiosk_playback_provider.dart';

/// 터치 시 중앙에 나타나는 동적 보안 QR 코드 발급 모달/화면
class QrDisplayModal extends ConsumerWidget {
  const QrDisplayModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(kioskConfigNotifierProvider);
    final playback = ref.watch(kioskPlaybackNotifierProvider);
    final payload = playback.currentPayload;

    final qrData = payload?.toJsonString() ?? '';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // 모달 내부 터치 시 15초 자동 복귀 카운트다운 연장
        ref.read(kioskPlaybackNotifierProvider.notifier).resetAutoDismissCountdown();
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.hairline, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A0F172A),
                  blurRadius: 32,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 상단 헤더: 매장명 & 닫기 버튼
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: const Text(
                              '스탬프 적립 키오스크',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              config.placeName,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        ref
                            .read(kioskPlaybackNotifierProvider.notifier)
                            .closeQrModal();
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surfaceSoft,
                        foregroundColor: AppColors.ink,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 22),
                      tooltip: '닫기 (광고 재생으로 복귀)',
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 중앙 QR 코드 카드
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.hairline, width: 1),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.hairline,
                            width: 1,
                          ),
                        ),
                        child: QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 210,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: AppColors.ink,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: AppColors.ink,
                          ),
                          errorCorrectionLevel: QrErrorCorrectLevel.M,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '스탬프 앱으로 스캔해 주세요',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '고객 스마트폰의 스탬프 앱 카메라로\n위 QR 코드를 비추면 즉시 적립됩니다.',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 30초 TOTP 갱신 타이머 게이지
                QrCountdownTimer(
                  remainingSeconds: playback.qrRemainingSeconds,
                ),

                const SizedBox(height: 16),

                // 하단 15초 자동 복귀 안내 및 닫기 버튼
                Row(
                  children: [
                    Expanded(
                      child: AutoDismissBadge(
                        remainingSeconds: playback.autoDismissCountdown,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(kioskPlaybackNotifierProvider.notifier)
                            .closeQrModal();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ink,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(100, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '완료',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

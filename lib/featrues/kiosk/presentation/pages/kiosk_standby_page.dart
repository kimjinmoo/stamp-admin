import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stamp_admin/core/constants/app_colors.dart';
import 'package:stamp_admin/featrues/admin/presentation/pages/admin_settings_page.dart';
import 'package:stamp_admin/featrues/admin/provider/kiosk_config_provider.dart';
import 'package:stamp_admin/featrues/kiosk/presentation/pages/qr_display_modal.dart';
import 'package:stamp_admin/featrues/kiosk/presentation/widgets/ad_media_view.dart';
import 'package:stamp_admin/featrues/kiosk/presentation/widgets/hidden_gesture_detector.dart';
import 'package:stamp_admin/featrues/kiosk/provider/kiosk_playback_provider.dart';

/// 키오스크 메인 대기 모드 화면 (광고 롤링 플레이어 및 제스처 오버레이)
class KioskStandbyPage extends ConsumerWidget {
  const KioskStandbyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(kioskConfigNotifierProvider);
    final playback = ref.watch(kioskPlaybackNotifierProvider);

    final ads = config.ads;
    final currentAdIndex = playback.currentAdIndex;
    final currentAd = (ads.isNotEmpty && currentAdIndex < ads.length)
        ? ads[currentAdIndex]
        : (ads.isNotEmpty ? ads.first : null);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 전체 화면 미디어 플레이어
          if (currentAd != null)
            AdMediaView(
              key: ValueKey(currentAd.id),
              adItem: currentAd,
              isPaused: playback.isQrModalOpen,
              onMediaFinished: () {
                ref.read(kioskPlaybackNotifierProvider.notifier).nextAd();
              },
            )
          else
            _buildEmptyPlaceholder(),

          // 2. 전체 화면 터치 감지기 (터치 시 QR 코드 모달 오픈)
          if (!playback.isQrModalOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  ref.read(kioskPlaybackNotifierProvider.notifier).openQrModal();
                },
              ),
            ),

          // 3. 상단 헤더 UI (좌측: 매장명, 중앙: 터치 안내 배지)
          if (!playback.isQrModalOpen)
            Positioned(
              top: 24,
              left: 24,
              right: 120, // 우측 히든 제스처 영역 침범 방지
              child: SafeArea(
                child: Row(
                  children: [
                    // 매장 정보 칩
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.storefront_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            config.placeName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // 중앙 터치 권유 플로팅 배지
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '화면을 터치하여 스탬프를 적립하세요',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 4. 하단 미디어 인디케이터 (현재 페이지 표시)
          if (!playback.isQrModalOpen && ads.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(ads.length, (index) {
                  final isSelected = index == currentAdIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isSelected ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  );
                }),
              ),
            ),

          // 5. 우측 상단 모서리 관리자 히든 제스처 영역 (5회 탭 또는 롱프레스)
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: HiddenGestureDetector(
                size: 100,
                onTrigger: () {
                  // 일시정지 상태로 관리자 페이지 진입
                  ref.read(kioskPlaybackNotifierProvider.notifier).closeQrModal();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminSettingsPage(),
                    ),
                  );
                },
                child: Container(
                  // 투명 터치 영역 (디버그 모드에서 시각적 힌트 줄 수도 있음)
                  color: Colors.transparent,
                ),
              ),
            ),
          ),

          // 6. QR 발급 모달 오버레이 (화면 터치 시 등장)
          if (playback.isQrModalOpen) ...[
            // 배경 딤 + 블러
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: AppColors.scrim,
                ),
              ),
            ),
            // QR 모달 카드
            const Positioned.fill(
              child: SafeArea(
                child: QrDisplayModal(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Container(
      color: const Color(0xFF0F172A),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tv_rounded,
              size: 64,
              color: AppColors.mutedSoft,
            ),
            SizedBox(height: 16),
            Text(
              '등록된 광고 미디어가 없습니다.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '우측 상단을 5회 터치하여 광고를 추가해 주세요.',
              style: TextStyle(
                color: AppColors.mutedSoft,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

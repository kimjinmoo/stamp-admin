import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/kiosk_constants.dart';
import '../../../core/utils/totp_generator.dart';
import '../../admin/provider/kiosk_config_provider.dart';

/// 키오스크 재생 및 QR 모드 전역 상태
class KioskPlaybackState {
  final int currentAdIndex;
  final bool isQrModalOpen;
  final int qrRemainingSeconds; // 30초 TOTP 윈도우 남은 시간
  final int autoDismissCountdown; // 15초 모달 자동 복귀 카운트다운
  final QrPayloadData? currentPayload;

  const KioskPlaybackState({
    this.currentAdIndex = 0,
    this.isQrModalOpen = false,
    this.qrRemainingSeconds = KioskConstants.totpTimeWindowSeconds,
    this.autoDismissCountdown = KioskConstants.qrAutoDismissSeconds,
    this.currentPayload,
  });

  KioskPlaybackState copyWith({
    int? currentAdIndex,
    bool? isQrModalOpen,
    int? qrRemainingSeconds,
    int? autoDismissCountdown,
    QrPayloadData? currentPayload,
  }) {
    return KioskPlaybackState(
      currentAdIndex: currentAdIndex ?? this.currentAdIndex,
      isQrModalOpen: isQrModalOpen ?? this.isQrModalOpen,
      qrRemainingSeconds: qrRemainingSeconds ?? this.qrRemainingSeconds,
      autoDismissCountdown: autoDismissCountdown ?? this.autoDismissCountdown,
      currentPayload: currentPayload ?? this.currentPayload,
    );
  }
}

/// 키오스크 재생 및 QR 상태 제어 Notifier
class KioskPlaybackNotifier extends Notifier<KioskPlaybackState> {
  Timer? _qrTickerTimer;

  @override
  KioskPlaybackState build() {
    ref.onDispose(() {
      _qrTickerTimer?.cancel();
    });
    return const KioskPlaybackState();
  }

  /// 다음 광고 미디어로 전환 (루프)
  void nextAd() {
    final ads = ref.read(kioskConfigNotifierProvider).ads;
    if (ads.isEmpty) return;
    final nextIndex = (state.currentAdIndex + 1) % ads.length;
    state = state.copyWith(currentAdIndex: nextIndex);
  }

  /// 이전 광고 미디어로 전환
  void prevAd() {
    final ads = ref.read(kioskConfigNotifierProvider).ads;
    if (ads.isEmpty) return;
    final prevIndex = (state.currentAdIndex - 1 + ads.length) % ads.length;
    state = state.copyWith(currentAdIndex: prevIndex);
  }

  /// 특정 인덱스로 광고 이동
  void setAdIndex(int index) {
    state = state.copyWith(currentAdIndex: index);
  }

  /// 화면 터치 -> QR 모달 진입
  void openQrModal() {
    _refreshQrPayload();
    _startQrTicker();

    state = state.copyWith(
      isQrModalOpen: true,
      autoDismissCountdown: KioskConstants.qrAutoDismissSeconds,
    );
  }

  /// QR 모달 닫기 -> 대기 모드(광고 재생)로 복귀
  void closeQrModal() {
    _qrTickerTimer?.cancel();
    _qrTickerTimer = null;

    state = state.copyWith(
      isQrModalOpen: false,
      autoDismissCountdown: KioskConstants.qrAutoDismissSeconds,
    );
  }

  /// 사용자가 QR 화면을 터치했을 때 카운트다운 15초 리셋
  void resetAutoDismissCountdown() {
    state = state.copyWith(
      autoDismissCountdown: KioskConstants.qrAutoDismissSeconds,
    );
  }

  /// QR 토큰 및 남은 시간 갱신
  void _refreshQrPayload() {
    final config = ref.read(kioskConfigNotifierProvider);
    final payload = TotpGenerator.generate(
      placeId: config.placeId,
      placeName: config.placeName,
    );

    state = state.copyWith(
      qrRemainingSeconds: payload.remainingSecondsInWindow,
      currentPayload: payload,
    );
  }

  /// 1초마다 도는 타이머 (30초 TOTP 갱신 & 15초 자동 닫힘)
  void _startQrTicker() {
    _qrTickerTimer?.cancel();
    _qrTickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isQrModalOpen) {
        timer.cancel();
        return;
      }

      // 1. 자동 복귀 카운트다운 감소
      final newAutoDismiss = state.autoDismissCountdown - 1;
      if (newAutoDismiss <= 0) {
        // 15초 만료 -> 자동 닫힘
        closeQrModal();
        return;
      }

      // 2. 30초 TOTP 윈도우 갱신 체크
      final config = ref.read(kioskConfigNotifierProvider);
      final payload = TotpGenerator.generate(
        placeId: config.placeId,
        placeName: config.placeName,
      );

      state = state.copyWith(
        autoDismissCountdown: newAutoDismiss,
        qrRemainingSeconds: payload.remainingSecondsInWindow,
        currentPayload: payload,
      );
    });
  }
}

final kioskPlaybackNotifierProvider =
    NotifierProvider<KioskPlaybackNotifier, KioskPlaybackState>(() {
  return KioskPlaybackNotifier();
});

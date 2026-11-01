import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/ad_item.dart';
import '../domain/kiosk_config.dart';
import '../repository/kiosk_config_repository.dart';

/// SharedPreferences 인스턴스 Provider (main에서 override)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

/// 레포지토리 Provider
final kioskConfigRepositoryProvider = Provider<KioskConfigRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return KioskConfigRepository(prefs);
});

/// 키오스크 전체 설정 상태 Notifier
class KioskConfigNotifier extends Notifier<KioskConfig> {
  late final KioskConfigRepository _repository;

  @override
  KioskConfig build() {
    _repository = ref.watch(kioskConfigRepositoryProvider);
    // 비동기 로딩을 초기화 단계에서 바로 수행
    _loadInitial();
    return KioskConfig.initial();
  }

  Future<void> _loadInitial() async {
    final loaded = await _repository.loadConfig();
    state = loaded;
  }

  /// 장소 정보 (placeId, placeName) 변경 및 저장
  Future<void> updatePlaceInfo(String placeId, String placeName) async {
    final updated = state.copyWith(
      placeId: placeId.trim(),
      placeName: placeName.trim(),
    );
    state = updated;
    await _repository.updatePlaceInfo(
      placeId: updated.placeId,
      placeName: updated.placeName,
    );
  }

  /// 관리자 비밀번호 변경 및 저장
  Future<void> updateAdminPin(String newPin) async {
    final updated = state.copyWith(adminPin: newPin.trim());
    state = updated;
    await _repository.updateAdminPin(updated.adminPin);
  }

  /// 광고 항목 추가
  Future<void> addAd(AdItem item) async {
    final newAds = [...state.ads, item];
    state = state.copyWith(ads: newAds);
    await _repository.updateAds(newAds);
  }

  /// 광고 항목 수정
  Future<void> updateAd(AdItem item) async {
    final newAds = state.ads.map((e) => e.id == item.id ? item : e).toList();
    state = state.copyWith(ads: newAds);
    await _repository.updateAds(newAds);
  }

  /// 광고 항목 삭제
  Future<void> removeAd(String id) async {
    final newAds = state.ads.where((e) => e.id != id).toList();
    state = state.copyWith(ads: newAds);
    await _repository.updateAds(newAds);
  }

  /// 광고 순서 변경 (onReorderItem 대응)
  Future<void> reorderAds(int oldIndex, int newIndex) async {
    final newAds = List<AdItem>.from(state.ads);
    final movedItem = newAds.removeAt(oldIndex);
    newAds.insert(newIndex, movedItem);

    state = state.copyWith(ads: newAds);
    await _repository.updateAds(newAds);
  }

  /// 기본값으로 복원
  Future<void> resetToDefault() async {
    final defaultConfig = await _repository.resetToDefault();
    state = defaultConfig;
  }

  /// 서버 동기화 Mock 함수 (admin.md 3.C)
  /// 로딩 인디케이터 1초 후 완료
  Future<bool> uploadToServer() async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}

final kioskConfigNotifierProvider = NotifierProvider<KioskConfigNotifier, KioskConfig>(() {
  return KioskConfigNotifier();
});

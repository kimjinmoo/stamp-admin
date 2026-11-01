import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/kiosk_constants.dart';
import '../domain/ad_item.dart';
import '../domain/kiosk_config.dart';

/// SharedPreferences 기반 키오스크 설정 영속 저장소
class KioskConfigRepository {
  final SharedPreferences _prefs;

  KioskConfigRepository(this._prefs);

  /// 저장된 키오스크 설정 불러오기
  Future<KioskConfig> loadConfig() async {
    final placeId = _prefs.getString(KioskConstants.prefKeyPlaceId) ?? KioskConstants.defaultPlaceId;
    final placeName = _prefs.getString(KioskConstants.prefKeyPlaceName) ?? KioskConstants.defaultPlaceName;
    final adminPin = _prefs.getString(KioskConstants.prefKeyAdminPin) ?? KioskConstants.defaultAdminPin;
    final adsJsonString = _prefs.getString(KioskConstants.prefKeyAdList);

    List<AdItem> ads = AdItem.defaultAds;
    if (adsJsonString != null && adsJsonString.isNotEmpty) {
      try {
        final decoded = jsonDecode(adsJsonString) as List<dynamic>;
        ads = decoded
            .map((item) => AdItem.fromJson(Map<String, dynamic>.from(item as Map)))
            .map((item) {
              // 403 Forbidden 구버전 Google Cloud Storage 비디오 URL 자동 마이그레이션
              if (item.path.contains('commondatastorage.googleapis.com')) {
                return item.copyWith(
                  path: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
                );
              }
              return item;
            })
            .toList();
      } catch (_) {
        ads = AdItem.defaultAds;
      }
    }

    return KioskConfig(
      placeId: placeId,
      placeName: placeName,
      ads: ads.isNotEmpty ? ads : AdItem.defaultAds,
      adminPin: adminPin,
    );
  }

  /// 전체 설정 일괄 저장
  Future<void> saveConfig(KioskConfig config) async {
    await _prefs.setString(KioskConstants.prefKeyPlaceId, config.placeId);
    await _prefs.setString(KioskConstants.prefKeyPlaceName, config.placeName);
    await _prefs.setString(KioskConstants.prefKeyAdminPin, config.adminPin);
    final adsJson = jsonEncode(config.ads.map((e) => e.toJson()).toList());
    await _prefs.setString(KioskConstants.prefKeyAdList, adsJson);
  }

  /// 장소 정보만 업데이트
  Future<void> updatePlaceInfo({required String placeId, required String placeName}) async {
    await _prefs.setString(KioskConstants.prefKeyPlaceId, placeId);
    await _prefs.setString(KioskConstants.prefKeyPlaceName, placeName);
  }

  /// 관리자 비밀번호 업데이트
  Future<void> updateAdminPin(String pin) async {
    await _prefs.setString(KioskConstants.prefKeyAdminPin, pin);
  }

  /// 광고 목록만 업데이트
  Future<void> updateAds(List<AdItem> ads) async {
    final adsJson = jsonEncode(ads.map((e) => e.toJson()).toList());
    await _prefs.setString(KioskConstants.prefKeyAdList, adsJson);
  }

  /// 기본값으로 초기화
  Future<KioskConfig> resetToDefault() async {
    await _prefs.remove(KioskConstants.prefKeyPlaceId);
    await _prefs.remove(KioskConstants.prefKeyPlaceName);
    await _prefs.remove(KioskConstants.prefKeyAdList);
    await _prefs.remove(KioskConstants.prefKeyAdminPin);
    return KioskConfig.initial();
  }
}

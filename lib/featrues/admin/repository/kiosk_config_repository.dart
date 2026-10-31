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
    final adsJsonString = _prefs.getString(KioskConstants.prefKeyAdList);

    List<AdItem> ads = AdItem.defaultAds;
    if (adsJsonString != null && adsJsonString.isNotEmpty) {
      try {
        final decoded = jsonDecode(adsJsonString) as List<dynamic>;
        ads = decoded
            .map((item) => AdItem.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      } catch (_) {
        ads = AdItem.defaultAds;
      }
    }

    return KioskConfig(
      placeId: placeId,
      placeName: placeName,
      ads: ads.isNotEmpty ? ads : AdItem.defaultAds,
    );
  }

  /// 전체 설정 일괄 저장
  Future<void> saveConfig(KioskConfig config) async {
    await _prefs.setString(KioskConstants.prefKeyPlaceId, config.placeId);
    await _prefs.setString(KioskConstants.prefKeyPlaceName, config.placeName);
    final adsJson = jsonEncode(config.ads.map((e) => e.toJson()).toList());
    await _prefs.setString(KioskConstants.prefKeyAdList, adsJson);
  }

  /// 장소 정보만 업데이트
  Future<void> updatePlaceInfo({required String placeId, required String placeName}) async {
    await _prefs.setString(KioskConstants.prefKeyPlaceId, placeId);
    await _prefs.setString(KioskConstants.prefKeyPlaceName, placeName);
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
    return KioskConfig.initial();
  }
}

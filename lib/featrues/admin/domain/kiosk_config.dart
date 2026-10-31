import 'dart:convert';
import '../../../core/constants/kiosk_constants.dart';
import 'ad_item.dart';

/// 키오스크 전체 설정 모델
class KioskConfig {
  final String placeId;
  final String placeName;
  final List<AdItem> ads;

  const KioskConfig({
    required this.placeId,
    required this.placeName,
    required this.ads,
  });

  /// 기본 초기 설정
  factory KioskConfig.initial() {
    return KioskConfig(
      placeId: KioskConstants.defaultPlaceId,
      placeName: KioskConstants.defaultPlaceName,
      ads: AdItem.defaultAds,
    );
  }

  KioskConfig copyWith({
    String? placeId,
    String? placeName,
    List<AdItem>? ads,
  }) {
    return KioskConfig(
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
      ads: ads ?? this.ads,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'placeName': placeName,
      'ads': ads.map((e) => e.toJson()).toList(),
    };
  }

  factory KioskConfig.fromJson(Map<String, dynamic> json) {
    final adsList = (json['ads'] as List<dynamic>?)
            ?.map((e) => AdItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        AdItem.defaultAds;

    return KioskConfig(
      placeId: json['placeId'] as String? ?? KioskConstants.defaultPlaceId,
      placeName: json['placeName'] as String? ?? KioskConstants.defaultPlaceName,
      ads: adsList.isNotEmpty ? adsList : AdItem.defaultAds,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory KioskConfig.fromJsonString(String source) {
    return KioskConfig.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }
}

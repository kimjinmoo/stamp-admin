import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../constants/kiosk_constants.dart';

/// TOTP 및 QR 페이로드 데이터 모델
class QrPayloadData {
  final String placeId;
  final String placeName;
  final int timestamp;
  final String token;
  final int timeWindow;
  final int remainingSecondsInWindow;

  const QrPayloadData({
    required this.placeId,
    required this.placeName,
    required this.timestamp,
    required this.token,
    required this.timeWindow,
    required this.remainingSecondsInWindow,
  });

  /// Client 앱과 100% 호환되는 JSON 페이로드 문자열 생성
  String toJsonString() {
    final map = {
      'placeId': placeId,
      'placeName': placeName,
      'timestamp': timestamp,
      'token': token,
    };
    return jsonEncode(map);
  }
}

/// 동적 보안 QR 코드 (HMAC-SHA256 기반 TOTP) 생성 유틸리티
class TotpGenerator {
  TotpGenerator._();

  /// 현재 시간 기준으로 토큰 및 QR 페이로드 생성
  static QrPayloadData generate({
    required String placeId,
    required String placeName,
    DateTime? currentTime,
    String secretKey = KioskConstants.sharedSecret,
    int windowSeconds = KioskConstants.totpTimeWindowSeconds,
  }) {
    final now = currentTime ?? DateTime.now();
    final nowSeconds = now.millisecondsSinceEpoch ~/ 1000;
    final timeWindow = nowSeconds ~/ windowSeconds;

    // HMAC-SHA256 서명 생성: "$placeId:$timeWindow"
    final input = '$placeId:$timeWindow';
    final keyBytes = utf8.encode(secretKey);
    final inputBytes = utf8.encode(input);

    final hmacSha256 = Hmac(sha256, keyBytes);
    final digest = hmacSha256.convert(inputBytes);
    final token = digest.toString();

    // 30초 윈도우 내 남은 시간 (1 ~ 30초)
    final elapsedInWindow = nowSeconds % windowSeconds;
    final remainingSeconds = windowSeconds - elapsedInWindow;

    return QrPayloadData(
      placeId: placeId,
      placeName: placeName,
      timestamp: nowSeconds,
      token: token,
      timeWindow: timeWindow,
      remainingSecondsInWindow: remainingSeconds,
    );
  }

  /// 토큰 유효성 검증 유틸 (Client 및 테스트 호환용)
  static bool verify({
    required String placeId,
    required String token,
    required int timestamp,
    String secretKey = KioskConstants.sharedSecret,
    int windowSeconds = KioskConstants.totpTimeWindowSeconds,
    int allowedWindowDrift = 1, // 이전/이후 1윈도우 허용 (네트워크 딜레이 대응)
  }) {
    final centerWindow = timestamp ~/ windowSeconds;
    final keyBytes = utf8.encode(secretKey);
    final hmacSha256 = Hmac(sha256, keyBytes);

    for (int drift = -allowedWindowDrift; drift <= allowedWindowDrift; drift++) {
      final windowToTest = centerWindow + drift;
      final input = '$placeId:$windowToTest';
      final digest = hmacSha256.convert(utf8.encode(input));
      if (digest.toString().toLowerCase() == token.toLowerCase()) {
        return true;
      }
    }
    return false;
  }
}

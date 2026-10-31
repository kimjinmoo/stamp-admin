import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:stamp_admin/core/constants/kiosk_constants.dart';
import 'package:stamp_admin/core/utils/totp_generator.dart';

void main() {
  group('TotpGenerator Unit Tests (동적 보안 규격 검증)', () {
    const testPlaceId = 'STORE_SEOUL_001';
    const testPlaceName = '강남 본점';

    test('동일한 30초 윈도우 내에서는 동일한 토큰을 생성해야 한다', () {
      const baseWindowSeconds = 1730380020; // 1730380020 % 30 == 0
      final t1 = DateTime.fromMillisecondsSinceEpoch((baseWindowSeconds + 2) * 1000);
      final t2 = DateTime.fromMillisecondsSinceEpoch((baseWindowSeconds + 20) * 1000); // 18초 후 동일 윈도우

      final payload1 = TotpGenerator.generate(
        placeId: testPlaceId,
        placeName: testPlaceName,
        currentTime: t1,
      );

      final payload2 = TotpGenerator.generate(
        placeId: testPlaceId,
        placeName: testPlaceName,
        currentTime: t2,
      );

      expect(payload1.timeWindow, equals(payload2.timeWindow));
      expect(payload1.token, equals(payload2.token));
      expect(payload1.token.length, equals(64)); // SHA256 hex string 길이 = 64
    });

    test('30초 윈도우가 변경되면 새로운 토큰이 생성되어야 한다', () {
      const baseWindowSeconds = 1730380020;
      final t1 = DateTime.fromMillisecondsSinceEpoch((baseWindowSeconds + 5) * 1000);
      final t2 = DateTime.fromMillisecondsSinceEpoch((baseWindowSeconds + 35) * 1000); // 30초 후 다음 윈도우

      final payload1 = TotpGenerator.generate(
        placeId: testPlaceId,
        placeName: testPlaceName,
        currentTime: t1,
      );

      final payload2 = TotpGenerator.generate(
        placeId: testPlaceId,
        placeName: testPlaceName,
        currentTime: t2,
      );

      expect(payload1.timeWindow != payload2.timeWindow, isTrue);
      expect(payload1.token != payload2.token, isTrue);
    });

    test('JSON 페이로드 문자열이 admin.md 2번 규격과 정확히 일치해야 한다', () {
      final payload = TotpGenerator.generate(
        placeId: testPlaceId,
        placeName: testPlaceName,
      );

      final jsonStr = payload.toJsonString();
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(decoded.containsKey('placeId'), isTrue);
      expect(decoded.containsKey('placeName'), isTrue);
      expect(decoded.containsKey('timestamp'), isTrue);
      expect(decoded.containsKey('token'), isTrue);

      expect(decoded['placeId'], equals(testPlaceId));
      expect(decoded['placeName'], equals(testPlaceName));
      expect(decoded['token'], equals(payload.token));
    });

    test('생성된 토큰은 TotpGenerator.verify에서 정상 검증(True)되어야 한다', () {
      final fixedTime = DateTime.fromMillisecondsSinceEpoch(1730380010 * 1000);
      final payload = TotpGenerator.generate(
        placeId: testPlaceId,
        placeName: testPlaceName,
        currentTime: fixedTime,
      );

      final isValid = TotpGenerator.verify(
        placeId: testPlaceId,
        token: payload.token,
        timestamp: payload.timestamp,
      );

      expect(isValid, isTrue);

      // 잘못된 placeId로 검증 시 실패해야 함
      final isInvalidPlace = TotpGenerator.verify(
        placeId: 'WRONG_PLACE',
        token: payload.token,
        timestamp: payload.timestamp,
      );
      expect(isInvalidPlace, isFalse);

      // 위변조된 토큰 검증 시 실패해야 함
      final isTampered = TotpGenerator.verify(
        placeId: testPlaceId,
        token: 'invalid_tampered_token_string',
        timestamp: payload.timestamp,
      );
      expect(isTampered, isFalse);
    });

    test('남은 유효시간(remainingSecondsInWindow)이 1~30 사이의 유효한 값이어야 한다', () {
      final payload = TotpGenerator.generate(
        placeId: testPlaceId,
        placeName: testPlaceName,
      );

      expect(payload.remainingSecondsInWindow >= 1, isTrue);
      expect(
        payload.remainingSecondsInWindow <= KioskConstants.totpTimeWindowSeconds,
        isTrue,
      );
    });
  });
}

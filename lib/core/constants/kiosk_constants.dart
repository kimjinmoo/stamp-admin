/// 키오스크 및 관리자 앱 전역 상수 정의
class KioskConstants {
  KioskConstants._();

  // TOTP 규격 상수 (Client 앱과 100% 호환)
  static const String sharedSecret = 'STAMP_SECRET_KEY_2026_V1';
  static const int totpTimeWindowSeconds = 30; // 30초 단위 변경

  // 키오스크 대기 / 모달 타이머
  static const int qrAutoDismissSeconds = 15; // 15초 미입력 시 복귀
  static const int defaultImageDisplaySeconds = 5; // 이미지 기본 노출 시간

  // 히든 관리자 제스처
  static const int adminGestureTapCount = 5; // 5회 연속 탭
  static const int adminGestureTimeLimitMs = 3000; // 3초 이내 5회 탭

  // 기본 매장 정보 및 관리자 보안
  static const String defaultPlaceId = 'STORE_SEOUL_001';
  static const String defaultPlaceName = '강남 본점';
  static const String defaultAdminPin = '0000'; // 초기 관리자 비밀번호

  // SharedPreferences 키
  static const String prefKeyPlaceId = 'stamp_kiosk_place_id';
  static const String prefKeyPlaceName = 'stamp_kiosk_place_name';
  static const String prefKeyAdList = 'stamp_kiosk_ad_list';
  static const String prefKeyAdminPin = 'stamp_kiosk_admin_pin';
}

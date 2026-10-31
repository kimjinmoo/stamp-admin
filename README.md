# 스탬프 키오스크 관리자 앱 (Stamp Admin Kiosk App)

매장에 비치되어 홍보 광고 미디어(이미지/동영상)를 무한 롤링 재생하고, 고객 터치 시 안전한 시간 기반 일회용 토큰(TOTP)이 포함된 **동적 보안 QR 코드**를 즉시 발급하는 Flutter 기반 키오스크 관리자 애플리케이션입니다.

---

## 📱 주요 핵심 흐름 및 기능

### 1. 평상시 (대기 모드 / 광고 플레이어)
* **이미지 & 동영상 통합 롤링 재생:** 이미지(JPG, PNG)와 동영상(MP4)이 혼합된 재생 목록을 전체 화면으로 끊김 없이 순차 재생합니다.
* **시간 기반 자동 전환:** 이미지는 설정된 시간(기본 5초 등) 동안 표시되고, 동영상은 재생이 완료될 때까지 재생된 후 다음 미디어로 자동 전환됩니다.
* **즉시 반응 터치:** 화면 전체에 제스처 감지기가 적용되어 있어 화면 어디든 터치하면 즉시 광고를 일시 정지하고 **QR 코드 발급 모달**을 띄웁니다.
* **히든 관리자 제스처:** 일반 고객의 오조작을 방지하기 위해 화면 **우측 상단 모서리를 5회 연속 탭**하거나 **2초간 길게 누르면** 관리자 설정 화면으로 안전하게 진입합니다.

### 2. 터치 시 (동적 보안 QR 발급 모드)
* **30초 주기 TOTP 실시간 갱신:** 단순 캡처/복사 어뷰징을 원천 차단하기 위해 30초마다 새로운 암호화 토큰이 생성되며, 화면이 열려 있는 동안에도 30초 주기가 바뀌면 실시간으로 QR 코드가 자동 갱신됩니다.
* **시각적 타이머 게이지:** 30초 윈도우 잔여 시간을 원형/선형 프로그레스 바(Fresh Mint ➔ 만료 임박 시 Zesty Coral) 및 고정폭 숫자(`tabular-nums`)로 시각화합니다.
* **15초 자동 복귀:** QR 코드 화면에서 15초 동안 추가 입력이 없거나 완료/닫기 버튼을 누르면 자동으로 대기 모드(광고 재생)로 복귀합니다. (화면 터치 시 카운트다운 자동 연장)

### 3. 관리자 설정 화면
* **매장 및 장소 설정:** 매장 코드(`placeId`) 및 매장 이름(`placeName`)을 입력하고 `shared_preferences`에 로컬 영속 저장합니다.
* **광고 미디어 관리:**
  * 로컬 기기 파일 탐색기(`FilePicker`)를 통한 이미지/영상 추가
  * 웹 URL 직접 등록 및 노출 시간(초) 설정
  * 즉시 테스트 가능한 고화질 추천 샘플 프리셋 원클릭 추가
  * 드래그 앤 드롭(`ReorderableListView`)을 통한 광고 재생 순서 변경
  * 미디어 삭제 및 초기 기본값 복원 기능
* **서버 동기화 (UI Mock):** `[서버에 설정 및 로그 올리기]` 버튼 클릭 시 1초 로딩 인디케이터 후 안내 다이얼로그 노출 (`Future<void> uploadToServer()`).

---

## 🔐 공통 동적 보안(TOTP) 규격 (Client 앱 호환)

클라이언트(고객용) 앱과의 100% 검증 호환성을 위해 아래 명세에 따라 동작합니다:

1. **공유 비밀키 (Shared Secret):** `STAMP_SECRET_KEY_2026_V1`
2. **시간 윈도우 (Time Window):** 30초 단위
   ```dart
   final timeWindow = (DateTime.now().millisecondsSinceEpoch ~/ 1000) ~/ 30;
   ```
3. **서명 생성 (HMAC-SHA256):**
   * 입력 문자열: `"$placeId:$timeWindow"`
   * 암호화 알고리즘: HMAC-SHA256 (Hex 소문자 변환)
4. **QR 페이로드 규격 (JSON String):**
   ```json
   {
     "placeId": "STORE_SEOUL_001",
     "placeName": "강남 본점",
     "timestamp": 1730380000,
     "token": "4e723528b72111d4d62f6b8b1dc6a24c2cfd770515157147b3fb5b058c49e7b4"
   }
   ```

---

## 🎨 디자인 시스템 (`DESIGN.md` 준수)

* **Fresh & Airy Canvas:** 눈의 피로를 최소화하는 순백색(`#FFFFFF`) 및 쿨 알바스터(`#F8FAFC`) 배경
* **Zesty Single Accent:** 활기찬 제스티 코랄(`AppColors.primary` — `#FF5A5F`)과 청량한 프레시 민트(`AppColors.secondary` — `#00D19A`)
* **Tactile Softness:** 모던 라운딩 코너 (버튼 14px, 카드 20px, QR 다이얼로그 28px, 배지 9999px Pill)
* **글래스모피즘 & 딤:** QR 발급 시 `BackdropFilter` 블러와 은은한 앰비언트 섀도우를 통한 세련된 공간감 연출

---

## 📂 프로젝트 구조

`AGENTS.md` 지침에 따라 Feature-First Clean Architecture(`lib/featrues/`)를 엄격히 준수합니다.

```text
lib/
├── main.dart                                   # 앱 진입점, SharedPreferences 주입, 테마 설정
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                     # DESIGN.md 색상 토큰
│   │   └── kiosk_constants.dart                # TOTP 키, 타이머 및 설정 기본값
│   ├── theme/
│   │   └── app_theme.dart                      # Material 3 모던 UI 테마
│   └── utils/
│       └── totp_generator.dart                 # HMAC-SHA256 TOTP 생성 및 검증 유틸
└── featrues/                                   # ⚠️ 레거시/가이드라인 준수: featrues
    ├── admin/
    │   ├── domain/
    │   │   ├── ad_item.dart                    # 광고 미디어 모델 및 내장 샘플 데이터
    │   │   └── kiosk_config.dart               # 매장 정보 및 설정 불변 모델
    │   ├── repository/
    │   │   └── kiosk_config_repository.dart    # SharedPreferences 기반 영속 저장소
    │   ├── provider/
    │   │   └── kiosk_config_provider.dart      # Riverpod 설정 관리 및 서버 동기화 Notifier
    │   └── presentation/
    │       ├── pages/
    │       │   └── admin_settings_page.dart    # 관리자 설정 대시보드 화면
    │       └── widgets/
    │           ├── ad_item_tile.dart           # 광고 미디어 타일 & 순서 변경 핸들
    │           └── add_ad_dialog.dart          # 로컬 파일 / URL / 프리셋 추가 다이얼로그
    └── kiosk/
        ├── provider/
        │   └── kiosk_playback_provider.dart    # 광고 롤링, QR 타이머, 15초 자동 닫힘 상태
        └── presentation/
            ├── pages/
            │   ├── kiosk_standby_page.dart     # 대기 모드 광고 플레이어 & 터치 감지
            │   └── qr_display_modal.dart       # 28px 라운드 카드 동적 QR 발급 모달
            └── widgets/
                ├── ad_media_view.dart          # 이미지/비디오 통합 플레이어 (오류 복구 포함)
                ├── qr_countdown_timer.dart     # 30초 실시간 게이지 및 15초 복귀 배지
                └── hidden_gesture_detector.dart # 우측 상단 5회 탭 / 롱프레스 감지기
```

---

## 🚀 실행 및 테스트

### 1. 패키지 의존성 설치
```bash
flutter pub get
```

### 2. 정적 분석 및 린트 검사 (0 errors/warnings)
```bash
flutter analyze
```

### 3. 단위 및 위젯 테스트 실행
TOTP 윈도우 계산, HMAC-SHA256 서명, JSON 페이로드 규격 검증 및 위젯 렌더링 테스트가 포함되어 있습니다.
```bash
flutter test
```

### 4. 앱 실행
```bash
# 데스크톱 (Windows) 실행
flutter run -d windows

# Chrome 웹 실행
flutter run -d chrome

# Android / 태블릿 실행
flutter run -d <device_id>
```

---

## 🛠 주요 사용 패키지
* `flutter_riverpod` (^3.4.3): 전역 및 상태 관리
* `qr_flutter` (^4.1.0): 동적 QR 코드 고화질 렌더링
* `crypto` (^3.0.8): HMAC-SHA256 해시 암호화
* `video_player` (^2.14.1): 키오스크 홍보 MP4 비디오 스트리밍/재생
* `shared_preferences` (^2.5.6): 매장 정보 및 광고 목록 로컬 영속 저장
* `file_picker` (^13.3.0): 기기 내 미디어 파일 선택
* `intl` (^0.20.3): 시간 및 포맷터 지원

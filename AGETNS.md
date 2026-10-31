# Gemini CLI Flutter Guidelines (AGENTS.md)

이 문서는 AI 에이전트가 **Grepiu Sign (`flutter_basic_fw`)** 프로젝트에서 코드를 탐색, 생성, 수정할 때 반드시 준수해야 할 아키텍처, 비즈니스 로직, 성능 최적화 및 보안 규칙을 정의합니다.

---

## 0. AI 에이전트 핵심 행동 수칙 (Golden Rules)
AI 에이전트는 작업 전후로 아래 5가지 절대 규칙을 최우선으로 검증해야 합니다.

1. **경로 스펠링 엄수 (`lib/featrues/`)**: 기존 레거시 호환성을 위해 기능 폴더명은 `features`가 아닌 **`lib/featrues/`**를 유지합니다. 임의로 폴더명을 수정하거나 `lib/features/` 경로로 새 파일을 생성하지 마세요.
2. **생성 파일 직접 수정 금지**: `*.g.dart`, `*.freezed.dart` 파일은 어떠한 경우에도 직접 편집하지 않으며, 모델/Provider 수정 시 반드시 `dart run build_runner build --delete-conflicting-outputs`를 실행합니다.
3. **신규 상태 관리 표준화**: 레거시 코드에 `ChangeNotifierProvider`가 일부 남아있으나, **모든 신규 및 리팩토링 코드는 반드시 `@riverpod` 어노테이션 기반 Generator 문법**으로만 작성합니다.
4. **자원 및 메모리 해제 (Dispose)**: 태블릿/키오스크 특성상 장시간 켜져 있으므로 `Timer`, `AudioPlayer`, `QuillController`, `HandSignatureControl`, `Ad` 객체는 위젯/Provider 소멸 시 반드시 `dispose()` 또는 `ref.onDispose()`로 해제해야 합니다.
5. **생략 없는 완전한 코드 작성**: 코드 수정 시 `// ... 기존 코드 생략` 등으로 임의 누락하여 파일이 깨지지 않도록 주의하고, 변경 후 `flutter analyze`가 0 error/warning인지 확인합니다.

---

## 1. 프로젝트 정체성 및 아키텍처

- **프로젝트명**: Grepiu Sign — 다국어 전자 동의/날인 프레임워크 (`KOR` / `ENG` / `JAP` / `CHI`)
- **화면 방향 및 환경**: 전역 강제 가로 모드 (`CommonUtils.setLandscapeMode()`). 주로 태블릿/패드 환경에서 동작합니다.
- **아키텍처 패턴**: Feature-first Clean Architecture (`lib/featrues/{feature}/`)

### 디렉토리 구조 및 레이어 의존성 규칙
`presentation` ➔ `provider` ➔ `repository` ➔ `domain` 순으로 단방향 참조만 허용합니다. (`domain`과 `repository`는 절대 UI 패키지를 import하지 않습니다.)

```text
lib/
├── main.dart                     # Firebase 초기화, ProviderScope, 가로모드 강제, 앱 진입점
├── core/                         # 전역 공통 유틸리티 (CommonUtils, CommonConstants, AdMobService 등)
└── featrues/                     # ⚠️ 주의: 스펠링 'featrues' 고정
    └── {feature_name}/
        ├── domain/               # Freezed 불변 엔티티 및 도메인 모델 (*.freezed.dart, *.g.dart)
        ├── repository/           # 데이터 접근 계층 (SignDB SQLite 제어, SyncRepository API 통신)
        ├── provider/             # Riverpod 상태 관리 (@riverpod 함수 및 Notifier 클래스)
        └── presentation/
            ├── pages/            # 전체 화면 단위 스크린 위젯
            └── widgets/          # 화면 내 분리된 재사용/모듈 위젯 (const 생성자 적극 활용)
```

---

## 2. 상태 관리 및 데이터 모델링 (Riverpod 3 & Freezed 3)

### Riverpod 가이드라인 (`flutter_riverpod ^3.1.0` + `riverpod_generator ^4.0.0`)
- **조회 전용 (Read-only / Future)**: `@riverpod` 함수형 Provider로 작성합니다.
- **상태 변경 (Mutable State)**: `@riverpod class XxxNotifier extends _$XxxNotifier`로 작성합니다.
- **비동기 안전성**: 비동기 작업(`await`) 이후 UI 컨텍스트나 상태를 건드릴 때는 반드시 `if (!context.mounted) return;`을 체크합니다.
- **불필요한 리빌드 최적화**: 위젯에서 거대한 상태 객체 전체를 구독하지 말고, `ref.watch(provider.select((s) => s.targetField))`를 사용하여 필요한 필드만 구독하세요.

### Freezed 불변 모델 (`freezed ^3.2.3` + `json_serializable ^6.11.2`)
- 모든 도메인/DTO 모델은 `@freezed`로 선언하여 불변성(Immutability)과 `copyWith`, 값 동등성(`==`)을 보장합니다.

### 코드 생성 명령어 (Flutter 최신 CLI 표준)
```bash
# 모델/Provider 변경 후 즉시 실행
dart run build_runner build --delete-conflicting-outputs

# 정적 분석 및 Riverpod 린트 검사
flutter analyze
dart run custom_lint
```

---

## 3. UI/UX, 반응형 및 성능 최적화 규칙

- **텍스트 오버플로우 원천 차단 (Text Scaling)**:
  - 다국어(특히 영어/일본어 번역 시 길어지는 문구) 대응을 위해 버튼 및 제한된 박스 내 텍스트는 2줄 줄바꿈이나 `...` 잘림이 발생하지 않도록 **`FittedBox(fit: BoxFit.scaleDown)`**로 감싸 자동 축소되게 구현합니다.
- **폰트 일관성 유지**:
  - 코드 표준 폰트 상수: `CommonConstants.standardFontFamily` (`NanumSquareNeo`)
  - 에셋 등록 폰트: `Pretendard` (9가지 가중치 `assets/fonts/Pretendard-*.otf`)
  - ⚠️ **최적화 주의**: 하드코딩된 폰트 패밀리 문자열 사용을 금지하고 반드시 `CommonConstants.standardFontFamily` 또는 `Theme.of(context).textTheme`을 참조하여 추후 폰트 단일화(`Pretendard` 통합 등) 시 한 곳에서만 변경 가능하도록 작성합니다.
- **반응형 스케일링 (`responsive_sizer ^3.3.1`)**:
  - 고정 픽셀 대신 `.sp`(폰트), `.w` / `vw`(너비), `.h` / `vh`(높이) 단위를 사용하여 다양한 태블릿 해상도에 대응합니다.
- **테마 및 Material 3 (`useMaterial3: true`)**:
  - 시드 컬러: `Colors.blue`
  - `AppBarTheme`: 배경 `Colors.white`, `elevation: 0`, `centerTitle: true`
  - `CardTheme`: 배경 `Colors.white`, `elevation: 2`, 모서리 `BorderRadius.circular(20)`
- **네이티브 스플래시 (`flutter_native_splash ^2.4.4`)**:
  - Light: `#e1f5fe`, Dark: `#042a49`, 이미지: `assets/splash/splash.png` (Android 12+ 명시적 설정 유지)
- **타이머 정책**:
  - 서명 페이지 진입 시 **60초 카운트다운 타이머**가 동작하며, 시간 내 서명 미완료 시 리소스를 정리하고 첫 화면으로 자동 복귀합니다.

---

## 4. 데이터베이스 아키텍처 (`SignDB` - SQLite)

- **위치**: `lib/featrues/sign/repository/sign_db.dart` (Singleton 패턴)
- **테이블 스키마**:
  1. `sign`: `(id TEXT PRIMARY KEY, createDate NUMERIC, imagePath TEXT, lang TEXT)`
  2. `consent_form`: `(id INTEGER PRIMARY KEY AUTOINCREMENT, consentText TEXT)`
  3. `auth`: `(key TEXT, device TEXT, createDate NUMERIC)`
  4. `metadata`: `(key TEXT PRIMARY KEY, value TEXT)` — 앱 설정 및 카운터 영속 저장소

### `metadata` 핵심 키 명세
| Key | 설명 및 동작 방식 |
|---|---|
| `translate_count` | 당일 AI 번역/동의서 저장 사용 횟수 (`00:00` 자정 기준 리셋) |
| `translate_date` | 마지막 AI 번역 수행 날짜 (`yyyy-MM-dd` 포맷 문자열) |
| `consent_submit_count` | 동의서 서명 완료 누적 횟수 (10회 주기 전면 광고 트리거용) |
| `translations_locked` | 일반 저장 후 언어 잠김 상태 플래그 |
| `display_mode` | 화면 테마/디스플레이 모드 설정값 |
| `permission_guide_completed` | 최초 권한 안내 가이드 완료 여부 (`true`/`false`) |

### DB 최적화 및 파일 정리 규칙
- **다국어 초기 시드**: 최초 실행 시 `KOR` / `ENG` / `JAP` / `CHI` 기본 동의서 및 설정 데이터를 트랜잭션(`batch`)으로 시드합니다.
- **고아 파일(Orphan File) 방지**: 서명 내역 삭제(`SignDB.deleteOlderThan` 등 기본 30일 경과 데이터 정리) 시 **반드시 로컬 스토리지의 실제 이미지 파일(`imagePath`)을 먼저 삭제(`File(path).delete()`)한 후 DB 레코드를 삭제**하여 태블릿 용량 누수를 방지합니다. 대량 삭제 시 SQLite `Batch`를 사용하세요.

---

## 5. 핵심 비즈니스 로직 명세

### A. 사용자 등급(Tier) 및 AdMob 광고 정책 (`AdMobService`)
- **위치**: `lib/core/utils/admob_service.dart`
- **등급 판별**: `AdMobService.isPremiumUser(Auth? auth)`
  - **프리미엄 사용자 (`auth != null && auth.key.isNotEmpty && !auth.isTest`)**: 배너, 네이티브, 전면, 보상형 등 **모든 광고 100% 차단 및 로드 스킵(메모리 절약)**.
  - **무료 사용자 (`auth.isTest == true` 또는 키가 `"SIGN"`)**: 아래 광고 정책 적용.

| 광고 유형 | 노출 위치 및 트리거 조건 | 운영 광고 단위 ID (`kReleaseMode`) |
|---|---|---|
| **배너 광고** (`AdMobBannerWidget`) | 메인 인증 화면(`AuthenticationScreen`) 하단 고정 | `ca-app-pub-2803985305864806/1151445465` |
| **네이티브 고급형** (`AdMobNativeWidget`) | 서명 관리 화면(`SignManagerScreen`) 하단 고정 | `ca-app-pub-2803985305864806/4899118789` |
| **전면 광고** (약 5초) | 서명 완료 누적 `consent_submit_count`가 **10의 배수(10, 20, 30...)**일 때 팝업 | `ca-app-pub-2803985305864806/9643344852` |
| **보상형 전면 광고** | 1) 동의서 백업/내보내기 실행 시<br>2) 무료 유저가 동의서 문구 **2회 ➔ 3회차 저장** 시도 시 (사전 안내 모달 승인 후) | `ca-app-pub-2803985305864806/3394465420` |

> **주의**: `kDebugMode`에서는 반드시 Google 공식 테스트 광고 ID가 매핑되도록 분기 로직을 유지해야 계정 정지를 막을 수 있습니다.

### B. 동의서 문구 일일 저장 제한 및 자정(00:00) 자동 리셋
- **일일 한도**:
  - **무료 사용자**: 하루 최대 **3회** 저장 가능 (2➔3회차 전환 시 보상형 광고 시청 필수). 3회 달성 시 저장 버튼 비활성화 및 익일 00:00 리셋 안내.
  - **프리미엄 사용자**: 하루 최대 **20회** 저장 가능. 왕관(👑) 아이콘 및 퍼플/골드 전용 프리미엄 테마 UI 적용.
- **자정 리셋 로직**:
  - 화면 진입 및 저장 시도 시 `SignDB`의 `translate_date`와 현재 로컬 날짜(`DateFormat('yyyy-MM-dd').format(DateTime.now())`)를 비교합니다.
  - 날짜가 다르면 즉시 `translate_date`를 오늘 날짜로 갱신하고 `translate_count`를 `0`으로 초기화합니다.

### C. 서버 동기화 및 인증 API (`SyncRepository`)
- **실시간 인증 검증**: `checkAuthStatus(key, device)` (`GET /v1/sign/authenticate/check`)
  - 앱 구동 시 프리미엄 키 상태를 확인하여 `resultCode == 100`이면 프리미엄 유지, 그 외(`!= 100`)에는 즉시 로컬 DB 계정을 무료 계정(`"SIGN"`)으로 강등 처리합니다.
- **번역 API**: `translate(key, device, text, language, {firebaseInstallationId, type})`
  - 무료 사용자(`type: "SIGN"`)의 서버 측 Rate Limit 식별을 위해 `FirebaseInstallations.instance.getId()` 값을 필수로 전송합니다.
- **전체 동기화**: `syncAllTranslations(key, device, {type})` — 정식 키 인증 성공 시 전체 다국어 동의서 일괄 번역 동기화.
- **응답 코드 (`resultCode`) 표준 처리**:
  - `100`: 정상 성공
  - `901`: 유효하지 않은 키 (무효 키 안내)
  - `903`: 일일/시간당 Rate Limit 초과 안내
  - `904`: 관리자 거부/차단된 키 안내
  - `905`: 등록 기기 대수 초과 또는 기기 불일치 안내

---

## 6. 주요 의존성 명세

### 런타임 의존성 (`dependencies`)
| 카테고리 | 패키지 | 버전 | 핵심 용도 |
|---|---|---|---|
| **상태/모델** | `flutter_riverpod` / `riverpod_annotation` | `^3.1.0` / `^4.0.0` | 전역 및 로컬 상태 관리 |
| **상태/모델** | `freezed_annotation` / `json_annotation` | `^3.1.0` / `^4.9.0` | 불변 객체 및 JSON 직렬화 |
| **데이터/네트워크** | `sqflite` / `path_provider` | `^2.4.1` / `^2.1.5` | 로컬 SQLite DB 및 파일 시스템 경로 |
| **데이터/네트워크** | `http` / `uuid` | `^1.3.0` / `^4.4.2` | REST API 통신 및 고유 식별자 생성 |
| **서명/문서/미디어** | `hand_signature` / `screenshot` | `^3.0.3` / `^3.0.0` | 전자서명 패드 드로잉 및 위젯 이미지 캡처 |
| **서명/문서/미디어** | `flutter_quill` | `^11.5.0` | 동의서 리치 텍스트 에디터 (`FlutterQuillLocalizations` 필수) |
| **서명/문서/미디어** | `audioplayers` / `photo_view` | `^6.6.0` / `^0.15.0` | 다국어 안내 음성 재생 및 서명 이미지 확대 |
| **UI/반응형** | `responsive_sizer` / `responsive_grid_list` | `^3.3.1` / `^1.4.0` | 태블릿 반응형 레이아웃 및 그리드 |
| **UI/반응형** | `animate_do` / `fl_chart` / `country_flags` | `^5.1.0` / `^1.2.0` / `^4.1.2` | 애니메이션, 통계 차트, 국가별 국기 아이콘 |
| **기기/권한/외부** | `permission_handler` / `storage_utility` | `^12.0.1` / `^1.0.0` | 권한 요청 및 디스크 잔여 용량 확인 |
| **기기/권한/외부** | `file_picker` / `open_file` / `gal` / `share_plus` / `url_launcher` | 각 최신 호환 버전 | 파일 입출력, 갤러리 저장, 외부 공유 |
| **수익화/식별** | `google_mobile_ads` | `^5.2.0` | AdMob 광고 렌더링 |
| **수익화/식별** | `firebase_core` / `firebase_app_installations` | `^4.11.0` / `^0.4.2+4` | Firebase 초기화 및 기기 고유 설치 ID 발급 |

### 개발 의존성 (`dev_dependencies`)
- `flutter_lints: ^6.0.0`, `custom_lint`, `riverpod_lint: ^3.1.0`
- `build_runner`, `riverpod_generator: ^4.0.0+1`, `freezed: ^3.2.3`, `json_serializable: ^6.11.2`

---

## 7. 정적 자산(Assets) 및 오픈소스 라이선스 관리

- **음성 에셋 (`assets/voice/`)**:
  - 동의 안내: `agreement_voice.{kor,eng,jap,chi}.mp3`
  - 서명 완료: `complete.{kor,eng,jap,chi}.mp3`
- **라이선스 파일 (`assets/common/license.txt`)**:
  - `pubspec.yaml`에 새로운 외부 패키지를 추가할 때마다 해당 패키지의 오픈소스 라이선스 전문을 확인하고 반드시 `assets/common/license.txt` 하단에 추가해야 합니다.

---

## 8. 에이전트 작업 검증 체크리스트 (Pre-commit Workflow)
코드를 작성하거나 수정한 후 작업을 완료하기 전에 반드시 아래 순서대로 명령어를 실행하여 무결성을 검증하세요.

```bash
# 1. 의존성 변경 시 패키지 동기화
flutter pub get

# 2. Freezed / Riverpod / JSON 코드 생성
dart run build_runner build --delete-conflicting-outputs

# 3. 정적 분석 및 린트 에러 확인 (경고 및 에러 0건 목표)
flutter analyze
dart run custom_lint

# 4. 단위 및 위젯 테스트 실행
flutter test
```
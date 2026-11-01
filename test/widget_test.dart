import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stamp_admin/core/theme/app_theme.dart';
import 'package:stamp_admin/featrues/admin/domain/ad_item.dart';
import 'package:stamp_admin/featrues/admin/domain/kiosk_config.dart';
import 'package:stamp_admin/featrues/admin/presentation/pages/admin_settings_page.dart';
import 'package:stamp_admin/featrues/admin/presentation/widgets/ad_item_tile.dart';
import 'package:stamp_admin/featrues/admin/presentation/widgets/add_ad_dialog.dart';
import 'package:stamp_admin/featrues/admin/provider/kiosk_config_provider.dart';
import 'package:stamp_admin/featrues/kiosk/presentation/pages/kiosk_standby_page.dart';
import 'package:stamp_admin/featrues/kiosk/presentation/pages/qr_display_modal.dart';
import 'package:stamp_admin/featrues/kiosk/presentation/pages/splash_screen.dart';
import 'package:stamp_admin/featrues/kiosk/presentation/widgets/ad_media_view.dart';
import 'package:stamp_admin/featrues/kiosk/presentation/widgets/admin_pin_dialog.dart';

void main() {
  group('KioskStandbyPage 해상도별 렌더링 및 Overflow 방어 테스트', () {
    testWidgets('초소형 세로 해상도 (320x568)에서 오버플로우 없이 렌더링되어야 한다', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const KioskAppTestWrapper(),
        ),
      );

      await tester.pump();

      expect(find.text('강남 본점'), findsOneWidget);
      expect(find.text('화면을 터치하여 스탬프를 적립하세요'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('일반 스마트폰 세로 해상도 (390x844)에서 오버플로우 없이 렌더링되어야 한다', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const KioskAppTestWrapper(),
        ),
      );

      await tester.pump();

      expect(find.text('강남 본점'), findsOneWidget);
      expect(find.text('화면을 터치하여 스탬프를 적립하세요'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('태블릿 및 와이드 해상도 (800x600, 1920x1080)에서 가로 헤더 형태로 정상 렌더링되어야 한다', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const KioskAppTestWrapper(),
        ),
      );

      await tester.pump();

      expect(find.text('강남 본점'), findsOneWidget);
      expect(find.text('화면을 터치하여 스탬프를 적립하세요'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('매우 긴 매장명 설정 시에도 좁은 해상도에서 오버플로우가 발생하지 않아야 한다', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            kioskConfigNotifierProvider.overrideWith(() => LongNameConfigNotifier()),
          ],
          child: const KioskAppTestWrapper(),
        ),
      );

      await tester.pump();

      expect(find.text('스타벅스 강남역 스탬프투어 리저브 2호점 프론트데스크'), findsOneWidget);
      expect(find.text('화면을 터치하여 스탬프를 적립하세요'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('화면 터치 시 QR 모달이 낮은 화면 높이(800x450)에서도 오버플로우 없이 렌더링되어야 한다', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 450);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const KioskAppTestWrapper(),
        ),
      );

      await tester.pump();

      // 화면 터치 -> QR 모달 오픈
      await tester.tap(find.text('화면을 터치하여 스탬프를 적립하세요'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('스탬프 앱으로 스캔해 주세요'), findsOneWidget);
      expect(find.text('동적 보안 인증'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('관리자 인증(PIN) 및 비밀번호 변경 테스트', () {
    testWidgets('설정 버튼 탭 시 비밀번호 다이얼로그가 뜨고 0000 입력 시 관리자 설정으로 이동한다', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const KioskAppTestWrapper(),
        ),
      );

      await tester.pump();

      // 우측 상단 설정 버튼 찾기
      final settingsButton = find.byIcon(Icons.settings_rounded);
      expect(settingsButton, findsOneWidget);

      // 설정 버튼 탭
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      // 관리자 인증 다이얼로그 확인
      expect(find.text('관리자 인증'), findsOneWidget);
      expect(find.textContaining('초기 비밀번호: 0000'), findsOneWidget);

      // 잘못된 비밀번호 1234 입력 후 확인
      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.widgetWithText(ElevatedButton, '확인'));
      await tester.pump();

      // 에러 메시지 노출 및 다이얼로그 유지
      expect(find.text('비밀번호가 일치하지 않습니다.'), findsOneWidget);
      expect(find.text('관리자 인증'), findsOneWidget);

      // 초기 비밀번호 0000 입력 후 확인
      await tester.enterText(find.byType(TextField), '0000');
      await tester.tap(find.widgetWithText(ElevatedButton, '확인'));
      await tester.pumpAndSettle();

      // 관리자 설정 페이지 도착 확인
      expect(find.text('키오스크 관리자 설정'), findsOneWidget);
      expect(find.text('관리자 접속 비밀번호 설정'), findsOneWidget);
    });

    testWidgets('관리자 설정 화면에서 비밀번호를 0000에서 9999로 정상 변경할 수 있다', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      late ProviderContainer container;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container = ProviderContainer(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
            ],
          ),
          child: const KioskAppTestWrapper(),
        ),
      );

      await tester.pump();

      // 설정 버튼 탭 -> 0000 입력 -> 진입
      await tester.tap(find.byIcon(Icons.settings_rounded));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '0000');
      await tester.tap(find.widgetWithText(ElevatedButton, '확인'));
      await tester.pumpAndSettle();

      // 비밀번호 변경 필드 3개 찾기
      // 0: placeId, 1: placeName, 2: currentPin, 3: newPin, 4: confirmPin
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(5));

      // 현재 비밀번호, 새 비밀번호, 확인 입력
      await tester.enterText(textFields.at(2), '0000');
      await tester.enterText(textFields.at(3), '9999');
      await tester.enterText(textFields.at(4), '9999');

      // 비밀번호 변경 버튼 클릭
      await tester.tap(find.widgetWithText(ElevatedButton, '비밀번호 변경'));
      await tester.pump();

      // 성공 스낵바 확인
      expect(find.text('관리자 비밀번호가 성공적으로 변경되었습니다.'), findsOneWidget);

      // Provider 상태에 변경된 비밀번호 반영 확인
      expect(container.read(kioskConfigNotifierProvider).adminPin, '9999');
    });
  });

  group('SplashScreen 스플래시 화면 브랜딩 및 전환 테스트', () {
    testWidgets('스플래시 화면이 정상 렌더링되고 브랜드 텍스트가 표시된다', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SplashScreen(),
          ),
        ),
      );

      await tester.pump();

      // 브랜드 로고 및 타이틀 텍스트 확인
      expect(find.text('STAMP KIOSK'), findsOneWidget);
      expect(find.text('강남 본점'), findsOneWidget);
      expect(find.text('키오스크 시스템을 준비하고 있습니다...'), findsOneWidget);

      // 애니메이션 및 약 1000ms 경과 후 KioskStandbyPage로 신속 전환 확인
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();

      expect(find.text('화면을 터치하여 스탬프를 적립하세요'), findsOneWidget);
    });
  });

  group('AdItemTile 및 미디어 추가 3자리 초 Overflow 방어 테스트', () {
    testWidgets('3자리 초(120초) 설정 시 좁은 해상도(320px)에서 AdItemTile이 오버플로우 없이 렌더링되어야 한다', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: AdItemTile(
                index: 0,
                item: const AdItem(
                  id: 'test_ad_1',
                  title: '신메뉴 프로모션 영상 1234567890',
                  type: AdMediaType.video,
                  sourceType: AdSourceType.file,
                  path: '/storage/emulated/0/Movies/sample_video.mp4',
                  durationSeconds: 120,
                ),
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('120초'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AddAdDialog에서 3자리 초(120) 입력 후 추가 시 정상적으로 onAdd 콜백이 호출되어야 한다', (WidgetTester tester) async {
      AdItem? addedItem;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddAdDialog(
                      onAdd: (item) {
                        addedItem = item;
                      },
                    ),
                  );
                },
                child: const Text('다이얼로그 열기'),
              ),
            ),
          ),
        ),
      );

      // 다이얼로그 열기
      await tester.tap(find.text('다이얼로그 열기'));
      await tester.pumpAndSettle();

      expect(find.text('새 광고 미디어 추가'), findsOneWidget);

      // 텍스트필드들: 0: 제목, 1: 경로/URL, 2: 노출시간
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(3));

      await tester.enterText(textFields.at(0), '120초짜리 특별 프로모션');
      await tester.enterText(textFields.at(1), 'https://example.com/promo.png');
      await tester.enterText(textFields.at(2), '120');

      // '광고 목록에 추가' 버튼 클릭
      await tester.tap(find.widgetWithText(ElevatedButton, '광고 목록에 추가'));
      await tester.pumpAndSettle();

      expect(addedItem, isNotNull);
      expect(addedItem!.durationSeconds, 120);
      expect(addedItem!.title, '120초짜리 특별 프로모션');
      expect(tester.takeException(), isNull);
    });

    testWidgets('투명 설정 버튼이 우측 상단에 배치되고 가볍게 탭 시 관리자 인증 팝업이 노출된다', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const KioskAppTestWrapper(),
        ),
      );

      await tester.pump();

      // 투명 설정 아이콘(크기 16px) 존재 확인
      final settingsIconFinder = find.byIcon(Icons.settings_rounded);
      expect(settingsIconFinder, findsOneWidget);

      final iconWidget = tester.widget<Icon>(settingsIconFinder);
      expect(iconWidget.size, 16);
      expect(iconWidget.color?.a, closeTo(0.20, 0.05));

      // 살짝 클릭(1회 탭) 시 관리자 인증 다이얼로그가 즉시 열리는지 확인
      await tester.tap(settingsIconFinder);
      await tester.pumpAndSettle();

      expect(find.text('관리자 인증'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AdMediaView에 기본 광고가 주어졌을 때 에러 없이 플레이스홀더 및 미디어가 안정적으로 렌더링된다', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AdMediaView(
              ads: AdItem.defaultAds,
              currentIndex: 0,
              isPaused: false,
              onMediaFinished: () {},
            ),
          ),
        ),
      );

      await tester.pump();

      // 첫 번째 광고 제목이 노출되어야 한다
      expect(find.text('스페셜티 시그니처 커피'), findsAtLeastNWidgets(1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('가로 모드(844x390, 640x360)에서 SplashScreen 렌더링 시 오버플로우 확인', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(home: SplashScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('가로 모드(844x390, 640x360)에서 KioskStandbyPage 렌더링 시 오버플로우 확인', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const KioskAppTestWrapper(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('초소형 가로 모드(568x320)에서 KioskStandbyPage 렌더링 시 오버플로우 확인', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(568, 320);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const KioskAppTestWrapper(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('초소형 가로 모드(568x320)에서 QrDisplayModal 렌더링 시 오버플로우 확인', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(568, 320);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(
            home: Scaffold(body: QrDisplayModal()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('가로 모드(640x360)에서 AdminPinDialog 렌더링 시 오버플로우 확인', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(640, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AdminPinDialog(correctPin: '0000')),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('가로 모드(640x360)에서 키보드(viewInsets: 200)가 올라와도 비밀번호 입력 후 확인 버튼으로 설정 화면에 정상 진입해야 한다', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(640, 360);
      tester.view.devicePixelRatio = 1.0;
      tester.view.viewInsets = const FakeViewPadding(bottom: 200);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetViewInsets();
      });

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const KioskAppTestWrapper(),
        ),
      );
      await tester.pump();

      // 우측 상단 투명 설정 버튼 탭
      await tester.tap(find.byIcon(Icons.settings_rounded));
      await tester.pumpAndSettle();

      expect(find.text('관리자 인증'), findsOneWidget);

      // 비밀번호 '0000' 입력
      await tester.enterText(find.byType(TextField), '0000');
      await tester.pump();

      // 확인 버튼 탭
      final confirmButton = find.widgetWithText(ElevatedButton, '확인');
      expect(confirmButton, findsOneWidget);
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // 관리자 설정 페이지로 정상 진입 확인
      expect(find.text('키오스크 관리자 설정'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('가로 모드(640x360)에서 AddAdDialog 렌더링 시 오버플로우 확인', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(640, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AddAdDialog(onAdd: (_) {})),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('가로 모드(640x360)에서 AdminSettingsPage 렌더링 시 오버플로우 확인', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(640, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(home: AdminSettingsPage()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}

class LongNameConfigNotifier extends KioskConfigNotifier {
  @override
  KioskConfig build() {
    return const KioskConfig(
      placeId: 'TEST_LONG_PLACE',
      placeName: '스타벅스 강남역 스탬프투어 리저브 2호점 프론트데스크',
      ads: [],
    );
  }
}

class KioskAppTestWrapper extends StatelessWidget {
  const KioskAppTestWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: const KioskStandbyPage(),
    );
  }
}

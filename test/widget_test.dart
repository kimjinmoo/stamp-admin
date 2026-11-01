import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stamp_admin/core/theme/app_theme.dart';
import 'package:stamp_admin/featrues/admin/domain/kiosk_config.dart';
import 'package:stamp_admin/featrues/admin/provider/kiosk_config_provider.dart';
import 'package:stamp_admin/featrues/kiosk/presentation/pages/kiosk_standby_page.dart';

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

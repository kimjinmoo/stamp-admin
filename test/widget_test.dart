import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stamp_admin/core/theme/app_theme.dart';
import 'package:stamp_admin/featrues/admin/provider/kiosk_config_provider.dart';
import 'package:stamp_admin/featrues/kiosk/presentation/pages/kiosk_standby_page.dart';

void main() {
  testWidgets('StampAdminApp 대기 모드 렌더링 테스트', (WidgetTester tester) async {
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

    // 이미지나 네트워크 로딩을 고려하여 1회 펌프
    await tester.pump();

    // 매장명 칩 또는 대기 화면 UI 텍스트 확인
    expect(find.text('강남 본점'), findsOneWidget);
    expect(find.text('화면을 터치하여 스탬프를 적립하세요'), findsOneWidget);
  });
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

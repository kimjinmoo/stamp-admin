import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'featrues/admin/provider/kiosk_config_provider.dart';
import 'featrues/kiosk/presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 시스템 UI 오버레이 설정 (키오스크 환경에 맞춘 풀스크린/클린 뷰)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // 로컬 영속 저장소 SharedPreferences 초기화
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const StampAdminApp(),
    ),
  );
}

/// 스탬프 키오스크 관리자 앱 진입점
class StampAdminApp extends StatelessWidget {
  const StampAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '스탬프 키오스크 관리자',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

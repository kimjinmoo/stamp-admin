import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../admin/provider/kiosk_config_provider.dart';
import '../widgets/stamp_logo_widget.dart';
import 'kiosk_standby_page.dart';

/// 밝은 테마의 생동감 넘치는 도장 스탬핑 애니메이션 스플래시 화면
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // 메인 스탬프 타격 컨트롤러
  late final AnimationController _stampController;
  late final Animation<double> _dropAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;

  // 파동(Ripple) 효과 컨트롤러
  late final AnimationController _rippleController;
  late final Animation<double> _rippleRadius;
  late final Animation<double> _rippleOpacity;

  // 콘텐츠 페이드인 및 프로그레스 컨트롤러
  late final AnimationController _contentController;
  late final Animation<double> _contentSlide;
  late final Animation<double> _contentFade;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // 1. 스탬프 낙하 & 임팩트 바운스 (0 ~ 380ms)
    _stampController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _dropAnimation = Tween<double>(begin: -100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _stampController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeInCubic),
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.4, end: 1.0), weight: 65),
      // 스쿼시 (도장 찍히는 순간 납작해짐)
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.88), weight: 15),
      // 스트레치 탄성 복귀
      TweenSequenceItem(tween: Tween<double>(begin: 0.88, end: 1.0), weight: 20),
    ]).animate(_stampController);

    _rotationAnimation = Tween<double>(begin: -0.08, end: 0.0).animate(
      CurvedAnimation(
        parent: _stampController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
      ),
    );

    // 2. 도장이 찍히는 순간 퍼지는 파동(Ripple) (240ms ~ 690ms)
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _rippleRadius = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOutQuad),
    );

    _rippleOpacity = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    // 3. 텍스트 및 프로그레스 바 (240ms ~ 790ms)
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _contentSlide = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _progressAnimation = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.2, 0.95, curve: Curves.easeInOutCubic),
    );

    // 애니메이션 시퀀스 실행
    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    // 1단계: 스탬프 낙하
    _stampController.forward();

    // 2단계: 도장이 찍히는 타이밍(약 240ms)에 파동 및 타이틀 애니메이션 발동
    await Future.delayed(const Duration(milliseconds: 240));
    if (mounted) {
      _rippleController.forward();
      _contentController.forward();
    }

    // 3단계: 준비 완료 후 메인 대기 화면으로 신속하고 부드럽게 전환 (총 약 0.85초)
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const KioskStandbyPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 280),
        ),
      );
    }
  }

  @override
  void dispose() {
    _stampController.dispose();
    _rippleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(kioskConfigNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // 산뜻한 밝은 쿨 알바스터 배경
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 화면 높이가 480 미만인 가로 모드이거나 가로가 세로보다 긴 경우
            final isLandscape = constraints.maxHeight < 480;

            if (isLandscape) {
              return Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildEmblemStack(isCompact: true),
                        const SizedBox(width: 40),
                        _buildContentColumn(config.placeName, isCompact: true),
                      ],
                    ),
                  ),
                ),
              );
            }

            // 일반 세로 모드
            return Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildEmblemStack(isCompact: false),
                      const SizedBox(height: 16),
                      _buildContentColumn(config.placeName, isCompact: false),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 도장 엠블럼 & 파동 애니메이션 스택
  Widget _buildEmblemStack({required bool isCompact}) {
    final stackSize = isCompact ? 170.0 : 220.0;
    final ring1Radius = isCompact ? 160.0 : 210.0;
    final ring2Radius = isCompact ? 120.0 : 160.0;
    final iconSize = isCompact ? 92.0 : 116.0;

    return SizedBox(
      width: stackSize,
      height: stackSize,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 파동 링 1 (Zesty Coral Wave)
          AnimatedBuilder(
            animation: _rippleController,
            builder: (context, child) {
              if (!_rippleController.isAnimating && _rippleController.isDismissed) {
                return const SizedBox.shrink();
              }
              final radius = _rippleRadius.value * ring1Radius;
              return Container(
                width: radius,
                height: radius,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(
                      alpha: (_rippleOpacity.value * 0.7).clamp(0.0, 1.0),
                    ),
                    width: (3.0 * (1.0 - _rippleRadius.value)).clamp(1.0, 3.0),
                  ),
                ),
              );
            },
          ),

          // 파동 링 2 (Fresh Mint Wave)
          AnimatedBuilder(
            animation: _rippleController,
            builder: (context, child) {
              if (!_rippleController.isAnimating && _rippleController.isDismissed) {
                return const SizedBox.shrink();
              }
              final radius = (_rippleRadius.value * ring2Radius).clamp(0.0, ring2Radius);
              return Container(
                width: radius,
                height: radius,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondary.withValues(
                      alpha: (_rippleOpacity.value * 0.5).clamp(0.0, 1.0),
                    ),
                    width: (2.0 * (1.0 - _rippleRadius.value)).clamp(0.8, 2.0),
                  ),
                ),
              );
            },
          ),

          // 도장 엠블럼 (낙하 + 회전 + 바운스)
          AnimatedBuilder(
            animation: _stampController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _dropAnimation.value),
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                ),
              );
            },
            child: Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 32,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      StampLogoWidget(size: iconSize, isLightMode: true),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 브랜드 타이틀 & 매장 칩 & 프로그레스 바 컬럼
  Widget _buildContentColumn(String placeName, {required bool isCompact}) {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _contentSlide.value),
          child: Opacity(
            opacity: _contentFade.value,
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 브랜드 영문 타이틀
          Text(
            'STAMP KIOSK',
            style: TextStyle(
              fontSize: isCompact ? 22 : 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 3.5,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),

          // 매장명 칩
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: AppColors.hairline, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x080F172A),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.storefront_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  placeName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isCompact ? 20 : 40),

          // 3. 부드러운 프로그레스 바
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isCompact ? 180 : 200),
            child: AnimatedBuilder(
              animation: _contentController,
              builder: (context, child) {
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9999),
                      child: LinearProgressIndicator(
                        value: _progressAnimation.value,
                        minHeight: 5,
                        backgroundColor: AppColors.surfaceStrong,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _progressAnimation.value >= 0.95
                          ? '키오스크 시스템 준비 완료'
                          : '키오스크 시스템을 준비하고 있습니다...',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.muted,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

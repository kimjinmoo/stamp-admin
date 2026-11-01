import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// 관리자 설정 화면 진입 전 비밀번호 확인 다이얼로그
class AdminPinDialog extends StatefulWidget {
  final String correctPin;

  const AdminPinDialog({
    super.key,
    required this.correctPin,
  });

  /// 다이얼로그 열기 헬퍼 메서드 (인증 성공 시 true 반환)
  static Future<bool> show(BuildContext context, String correctPin) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AdminPinDialog(correctPin: correctPin),
    );
    return result ?? false;
  }

  @override
  State<AdminPinDialog> createState() => _AdminPinDialogState();
}

class _AdminPinDialogState extends State<AdminPinDialog> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorMessage;
  bool _obscureText = true;

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _verifyPin() {
    final inputPin = _pinController.text.trim();

    if (inputPin.isEmpty) {
      setState(() {
        _errorMessage = '비밀번호를 입력해 주세요.';
      });
      _focusNode.requestFocus();
      return;
    }

    if (inputPin == widget.correctPin) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = '비밀번호가 일치하지 않습니다.';
        _pinController.clear();
      });
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final viewInsetsBottom = mediaQuery.viewInsets.bottom;
    final isLandscape = screenHeight < 500;
    // 키보드가 올라왔을 때 사용 가능한 순수 높이
    final availableHeight = screenHeight - viewInsetsBottom;

    return Dialog(
      backgroundColor: AppColors.canvas,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: isLandscape ? 8 : 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isLandscape ? 520 : 380,
          maxHeight: availableHeight * 0.94,
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 20 : 24,
            vertical: isLandscape ? 14 : 24,
          ),
          child: isLandscape
              ? _buildLandscapeContent()
              : _buildPortraitContent(isCompact: false),
        ),
      ),
    );
  }

  /// 가로 모드: 좌측(제목 & 설명) + 우측(입력 필드 & 액션 버튼) 2열 와이드 배치
  Widget _buildLandscapeContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 좌측: 아이콘 + 제목 + 안내 문구
        Expanded(
          flex: 4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '관리자 인증',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '관리자 설정 진입 비밀번호를 입력해 주세요.\n(초기 비밀번호: 0000)',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 20),

        // 우측: 비밀번호 입력창 + 확인/취소 버튼
        Expanded(
          flex: 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPinTextField(isCompact: true),
              const SizedBox(height: 10),
              _buildActionButtons(isCompact: true),
            ],
          ),
        ),
      ],
    );
  }

  /// 세로 모드: 기존의 깔끔한 중앙 1열 배치
  Widget _buildPortraitContent({required bool isCompact}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. 자물쇠 아이콘
        Container(
          width: isCompact ? 44 : 56,
          height: isCompact ? 44 : 56,
          decoration: const BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_rounded,
            color: AppColors.primary,
            size: isCompact ? 22 : 28,
          ),
        ),
        SizedBox(height: isCompact ? 10 : 16),

        // 2. 제목 & 서브타이틀
        Text(
          '관리자 인증',
          style: TextStyle(
            fontSize: isCompact ? 18 : 20,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '관리자 설정으로 진입하려면 비밀번호를 입력해 주세요.\n(초기 비밀번호: 0000)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.muted,
            height: 1.35,
          ),
        ),
        SizedBox(height: isCompact ? 16 : 24),

        // 3. 비밀번호 입력 필드
        _buildPinTextField(isCompact: isCompact),
        SizedBox(height: isCompact ? 16 : 24),

        // 4. 액션 버튼 (취소, 확인)
        _buildActionButtons(isCompact: isCompact),
      ],
    );
  }

  Widget _buildPinTextField({required bool isCompact}) {
    return TextField(
      controller: _pinController,
      focusNode: _focusNode,
      autofocus: true,
      obscureText: _obscureText,
      keyboardType: TextInputType.number,
      maxLength: 10,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: isCompact ? 18 : 24,
        letterSpacing: 6,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      decoration: InputDecoration(
        hintText: 'PIN 입력',
        hintStyle: const TextStyle(
          fontSize: 14,
          letterSpacing: 0,
          fontWeight: FontWeight.normal,
          color: AppColors.mutedSoft,
        ),
        counterText: '',
        errorText: _errorMessage,
        errorStyle: const TextStyle(
          fontSize: 11,
          color: AppColors.error,
        ),
        filled: true,
        fillColor: AppColors.surfaceSoft,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isCompact ? 8 : 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.muted,
            size: 18,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          tooltip: _obscureText ? '비밀번호 표시' : '비밀번호 숨김',
        ),
      ),
      onSubmitted: (_) => _verifyPin(),
    );
  }

  Widget _buildActionButtons({required bool isCompact}) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.muted,
              side: const BorderSide(color: AppColors.hairline),
              minimumSize: Size.fromHeight(isCompact ? 40 : 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '취소',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: _verifyPin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: Size.fromHeight(isCompact ? 40 : 48),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '확인',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

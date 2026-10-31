import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/ad_item.dart';
import '../../provider/kiosk_config_provider.dart';
import '../widgets/ad_item_tile.dart';
import '../widgets/add_ad_dialog.dart';

/// 관리자 전용 설정 화면 (장소 정보, 광고 미디어 관리, 서버 동기화)
class AdminSettingsPage extends ConsumerStatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  ConsumerState<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends ConsumerState<AdminSettingsPage> {
  final _placeIdController = TextEditingController();
  final _placeNameController = TextEditingController();
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    final config = ref.read(kioskConfigNotifierProvider);
    _placeIdController.text = config.placeId;
    _placeNameController.text = config.placeName;
  }

  @override
  void dispose() {
    _placeIdController.dispose();
    _placeNameController.dispose();
    super.dispose();
  }

  Future<void> _savePlaceInfo() async {
    final placeId = _placeIdController.text.trim();
    final placeName = _placeNameController.text.trim();

    if (placeId.isEmpty || placeName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('장소 코드와 매장명을 모두 입력해 주세요.')),
      );
      return;
    }

    await ref
        .read(kioskConfigNotifierProvider.notifier)
        .updatePlaceInfo(placeId, placeName);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('매장 정보가 성공적으로 저장되었습니다.')),
      );
    }
  }

  Future<void> _handleServerSync() async {
    setState(() => _isSyncing = true);

    try {
      await ref.read(kioskConfigNotifierProvider.notifier).uploadToServer();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.cloud_done_rounded, color: AppColors.secondary),
                SizedBox(width: 8),
                Text('서버 동기화 안내'),
              ],
            ),
            content: const Text('서버 업로드 준비 중입니다 (추후 연동)'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  void _openAddAdDialog() {
    showDialog(
      context: context,
      builder: (context) => AddAdDialog(
        onAdd: (newAd) {
          ref.read(kioskConfigNotifierProvider.notifier).addAd(newAd);
        },
      ),
    );
  }

  Future<void> _confirmResetToDefault() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('설정 초기화'),
        content: const Text(
          '기본 매장 정보와 내장 샘플 광고 미디어 리스트로 복원하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(80, 40),
            ),
            child: const Text('초기화'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(kioskConfigNotifierProvider.notifier).resetToDefault();
      final resetConfig = ref.read(kioskConfigNotifierProvider);
      _placeIdController.text = resetConfig.placeId;
      _placeNameController.text = resetConfig.placeName;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('설정이 기본값으로 복원되었습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(kioskConfigNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(
        title: const Text('키오스크 관리자 설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: '대기 화면으로 돌아가기',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _confirmResetToDefault,
            tooltip: '기본 설정 복원',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. 장소 정보 설정 카드
                  _buildSectionCard(
                    title: '매장 및 장소 설정',
                    subtitle: 'TOTP 동적 QR 코드 생성에 사용되는 고유 매장 식별 정보입니다.',
                    icon: Icons.store_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _placeIdController,
                          decoration: const InputDecoration(
                            labelText: '장소 코드 (placeId)',
                            hintText: '예: STORE_SEOUL_001',
                            prefixIcon: Icon(Icons.tag_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _placeNameController,
                          decoration: const InputDecoration(
                            labelText: '매장 이름 (placeName)',
                            hintText: '예: 강남 본점',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: _savePlaceInfo,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(140, 46),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.save_rounded, size: 18),
                            label: const Text('매장 정보 저장'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. 광고 미디어 리스트 관리 카드
                  _buildSectionCard(
                    title: '대기 모드 광고 미디어 목록',
                    subtitle: '핸들을 드래그하여 순서를 변경하거나 새 미디어를 추가할 수 있습니다.',
                    icon: Icons.slideshow_rounded,
                    action: ElevatedButton.icon(
                      onPressed: _openAddAdDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ink,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(120, 42),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('미디어 추가'),
                    ),
                    child: config.ads.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSoft,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                '등록된 광고 미디어가 없습니다.\n상단의 [미디어 추가] 버튼을 눌러 등록하세요.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.muted),
                              ),
                            ),
                          )
                        : ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: config.ads.length,
                            onReorderItem: (oldIndex, newIndex) {
                              ref
                                  .read(kioskConfigNotifierProvider.notifier)
                                  .reorderAds(oldIndex, newIndex);
                            },
                            itemBuilder: (context, index) {
                              final item = config.ads[index];
                              return AdItemTile(
                                key: ValueKey(item.id),
                                index: index,
                                item: item,
                                onDelete: () {
                                  _confirmDeleteAd(item);
                                },
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 20),

                  // 3. 서버 동기화 섹션 (admin.md 3.C)
                  _buildSectionCard(
                    title: '서버 동기화 및 관리 로그',
                    subtitle: '현재 설정 및 키오스크 발급 로그를 중앙 서버로 전송합니다.',
                    icon: Icons.cloud_sync_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '중앙 관제 서버와 연동하여 최신 광고 목록을 다운로드하거나 키오스크 동작 로그를 업로드할 수 있습니다.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.muted,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isSyncing ? null : _handleServerSync,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: _isSyncing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.cloud_upload_rounded),
                          label: Text(
                            _isSyncing
                                ? '서버와 동기화 중...'
                                : '서버에 설정 및 로그 올리기',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 대기 화면 바로 돌아가기 하단 CTA
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: AppColors.canvas,
                      side: const BorderSide(color: AppColors.hairline),
                    ),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('대기 모드로 돌아가기 (광고 재생 재개)'),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAd(AdItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('광고 삭제'),
        content: Text('\'${item.title}\' 미디어를 광고 목록에서 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(kioskConfigNotifierProvider.notifier)
                  .removeAd(item.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(80, 40),
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
    Widget? action,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.hairline, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: 12),
                action,
              ],
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: AppColors.hairline),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

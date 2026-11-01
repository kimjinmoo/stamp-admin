import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/ad_item.dart';

/// 광고 미디어(파일 또는 URL) 추가 다이얼로그
class AddAdDialog extends StatefulWidget {
  final ValueChanged<AdItem> onAdd;

  const AddAdDialog({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddAdDialog> createState() => _AddAdDialogState();
}

class _AddAdDialogState extends State<AddAdDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // URL 입력 폼 컨트롤러
  final _titleController = TextEditingController();
  final _pathController = TextEditingController();
  final _durationController = TextEditingController(text: '5');
  AdMediaType _selectedMediaType = AdMediaType.image;
  AdSourceType _selectedSourceType = AdSourceType.network;

  bool _isPickingFile = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _pathController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickLocalFile() async {
    setState(() => _isPickingFile = true);

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'mp4', 'mov'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        final path = file.path ?? '';
        final ext = (file.extension ?? '').toLowerCase();

        final isVideo = ['mp4', 'mov'].contains(ext);
        _selectedMediaType = isVideo ? AdMediaType.video : AdMediaType.image;
        _selectedSourceType = AdSourceType.file;
        _pathController.text = path;
        _titleController.text = file.name;
        _durationController.text = isVideo ? '15' : '5';

        // 탭을 입력 폼으로 전환
        _tabController.animateTo(0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('파일 선택 중 오류 발생: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingFile = false);
      }
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    final path = _pathController.text.trim();
    final duration = int.tryParse(_durationController.text.trim()) ?? 5;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('광고 제목을 입력해 주세요.')),
      );
      return;
    }

    if (path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('파일 경로 또는 URL을 입력해 주세요.')),
      );
      return;
    }

    final newAd = AdItem(
      id: 'ad_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      type: _selectedMediaType,
      sourceType: _selectedSourceType,
      path: path,
      durationSeconds: duration > 0 ? duration : 5,
    );

    widget.onAdd(newAd);
    Navigator.of(context).pop();
  }

  void _addPresetSample(String title, String url, AdMediaType type, int duration) {
    final newAd = AdItem(
      id: 'ad_sample_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      type: type,
      sourceType: AdSourceType.network,
      path: url,
      durationSeconds: duration,
    );
    widget.onAdd(newAd);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final dialogMaxHeight = math.min(680.0, screenHeight > 400 ? screenHeight * 0.88 : screenHeight);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 520, maxHeight: dialogMaxHeight),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '새 광고 미디어 추가',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 탭 바
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.muted,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: '직접 입력 / 파일'),
                  Tab(text: '추천 샘플 URL'),
                ],
              ),

              const SizedBox(height: 16),

              // 탭 뷰
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFormTab(),
                    _buildPresetTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 로컬 파일 불러오기 버튼
          if (!kIsWeb)
            OutlinedButton.icon(
              onPressed: _isPickingFile ? null : _pickLocalFile,
              icon: _isPickingFile
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.folder_open_rounded, color: AppColors.ink),
              label: const Text(
                '내 PC / 태블릿에서 파일 가져오기',
                style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.surfaceSoft,
                side: const BorderSide(color: AppColors.hairline),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

          if (!kIsWeb) const SizedBox(height: 16),

          // 미디어 유형 선택 (Segmented)
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('이미지')),
                  selected: _selectedMediaType == AdMediaType.image,
                  selectedColor: AppColors.primarySoft,
                  onSelected: (val) {
                    if (val) setState(() => _selectedMediaType = AdMediaType.image);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('동영상')),
                  selected: _selectedMediaType == AdMediaType.video,
                  selectedColor: AppColors.primarySoft,
                  onSelected: (val) {
                    if (val) setState(() => _selectedMediaType = AdMediaType.video);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 소스 유형 선택 (Network vs File)
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('웹 URL')),
                  selected: _selectedSourceType == AdSourceType.network,
                  selectedColor: AppColors.surfaceStrong,
                  onSelected: (val) {
                    if (val) setState(() => _selectedSourceType = AdSourceType.network);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('로컬 파일')),
                  selected: _selectedSourceType == AdSourceType.file,
                  selectedColor: AppColors.surfaceStrong,
                  onSelected: (val) {
                    if (val) setState(() => _selectedSourceType = AdSourceType.file);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 제목 입력
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '광고 제목',
              hintText: '예: 신메뉴 딸기라떼 출시',
            ),
          ),

          const SizedBox(height: 12),

          // 경로 / URL 입력
          TextField(
            controller: _pathController,
            decoration: InputDecoration(
              labelText: _selectedSourceType == AdSourceType.network
                  ? '미디어 웹 URL'
                  : '로컬 파일 경로',
              hintText: _selectedSourceType == AdSourceType.network
                  ? 'https://.../image.jpg'
                  : 'C:/.../media.mp4',
            ),
          ),

          const SizedBox(height: 12),

          // 노출 시간 입력
          TextField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: const InputDecoration(
              labelText: '노출 시간 (초 단위)',
              hintText: '이미지 기본 5초, 영상 기본 15초',
              suffixText: '초',
            ),
          ),

          const SizedBox(height: 24),

          // 추가 버튼
          ElevatedButton(
            onPressed: _submit,
            child: const Text('광고 목록에 추가'),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetTab() {
    final presets = [
      {
        'title': '프리미엄 원두 드립 커피 (이미지)',
        'type': AdMediaType.image,
        'url': 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=1200&auto=format&fit=crop&q=80',
        'duration': 5,
      },
      {
        'title': '매장 특별 디저트 & 마카롱 (이미지)',
        'type': AdMediaType.image,
        'url': 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=1200&auto=format&fit=crop&q=80',
        'duration': 5,
      },
      {
        'title': '매장 홍보 버터플라이 (영상)',
        'type': AdMediaType.video,
        'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
        'duration': 15,
      },
      {
        'title': '자연과 함께하는 커피 비디오 (영상)',
        'type': AdMediaType.video,
        'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        'duration': 15,
      },
      {
        'title': '스탬프 적립 이벤트 5+1 혜택 (이미지)',
        'type': AdMediaType.image,
        'url': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=1200&auto=format&fit=crop&q=80',
        'duration': 6,
      },
    ];

    return ListView.separated(
      itemCount: presets.length,
      separatorBuilder: (_, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final p = presets[index];
        final isVideo = p['type'] == AdMediaType.video;

        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.hairline),
          ),
          leading: CircleAvatar(
            backgroundColor: isVideo ? AppColors.primarySoft : AppColors.secondarySoft,
            child: Icon(
              isVideo ? Icons.videocam_rounded : Icons.image_rounded,
              color: isVideo ? AppColors.primary : AppColors.secondary,
              size: 20,
            ),
          ),
          title: Text(
            p['title'] as String,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${p['duration']}초 노출',
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          trailing: ElevatedButton(
            onPressed: () {
              _addPresetSample(
                p['title'] as String,
                p['url'] as String,
                p['type'] as AdMediaType,
                p['duration'] as int,
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(60, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              backgroundColor: AppColors.ink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('추가', style: TextStyle(fontSize: 12)),
          ),
        );
      },
    );
  }
}

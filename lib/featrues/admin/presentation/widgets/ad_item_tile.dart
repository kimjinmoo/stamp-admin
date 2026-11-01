import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/ad_item.dart';

/// 광고 목록에서 개별 미디어를 표시하는 타일 위젯
class AdItemTile extends StatelessWidget {
  final int index;
  final AdItem item;
  final VoidCallback onDelete;
  final ValueChanged<int>? onDurationChanged;

  const AdItemTile({
    super.key,
    required this.index,
    required this.item,
    required this.onDelete,
    this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 드래그 핸들 (순서 변경용)
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.drag_indicator_rounded,
                  color: AppColors.mutedSoft,
                  size: 24,
                ),
              ),
            ),

            // 썸네일 / 미디어 아이콘
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 64,
                height: 64,
                color: AppColors.surfaceStrong,
                child: _buildThumbnail(),
              ),
            ),

            const SizedBox(width: 14),

            // 광고 상세 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: item.type == AdMediaType.video
                              ? AppColors.primarySoft
                              : AppColors.secondarySoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.type.displayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: item.type == AdMediaType.video
                                ? AppColors.primary
                                : AppColors.secondary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceStrong,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.sourceType.displayName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.hairline,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '${item.durationSeconds}초',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.body,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.path,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedSoft,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 삭제 버튼
            IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 22,
              ),
              tooltip: '광고 삭제',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (item.type == AdMediaType.image) {
      if (item.sourceType == AdSourceType.network) {
        return Image.network(
          item.path,
          fit: BoxFit.cover,
          errorBuilder: (_, error, stackTrace) => const Icon(
            Icons.broken_image_rounded,
            color: AppColors.mutedSoft,
          ),
        );
      } else if (!kIsWeb) {
        return Image.file(
          File(item.path),
          fit: BoxFit.cover,
          errorBuilder: (_, error, stackTrace) => const Icon(
            Icons.broken_image_rounded,
            color: AppColors.mutedSoft,
          ),
        );
      }
    }

    return Icon(
      item.type == AdMediaType.video
          ? Icons.videocam_rounded
          : Icons.image_rounded,
      color: AppColors.primary,
      size: 28,
    );
  }
}

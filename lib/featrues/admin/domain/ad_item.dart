enum AdMediaType {
  image,
  video;

  String get displayName => this == AdMediaType.image ? '이미지' : '동영상';
}

enum AdSourceType {
  network,
  file;

  String get displayName => this == AdSourceType.network ? '웹 URL' : '로컬 파일';
}

/// 키오스크에 재생될 광고 미디어 아이템
class AdItem {
  final String id;
  final String title;
  final AdMediaType type;
  final AdSourceType sourceType;
  final String path;
  final int durationSeconds; // 이미지일 경우 표시 시간(초), 영상의 경우 기본 제한 시간

  const AdItem({
    required this.id,
    required this.title,
    required this.type,
    required this.sourceType,
    required this.path,
    this.durationSeconds = 5,
  });

  AdItem copyWith({
    String? id,
    String? title,
    AdMediaType? type,
    AdSourceType? sourceType,
    String? path,
    int? durationSeconds,
  }) {
    return AdItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      sourceType: sourceType ?? this.sourceType,
      path: path ?? this.path,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'sourceType': sourceType.name,
      'path': path,
      'durationSeconds': durationSeconds,
    };
  }

  factory AdItem.fromJson(Map<String, dynamic> json) {
    return AdItem(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? '광고 미디어',
      type: json['type'] == 'video' ? AdMediaType.video : AdMediaType.image,
      sourceType: json['sourceType'] == 'file' ? AdSourceType.file : AdSourceType.network,
      path: json['path'] as String? ?? '',
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 5,
    );
  }

  /// 기본 내장 샘플 광고 목록 (즉시 테스트용)
  static List<AdItem> get defaultAds => [
        const AdItem(
          id: 'sample_ad_img_1',
          title: '스페셜티 시그니처 커피',
          type: AdMediaType.image,
          sourceType: AdSourceType.network,
          path: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=1200&auto=format&fit=crop&q=80',
          durationSeconds: 5,
        ),
        const AdItem(
          id: 'sample_ad_vid_1',
          title: '키오스크 홍보 프로모션 영상',
          type: AdMediaType.video,
          sourceType: AdSourceType.network,
          // 안정적인 공개 H.264 테스트 MP4 영상 (Big Buck Bunny 10초 버전)
          path: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
          durationSeconds: 15,
        ),
        const AdItem(
          id: 'sample_ad_img_2',
          title: '갓 구운 프리미엄 베이커리',
          type: AdMediaType.image,
          sourceType: AdSourceType.network,
          path: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=1200&auto=format&fit=crop&q=80',
          durationSeconds: 6,
        ),
        const AdItem(
          id: 'sample_ad_img_3',
          title: '스탬프 10개 적립 시 아메리카노 1잔 무료',
          type: AdMediaType.image,
          sourceType: AdSourceType.network,
          path: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=1200&auto=format&fit=crop&q=80',
          durationSeconds: 5,
        ),
      ];
}

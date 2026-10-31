# B2C Consumer Design System (DESIGN.md)

## 1. Overview & Design Philosophy

이 디자인 시스템은 B2C(일반 소비자향) 라이프스타일, 스탬프 투어, 마켓플레이스 앱을 위해 설계된 **심플하고 상큼하며 세련된(Simple, Fresh & Sophisticated)** 모던 UI/UX 가이드라인입니다.

에어비앤비(Airbnb)의 **여백 중심 레이아웃과 직관적인 카드 구조**를 계승하면서, 최신 B2C 트렌드인 **소프트 벤토 그리드(Soft Bento Grid)**, **아크릴 글래스모피즘(Acrylic Glassmorphism)**, 그리고 시선을 사로잡는 **상큼한 코랄 & 민트 포인트 컬러**를 결합했습니다.

### 핵심 디자인 키워드 (Key Characteristics)
* **Fresh & Airy Canvas (상큼하고 쾌적한 여백):** 배경은 순백색(`#FFFFFF`)과 아주 은은한 쿨 알바스터(`#F8FAFC`)를 사용하여 시각적 피로도를 낮추고 콘텐츠(사진, 스탬프, 배지)가 돋보이게 합니다.
* **Zesty Single Accent (생기 넘치는 단일 포인트):** 주요 CTA 버튼, 핵심 아이콘, 활성화 상태에는 상큼하고 에너지 넘치는 **제스티 코랄(`{colors.primary}` — `#FF5A5F`)**을 사용하고, 보상/콤보/성공 피드백에는 청량한 **프레시 민트(`{colors.secondary}` — `#00D19A`)**를 매치하여 B2C 특유의 경쾌함을 전달합니다.
* **Tactile Softness (부드러운 촉각적 곡률):** 날카로운 모서리를 배제하고 버튼(`12px`), 카드(`20px`), 바텀시트(`28px`), 검색창 및 배지(`9999px` Pill) 등 넉넉한 라운딩을 적용하여 친근하고 세련된 인상을 줍니다.
* **Bento & Floating Glass (벤토 그리드와 플로팅 글래스):** 대시보드와 정보 요약 영역은 정돈된 벤토 그리드(Bento Grid)로 구성하며, 상단 네비게이션과 하단 플로팅 바는 `backdrop-filter: blur(20px)`가 적용된 반투명 레이어로 공간감을 부여합니다.
* **Tabular Number Hero (숫자 중심의 시각적 쾌감):** 평점, 스탬프 콤보, 랭킹 점수 등 핵심 지표는 `64px` 크기의 굵은 고정폭 숫자(`tabular-nums`)로 렌더링하여 게이미피케이션 효과를 극대화합니다.

---

## 2. Color Palette (B2C Fresh & Sophisticated)

전체 화면의 **85%는 화이트/쿨그레이 캔버스**, **10%는 선명한 차콜 잉크 텍스트**, 나머지 **5%에만 코랄 & 민트 포인트 컬러**를 사용하여 심플하면서도 상큼한 인상을 유지합니다.

### Brand & Accent Colors (브랜드 및 포인트)
| Token | Hex | 명칭 및 용도 |
|---|---|---|
| `{colors.primary}` | `#FF5A5F` | **Zesty Coral (메인 포인트):** 주요 CTA 버튼, 검색 오브(Orb), 하트(찜), 스탬프 찍기 FAB, 활성 탭 포인트 |
| `{colors.primary-active}` | `#E04348` | **Coral Pressed:** 메인 버튼 터치/클릭(Press) 상태 |
| `{colors.primary-soft}` | `#FFF0F1` | **Coral Tint:** 선택된 칩(Chip) 배경, 프로모션 배너 배경, 비활성 CTA 텍스트 배경 |
| `{colors.secondary}` | `#00D19A` | **Fresh Mint (서브/리워드):** 스탬프 획득 완료, 콤보(Combo) 상승 게이지, 실시간 인증 배지 |
| `{colors.secondary-soft}` | `#E6FBF5` | **Mint Tint:** 콤보 유지 타이머 배경, 인증 완료 태그 배경 |
| `{colors.accent-pop}` | `#FFB800` | **Sunny Amber (강조/랭킹):** 1위 왕관, 스페셜 리워드, 별점 아이콘 포인트 |

### Surface & Canvas (배경 및 표면)
| Token | Hex | 명칭 및 용도 |
|---|---|---|
| `{colors.canvas}` | `#FFFFFF` | **Pure White:** 기본 페이지 배경, 기본 카드 표면 |
| `{colors.surface-soft}` | `#F8FAFC` | **Cool Alabaster:** 섹션 구분 배경, 벤토 그리드 셀 배경, 입력창 기본 배경 |
| `{colors.surface-strong}` | `#F1F5F9` | **Slate Wash:** 원형 아이콘 버튼 배경, 비활성 필드, 스켈레톤 로딩 베이스 |
| `{colors.surface-glass}` | `rgba(255, 255, 255, 0.82)` | **Floating Glass:** 상단 헤더, 하단 고정 바, 플로팅 배지용 반투명 표면 (`blur(20px)` 필수) |

### Typography & Ink (텍스트 계층)
| Token | Hex | 명칭 및 용도 |
|---|---|---|
| `{colors.ink}` | `#111827` | **Deep Charcoal:** 헤드라인, 본문 타이틀, 가격/점수 텍스트 (순수 검정 `#000` 대신 세련된 딥 차콜 사용) |
| `{colors.body}` | `#334155` | **Slate Body:** 일반 본문, 상세 설명, 리뷰 텍스트 |
| `{colors.muted}` | `#64748B` | **Cool Muted:** 서브 타이틀, 날짜/거리 메타 정보, 비활성 탭 라벨 |
| `{colors.muted-soft}` | `#94A3B8` | **Placeholder:** 입력창 플레이스홀더, 비활성 링크, 법적 고지 캡션 |
| `{colors.on-primary}` | `#FFFFFF` | **Pure White:** 코랄/민트 버튼 위의 텍스트 및 아이콘 |

### Hairlines & Semantic (경계선 및 상태 표시)
* **Hairline (`{colors.hairline}` — `#E2E8F0`):** 기본 `1px` 카드 테두리, 리스트 구분선, 검색바 내부 분할선
* **Hairline Soft (`{colors.hairline-soft}` — `#F1F5F9`):** 긴 목록 내부의 은은한 구분선
* **Border Focus (`{colors.border-focus}` — `#111827`):** 입력창 포커스 시 `2px` 테두리 색상
* **Error (`{colors.error}` — `#F43F5E`):** 폼 유효성 에러, 만료된 QR 경고, 콤보 실패 알림
* **Scrim (`{colors.scrim}` — `rgba(15, 23, 42, 0.45)`):** 모달 및 바텀시트 배경 딤(Dim) 처리 (`backdrop-filter: blur(4px)` 병행 권장)

---

## 3. Typography (모던 타이포그래피 스케일)

### Font Family
* **Korean / Global Standard:** `Pretendard Variable`, `Pretendard`, `-apple-system`, `BlinkMacSystemFont`, `Inter`, `sans-serif`
* **Numeric / Score Display:** 모든 카운트다운 타이머, 평점, 콤보 배수, 가격에는 반드시 `font-variant-numeric: tabular-nums`를 적용하여 숫자가 바뀔 때 레이아웃이 흔들리지 않도록 고정합니다.

### Hierarchy Scale

| Token | Size | Weight | Line Height | Letter Spacing | 주요 사용처 |
|---|---|---|---|---|---|
| `{typography.hero-metric}` | `56px` | `800` | `1.08` | `-1.5px` | 콤보 카운터, 평점 디스플레이 (`4.92`), 랭킹 총점 |
| `{typography.display-xl}` | `28px` | `700` | `1.35` | `-0.6px` | 홈 화면 메인 히어로 타이틀 |
| `{typography.display-lg}` | `22px` | `700` | `1.30` | `-0.4px` | 상세 페이지 타이틀, 모달 헤드라인 |
| `{typography.display-md}` | `19px` | `700` | `1.35` | `-0.3px` | 섹션 헤더 ("내 스탬프 보드", "실시간 랭킹") |
| `{typography.title-md}` | `16px` | `600` | `1.40` | `-0.2px` | 카드 타이틀, 매장명, 리스트 아이템 제목 |
| `{typography.body-md}` | `15px` | `400` | `1.55` | `-0.1px` | 기본 본문 텍스트, 안내 문구 |
| `{typography.body-sm}` | `13px` | `400` | `1.45` | `0px` | 카드 메타 정보 (날짜, 거리, 획득 시간) |
| `{typography.button-md}` | `16px` | `600` | `1.25` | `-0.1px` | 주요 CTA 버튼 라벨 |
| `{typography.badge}` | `11px` | `700` | `1.20` | `0.2px` | 플로팅 배지 ("HOT", "COMBO x3", "Guest Favorite") |
| `{typography.uppercase-tag}` | `10px` | `800` | `1.20` | `0.6px` | 상단 탭 `NEW` 태그, 마이크로 라벨 |

---

## 4. Layout, Spacing & Shape Language

### Spacing System (4px Grid Base)
* `{spacing.xxs}`: `2px` · `{spacing.xs}`: `4px` · `{spacing.sm}`: `8px` · `{spacing.md}`: `12px`
* `{spacing.base}`: `16px` (기본 카드 간격 및 모바일 좌우 여백)
* `{spacing.lg}`: `24px` (카드 내부 패딩, 벤토 박스 여백)
* `{spacing.xl}`: `32px` (서브 섹션 간격)
* `{spacing.section}`: `56px` (주요 페이지 섹션 간 상하 여백)

### Corner Radius (Shape Tokens)
* `{rounded.sm}` (`10px`): 소형 입력 필드, 인라인 태그, 툴팁
* `{rounded.md}` (`14px`): 기본 CTA 버튼, 세컨더리 버튼, 텍스트 인풋
* `{rounded.lg}` (`20px`): 프로퍼티 카드, 스탬프 카드, 벤토 그리드 셀
* `{rounded.xl}` (`28px`): 모달 다이얼로그, 바텀시트 상단 모서리, QR 코드 컨테이너
* `{rounded.full}` (`9999px`): 글로벌 검색바(Pill), 카테고리 필터 칩, 원형 아이콘 버튼

### Bento Grid & Whitespace Philosophy
* 상단 대시보드(예: 내 점수, 현재 콤보, 남은 시간 타이머)는 2x2 또는 1+2 형태의 **벤토 그리드(Bento Grid)**로 배치하고 셀 간격을 `12px`로 촘촘하게 유지합니다.
* 반면, 섹션과 섹션 사이에는 `48px~56px`의 넉넉한 여백을 두어 스크롤 시 답답함 없이 상큼하고 정돈된 리듬감을 제공합니다.

---

## 5. Elevation & Modern Effects

과도하고 무거운 검은색 그림자 대신, **1px 보더와 은은한 컬러 확산광(Ambient Shadow)**을 조합하여 깔끔하게 띄웁니다.

* **Level 0 — Flat Surface:** 기본 섹션, 벤토 셀 (`background: {colors.surface-soft}`, 그림자 없음, 필요시 `1px solid {colors.hairline-soft}`)
* **Level 1 — Card Rest & Hover Float:**
  ```css
  box-shadow: 0 0 0 1px rgba(15, 23, 42, 0.04), 
              0 4px 12px -2px rgba(15, 23, 42, 0.06), 
              0 12px 24px -4px rgba(15, 23, 42, 0.04);
  ```
* **Level 2 — Primary CTA Coral Glow (핵심 버튼 전용):**
  ```css
  box-shadow: 0 8px 20px -4px rgba(255, 90, 95, 0.38);
  ```
* **Glass Overlay (네비게이션 & 플로팅 바):**
  ```css
  background: rgba(255, 255, 255, 0.82);
  backdrop-filter: blur(20px) saturate(180%);
  border-bottom: 1px solid rgba(226, 232, 240, 0.7);
  ```

---

## 6. Core Components

### A. Buttons & Floating Actions
* **`button-primary`:** `{colors.primary}` (`#FF5A5F`) 배경, `{colors.on-primary}` 흰색 텍스트, `{rounded.md}` (`14px`), 높이 `52px`, 패딩 `0 24px`, 폰트 두께 `600`. 터치 시 scale `0.98` 마이크로 인터랙션 및 `{colors.primary-active}` 적용.
* **`button-secondary`:** `{colors.canvas}` 배경, `{colors.ink}` 텍스트, `1px solid {colors.hairline}` 테두리, 높이 `52px`, `{rounded.md}`.
* **`button-tinted`:** `{colors.primary-soft}` (`#FFF0F1`) 배경, `{colors.primary}` 텍스트, 테두리 없음. 보조 액션이나 필터 리셋 버튼에 사용.
* **`fab-scan-orb`:** 우측 하단 또는 하단 중앙에 위치한 QR 스캔 전용 플로팅 버튼. `{rounded.full}`, `56x56px` (또는 확장형 Pill), `{colors.primary}` 배경에 Level 2 Coral Glow 그림자 적용.

### B. Search & Category Strip
* **`search-bar-pill`:** 높이 `60px`, `{rounded.full}`, 흰색 배경, Level 1 그림자. 내부는 `1px` 세로 헤어라인으로 영역을 나누고 우측 끝에 `44x44px` 크기의 코랄 서치 오브(`{colors.primary}`)를 배치합니다.
* **`category-chip`:** 높이 `40px`, `{rounded.full}`. 비활성 시 `{colors.surface-soft}` 배경 + `{colors.muted}` 텍스트 / 활성 시 `{colors.ink}` 배경 + 흰색 텍스트(또는 `{colors.primary-soft}` 배경 + `{colors.primary}` 텍스트).

### C. Cards, Stamps & Gamification UI
* **`bento-stat-card`:** `{rounded.lg}` (`20px`), 패딩 `20px`, `{colors.surface-soft}` 배경. 상단에 작은 아이콘과 캡션, 하단에 `{typography.hero-metric}` 크기의 숫자를 배치.
* **`stamp-slot-card`:** 스탬프 보드의 개별 슬롯. 미획득 시 점선 테두리(`1.5px dashed #CBD5E1`)와 흐린 아이콘 표시. 획득 시 `{colors.secondary-soft}` (`#E6FBF5`) 배경으로 전환되며 프레시 민트(`#00D19A`) 도장 그래픽과 스프링 바운스 애니메이션 재생.
* **`combo-timer-banner`:** 상단 고정형 프로그레스 카드. 남은 시간에 따라 프레시 민트(`#00D19A`)에서 종료 임박 시 제스티 코랄(`#FF5A5F`)로 게이지 색상이 자연스럽게 그라데이션 전환됨.
* **`ranking-podium-card`:** 1~3위 유저를 보여주는 상단 카드. 1위는 `{colors.accent-pop}` (`#FFB800`) 골드 링 아바타와 왕관 배지를 부여하고, 내 순위 카드(`My Rank`)는 `{colors.primary-soft}` 배경과 `1.5px solid {colors.primary}` 테두리로 하이라이트.

### D. Modals & QR Showcase (Kiosk / Admin 호환)
* **`qr-modal-sheet`:** `{rounded.xl}` (`28px`) 카드 중앙에 고대비 QR 코드 배치. 테두리에 30초 주기로 줄어드는 원형 또는 선형 코랄/민트 타이머 프로그레스 바를 배치하여 동적 보안 상태임을 직관적으로 시각화.

---

## 7. Motion & Micro-interactions

B2C 앱의 생동감과 손맛(Tactile Feedback)을 살리기 위해 모든 상태 변화에 자연스러운 물리 기반 애니메이션을 적용합니다.

* **Touch Scale Down:** 모든 카드와 주요 버튼은 터치(`onTapDown`) 시 `120ms` 동안 `scale(0.97)`로 살짝 줄어들고, 손을 떼면 원래 크기로 복원됩니다.
* **Stamp Pop Animation:** 스탬프 획득 순간 `Curves.elasticOut` (Duration: `500ms`) 커브를 사용해 도장이 화면에 쫀득하게 찍히는 연출을 제공하고 가벼운 햅틱 피드백(`HapticFeedback.mediumImpact()`)을 동반합니다.
* **Skeleton Shimmer:** 이미지나 랭킹 로딩 시 스피너 대신 `{colors.surface-strong}`에서 `{colors.surface-soft}`로 흐르는 부드러운 Shimmer 스켈레톤 UI를 노출합니다.

---

## 8. Responsive Breakpoints & Touch Targets

| Breakpoint | Width Range | Layout & Grid Strategy |
|---|---|---|
| **Mobile (Default B2C)** | `< 744px` | 단일 컬럼 스크롤, 스탬프 보드 `2~3열` 그리드, 하단 플로팅 탭바(`BottomNavigationBar`) 고정, 주요 모달은 바텀시트로 노출 |
| **Tablet / Kiosk** | `744px – 1128px` | 좌측 또는 상단 네비게이션 레일, 카드 그리드 `3~4열`, 키오스크(Admin) 모드에서는 좌측 광고 플레이어 + 우측 인터랙션 패널 분할 가능 |
| **Desktop / Wide** | `> 1128px` | 최대 콘텐츠 너비 `1200px` 중앙 정렬, 카드 그리드 `4~6열`, 우측 스티키 요약/액션 카드 고정 |

### Accessibility & Touch Rules
* 모든 터치 가능한 요소(버튼, 탭, 아이콘, 스탬프 슬롯)의 최소 히트 영역은 **`48x48px` 이상**을 보장합니다.
* 텍스트 잘림 방지: 다국어나 긴 매장명이 들어가더라도 레이아웃이 깨지지 않도록 버튼 및 배지 내부 텍스트는 `FittedBox(fit: BoxFit.scaleDown)` 또는 `maxLines: 1` + `TextOverflow.ellipsis` 규칙을 엄격히 적용합니다.
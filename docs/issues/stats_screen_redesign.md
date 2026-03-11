# Stats画面の新規作成

## 背景

現在、Stats画面は存在しない。
VoiceCapsuleは子どもの感情（笑い声・泣き声）を記録するアプリであり、「今日どれだけ笑ったか」「今週の感情傾向」を振り返る画面が必要。

Stats画面は **分析ツールではなく、思い出を振り返る画面** として設計する。

## 画面の位置づけ

```
BottomNav: Stats タブ
  └── Stats画面（今日・今週）
        └── AppBar 右上 📅 アイコン
              └── Emotion Heatmap画面（月次）← stats_screen_ui.md
```

Stats画面は週次の振り返り。AppBar右上のカレンダーアイコンから月次のEmotionHeatmap画面へ遷移する。

## 参考デザイン

添付画像（Stats UI モックアップ）参照。

## 新しいUI構造

```
Today's Emotion カード
  ↓
Weekly Points / Streak カード
  ↓
Emotion Frequency
  ↓
Weekly Trend（棒グラフ）
  ↓
Moments Insight カード
```

---

## 各セクションの仕様

### 1. Today's Emotion カード

```
┌─────────────────────────────────────────┐
│ TODAY                    +18 points     │
│                                         │
│  😆 😆 😆 😆                            │
│                                         │
│  [波形装飾（グラデーションコンテナ）]    │
└─────────────────────────────────────────┘
```

- 今日検出された感情絵文字を横並びで表示
- 今日獲得したポイントをバッジ形式で右上に表示
- 波形は装飾用（グラデーションコンテナで表現）

### 2. Weekly Points / Streak カード（横並び2カード）

```
┌──────────────────┐  ┌──────────────────┐
│ Weekly Points    │  │  🏆              │
│ 30               │  │  STREAK          │
│ +12% vs last week│  │  5 Days          │
└──────────────────┘  └──────────────────┘
```

- 左: 今週の合計ポイント・先週比
- 右: 連続記録日数（ストリーク）

### 3. Emotion Frequency

```
Emotion Frequency

😆 Laughter    25 events
████████████████████████░░░░

😭 Cries        5 events
████░░░░░░░░░░░░░░░░░░░░░░░░
```

- 今週の感情ごとの検出件数
- プログレスバーで視覚化（最大件数を100%として相対表示）

### 4. Weekly Trend（棒グラフ）

```
Weekly Trend

     ▓
  ▓  ▓     ▓
▓ ▓  ▓  ▓  ▓
─────────────
Mon Tue Wed Thu Fri
```

- 曜日ごとの感情イベント件数を棒グラフで表示
- `colorScheme.primary` で塗りつぶし、角丸

### 5. Moments Insight カード

```
┌─────────────────────────────────────────┐
│ Moments Insight                         │
│                                         │
│ This week felt **joyful**.              │
│ You recorded 5x more laughter than      │
│ crying moments. Keep capturing these    │
│ happy sounds!                           │
└─────────────────────────────────────────┘
```

- `colorScheme.primary` 背景、テキスト2〜3行
- 笑い率に応じてメッセージを動的生成（笑い > 泣き → joyful、逆 → challenging など）

---

## BottomNavigation の変更

現在の構成:
```
Home | Capsules | Family | Settings
```

変更後（画像参照）:
```
Capsules | Record | Stats | Profile
```

| index | 変更前 | 変更後 |
|-------|--------|--------|
| 0 | Home（TimelineScreen） | Capsules（TimelineScreen） |
| 1 | Capsules（RecordingScreen） | Record（RecordingScreen） |
| 2 | Family（FamilyScreen） | Stats（StatsScreen）※新規 |
| 3 | Settings（SettingsScreen） | Profile（SettingsScreen 流用） |

- FamilyScreen は BottomNav から外れる（Settings等からアクセス）
- Profile タブは SettingsScreen をそのまま流用

---

## UIデザイン方針

| 項目 | 仕様 |
|------|------|
| 背景色 | `colorScheme.surface` |
| アクセントカラー | `colorScheme.primary` |
| カード角丸 | 16px |
| スペーシング | 8 / 16 / 24 のみ |
| emoji | 感情表示に積極活用 |

---

## 影響範囲

| レイヤー | ファイル | 変更内容 |
|---------|---------|---------|
| presentation | `lib/presentation/screens/stats_screen.dart` | 新規作成 |
| presentation | `lib/presentation/screens/stats/widgets/today_emotion_card.dart` | 新規作成 |
| presentation | `lib/presentation/screens/stats/widgets/weekly_points_card.dart` | 新規作成 |
| presentation | `lib/presentation/screens/stats/widgets/streak_card.dart` | 新規作成 |
| presentation | `lib/presentation/screens/stats/widgets/emotion_frequency_section.dart` | 新規作成 |
| presentation | `lib/presentation/screens/stats/widgets/weekly_trend_chart.dart` | 新規作成 |
| presentation | `lib/presentation/screens/stats/widgets/moments_insight_card.dart` | 新規作成 |
| presentation | `lib/presentation/screens/main_screen.dart` | BottomNav変更・StatsScreen追加 |
| application | `lib/application/providers/stats_provider.dart` | 新規作成 |
| domain | `lib/domain/models/stats_data.dart` | 新規作成 |

## 新規作成ファイル

- `lib/presentation/screens/stats_screen.dart`
- `lib/presentation/screens/stats/widgets/today_emotion_card.dart`
- `lib/presentation/screens/stats/widgets/weekly_points_card.dart`
- `lib/presentation/screens/stats/widgets/streak_card.dart`
- `lib/presentation/screens/stats/widgets/emotion_frequency_section.dart`
- `lib/presentation/screens/stats/widgets/weekly_trend_chart.dart`
- `lib/presentation/screens/stats/widgets/moments_insight_card.dart`
- `lib/application/providers/stats_provider.dart`
- `lib/domain/models/stats_data.dart`

## 修正ファイル

- `lib/presentation/screens/main_screen.dart`

## 使用する依存パッケージ

追加なし（既存パッケージのみ）
棒グラフは `CustomPaint` または `Container` + `Column` で実装

## データソース

`StatsProvider` で集計するデータ（既存 `CapsuleRepository` から取得）:
- 今日の感情イベント一覧（絵文字表示用）
- 今日の獲得ポイント
- 今週の日別イベント件数（棒グラフ用）
- 今週の感情別件数（笑い / 泣き）
- 今週の合計ポイント・先週比
- 連続記録日数（ストリーク）

## リスク・エッジケース

- データが0件: 各セクションに空状態を表示
- 先週データが0件: 先週比は「-」表示（除算エラー回避）
- 連続記録日数: 端末ローカル時刻基準
- BottomNav index変化: `initialIndex` を使用している箇所を合わせて修正
- FamilyScreen へのアクセス経路: Settings等からの導線を確保

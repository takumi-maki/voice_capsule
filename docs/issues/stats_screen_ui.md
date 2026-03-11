# 感情ヒートマップ画面の新規作成

## 背景

現在、アプリには録音の一覧（タイムライン）はあるが、感情イベントの「月単位の傾向」を俯瞰できる画面がない。
親御様が「今月子どもがよく笑った日はいつか」「感情が豊かだった時期はいつか」を直感的に把握できる
思い出の可視化機能として、感情ヒートマップ画面を新規作成する。

## 画面の位置づけ

Stats画面（`stats_screen_redesign.md`）のAppBar右上 📅 アイコンから push 遷移する。
BottomNavには追加しない。

## 目標UI（添付スクリーンショットを参照）

```
┌────────────────────────────────────┐
│ ← Emotion Heatmap            📅    │
│                                    │
│  This Month Summary                │
│  ┌──────────────┐ ┌─────────────┐  │
│  │  😆          │ │  😭         │  │
│  │  38          │ │  8          │  │
│  │  Laughs      │ │  Cries      │  │
│  └──────────────┘ └─────────────┘  │
│                                    │
│  ┌──────────────────────────────┐  │
│  │ October 2023   INTENSITY □■■■ │  │
│  │                              │  │
│  │  M   T   W   T   F   S   S  │  │
│  │                          ■  │  │
│  │  ■   ■   ■   ■   ■   ■   ■  │  │
│  │  ■   ■   ■   ■   ■   ■   ■  │  │
│  │  ■   ■   ■   ■   ■   ■   ■  │  │
│  │  ■   ■   ■   ■   ■   ■   ■  │  │
│  │  ■   ■               (空)   │  │
│  └──────────────────────────────┘  │
│                                    │
│  ┌──────────────────────────────┐  │
│  │ October 12          +20 pts  │  │
│  │ Thursday                     │  │
│  │ 😆😆😭  3 moments captured   │  │
│  │                              │  │
│  │  [ View Moments ]            │  │
│  └──────────────────────────────┘  │
│                                    │
│  ┌──────────────────────────────┐  │
│  │ MONTHLY GOAL                 │  │
│  │ 1,240 pts         🏆         │  │
│  │ Top 5% of users this month!  │  │
│  └──────────────────────────────┘  │
└────────────────────────────────────┘
```

## カラーパレット

| 状態 | 色コード | 説明 |
|------|---------|------|
| 0 events | `#F3E8DD` | 記録なし（最も薄い） |
| 1–2 events (low) | `#F5CBA7` | 少ない |
| 3–5 events (medium) | `#E89B57` | 中程度 |
| 6+ events (high) | `#C76B2A` | 多い（最も濃い） |
| background | `#F5EFE8` | 画面背景 |
| accent | `#E89B57` | アクセントカラー |

## 変更内容

### 1. Emotion Summary セクション

ヒートマップの上部に月間の感情集計を表示する。

**表示内容:**
- 😆 笑い合計数（Laughs）
- 😭 泣き合計数（Cries）

**レイアウト:** 横並び2カード（各カード: 絵文字 + 数値 + ラベル）

### 2. Emotion Heatmap グリッド

GitHub Contribution グラフ風のカレンダーグリッド。

**仕様:**
- 表示単位: 月（デフォルト: 当月）
- 列: Mon〜Sun（月曜始まり）
- セルサイズ: 均等分割（画面幅に応じてレスポンシブ）
- セル形状: 角丸正方形（8px）
- 色: イベント数に応じて4段階のオレンジグラデーション
- 凡例（INTENSITY）: ヘッダー右上に4段階カラーボックスを表示
- 月切り替え: ヘッダー右上のカレンダーアイコンまたは左右スワイプ

**インタラクション:**
- セルタップ → Daily Summary カードに選択日の内容を反映
- 未来の日付セルはタップ不可・グレーアウト

### 3. Daily Summary カード

ヒートマップでタップした日の詳細を表示するカード。

**表示内容:**
- 日付（例: October 12）と曜日
- 獲得ポイント（+N pts）バッジ（右上）
- 感情絵文字一覧（😆😆😭 形式）
- 「N moments captured today」テキスト
- 「View Moments」ボタン → タイムライン画面へ遷移し、該当日でフィルタリング

**初期表示:** 当日（または当月最後に記録のある日）

### 4. Monthly Goal カード

月間ポイントの達成状況を表示するダークカード。

**表示内容:**
- 月間合計ポイント（pts）
- 達成メッセージ（例: Top 5% of users this month!）
- トロフィーアイコン

**注意:** ゴールの設定ロジック・ランキングデータの有無は要確認。

## 影響範囲

| レイヤー | ファイル | 変更内容 |
|---------|---------|---------|
| presentation | `lib/presentation/screens/stats/emotion_heatmap_screen.dart` | **新規作成**（画面本体） |
| presentation | `lib/presentation/widgets/stats/emotion_summary_card.dart` | **新規作成** |
| presentation | `lib/presentation/widgets/stats/emotion_heatmap_grid.dart` | **新規作成** |
| presentation | `lib/presentation/widgets/stats/daily_summary_card.dart` | **新規作成** |
| presentation | `lib/presentation/widgets/stats/monthly_goal_card.dart` | **新規作成** |
| application | `lib/application/providers/emotion_heatmap_provider.dart` | **新規作成** |
| domain | `lib/domain/entities/daily_emotion_summary.dart` | **新規作成**（値オブジェクト） |
| infrastructure | `lib/infrastructure/repositories/audio_event_repository.dart` | `getEventsByMonth()` メソッド追加 |

## 新規作成ファイル

- `lib/presentation/screens/stats/emotion_heatmap_screen.dart`
- `lib/presentation/widgets/stats/emotion_summary_card.dart`
- `lib/presentation/widgets/stats/emotion_heatmap_grid.dart`
- `lib/presentation/widgets/stats/daily_summary_card.dart`
- `lib/presentation/widgets/stats/monthly_goal_card.dart`
- `lib/application/providers/emotion_heatmap_provider.dart`
- `lib/domain/entities/daily_emotion_summary.dart`

## 修正ファイル

- `lib/infrastructure/repositories/audio_event_repository.dart`（月別クエリ追加）
- ボトムナビゲーション（HEATMAP タブへの遷移を追加）

## データ構造

```dart
// 日別感情サマリー（ドメインエンティティ）
class DailyEmotionSummary {
  final DateTime date;
  final int laughCount;
  final int cryCount;
  final int totalPoints;

  int get totalEvents => laughCount + cryCount;
  HeatmapIntensity get intensity => _calcIntensity(totalEvents);
}

enum HeatmapIntensity { none, low, medium, high }
// none: 0件, low: 1–2件, medium: 3–5件, high: 6件以上
```

## 使用する依存パッケージ

追加なし（既存パッケージのみで実装可能）

- `GridView` または `Table` ウィジェットでグリッドを構築
- `CustomPainter` は不要（シンプルな `Container` + `BorderRadius` で対応）

## リスク・エッジケース

- **当月に録音が 0 件**: ヒートマップは全セルが薄色（#F3E8DD）で表示、Daily Summary は非表示にするか要確認
- **月の最初の日が月曜以外**: グリッドの先頭にオフセット（空セル）を挿入して対���
- **2月など日数が少ない月**: グリッドの最後の行に空セルを追加して対応
- **Monthly Goal のデータソース**: ランキングやゴール設定ロジックが未実装の場合、ハードコードまたは非表示にするか要確認
- **View Moments ボタンの遷移**: タイムライン画面に日付フィルターを渡す仕組みが必要
- **月切り替えのパフォーマンス**: 月切り替え時に再クエリが走るため、ローディング状態の考慮が必要

## 実装ステップ

1. `DailyEmotionSummary` エンティティを作成
2. `AudioEventRepository` に `getEventsByMonth()` を追加
3. `emotion_heatmap_provider.dart` を作成（選択月の日別サマリーを生成）
4. `EmotionSummaryCard` ウィジェットを作成
5. `EmotionHeatmapGrid` ウィジェットを作成（タップコールバック付き）
6. `DailySummaryCard` ウィジェットを作成
7. `MonthlyGoalCard` ウィジェットを作成
8. `EmotionHeatmapScreen` で上記を組み合わせる
9. ボトムナビゲーションに HEATMAP タブを追加

## 確認事項（実装前に決定が必要）

1. **Monthly Goal の仕様**: ポイント目標値の設定方法・ランキング表示の有無
2. **当月に録音が 0 件**: Daily Summary カードを非表示にするか `No moments yet` 表示にするか
3. **View Moments の遷移**: タイムライン画面に日付フィルターを渡す実装方針
4. **月切り替えUI**: カレンダーアイコンタップ時のUIをDatePickerにするか、前後矢印ボタンにするか
5. **ボトムナビゲーションのタブ構成**: 既存タブの変更範囲

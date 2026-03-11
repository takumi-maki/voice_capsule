# Review Recording Screen UI リニューアル

## 概要

録音後の一時確認画面フローを刷新する。新しい「Review Recording」画面を挿入し、感情検出結果を再生しながら確認できるようにする。

## 現状フロー

```
RecordingScreen（録音完了）
  → PlaybackControls（Saveタップ）
  → SaveRecordingScreen（タイトル・場所・子供選択）
  → 保存 → YAMNet分析 → タイムライン
```

## 新フロー

```
RecordingScreen（録音完了）
  → PlaybackControls（Saveタップ）
  → ReviewRecordingScreen（感情検出結果 + 再生）  ← 新規
      ├─ "Save to Memories" → SaveRecordingScreen（タイトル・場所・子供選択）
      └─ "Delete" → 録音ファイル削除 → RecordingScreen（リセット）
```

## 目標UI

```
┌─────────────────────────────┐
│ ← Review Recording           │  AppBar
├─────────────────────────────┤
│                             │
│   EMOTION DETECTION         │  primaryカラー・大文字
│   We've mapped your feelings│  サブテキスト
│                             │
│  ┌───────────────────────┐  │
│  │ 0:02  0:08  0:11      │  │  タイムスタンプラベル
│  │  😂    😂    😭        │  │  感情絵文字マーカー（白円背景）
│  │  |     |     |        │  │
│  │ ▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌     │  │  実際の音声振幅による波形バー
│  └───────────────────────┘  │  角丸16px カード
│                             │
│       ↺10  ▶  10↻          │  再生コントロール
│       ─────●─────          │  プログレスバー
│       0:37          2:23   │  現在時刻 / 総時間
│                             │
│  ┌───────────────────────┐  │
│  │ Total Emotion Points  │  │  カード（角丸16px）
│  │ 13 pt          😊     │  │
│  └───────────────────────┘  │
│                             │
│  ✦ Save to Memories        │  primaryボタン（角丸24px）
│  🗑 Delete                  │  secondaryボタン（角丸24px）
└─────────────────────────────┘
```

## 仕様確認済み事項

| 項目 | 決定内容 |
|-----|---------|
| "Save to Memories" 押下後 | 既存の `SaveRecordingScreen`（タイトル・場所・子供選択）へ遷移 |
| 波形データ | 実際の音声振幅データを使用（PCM サンプルから RMS 計算） |
| ローディング表示 | 画面遷移後にインラインで「分析中...」を表示 |
| 分析中の音声再生 | 分析と並行して再生可能にする |

## 影響レイヤー

| レイヤー | 変更内容 |
|---------|---------|
| presentation | `ReviewRecordingScreen` 新規作成 |
| presentation | `EmotionWaveform` ウィジェット新規作成 |
| presentation | `EmotionPointsCard` ウィジェット新規作成 |
| presentation | `PlaybackControls` のナビゲーション先変更 |
| application | `reviewRecordingProvider` 新規作成（分析結果の一時保持） |
| infrastructure | `AudioAnalyzer` に振幅抽出メソッド追加 |
| domain | 変更なし |

## 新規作成ファイル

```
lib/
├── presentation/
│   └── screens/
│       ├── review_recording_screen.dart
│       └── review_recording/
│           └── widgets/
│               ├── emotion_waveform.dart
│               └── emotion_points_card.dart
└── application/
    └── providers/
        └── review_recording_provider.dart
```

## 修正が必要な既存ファイル

| ファイル | 変更内容 |
|---------|---------|
| `lib/presentation/screens/recording/widgets/playback_controls.dart` | ナビゲーション先を `ReviewRecordingScreen` に変更 |
| `lib/infrastructure/audio/audio_analyzer.dart` | `extractAmplitudes(filePath, barCount)` メソッド追加 |

## 実装詳細

### `AudioAnalyzer.extractAmplitudes()`

WAV の PCM サンプルを `barCount` 個のチャンクに分割し、各チャンクの RMS を `[0.0, 1.0]` に正規化して返す。

```
_loadWavSamples() → List<double>(全サンプル)
  → N チャンクに分割
  → 各チャンクの RMS = sqrt(mean(sample²))
  → 全チャンク中の最大 RMS で正規化
  → List<double>(barCount 件)
```

### `reviewRecordingProvider`

```dart
class ReviewRecordingState {
  final bool isAnalyzing;
  final List<AudioEvent> events;       // 検出された感情イベント
  final List<double> waveformBars;    // 正規化済み振幅（barCount 件）
}
```

- `initAnalysis(String filePath)` で波形抽出と YAMNet 分析を並列実行
- YAMNet 分析には仮 UUID の `recordingId` を使用（永続化は行わない）
- "Save to Memories" 後の `saveRecording()` で実際の `recordingId` で改めて YAMNet 分析・保存

### `EmotionWaveform` ウィジェット

- 引数：`List<double> bars`、`List<AudioEvent> events`、`Duration duration`、`bool isAnalyzing`
- `isAnalyzing: true` の間は「分析中...」ローディング表示
- 分析完了後に波形バー + 感情マーカーを表示
- マーカー：タイムスタンプを `duration` で正規化し、バーのインデックスに対応付け
- 笑い声（EventType.laugh）→ 😂、泣き声（EventType.cry）→ 😭

### `EmotionPointsCard` ウィジェット

- 引数：`int points`
- ポイント計算：`events.length`（1 件 = 1 pt）

## UIコンポーネント仕様

### 感情波形カード
- 背景：`theme.colorScheme.surfaceContainerHighest` + 内側グラデーション
- 角丸：16px
- 波形バー色：`theme.colorScheme.primary`（イベントなし部分は `withValues(alpha: 0.4)`）
- 感情マーカー：直径 40px 白円 + 絵文字（Text ウィジェット）
- タイムスタンプ：`M:ss` 形式、primaryカラー、`bodySmall`

### ボタン
| ボタン | スタイル | アイコン | ラベル |
|-------|--------|--------|------|
| Save to Memories | ElevatedButton（primary, 高さ56px, 角丸24px） | `Icons.auto_awesome` | Save to Memories |
| Delete | TextButton（高さ56px, 角丸24px） | `Icons.delete_outline` | Delete |

## 受け入れ条件

- [ ] AppBar に「Review Recording」タイトルと戻るボタン
- [ ] 「EMOTION DETECTION」「We've mapped your feelings」が表示される
- [ ] 画面表示直後に「分析中...」ローディングが表示される
- [ ] 分析中も音声の再生・一時停止・シークが動作する
- [ ] 分析完了後、実際の音声振幅による波形バーが表示される
- [ ] 検出された感情イベントの位置に絵文字マーカーとタイムスタンプが表示される
- [ ] 再生コントロール（±10秒スキップ）が機能する
- [ ] プログレスバーに現在位置と総時間が表示される
- [ ] Total Emotion Points カードに `events.length` が表示される
- [ ] 「Save to Memories」→ `SaveRecordingScreen` に遷移する
- [ ] 「Delete」→ 録音ファイルを削除して `RecordingScreen` にリセットされる
- [ ] UIルール（角丸16/24px・スペーシング8/16/24px・テーマカラー）に準拠している

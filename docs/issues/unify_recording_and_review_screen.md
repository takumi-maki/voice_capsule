# RecordingScreen と ReviewRecordingScreen の統合

## 概要

録音後に別画面（ReviewRecordingScreen）へ遷移している現状フローを廃止し、
RecordingScreen 内で録音モードとレビューモードを切り替える1画面に統合する。

## 現状フロー

```
RecordingScreen（録音 + 再生 + チップ分析表示）
  → PlaybackControls "Save to Memories" タップ
    → ReviewRecordingScreen（EMOTION DETECTION + 波形 + 保存/削除）← 別画面
        → SaveRecordingScreen（タイトル・場所・子供選択）
```

## 新フロー

```
RecordingScreen（録音モード）
  idle / recording / paused → 既存の録音UI
  stopped → レビューモードに切り替え（同一画面内）
    ├─ "Save to Memories" → SaveRecordingScreen（タイトル・場所・子供選択）
    └─ "Delete" → 録音ファイル削除 → 録音モードにリセット
```

## 目標UI

### 録音モード（idle / recording / paused）
```
┌─────────────────────────────┐
│  Record Voice                │  AppBar
├─────────────────────────────┤
│  Tap the microphone to...   │  状態メッセージ
│                             │
│  [🎵 ライブ波形]             │  WaveformVisualizer
│                             │
│           ⏺                │  RecordingButton
│                             │
│         0:00               │  RecordingTimer
└─────────────────────────────┘
```

### レビューモード（stopped）
```
┌─────────────────────────────┐
│  Record Voice                │  AppBar（タイトル変更なし）
├─────────────────────────────┤
│                             │
│  EMOTION DETECTION          │  primaryカラー・大文字
│  We've mapped your feelings │  サブテキスト
│                             │
│  ┌───────────────────────┐  │
│  │ 0:02  0:08  0:11      │  │  タイムスタンプ
│  │  😂    😂    😭        │  │  感情マーカー
│  │  |     |     |        │  │
│  │ ▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌     │  │  音声振幅波形
│  └───────────────────────┘  │  角丸16px
│                             │
│      ↺10  ▶  10↻           │  再生コントロール
│      ─────●─────           │  プログレスバー
│      0:37          2:23    │  現在位置 / 総時間
│                             │
│  ┌───────────────────────┐  │
│  │ Total Emotion Points  │  │  角丸16px カード
│  │ 13 pt          😊     │  │
│  └───────────────────────┘  │
│                             │
│  ✦ Save to Memories        │  primaryボタン（角丸24px）
│  🗑 Delete                  │  TextButton（角丸24px）
└─────────────────────────────┘
```

## モード切り替えのトリガー

| 操作 | 遷移 |
|-----|------|
| 録音停止（RecordingButton タップ） | 録音モード → レビューモード（分析も自動開始） |
| "Delete" タップ → 確認ダイアログ → 削除 | レビューモード → 録音モード（リセット） |
| "Save to Memories" タップ | → `SaveRecordingScreen` へ遷移 |

録音停止と同時に `reviewRecordingProvider.initAnalysis(filePath)` を呼び出し、
分析を即座に開始する（現状は ReviewRecordingScreen の initState で開始していたため遅延があった）。

## 影響レイヤー

| レイヤー | 変更内容 |
|---------|---------|
| presentation | `RecordingScreen` にレビューモードを統合 |
| presentation | `PlaybackControls` ウィジェットを削除（インライン化） |
| presentation | `ReviewRecordingScreen` を削除 |
| application | `reviewRecordingProvider` — 変更なし（引き続き使用） |
| application | `recordingAnalysisProvider` — 削除（reviewRecordingProvider に一本化） |
| domain | 変更なし |
| infrastructure | 変更なし |

## 削除ファイル

```
lib/
├── presentation/
│   └── screens/
│       └── review_recording_screen.dart          ← 削除
└── application/
    └── providers/
        └── recording_analysis_provider.dart      ← 削除（reviewRecordingProvider に統合）
```

## 修正が必要な既存ファイル

| ファイル | 変更内容 |
|---------|---------|
| `lib/presentation/screens/recording_screen.dart` | ConsumerStatefulWidget 化・レビューモード UI 追加 |
| `lib/presentation/screens/recording/widgets/playback_controls.dart` | 削除、または再生コントロールのみに縮小 |
| `lib/infrastructure/repositories/audio_recorder_repository_impl.dart` 等 | 録音停止時に `initAnalysis` を呼ぶトリガー追加（RecordingButton 経由） |

## 実装詳細

### RecordingScreen のステート管理

`ConsumerWidget` → `ConsumerStatefulWidget` に変更。

```dart
bool get _isReviewMode => recordingState == RecordingState.stopped;
```

`build` 内で `_isReviewMode` に応じて `AnimatedSwitcher` で切り替え：

```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  child: _isReviewMode
      ? _buildReviewMode(context, ref, theme)   // レビューモード
      : _buildRecordingMode(context, ref, theme), // 録音モード
)
```

### 分析の自動開始タイミング

`RecordingButton` が録音停止を検知した後（`RecordingState.stopped` への遷移）、
`RecordingScreen` の `ref.listen` で検知して `initAnalysis` を呼ぶ：

```dart
ref.listen(recordingProvider, (prev, next) {
  if (prev != RecordingState.stopped && next == RecordingState.stopped) {
    final filePath = ref.read(recordingProvider.notifier).currentFilePath;
    if (filePath != null) {
      ref.read(reviewRecordingProvider.notifier).initAnalysis(filePath);
    }
  }
});
```

### Delete 処理

```dart
Future<void> _deleteRecording() async {
  // 確認ダイアログ
  await audioPlayerNotifier.stop();
  await File(filePath).delete();
  await recordingNotifier.resetRecording();
  timerNotifier.reset();
  reviewRecordingNotifier.reset();
  // 録音モードに戻る（状態リセットで自動的に切り替わる）
}
```

## UIコンポーネント仕様（レビューモード）

### 再生コントロール
- 既存の `PlaybackControls` ウィジェットの再生部分をインライン化
- ボタンサイズ：スキップ 48×48px、再生/一時停止 72×72px（既存踏襲）

### ボタン
| ボタン | スタイル | アイコン | ラベル |
|-------|--------|--------|------|
| Save to Memories | ElevatedButton（primary, 高さ56px, 角丸24px） | `Icons.auto_awesome` | Save to Memories |
| Delete | TextButton（高さ56px, 角丸24px） | `Icons.delete_outline` | Delete |

## 受け入れ条件

- [ ] 録音停止後、同一画面でレビューモードに切り替わる（画面遷移なし）
- [ ] レビューモード切り替えと同時に感情分析が開始される
- [ ] 「EMOTION DETECTION」「We've mapped your feelings」が表示される
- [ ] 分析中は「分析中...」ローディング表示、完了後に波形バー + 感情マーカーが表示される
- [ ] 分析中も音声の再生・一時停止・シークが動作する
- [ ] 再生コントロール（±10秒スキップ）が機能する
- [ ] プログレスバーに現在位置と総時間が表示される
- [ ] Total Emotion Points カードに `events.length` が表示される
- [ ] 「Save to Memories」→ `SaveRecordingScreen` に遷移する
- [ ] 「Delete」→ 録音ファイルを削除して録音モードにリセットされる
- [ ] 録音モード ↔ レビューモードの切り替えにアニメーションがある
- [ ] `ReviewRecordingScreen` が削除されナビゲーションスタックが浅くなっている
- [ ] UIルール（角丸16/24px・スペーシング8/16/24px・テーマカラー）に準拠している

# 音声トリミング機能 詳細設計書

## 要件整理

### 機能概要

一時音声確認画面で、録音の開始位置と終了位置を指定してトリミングできる。

### 現状の課題

- 録音後にトリミングができない
- 不要な部分（最初や最後の無音部分など）を削除できない

### 実装方針

#### 影響するレイヤー

- **application層**：
  - トリミング処理のロジック
  - 新しいファイルの生成

- **infrastructure層**：
  - FFmpeg または just_audio の機能を使用
  - ファイル操作

- **presentation層**：
  - トリミングUI（範囲選択スライダー）
  - プレビュー機能

- **domain層**：
  - 変更なし

#### 新規作成ファイル

```
lib/application/
  └── services/
      └── audio_trimming_service.dart

lib/presentation/
  └── screens/
      └── recording/
          └── widgets/
              └── trimming_slider.dart
```

#### 修正が必要な既存ファイル

- `lib/presentation/screens/recording_screen.dart`（トリミングUI追加）
- `lib/application/providers/recording_provider.dart`（トリミング処理追加）

#### 使用する依存パッケージ

**オプション1：ffmpeg_kit_flutter**

- 音声ファイルのトリミングに最適
- ファイルサイズが大きい（約20MB）
- 新規追加が必要

**オプション2：just_audio + path_provider**

- 既存パッケージで実装可能
- トリミングは手動実装が必要
- ファイル操作が複雑

**推奨：ffmpeg_kit_flutter_min_gpl**

- 最小構成で約10MB
- トリミングコマンドが簡単

#### 状態管理への影響

- `trimmingRangeProvider`：トリミング範囲（開始/終了）を管理
- `isTrimming Provider`：トリミング処理中フラグ

### UI設計

#### トリミングUI

```
┌─────────────────────────┐
│  Recording Preview      │
├─────────────────────────┤
│                         │
│  ━━━━━━━━━━━━━━━━━━━   │
│  00:00        02:18     │
│                         │
│  [Trim Audio]           │
│                         │
│  ┌─────────────────┐   │
│  │ ●━━━━━━━━━━━● │   │
│  │ 00:05    02:10  │   │
│  └─────────────────┘   │
│                         │
│  [Preview] [Apply]      │
│                         │
│  [Save Recording]       │
└─────────────────────────┘
```

### 機能要件

#### 基本機能

1. **範囲選択スライダー**：開始位置と終了位置を指定
2. **プレビュー再生**：選択範囲のみを再生
3. **トリミング実行**：新しいファイルを生成
4. **元ファイル保持**：トリミング前のファイルは削除

#### UI要素

1. **デュアルスライダー**：開始/終了の2つのつまみ
2. **時間表示**：選択範囲の開始時間と終了時間
3. **プレビューボタン**：選択範囲を再生
4. **適用ボタン**：トリミングを実行

### 実装詳細

#### ffmpeg_kit_flutter を使用する場合

```dart
Future<String> trimAudio(
  String inputPath,
  Duration startTime,
  Duration endTime,
) async {
  final outputPath = '${inputPath}_trimmed.m4a';

  final command = '-i $inputPath '
      '-ss ${startTime.inSeconds} '
      '-to ${endTime.inSeconds} '
      '-c copy $outputPath';

  await FFmpegKit.execute(command);
  return outputPath;
}
```

#### トリミング範囲の管理

```dart
class TrimmingRange {
  final Duration start;
  final Duration end;

  Duration get duration => end - start;
}
```

### 想定されるリスクとエッジケース

1. **処理時間**：長い録音のトリミングに時間がかかる
2. **ファイルサイズ**：ffmpeg の追加で APK サイズが増加
3. **エラーハンドリング**：トリミング失敗時の処理
4. **最小範囲**：1秒未満のトリミングは禁止
5. **メモリ使用量**：大きなファイルの処理

### 実装の流れ

1. **パッケージの追加**
   - ffmpeg_kit_flutter_min_gpl を pubspec.yaml に追加

2. **AudioTrimmingService の作成**
   - トリミング処理のロジック
   - ファイル操作

3. **TrimmingSlider ウィジェットの作成**
   - デュアルスライダーUI
   - 時間表示

4. **RecordingScreen への組み込み**
   - トリミングUIの追加
   - プレビュー機能
   - 適用ボタン

5. **動作確認**
   - 各種範囲でのトリミング
   - エラーハンドリング

## 確定事項

1. ffmpeg：一旦ffmpegなしでDartのみで実装を試みる。問題があれば追加を検討
2. トリミング前の元ファイル：削除する
3. トリミング：スキップ可能（オプション機能）
4. 最小トリミング範囲：1秒以上。スタート位置とエンド位置をそれぞれ選択できるデュアルスライダー形式

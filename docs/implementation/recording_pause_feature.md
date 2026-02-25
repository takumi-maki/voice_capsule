# 録音一時停止機能 詳細設計書

## 要件整理

### 機能概要

録音中に一時停止ボタンを押すと録音を一時停止し、再開ボタンで録音を再開できる。

### 現状の課題

- 現在は録音開始→停止のみ対応
- 一時停止して再開する機能がない

### 実装方針

#### 影響するレイヤー

- **application層**：
  - recording_provider に pause/resume 機能追加

- **infrastructure層**：
  - record パッケージの pause/resume API を使用

- **presentation層**：
  - RecordingScreen の UI 更新（一時停止ボタン追加）

- **domain層**：
  - RecordingState に paused 状態を追加

#### 新規作成ファイル

なし

#### 修正が必要な既存ファイル

- `lib/application/providers/recording_provider.dart`
- `lib/presentation/screens/recording_screen.dart`
- `lib/presentation/screens/recording/widgets/recording_controls.dart`

#### 使用する依存パッケージ

- record（既存）：pause() / resume() メソッドを使用
- flutter_riverpod（既存）

#### 状態管理への影響

- `RecordingState` enum に `paused` を追加
- `recordingProvider` に pause/resume メソッド追加

### 状態遷移

```
idle → recording → paused → recording → stopped
  ↓                  ↓
  └─────────────────→ stopped
```

### UI設計

#### 録音中の状態

```
┌─────────────────────────┐
│      Recording...       │
│      ⏺ 01:23           │
│                         │
│      [⏸ Pause]         │
│      [⏹ Stop]          │
└─────────────────────────┘
```

#### 一時停止中の状態

```
┌─────────────────────────┐
│      Paused             │
│      ⏸ 01:23           │
│                         │
│      [▶ Resume]         │
│      [⏹ Stop]          │
└─────────────────────────┘
```

### データ構造の変更

#### RecordingState（変更前）

```dart
enum RecordingState {
  idle,
  recording,
  stopped,
}
```

#### RecordingState（変更後）

```dart
enum RecordingState {
  idle,
  recording,
  paused,      // 追加
  stopped,
}
```

### 実装詳細

#### RecordingProvider の拡張

```dart
class RecordingNotifier extends StateNotifier<RecordingState> {
  // 既存メソッド
  Future<void> startRecording();
  Future<void> stopRecording();

  // 新規メソッド
  Future<void> pauseRecording();   // 追加
  Future<void> resumeRecording();  // 追加
}
```

#### record パッケージの API

- `await _recorder.pause()`：録音を一時停止
- `await _recorder.resume()`：録音を再開

### 想定されるリスクとエッジケース

1. **一時停止中のタイマー**：タイマーも一時停止する必要がある
2. **一時停止の回数制限**：何度でも一時停止/再開可能
3. **一時停止中のタブ切り替え**：警告ダイアログは不要（録音中のみ）
4. **プラットフォーム対応**：iOS/Android で pause/resume が動作するか確認

### 実装の流れ

1. **domain層の変更**
   - RecordingState に paused を追加

2. **application層の実装**
   - pauseRecording() メソッド追加
   - resumeRecording() メソッド追加
   - タイマーの一時停止/再開処理

3. **presentation層の実装**
   - 一時停止ボタンの追加
   - 再開ボタンの追加
   - 状態に応じたUI切り替え

4. **動作確認**
   - iOS/Android での動作確認
   - タイマーの動作確認

## 確定事項

1. 一時停止中のタイマー：停止した時間で固定表示する
2. 一時停止の回数制限：なし（何度でも可能）
3. 一時停止中のタブ切り替え：ポップアップで「録音が一時停止中です。録音を破棄しますか？」と通知し、承認で録音を削除してタブ切り替え

# バグ: 録音保存後にRecordVoice画面へ戻るとタイマーが前の値のまま表示される

## 再現手順

1. Record Voice タブで録音を開始する
2. 録音を停止し、保存画面（SaveRecordingScreen）でタイトルを入力して「保存」をタップ
3. Timeline タブへ遷移する
4. Record Voice タブへ戻る

## 期待する動作

タイマーが `00:00` にリセットされた状態で表示される。

## 実際の動作

タイマーが前の録音の経過時間（例: `01:23`）のまま表示される。

## 原因

[`save_recording_screen.dart:231`](../../lib/presentation/screens/save_recording_screen.dart#L231) の `_saveRecording()` メソッド内で、`recordingProvider.notifier.resetRecording()` は呼ばれているが、**`recordingTimerProvider.notifier.reset()` が呼ばれていない**。

```dart
// save_recording_screen.dart - _saveRecording()
await recordingNotifier.saveRecording(...);
await recordingNotifier.resetRecording();  // ← RecordingState は idle に戻る
// ↑ recordingTimerProvider のリセットが抜けている
```

一方、録音を破棄（`_showDiscardDialog`）した場合や、録音中にタブを切り替えた場合（`_stopAndDiscardRecording`）は `timerNotifier.reset()` が正しく呼ばれている。

## 影響範囲

- **レイヤー**: presentation（`SaveRecordingScreen`）
- **ファイル**: [`lib/presentation/screens/save_recording_screen.dart`](../../lib/presentation/screens/save_recording_screen.dart)
- **Provider**: `recordingTimerProvider`（[`lib/application/providers/recording_timer_provider.dart`](../../lib/application/providers/recording_timer_provider.dart)）

## 修正方針

`_saveRecording()` の保存処理完了後に `recordingTimerProvider.notifier.reset()` を呼び出す。

```dart
void _saveRecording() async {
  // ...
  await recordingNotifier.saveRecording(...);
  await recordingNotifier.resetRecording();
  ref.read(recordingTimerProvider.notifier).reset();  // ← 追加
  // ...
}
```

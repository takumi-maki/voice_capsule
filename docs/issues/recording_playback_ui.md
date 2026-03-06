# Recording Playback UI Implementation

## Issue Description
録音完了後のPlay中のUIを実装する必要があります。

## Requirements

### UI Components
- **中央の波形表示**: `waveform_visualizer.dart`と同じコンポーネントを使用
- **プログレスバー**: 再生時間を視覚的に表示、シーク機能付き
- **時間表示**: 現在時間 / 総時間（例：01:24 / 04:32）
- **再生コントロール**: 
  - 早送りボタン（10秒スキップ）
  - 巻き戻しボタン（10秒戻る）
  - 停止ボタン（再生を停止して録音完了画面に戻る）

### 参考デザイン
`screens/audio_playback/code.html`のUIを参考にする：
- プログレスバーのデザイン
- 時間表示のフォーマット
- ボタンの配置とスタイル

### Screen States
1. **再生中状態**: 波形アニメーション、プログレスバー更新
2. **一時停止状態**: 波形停止、プログレスバー固定
3. **再生完了状態**: 自動的に録音完了画面に戻る

### Design Requirements
- 既存のRecording画面と一貫したデザイン言語
- プログレスバーでのシーク操作が直感的
- 再生状態が明確に分かるビジュアルフィードバック
- Material Design 3のガイドラインに準拠

## File Structure
```
lib/presentation/screens/recording/widgets/
├── playback_controls.dart (新規)
├── playback_progress_bar.dart (新規)
└── waveform_visualizer.dart (既存を再利用)
```

## Implementation Notes

### 影響するレイヤー
- **presentation**: 新しいPlayback UI コンポーネント
- **application**: AudioPlayerProviderの拡張（シーク、進捗管理）

### 新規作成するファイル
- `playback_controls.dart`: 早送り/巻き戻し/停止ボタン
- `playback_progress_bar.dart`: プログレスバーとシーク機能

### 修正が必要な既存ファイル
- `recording_controls.dart`: Play状態の管理
- `audio_player_provider.dart`: シーク機能、進捗通知の追加
- `recording_screen.dart`: Playback UI の表示切り替え

### 使用する依存パッケージ
- 既存のjust_audioパッケージを活用
- flutter_riverpodで状態管理

### 状態管理（Riverpod）への影響
- AudioPlayerProviderに以下を追加：
  - 再生進捗の監視
  - シーク機能
  - 再生完了の検知

## 想定されるリスクやエッジケース
- シーク操作中の音声ファイルの整合性
- 再生完了時の状態遷移
- プログレスバーの更新頻度とパフォーマンス
- 音声ファイルの長さが取得できない場合

## 実装の流れ
1. AudioPlayerProviderにシーク機能と進捗監視を追加
2. PlaybackProgressBarコンポーネントを作成
3. PlaybackControlsコンポーネントを作成
4. RecordingScreenでPlayback状態の表示切り替えを実装
5. 既存のWaveformVisualizerを再生状態に対応

## Acceptance Criteria
- [x] 再生中に波形アニメーションが表示される
- [x] プログレスバーが再生進捗を正確に表示する
- [x] プログレスバーをタップ/ドラッグでシークできる
- [x] 早送り/巻き戻しボタンが10秒単位で動作する
- [x] 停止ボタンで録音完了画面に戻る
- [x] 時間表示が正確（現在時間 / 総時間）
- [x] 再生完了時に自動的に録音完了画面に戻る
- [x] 既存デザインとの一貫性が保たれている
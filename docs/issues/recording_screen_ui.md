# Recording Screen UI Implementation

## Issue Description
Recording画面のUIを実装する必要があります。

## Requirements

### UI Components
- **録音ボタン**: 中央に大きな録音開始/停止ボタン（録音完了後は非表示）
- **録音状態表示**: 録音中のビジュアルフィードバック（波形アニメーションなど）
- **タイマー表示**: 録音時間の表示
- **録音完了後の操作**: 再生、保存、やり直しボタン
  - **Retryボタン**: 確認ポップアップ付きで録音をやり直し

### Screen States
1. **待機状態**: 録音開始前
2. **録音中状態**: アクティブな録音中
3. **録音完了状態**: 録音終了後の確認画面（一時保存画面）
   - マイクボタンは非表示
   - Play/Save/Retryボタンのみ表示

### Design Requirements
- CharacterSelectionScreenと一貫したデザイン言語
- 直感的で使いやすいUI
- 録音状態が明確に分かるビジュアルフィードバック
- アクセシビリティを考慮した設計

## File Structure
```
lib/presentation/screens/recording/
├── recording_screen.dart
├── widgets/
│   ├── recording_button.dart
│   ├── recording_timer.dart
│   ├── waveform_visualizer.dart
│   └── recording_controls.dart
```

## Implementation Notes
- 既存のCharacterSelectionScreenのデザインパターンを参考にする
- Material Design 3のガイドラインに従う
- 状態管理にはStatefulWidgetまたはBlocパターンを使用
- 録音機能の実装は別途検討（この段階ではUI実装のみ）

## Update: Retry機能の詳細仕様
### 実装方針
1. **影響するレイヤー**:
   - presentation（UI修正）
   - application（RecordingProviderにリセット機能追加）

2. **修正が必要な既存ファイル**:
   - `recording_controls.dart` - 確認ダイアログ追加
   - `recording_button.dart` - stopped状態時は非表示
   - `recording_provider.dart` - resetRecording()メソッド追加

3. **状態管理（Riverpod）への影響**:
   - RecordingProviderにリセット機能追加
   - 状態遷移: stopped → idle

### 想定されるリスクやエッジケース
- ファイル削除の失敗
- ダイアログ表示中の状態管理
- タイマーとの同期

## Acceptance Criteria
- [ ] 録音ボタンが中央に配置されている
- [ ] 録音状態が視覚的に分かりやすい
- [ ] タイマー表示が正確に動作する
- [ ] 録音完了後の操作が直感的
- [ ] 既存画面との一貫したデザイン
- [ ] 録音完了後はマイクボタンが非表示
- [ ] Retryボタンに確認ダイアログが表示される
- [ ] Retryボタンで録音状態がリセットされる
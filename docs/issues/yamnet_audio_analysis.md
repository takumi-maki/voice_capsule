# YAMNet音声分析システムの実装（笑い声・泣き声検出）

## Issue Description

録音データからYAMNet（TensorFlow Lite）を使って笑い声・泣き声を検出する音声分析システムを実装する。
分析は完全オンデバイスで行い、外部APIへの音声送信は行わない。

## Background

VoiceCapsuleの中核機能として、子どもの録音から感情イベントを自動検出しポイント化する仕組みが必要。

## Requirements

### 録音設定変更

YAMNetの入力仕様に合わせるため録音フォーマットを変更する。

| 項目 | 変更前 | 変更後 |
|---|---|---|
| encoder | AAC-LC | WAV (PCM) |
| sampleRate | 44100Hz | 16000Hz |
| numChannels | 未指定 | 1 (mono) |

### 検出対象イベント

YAMNetの521分類から以下のみを使用する。

| ラベル | イベント | ポイント |
|---|---|---|
| Laughter | laugh | +5pt |
| Baby cry | cry | +3pt |

スコア閾値: `0.6`

### 分析パイプライン

```
recording.wav
      ↓
audio window (0.96秒)
      ↓
YAMNet inference
      ↓
score filtering (> 0.6)
      ↓
AudioEvent保存
      ↓
DailyPoint更新
```

### 解析タイミング

録音停止直後に実行する（バックグラウンドキュー不要）。

## Architecture

### ドメインモデル

```dart
// AudioEvent
class AudioEvent {
  String id;
  String recordingId;
  EventType type;   // laugh / cry
  double timestamp; // 録音内の位置（秒）
  double score;
}

enum EventType { laugh, cry }
```

### Clean Architecture構成

```
domain
 ├─ entities/
 │   └─ audio_event.dart
 └─ repositories/
     └─ audio_event_repository.dart

application
 └─ usecases/
     └─ analyze_recording_usecase.dart

infrastructure
 ├─ audio/
 │   ├─ yamnet_classifier.dart
 │   └─ audio_analyzer.dart
 └─ repositories/
     └─ audio_event_repository_impl.dart

presentation
 └─ providers/
     └─ audio_event_provider.dart
```

## File Structure

### 新規作成ファイル

```
lib/domain/entities/audio_event.dart
lib/domain/repositories/audio_event_repository.dart
lib/infrastructure/audio/yamnet_classifier.dart
lib/infrastructure/audio/audio_analyzer.dart
lib/infrastructure/repositories/audio_event_repository_impl.dart
lib/application/usecases/analyze_recording_usecase.dart
lib/application/providers/audio_event_provider.dart
assets/models/yamnet.tflite
```

### 修正ファイル

```
lib/infrastructure/repositories/audio_recorder_repository_impl.dart  # 録音設定変更
lib/application/providers/recording_provider.dart                    # 拡張子変更・解析トリガー追加
pubspec.yaml                                                          # tflite_flutter追加・assets追加
```

## Dependencies

```yaml
tflite_flutter: ^0.12.1  # publisher: tensorflow.org
```

## Non-functional Requirements

- 完全オフライン動作
- 音声データは外部送信しない
- 推論はIsolateで実行（UIブロックなし）
- 推論時間目安: 30秒録音 → 約1秒以内（iPhone実機）

## Implementation Notes

- `tflite_flutter_helper` は不使用（`tflite_flutter v0.12` 単体で実装）
- 既存の`.aac`録音ファイルは再生可能だが、解析は新録音からのみ対象
- `just_audio` はWAV再生に対応済みのため再生機能への影響なし

## Future Extensions

将来追加可能なイベント候補

```
clap / singing / baby babble
```

## Implementation Steps

- [ ] pubspec.yaml更新 + YAMNetモデルをassets配置
- [ ] `AudioEvent` entity / `AudioEventRepository` interface作成
- [ ] 録音設定変更（WAV / 16kHz / mono）
- [ ] `YamnetClassifier`実装（TFLiteモデルロード・推論）
- [ ] `AudioAnalyzer`実装（WAV読み込み・ウィンドウ分割・スコア判定）
- [ ] `AudioEventRepositoryImpl`実装（SharedPreferencesで永続化）
- [ ] `AnalyzeRecordingUseCase`実装
- [ ] `recording_provider.dart`修正（解析トリガー追加）
- [ ] シミュレータで動作確認

## Acceptance Criteria

- [ ] 録音保存直後に自動で音声分析が実行される
- [ ] 笑い声・泣き声がスコア0.6以上で検出される
- [ ] 検出イベントがAudioEventとして保存される
- [ ] UIスレッドをブロックしない
- [ ] 完全オフラインで動作する

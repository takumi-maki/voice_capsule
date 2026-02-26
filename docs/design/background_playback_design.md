# バックグラウンド再生 設計書

## 1. 基本設計

### 1.1 現状分析

#### 現在の実装状況

| 項目                       | 状態            | 詳細                                                  |
| -------------------------- | --------------- | ----------------------------------------------------- |
| just_audio                 | ✅ 導入済み     | v0.9.40                                               |
| audio_session              | ⚠️ 間接依存のみ | just_audioの推移的依存として存在。明示的な初期化なし  |
| iOS UIBackgroundModes      | ❌ 未設定       | Info.plistに`audio`モードの宣言なし                   |
| Android FOREGROUND_SERVICE | ❌ 未設定       | AndroidManifest.xmlにパーミッション・サービス宣言なし |
| AudioSession初期化         | ❌ 未実装       | main.dartおよびリポジトリにAudioSession設定なし       |

#### 現在のアーキテクチャ

```
presentation
  └── PlaybackScreen (UI + コントロール)
        ↓
application
  └── AudioPlayerNotifier (StateNotifier<AudioPlayerState>)
        ↓
infrastructure
  └── AudioPlayerRepositoryImpl (just_audio.AudioPlayer ラッパー)
        ↓
domain
  └── AudioPlayerRepository (インターフェース)
```

#### 問題の根本原因

1. **iOS**: `UIBackgroundModes` に `audio` が未宣言 → アプリがバックグラウンドに移行すると即座にオーディオセッションが中断される
2. **Android**: `FOREGROUND_SERVICE` パーミッションおよび `FOREGROUND_SERVICE_MEDIA_PLAYBACK` が未宣言 → バックグラウンドでプロセスがOSに停止される
3. **AudioSession未初期化**: オーディオカテゴリ（playback）が設定されていないため、OSが再生用途と認識できない

### 1.2 要件定義

#### 機能要件

| ID    | 要件                                                                 | 優先度 |
| ----- | -------------------------------------------------------------------- | ------ |
| FR-01 | アプリがバックグラウンドに移行しても音声再生が継続する               | 必須   |
| FR-02 | ロック画面にメディアコントロール（再生/一時停止/シーク）が表示される | 必須   |
| FR-03 | ロック画面に録音タイトルが表示される                                 | 必須   |
| FR-04 | 他のアプリの音声再生時に適切にオーディオフォーカスを処理する         | 必須   |
| FR-05 | 再生完了時にバックグラウンドセッションが適切に終了する               | 必須   |

#### 非機能要件

| ID     | 要件                                                                    |
| ------ | ----------------------------------------------------------------------- |
| NFR-01 | バッテリー消費を最小限に抑える                                          |
| NFR-02 | 既存の再生UIに影響を与えない                                            |
| NFR-03 | 新規パッケージの追加なし（audio_sessionはjust_audioの推移的依存を利用） |

### 1.3 技術方針

just_audioは内部的にaudio_sessionパッケージと連携しており、以下の設定を行うことでバックグラウンド再生が実現可能：

1. **プラットフォーム設定**：iOS/Androidのマニフェストにバックグラウンドオーディオ宣言を追加
2. **AudioSession初期化**：アプリ起動時にオーディオセッションカテゴリを`playback`に設定
3. **メディアコントロール連携**：just_audioの`AudioPlayer`がロック画面コントロールを自動的にハンドリング（MediaItem設定が必要）

---

## 2. 詳細設計

### 2.1 影響するレイヤー

| レイヤー         | 影響 | 内容                                                                |
| ---------------- | ---- | ------------------------------------------------------------------- |
| presentation     | なし | UI変更不要                                                          |
| application      | 修正 | AudioPlayerNotifierにメディアメタデータ設定を追加                   |
| domain           | 修正 | AudioPlayerRepositoryにメタデータ設定メソッドを追加                 |
| infrastructure   | 修正 | AudioPlayerRepositoryImplにAudioSession初期化・メタデータ設定を追加 |
| プラットフォーム | 修正 | iOS Info.plist / Android AndroidManifest.xml                        |

### 2.2 修正が必要な既存ファイル

| ファイル                                                            | 変更内容                                                                                                    |
| ------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `ios/Runner/Info.plist`                                             | `UIBackgroundModes` に `audio` を追加                                                                       |
| `android/app/src/main/AndroidManifest.xml`                          | `FOREGROUND_SERVICE` / `FOREGROUND_SERVICE_MEDIA_PLAYBACK` パーミッション追加、フォアグラウンドサービス宣言 |
| `lib/main.dart`                                                     | AudioSession初期化処理を追加                                                                                |
| `lib/domain/repositories/audio_player_repository.dart`              | `setMediaItem` メソッドを追加                                                                               |
| `lib/infrastructure/repositories/audio_player_repository_impl.dart` | AudioSession設定、`setMediaItem` 実装を追加                                                                 |
| `lib/application/providers/audio_player_provider.dart`              | `play()` 時にメディアメタデータを設定するロジックを追加                                                     |

### 2.3 新規作成ファイル

なし

### 2.4 使用する依存パッケージ

| パッケージ      | 状態                         | 用途                                                       |
| --------------- | ---------------------------- | ---------------------------------------------------------- |
| `just_audio`    | 既存                         | オーディオ再生エンジン                                     |
| `audio_session` | 推移的依存（just_audio経由） | オーディオセッション管理。pubspec.yamlへの明示的追加は不要 |

### 2.5 各ファイルの変更詳細

#### 2.5.1 iOS Info.plist

追加する設定：

```xml
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
</array>
```

これにより、iOSがアプリをバックグラウンドオーディオ対応として認識する。

#### 2.5.2 Android AndroidManifest.xml

追加するパーミッション：

```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"/>
```

`<application>` 内に追加するサービス宣言：

```xml
<service
    android:name="com.ryanheise.audioservice.AudioService"
    android:foregroundServiceType="mediaPlayback"
    android:exported="false" />
```

#### 2.5.3 lib/main.dart

`main()` 関数内で `AudioSession` を初期化：

```
処理フロー:
1. WidgetsFlutterBinding.ensureInitialized()（既存）
2. AudioSession.instance を取得
3. AudioSessionConfiguration(
     avAudioSessionCategory: AVAudioSessionCategory.playback,
     androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
     androidAudioAttributes: AndroidAudioAttributes(
       contentType: AndroidAudioContentType.music,
       usage: AndroidAudioUsage.media,
     ),
   ) で設定
```

#### 2.5.4 domain/repositories/audio_player_repository.dart

インターフェースに追加：

```
Future<void> setMediaItem({
  required String title,
  required String filePath,
})
```

再生時にロック画面に表示するメタデータを設定するためのメソッド。

#### 2.5.5 infrastructure/repositories/audio_player_repository_impl.dart

変更内容：

1. `play()` メソッド内で `AudioSource.file()` を使用し、`tag` に `MediaItem` を設定
2. `setMediaItem()` の実装

```
処理フロー:
1. play(filePath) 呼び出し時
2. MediaItem(id: filePath, title: title) を作成
3. AudioSource.file(filePath, tag: mediaItem) でソースを設定
4. _player.setAudioSource(source) → _player.play()
```

#### 2.5.6 application/providers/audio_player_provider.dart

変更内容：

1. `play()` メソッドのシグネチャを拡張：`play(String filePath, {String? title})`
2. 再生前に `_repository.setMediaItem()` を呼び出し

### 2.6 状態管理への影響

| プロバイダー          | 影響                                                     |
| --------------------- | -------------------------------------------------------- |
| `audioPlayerProvider` | `play()` メソッドのシグネチャ変更（titleパラメータ追加） |
| その他のプロバイダー  | 影響なし                                                 |

### 2.7 呼び出し元の修正

`play()` のシグネチャ変更に伴い、以下の呼び出し元を修正：

| ファイル               | 現在                                           | 変更後                                                                 |
| ---------------------- | ---------------------------------------------- | ---------------------------------------------------------------------- |
| `PlaybackScreen`       | `notifier.play(recording.filePath)`            | `notifier.play(recording.filePath, title: recording.title)`            |
| `RecordingCard`        | `audioPlayerNotifier.play(recording.filePath)` | `audioPlayerNotifier.play(recording.filePath, title: recording.title)` |
| `TimelineScreen`（旧） | 該当なし（リニューアル済み）                   | -                                                                      |

### 2.8 処理シーケンス

```
ユーザーが「Listen Now」タップ
  ↓
RecordingCard._playRecording()
  ↓
AudioPlayerNotifier.play(filePath, title: title)
  ↓
AudioPlayerRepositoryImpl.play(filePath, title: title)
  ├── MediaItem(id: filePath, title: title) 作成
  ├── AudioSource.file(filePath, tag: mediaItem) 設定
  ├── _player.setAudioSource(source)
  └── _player.play()
  ↓
[OS レベル]
  ├── AudioSession: playbackカテゴリで再生中と認識
  ├── iOS: UIBackgroundModes=audio により中断されない
  ├── Android: ForegroundService により停止されない
  └── ロック画面: MediaItem の title が表示される
```

### 2.9 想定されるリスクとエッジケース

| リスク                                                | 対策                                                                               |
| ----------------------------------------------------- | ---------------------------------------------------------------------------------- |
| 他のアプリが音声を再生した場合のフォーカス競合        | AudioSessionのinterruptionイベントを監視し、一時停止/再開を処理                    |
| 再生完了後もフォアグラウンドサービスが残る（Android） | just_audioが自動的にサービスを停止するが、`stop()` 時に明示的にクリーンアップ      |
| 電話着信時の割り込み                                  | AudioSessionのinterruptionハンドリングで自動一時停止                               |
| `play()` シグネチャ変更による既存コードの破損         | `title` をオプショナルパラメータにし、後方互換性を維持                             |
| audio_sessionのimportパス                             | just_audioの推移的依存を利用。直接importが解決できない場合はpubspec.yamlに明示追加 |

### 2.10 実装の流れ

| ステップ | 内容                                                                   |
| -------- | ---------------------------------------------------------------------- |
| 1        | iOS Info.plist に `UIBackgroundModes: audio` を追加                    |
| 2        | Android AndroidManifest.xml にパーミッション・サービス宣言を追加       |
| 3        | `lib/main.dart` に AudioSession 初期化を追加                           |
| 4        | `domain/repositories/audio_player_repository.dart` にメソッド追加      |
| 5        | `infrastructure/repositories/audio_player_repository_impl.dart` を修正 |
| 6        | `application/providers/audio_player_provider.dart` を修正              |
| 7        | 呼び出し元（PlaybackScreen, RecordingCard）を修正                      |
| 8        | 実機でバックグラウンド再生・ロック画面コントロールを検証               |

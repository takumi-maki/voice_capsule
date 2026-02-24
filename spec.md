# 📘 基本設計書（VoiceCapsule）

## 1. システム概要

### ■ システム名

VoiceCapsule（仮）

### ■ 目的

子どもの声を簡単に録音・保存し、
音量に応じてキャラクターが軽く反応する思い出アプリ。

### ■ 対象ユーザー

2〜6歳の子どもを持つ親

### ■ プラットフォーム

* iOS
* Android
* Flutter クロスプラットフォーム

---

## 2. システム構成

### ■ アーキテクチャ

```
UI（Flutter）
↓
Application Layer
↓
Domain Layer
↓
Local Storage
```

完全オフライン設計。

---

## 3. 機能一覧

### F01 録音機能

* 音声録音開始／停止
* WAV or AAC 保存
* ファイルパス生成

### F02 再生機能

* 音声再生
* 一時停止
* シークバー

### F03 音量反応アニメーション

* 再生中の音量取得（RMS）
* 閾値超過でキャラ状態変更

  * Neutral
  * Talking
  * Bounce

### F04 一覧表示

* 日付順表示
* キャラアイコン表示
* 背景アイコン表示

### F05 キャラ選択

* 父 / 母 / 息子 / 娘

### F06 背景選択

* 家 / 車 / 公園

### F07 制限機能（無料版）

* 保存上限：3件
* 超過時はアップグレード導線表示

### F08 エクスポート

* 音声ファイル共有
* 端末保存

---

## 4. 非機能要件

### パフォーマンス

* 録音開始まで1秒以内
* 再生遅延500ms以内

### セキュリティ

* 完全ローカル保存
* 外部送信なし

### UI方針

* パステルカラー
* 角丸統一（16/24）
* 余白 8/16/24 ルール

---

# 📙 詳細設計書

---

## 1. データ設計

### ■ Recording Entity

```dart
class Recording {
  String id;
  String filePath;
  DateTime createdAt;
  CharacterType character;
  BackgroundType background;
  int duration;
}
```

---

### ■ CharacterType

```dart
enum CharacterType {
  father,
  mother,
  son,
  daughter
}
```

---

### ■ BackgroundType

```dart
enum BackgroundType {
  house,
  car,
  park
}
```

---

## 2. 保存設計

### ■ 音声ファイル

* 保存先：ApplicationDocumentsDirectory
* 命名規則：

```
recording_yyyyMMdd_HHmmss.aac
```

### ■ メタデータ

* jsonファイルで管理

```
recordings.json
```

---

## 3. 画面設計

---

### 3.1 録音画面

#### UI要素

* AppBar（Recording）
* CharacterPreviewWidget
* WaveformWidget
* RecordButton

#### 状態管理

```
Idle
Recording
Stopped
```

---

### 3.2 タイムライン画面

#### UI要素

* ListView.builder
* RecordingCard

  * Date
  * Character icon
  * Background icon
  * Play button

---

### 3.3 再生画面

#### UI要素

* BackgroundWidget
* CharacterAnimatedWidget
* AudioControls

#### アニメロジック

```
if (rms < 0.02) → Neutral
if (0.02 <= rms < 0.1) → Talking
if (rms >= 0.1) → Bounce
```

---

## 4. パッケージ構成

```
/lib
 ├─ main.dart
 ├─ core/
 ├─ domain/
 ├─ application/
 ├─ infrastructure/
 └─ presentation/
```

---

## 5. 状態管理

軽くいくなら：

* Riverpod or Provider

個人開発なら Riverpod 推奨。

---

## 6. 課金設計

* in_app_purchase
* 買い切り
* フラグ管理：

```
isPremium: bool
```

---

## 7. 今後拡張余地

* クラウド同期
* 家族共有
* 年齢別フォルダ
* タイムカプセル再生機能


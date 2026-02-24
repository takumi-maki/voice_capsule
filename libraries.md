# 📦 VoiceCapsule 使用ライブラリ一覧

## 🎯 必須ライブラリ

### 録音機能（F01）
- **record** (^5.1.0)
  - 音声録音（AAC形式）
  - iOS/Android対応
  - パーミッション管理

### 再生機能（F02）
- **just_audio** (^0.9.40)
  - 音声再生・一時停止
  - シークバー対応
  - ストリーム対応
  - ⚠️ RMS取得は不可（再生専用）

### ファイル管理（F01, F08）
- **path_provider** (^2.1.4)
  - ApplicationDocumentsDirectory取得
  - ファイルパス生成

### データ永続化（F04, F07）
- **shared_preferences** (^2.3.2)
  - isPremiumフラグ管理
  - 簡易設定保存

### JSON管理（F04）
- **dart:convert** (標準ライブラリ)
  - recordings.json読み書き

### 状態管理（全体）
- **flutter_riverpod** (^2.5.1)
  - 状態管理
  - DI

### UUID生成（F01）
- **uuid** (^4.5.1)
  - Recording ID生成

### 日付フォーマット（F01, F04）
- **intl** (^0.19.0)
  - ファイル名生成（yyyyMMdd_HHmmss）
  - 日付表示

---

## 🎨 UI関連

### アニメーション（F03）
- **flutter標準** (AnimatedContainer, AnimatedScale)
  - キャラクター口パクアニメ（ループ）
  - ⚠️ RMS連動は実装困難→シンプルなループで十分

### ファイル共有（F08）
- **share_plus** (^10.1.2)
  - 音声ファイル共有

### パーミッション（F01）
- **permission_handler** (^11.3.1)
  - マイク権限管理

---

## 💰 課金機能（F07）※Phase5で実装

### アプリ内課金
- **in_app_purchase** (^3.2.0)
  - 買い切り課金
  - iOS/Android対応
  - ⚠️ 最初は実装しない（Phase5まで後回し）

---

## 🧪 開発・テスト

### Linter
- **flutter_lints** (^5.0.0)
  - コード品質管理

### テスト
- **flutter_test** (標準)
- **mockito** (^5.4.4) ※必要に応じて

---

## 📋 pubspec.yaml 記載内容

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 状態管理
  flutter_riverpod: ^2.5.1
  
  # 音声
  record: ^5.1.0
  just_audio: ^0.9.40
  
  # ファイル・パス
  path_provider: ^2.1.4
  
  # データ管理
  shared_preferences: ^2.3.2
  uuid: ^4.5.1
  intl: ^0.19.0
  
  # 共有・パーミッション
  share_plus: ^10.1.2
  permission_handler: ^11.3.1
  
  # 課金（Phase5で追加）
  # in_app_purchase: ^3.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

---

## ⚠️ 注意事項

### iOS設定（Info.plist）
```xml
<key>NSMicrophoneUsageDescription</key>
<string>録音機能に使用します</string>
```

### Android設定（AndroidManifest.xml）
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

※ WRITE_EXTERNAL_STORAGEは不要（Scoped Storage対応）

---

## 🚫 不要なライブラリ

- ❌ Firebase系（完全オフライン）
- ❌ Dio/http（通信なし）
- ❌ Hive/Drift（JSON管理で十分）
- ❌ GetX（Riverpodで統一）

---

## 🔥 実装時の重要注意点

### 1. RMS音量解析について
**just_audioはRMS取得不可**

解決策：
- ✅ B案採用：再生中は口パクアニメをループ
- ❌ A案（録音時保存）は複雑すぎる

実装方針：
```dart
// 再生中は単純にアニメループ
AnimationController(duration: Duration(milliseconds: 300))
  ..repeat(reverse: true);
```

### 2. record パッケージ注意
- iOSシミュレータではマイク動作しない場合あり
- 実機テスト必須
- background recording は使わない

### 3. 実装優先順位

Phase 1-3を最優先：
1. 録音 → 保存
2. 再生
3. JSON管理 → 一覧表示

Phase 4-5は後回し：
4. UI統一
5. 課金（最後）

### 4. shared_preferences用途
- isPremium フラグのみ
- 将来的に設定増えたらmodel化検討

### 5. パーミッション実装
iOS: Info.plist に NSMicrophoneUsageDescription 必須
Android: RECORD_AUDIO のみ（WRITE_EXTERNAL_STORAGE 不要）

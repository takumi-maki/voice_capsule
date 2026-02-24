# 下部タブナビゲーション実装

## 概要

アプリに下部タブナビゲーションを追加し、3つの主要画面を切り替えられるようにする。

## 要件

### タブ構成

1. **RECORD** (マイクアイコン)
   - 録音画面
   - 初期表示タブ
   - アイコン: `Icons.mic`

2. **MEMORIES** (ボックスアイコン)
   - タイムライン/一覧画面
   - アイコン: `Icons.inbox` または `Icons.folder`

3. **SETTINGS** (歯車アイコン)
   - 設定画面
   - アイコン: `Icons.settings`

### 設定画面の内容

1. **子供のプロフィール編集**
   - 既存の `ChildProfileSetupScreen` を再利用
   - 名前、生年月日、アバターの編集

2. **通知設定**
   - 将来の拡張用
   - 現時点では「準備中」メッセージを表示

3. **アプリ情報**
   - アプリバージョン
   - ライセンス情報
   - 開発者情報

4. **プライバシーポリシー**
   - プレースホルダーテキストを表示
   - 将来的に実際のポリシーに置き換え

### 録音中のタブ切り替え

- 録音中（`RecordingState.recording`）に他のタブに切り替えようとした場合
- 警告ダイアログを表示
- ユーザーが確認した場合のみタブ切り替えを許可
- 録音は自動的に停止

## アーキテクチャ

### 影響するレイヤー

- **presentation層**: 新規画面の作成、既存画面の修正

### 新規作成するファイル

```
lib/presentation/screens/
├── main_screen.dart                          # タブナビゲーション付きメイン画面
├── settings_screen.dart                      # 設定画面（メニューリスト）
└── settings/
    ├── app_info_screen.dart                  # アプリ情報画面
    └── privacy_policy_screen.dart            # プライバシーポリシー画面
```

### 修正が必要な既存ファイル

- `lib/main.dart`
  - `AppInitializer` で `MainScreen` を表示
- `lib/presentation/screens/save_recording_screen.dart`
  - 保存後の遷移を `MainScreen` の MEMORIES タブに変更

## 実装詳細

### MainScreen

```dart
class MainScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});
}
```

**機能:**

- `BottomNavigationBar` で3つのタブを表示
- `IndexedStack` で画面の状態を保持
- 録音中のタブ切り替え時に警告ダイアログを表示
- タブの色: 選択時はオレンジ、非選択時はグレー

**録音中の警告ダイアログ:**

```
タイトル: 録音中です
内容: 録音を停止してタブを切り替えますか？
ボタン: キャンセル / 停止して切り替え
```

### SettingsScreen

**設定項目:**

1. 子供のプロフィール編集
   - アイコン: `Icons.person`
   - タップ → `ChildProfileSetupScreen` に遷移
2. 通知設定
   - アイコン: `Icons.notifications`
   - タップ → 「準備中」スナックバー表示
3. アプリ情報
   - アイコン: `Icons.info`
   - タップ → `AppInfoScreen` に遷移
4. プライバシーポリシー
   - アイコン: `Icons.privacy_tip`
   - タップ → `PrivacyPolicyScreen` に遷移

**UI:**

- リスト形式で表示
- 各項目は `ListTile` を使用
- 右側に `Icons.chevron_right` を表示

### AppInfoScreen

**表示内容:**

- アプリ名: VoiceCapsule
- バージョン: 1.0.0
- ビルド番号: 1
- ライセンス情報へのリンク（Flutter標準の `showLicensePage`）

### PrivacyPolicyScreen

**表示内容:**

- プレースホルダーテキスト
- スクロール可能な長文テキスト

## 状態管理

### タブインデックスの管理

オプション: StateProvider でタブインデックスを管理

```dart
final selectedTabIndexProvider = StateProvider<int>((ref) => 0);
```

または、StatefulWidget の state で管理（シンプル）

## UIルール

### 色

- 選択中のタブ: `theme.colorScheme.primary` (オレンジ)
- 非選択のタブ: `Colors.grey`
- 背景: `Colors.white`

### スペーシング

- タブバーの高さ: 60px
- 設定項目の間隔: 16px

### 角丸

- 設定画面のカード: 16px

## 想定されるリスクとエッジケース

1. **録音中のタブ切り替え**
   - リスク: ユーザーが誤って録音を停止する
   - 対策: 明確な警告ダイアログを表示

2. **保存後の遷移**
   - リスク: MainScreen への遷移がうまくいかない
   - 対策: Navigator.pushReplacement で確実に遷移

3. **状態の保持**
   - リスク: タブ切り替え時に画面の状態が失われる
   - 対策: IndexedStack を使用して状態を保持

4. **プロフィール編集後の戻り先**
   - リスク: 編集後に設定画面に戻れない
   - 対策: Navigator.pop で戻る

## 実装の流れ

### ステップ1: MainScreen の作成

1. BottomNavigationBar の実装
2. IndexedStack で3画面を管理
3. 録音中の警告ダイアログ実装

### ステップ2: SettingsScreen の作成

1. 設定項目のリスト表示
2. 各項目のタップハンドラー実装

### ステップ3: 設定詳細画面の作成

1. AppInfoScreen の実装
2. PrivacyPolicyScreen の実装

### ステップ4: main.dart の修正

1. AppInitializer で MainScreen を表示

### ステップ5: 保存後の遷移修正

1. SaveRecordingScreen で MainScreen(initialIndex: 1) に遷移

### ステップ6: テスト

1. タブ切り替えの動作確認
2. 録音中の警告ダイアログ確認
3. 保存後の遷移確認
4. 設定画面の各項目の動作確認

## 将来の拡張

1. **通知設定の実装**
   - ローカル通知の設定
   - リマインダー機能

2. **プライバシーポリシーの更新**
   - 実際のポリシーテキストに置き換え
   - Web表示またはPDF表示

3. **その他の設定項目**
   - テーマ設定（ダーク/ライトモード）
   - 言語設定
   - データのエクスポート/インポート

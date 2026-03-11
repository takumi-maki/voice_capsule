# Settings 画面と UserProfileSetupScreen の重複排除

## 概要

Settings 画面のプロフィール編集項目と、UserProfileSetupScreen 内の編集時タイトルに重複がある。
既存のナビゲーション経路で到達できるため、Settings の項目と body 内の重複テキストを削除する。

## 重複箇所

### 1. Settings の「自分のプロフィール編集」

| アクセス経路 | 画面 |
|------------|------|
| TimelineHeader 右上アバタータップ | `UserProfileSetupScreen(isEditing: true)` |
| Settings → 「自分のプロフィール編集」| `UserProfileSetupScreen(isEditing: true)` ← **重複** |

### 2. Settings の「子供のプロフィール編集」

| アクセス経路 | 画面 |
|------------|------|
| Family タブ → 各カード鉛筆アイコン | `ChildProfileSetupScreen(child: child)` |
| Family タブ → Add Child ボタン | `ChildProfileSetupScreen()` |
| Settings → 「子供のプロフィール編集」| `ChildProfileSetupScreen()` ← **重複** |

### 3. UserProfileSetupScreen の編集時タイトル二重表示

`isEditing: true` のとき：
- AppBar タイトル：「プロフィール編集」
- body 内テキスト：「プロフィールを編集」← **重複**

## 変更内容

### `lib/presentation/screens/settings_screen.dart`

- 「自分のプロフィール編集」の `_buildSettingItem` と `Divider` を削除
- 「子供のプロフィール編集」の `_buildSettingItem` と `Divider` を削除
- 不要になった `_navigateToUserProfileEdit`・`_navigateToProfileEdit` メソッドを削除
- 不要になった import（`child_profile_setup_screen.dart`・`user_profile_setup_screen.dart`）を削除

Settings 画面の構成（変更後）：
```
設定
├── 通知設定（Coming soon）
├── アプリ情報
└── プライバシーポリシー
```

### `lib/presentation/screens/onboarding/user_profile_setup_screen.dart`

編集時（`isEditing: true`）に表示されている body 内の重複テキストを削除：

```dart
// 削除対象
Text(
  widget.isEditing ? 'プロフィールを編集' : 'あなたのプロフィールを設定',
  ...
),
const SizedBox(height: 8),
Text(
  widget.isEditing ? '' : 'VoiceCapsuleへようこそ...',
  ...
),
```

オンボーディング時（`isEditing: false`）の説明テキストは残す：

```dart
// isEditing: false のときのみ表示
if (!widget.isEditing) ...[
  Text('あなたのプロフィールを設定', ...),
  const SizedBox(height: 8),
  Text('VoiceCapsuleへようこそ。まずあなた自身のプロフィールを登録してください。', ...),
  const SizedBox(height: 48),
],
```

## 影響レイヤー

| レイヤー | 変更内容 |
|---------|---------|
| presentation | `settings_screen.dart` — 2項目削除 |
| presentation | `user_profile_setup_screen.dart` — 編集時の重複タイトルテキスト削除 |

## 削除ファイル

なし（既存ファイルの修正のみ）

## 受け入れ条件

- [ ] Settings 画面に「自分のプロフィール編集」「子供のプロフィール編集」が表示されない
- [ ] TimelineHeader のアバターから引き続き自分のプロフィール編集へ遷移できる
- [ ] Family タブから引き続き子供のプロフィール編集・追加ができる
- [ ] `UserProfileSetupScreen(isEditing: true)` でタイトルが AppBar のみになる（body 内に重複テキストなし）
- [ ] `UserProfileSetupScreen(isEditing: false)`（オンボーディング）では説明テキストが引き続き表示される

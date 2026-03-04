# 親プロフィール編集機能

## 概要

タイムライン画面ヘッダー右上のアバターアイコンをタップすることで、親（ユーザー）プロフィールの編集画面へ遷移できる機能。

## 画面フロー

```
TimelineScreen（ヘッダー右上アバタータップ）
  └── UserProfileSetupScreen(isEditing: true)
        └── 更新保存 → pop して TimelineScreen へ戻る
```

## 変更ファイル

| ファイル                                                             | 変更内容                                                         |
| -------------------------------------------------------------------- | ---------------------------------------------------------------- |
| `lib/presentation/widgets/timeline_header.dart`                      | アバターを `GestureDetector` でラップ、タップで編集画面へ遷移    |
| `lib/presentation/screens/onboarding/user_profile_setup_screen.dart` | 編集時に `updateProfile` を使用（既存 `id`・`createdAt` を保持） |
| `lib/domain/entities/user.dart`                                      | `copyWith` メソッド追加                                          |

## 編集時の保存ロジック

- `isEditing: true` の場合、`userProfileProvider` から現在の `User` を取得
- `copyWith(name:, photoPath:)` で新しいインスタンスを生成
- `updateProfile(user)` で保存（UUID・作成日時は変わらない）

## エッジケース

| ケース                         | 挙動                                                           |
| ------------------------------ | -------------------------------------------------------------- |
| 写真を変更しない               | 既存の `photoPath` をそのまま `copyWith` に渡す                |
| 写真を削除した場合             | `_photoPath = null` → `copyWith(photoPath: null)` で null 保存 |
| 編集画面から戻った後のヘッダー | `userProfileProvider` を `watch` しているため自動更新          |

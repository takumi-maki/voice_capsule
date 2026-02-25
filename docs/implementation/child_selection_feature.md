# 子供複数選択機能 詳細設計書

## 要件整理

### 機能概要

兄弟がいる場合に、複数の子供を選択して録音を紐付けられるようにする。

### 現状の課題

- 現在は単一の子供プロフィールのみ対応
- 兄弟がいる場合に複数の子供に同じ録音を紐付けられない

### 実装方針

#### 影響するレイヤー

- **domain層**：
  - Recording エンティティの変更（childId → childIds）
  - ChildProfile エンティティ（既存）

- **application層**：
  - child_profile_provider の拡張（複数選択対応）
  - recording_provider の変更（複数ID保存対応）

- **infrastructure層**：
  - child_profile_repository の拡張（複数取得）
  - recording_repository の変更（複数ID対応）

- **presentation層**：
  - 子供選択画面の新規作成
  - 録音保存フローへの組み込み

#### 新規作成ファイル

```
lib/presentation/
  └── screens/
      └── child_selection_screen.dart

lib/application/
  └── providers/
      └── selected_children_provider.dart
```

#### 修正が必要な既存ファイル

- `lib/domain/entities/recording.dart`（childId → childIds）
- `lib/application/providers/recording_provider.dart`
- `lib/infrastructure/repositories/recording_repository.dart`
- `lib/presentation/screens/save_recording_screen.dart`

#### 使用する依存パッケージ

- flutter_riverpod（既存）
- shared_preferences（既存）

#### 状態管理への影響

- `selectedChildrenProvider`：選択中の子供IDリストを管理
- 既存の `childProfileProvider` は維持

### UI設計

#### 子供選択画面

```
┌─────────────────────────┐
│  ← Select Children      │
├─────────────────────────┤
│                         │
│  ┌─────┐  ┌─────┐      │
│  │ ✓   │  │     │      │
│  │ 👦  │  │ 👧  │      │
│  │太郎 │  │花子 │      │
│  └─────┘  └─────┘      │
│                         │
│  [Continue]             │
└─────────────────────────┘
```

- 複数選択可能なカード形式
- 選択状態はチェックマーク表示
- 最低1人は選択必須

### データ構造の変更

#### Recording エンティティ（変更前）

```dart
class Recording {
  final String childId;  // 単一ID
}
```

#### Recording エンティティ（変更後）

```dart
class Recording {
  final List<String> childIds;  // 複数ID対応
}
```

### 想定されるリスクとエッジケース

1. **既存データの移行**：childId → childIds への変換が必要
2. **子供が1人の場合**：選択画面をスキップするか表示するか
3. **全員選択の場合**：「全員」ボタンの追加を検討
4. **削除時の整合性**：子供を削除した場合の録音データの扱い

### 実装の流れ

1. **domain層の変更**
   - Recording エンティティの childIds 対応
   - マイグレーション処理の実装

2. **infrastructure層の変更**
   - Repository での複数ID保存・取得

3. **application層の実装**
   - selectedChildrenProvider の作成
   - recording_provider の更新

4. **presentation層の実装**
   - ChildSelectionScreen の作成
   - SaveRecordingScreen への組み込み

5. **既存データの移行**
   - 起動時に childId → childIds 変換

## 確定事項

1. 子供が1人の場合：デフォルト選択（選択画面は表示しない）。複数登録がある場合のみ選択UIを表示
2. 既存の録音データ：自動移行する（childId → childIds[childId]）
3. タイムライン表示：録音カードのサムネイル背景画像の右下に子供のアバターアイコンを表示

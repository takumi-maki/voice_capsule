# ユーザープロフィール & 子供複数登録 設計書

## 1. 基本設計

### 1.1 現状分析

#### 現在の実装

| 項目 | 状態 | 詳細 |
|------|------|------|
| 親（ユーザー）プロフィール | ❌ 未実装 | Entity・Provider・Repository なし |
| 子供プロフィール（単一） | ✅ 実装済み | `Child` エンティティ、SharedPreferences 永続化 |
| 子供プロフィール（複数） | ⚠️ バックエンドのみ | `getAllProfiles()` 実装済み、UI未実装 |
| タイムラインヘッダー右上 | ⚠️ 子供アバター表示 | 本来は自分（親）のアバターにしたい |
| 録音と子供の紐付け | ✅ 実装済み | `Recording.childIds: List<String>` |
| ボトムナビゲーション | ⚠️ 3タブ | RECORD / MEMORIES / SETTINGS |
| Familyタブ | ❌ 未実装 | 子供管理画面なし |
| アクティブ子供フィルター | ❌ 未実装 | タイムラインのフィルタリングなし |

#### 問題の根本原因

- 「自分（親）」のプロフィールという概念がなく、子供プロフィールで代用している
- タイムラインヘッダーの右上アイコンが子供のアバターになっている
- 複数子供の登録・管理UIが未実装
- ボトムナビゲーションが3タブで、Familyタブがない

### 1.2 要件定義

#### 機能要件

| ID | 要件 | 優先度 |
|----|------|--------|
| FR-01 | 親（ユーザー）自身のプロフィール（名前・写真）を登録できる | 必須 |
| FR-02 | タイムラインヘッダー右上に親のアバターを表示する | 必須 |
| FR-03 | 子供を複数登録・編集・削除できる | 必須 |
| FR-04 | 録音時に紐付ける子供を選択できる（既存機能の活用） | 必須 |
| FR-05 | オンボーディングで親プロフィールを最初に設定する | 必須 |
| FR-06 | ボトムナビゲーションを4タブに変更する | 必須 |
| FR-07 | Familyタブで子供一覧・追加・削除ができる | 必須 |
| FR-08 | Familyタブでアクティブな子供を選択できる | 必須 |
| FR-09 | タイムラインをアクティブな子供でフィルタリングできる | 必須 |

### 1.3 新しいデータモデル

#### 親（ユーザー）エンティティ
```
User {
  id: String
  name: String
  photoPath: String?
  createdAt: DateTime
  initials: String (getter)
}
```

#### 子供エンティティ（既存 Child を流用）
```
Child {
  id: String
  name: String
  photoPath: String?
  createdAt: DateTime
}
```

### 1.4 ボトムナビゲーション変更

```
現在: RECORD / MEMORIES / SETTINGS（3タブ）
変更後: Home / Capsules / Family / Settings（4タブ）

Home     → タイムライン画面（既存 MEMORIES）
Capsules → 録音画面（既存 RECORD）
Family   → ファミリー管理画面（新規）
Settings → 設定画面（既存）
```

### 1.5 画面フロー

```
初回起動
  └── オンボーディング
        ├── Step 1: 親プロフィール設定（名前・写真）← 新規
        └── Step 2: 子供プロフィール設定（名前・写真）← 既存を流用

メイン画面（4タブ）
  ├── Home（タイムライン）← アクティブ子供でフィルタリング
  ├── Capsules（録音）
  ├── Family（子供管理）← 新規
  └── Settings（設定）

タイムラインヘッダー右上：親のアバター ← 変更
```

---

## 2. 詳細設計

### 2.1 影響するレイヤー

| レイヤー | 影響 | 内容 |
|----------|------|------|
| domain | 新規追加 | `User` エンティティ、`UserRepository` インターフェース |
| infrastructure | 新規追加 | `UserRepositoryImpl`（SharedPreferences） |
| application | 新規追加 | `userProfileProvider`、`activeChildProvider` |
| presentation | 新規・修正 | ボトムナビ、Familyタブ、オンボーディング、ヘッダー |

### 2.2 フェーズ分割

#### Phase 1: ボトムナビ4タブ化 + Familyタブ（子供管理）
#### Phase 2: 親プロフィール + ヘッダー変更 + オンボーディング
#### Phase 3: アクティブ子供選択 + タイムラインフィルタリング

---

## 3. Phase 1 詳細設計

### 3.1 新規作成ファイル

```
lib/presentation/screens/
  family_screen.dart    ← Familyタブ画面
```

### 3.2 修正が必要な既存ファイル

| ファイル | 変更内容 |
|----------|----------|
| `lib/presentation/screens/main_screen.dart` | 4タブ化（Home/Capsules/Family/Settings） |

### 3.3 Family画面 UIデザイン

```
┌─────────────────────────────────┐
│  ← Family Members               │
│                                 │
│  ┌─────────────────────────┐    │
│  │ 🧒 Hana                 │    │
│  │    Active Profile    ✅  │    │
│  └─────────────────────────┘    │
│  ┌─────────────────────────┐    │
│  │ 🧒 Haru                 │    │
│  │    Tap to select     ○  │    │
│  └─────────────────────────┘    │
│                                 │
│  ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐    │
│  │  + Add Child            │    │
│  └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘    │
│                                 │
│  Selecting a child will         │
│  customize the VoiceCapsule     │
│  experience...                  │
│                                 │
│  [    Save Selection    ]       │
│                                 │
│ [Home][Capsules][Family][Settings]│
└─────────────────────────────────┘
```

#### 各要素の仕様

**子供リスト（カード形式）**
- アバター（左）+ 名前（太字）+ サブテキスト（右）
- アクティブ：「Active Profile」+ オレンジチェックマーク
- 非アクティブ：「Tap to select」+ グレーラジオボタン
- カード角丸：16px

**「+ Add Child」ボタン**
- 破線枠、オレンジテキスト・アイコン
- タップ → `ChildProfileSetupScreen` へ遷移

**説明文**
- 「Selecting a child will customize the VoiceCapsule experience and organize voice recordings for their specific profile.」

**Save Selectionボタン**
- 全幅、オレンジ、角丸24px
- ボトムナビの上に固定

### 3.4 状態管理への影響（Phase 1）

- 既存の `childProfileProvider` を使用
- 新規プロバイダーなし（Phase 3で追加）

### 3.5 想定されるリスクとエッジケース（Phase 1）

| リスク | 対策 |
|--------|------|
| 子供が0人の場合 | 「+ Add Child」のみ表示 |
| 録音中にFamilyタブへ切り替え | 既存の警告ダイアログを流用 |
| タブ数増加によるUI崩れ | `BottomNavigationBarType.fixed` で対応 |

---

## 4. Phase 2 詳細設計

### 4.1 新規作成ファイル

```
lib/
  domain/
    entities/user.dart
    repositories/user_repository.dart
  infrastructure/
    repositories/user_repository_impl.dart
  application/
    providers/user_profile_provider.dart
  presentation/
    screens/
      onboarding/user_profile_setup_screen.dart
```

### 4.2 修正が必要な既存ファイル

| ファイル | 変更内容 |
|----------|----------|
| `lib/main.dart` | AppInitializerに親プロフィール未設定チェック追加 |
| `lib/presentation/widgets/timeline_header.dart` | 右上アイコンを親アバターに変更 |
| `lib/presentation/screens/settings_screen.dart` | 「自分のプロフィール編集」メニュー追加 |

### 4.3 AppInitializer フロー

```
1. userProfileProvider が null → UserProfileSetupScreen
2. childProfileProvider が null → ChildProfileSetupScreen
3. 両方あり → MainScreen
```

### 4.4 永続化キー一覧

| キー | 内容 |
|------|------|
| `user_profile` | 親プロフィール（新規） |
| `child_profile` | 子供プロフィール（既存・単一） |
| `child_profiles` | 子供プロフィール（既存・複数） |

---

## 5. Phase 3 詳細設計

### 5.1 新規作成ファイル

```
lib/application/providers/active_child_provider.dart
```

### 5.2 修正が必要な既存ファイル

| ファイル | 変更内容 |
|----------|----------|
| `lib/presentation/screens/family_screen.dart` | Save Selectionでアクティブ子供を保存 |
| `lib/presentation/screens/timeline_screen.dart` | アクティブ子供でフィルタリング |

### 5.3 activeChildProvider 設計

```
ActiveChildNotifier extends StateNotifier<String?>
  - _loadActiveChildId()       ← SharedPreferencesから読み込み
  - setActiveChild(String id)  ← 選択・永続化
  - clearActiveChild()         ← 全件表示に戻す

activeChildProvider: StateNotifierProvider<ActiveChildNotifier, String?>
```

- SharedPreferences キー: `active_child_id`
- null = 全件表示

### 5.4 タイムラインフィルタリング

```
TimelineScreen:
  activeChildId = ref.watch(activeChildProvider)
  recordings = ref.watch(recordingListProvider)

  表示対象:
    activeChildId == null → 全件表示
    activeChildId != null → recording.childIds.contains(activeChildId) のみ表示
```

### 5.5 想定されるリスクとエッジケース（Phase 3）

| リスク | 対策 |
|--------|------|
| アクティブ子供が削除された場合 | `activeChildProvider` を null にリセット |
| アクティブ子供に録音が0件の場合 | 空状態UI表示（「この子供の録音はまだありません」） |
| 子供未登録の場合 | 全件表示（activeChildId = null） |

---

## 6. メンバー選択画面 詳細設計（録音保存時）

### 6.1 現状

`ChildSelectionScreen` が既に存在するが、シンプルなグリッド表示のみ。
`SaveRecordingScreen` から遷移する形で使用されている。

### 6.2 新しいUIデザイン

```
┌─────────────────────────────────┐
│  ← Multi-Member Selection       │
│                                 │
│  Who is in this memory?         │
│  Select one or more family      │
│  members                        │
│                                 │
│  [✓][✓][ ][ ]  ← アバター横並び  │
│                                 │
│     ┌──────────────────┐        │
│     │  選択中メンバーの  │        │
│     │  重なりアバター表示│        │
│     └──────────────────┘        │
│                                 │
│  👥 GROUP MEMORY                │
│  2 Selected                     │
│  These members will be          │
│  associated with the recording  │
│  and indexed in the archive.    │
│                                 │
│  [        Save        ]         │
│                                 │
│  PARTICIPANTS CAN BE EDITED     │
│  LATER IN MEMORY DETAILS        │
└─────────────────────────────────┘
```

### 6.3 修正が必要な既存ファイル

| ファイル | 変更内容 |
|----------|----------|
| `lib/presentation/screens/child_selection_screen.dart` | UIを全面リニューアル |

### 6.4 重なりアバター表示の実装方針

```
選択数に応じた表示:
- 0人: 空のプレースホルダー
- 1人: 中央に大きなアバター（120px）
- 2人: Stack で右にオフセット（左: -30px, 右: +30px）
- 3人以上: 最初の2人を重ねて表示 + 「+N」バッジ
```

### 6.5 想定されるリスクとエッジケース

| リスク | 対策 |
|--------|------|
| メンバーが1人しかいない場合 | SOLO MEMORY として表示 |
| メンバーが多い場合（5人以上） | 横スクロール対応 |
| 全員選択解除 | Saveボタンを非活性化 |
| アバター画像なし | イニシャル表示（既存の `ChildAvatar` を踏襲） |

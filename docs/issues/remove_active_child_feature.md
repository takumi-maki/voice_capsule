# Family Members画面のアクティブ機能を削除・画面整理

## 背景

現在の Family Members 画面は「アクティブな子どもを選択する」という機能を持っているが、UXが複雑でごちゃごちゃしている。この機能を削除し、シンプルな子どもプロフィール管理画面として整理する。
また Timeline の絞り込みは、フィルターチップ（全員デフォルト選択）に置き換える。

## 現状の問題

```
┌────────────────────────────────┐
│  Family Members                │
│                                │
│  ┌──────────────────────────┐  │  ← アクティブ時: primary色ボーダー
│  │ 👶 Takumi                │  │
│  │    Active Profile ✓      │  │  ← "Active Profile" / "Tap to select"
│  │              ✏️  🗑        │  │  ← check_circle / radio_button_unchecked
│  └──────────────────────────┘  │
│                                │
│  Selecting a child will...     │  ← 説明テキスト
│  + Add Child                   │
│                                │
│  ┌──────────────────────────┐  │  ← Save Selection ボタン（常時表示）
│  │     Save Selection       │  │
│  └──────────────────────────┘  │
└────────────────────────────────┘
```

## 変更内容

### 1. Family Members 画面の整理

**削除するUI要素:**
- カードの選択状態ボーダー（`isActive` 時の primary border）
- subtitle の "Active Profile" / "Tap to select" テキスト
- trailing の `check_circle` / `radio_button_unchecked` アイコン
- 「Save Selection」ボタン
- 説明テキスト（"Selecting a child will customize..."）

**削除するロジック:**
- `_selectedChildId` State変数
- `onTap: () => setState(() => _selectedChildId = child.id)`
- `_saveSelection()` メソッド
- `activeChildProvider` の参照（import 含む）

**目指すUI:**

```
┌────────────────────────────────┐
│  Family Members                │
│                                │
│  ┌──────────────────────────┐  │
│  │ 👶 Takumi                │  │  ← シンプルなカード（選択UI なし）
│  │                ✏️  🗑     │  │  ← 編集・削除のみ
│  └──────────────────────────┘  │
│                                │
│  + Add Child                   │
└────────────────────────────────┘
```

### 2. Timeline のフィルタリングをフィルターチップに置き換え

現在の `activeChildProvider` による絞り込みを廃止し、Timeline 画面の Free Version Banner の直下にフィルターチップを追加する。

**仕様:**
- デフォルトは全員表示（チップ未選択）
- 子どもごとのチップを横スクロールで表示（「全員」チップは不要）
- チップをタップすると絞り込み（その子のみ表示）
- 選択中のチップをもう一度タップすると解除 → 全員表示に戻る
- 状態は画面内ローカルState（永続化なし）
- 子どもが1人以下の場合はチップ行自体を非表示

**目指すUI:**

```
┌────────────────────────────────┐
│  Home              （Header）  │
│ ┌────────────────────────────┐ │
│ │  Free Version Banner       │ │
│ └────────────────────────────┘ │
│  [👶 Takumi] [👧 Hana]          │  ← Free Version Banner 直下
│                                │
│  ┌──────────────────────────┐  │
│  │  録音カード              │  │
│  └──────────────────────────┘  │
└────────────────────────────────┘
```

## 影響範囲

| レイヤー | ファイル | 変更内容 |
|---------|---------|---------|
| presentation | `lib/presentation/screens/family_screen.dart` | アクティブUI・ロジックを全削除 |
| presentation | `lib/presentation/screens/timeline_screen.dart` | フィルターチップ追加、`activeChildProvider` 削除 |
| application | `lib/application/providers/active_child_provider.dart` | ファイルごと削除 |

## 新規作成ファイル

なし（`TimelineScreen` 内のローカルStateで管理）

## 削除ファイル

- `lib/application/providers/active_child_provider.dart`

## リスク・エッジケース

- 子どもが1人の場合: チップ行を非表示（全録音を常に表示）
- 子どもが0人の場合: チップ行を非表示、録音も空状態メッセージを表示（既存動作と同じ）

# 場所選択画面リデザイン 詳細設計書

## 要件整理

### 機能概要

「録音を保存」画面の場所選択UIを、添付画像のようなカード形式のデザインに変更する。

### 現状の課題

- 現在の場所選択画面がシンプルすぎる
- 視覚的な魅力が不足している

### 実装方針

#### 影響するレイヤー

- **presentation層**：
  - BackgroundSelectionScreen の全面リニューアル
  - SaveRecordingScreen の UI 調整

- **application層**：
  - 変更なし

- **domain層**：
  - 変更なし

- **infrastructure層**：
  - 変更なし

#### 新規作成ファイル

```
lib/presentation/
  └── screens/
      └── background_selection/
          └── widgets/
              ├── scene_card.dart
              └── scene_preview.dart
```

#### 修正が必要な既存ファイル

- `lib/presentation/screens/background_selection_screen.dart`（全面書き換え）
- `lib/presentation/screens/save_recording_screen.dart`（遷移方法の変更）

#### 使用する依存パッケージ

- flutter_riverpod（既存）
- 画像アセットの追加が必要

#### 状態管理への影響

- 既存の状態管理をそのまま使用
- 新規プロバイダーは不要

### UI設計（添付画像を参考）

#### 場所選択画面

```
┌─────────────────────────────────┐
│  ← ENVIRONMENT    Step 2 of 3  ?│
├─────────────────────────────────┤
│                                 │
│  Choose a scene                 │
│  Where does this memory live?   │
│                                 │
│  ┌─────┐ ┌─────┐ ┌─────┐      │
│  │     │ │     │ │  ✓  │      │
│  │🏠   │ │🚗   │ │🌳   │      │
│  │HOUSE│ │ CAR │ │PARK │      │
│  └─────┘ └─────┘ └─────┘      │
│                                 │
│  ┌─────────────────────────┐   │
│  │                         │   │
│  │    🌳 プレビュー画像    │   │
│  │       👦                │   │
│  │   PREVIEW MODE          │   │
│  └─────────────────────────┘   │
│                                 │
│  [Confirm Selection ✓]          │
└─────────────────────────────────┘
```

### デザイン仕様

#### ヘッダー

- 左：戻るボタン
- 中央：「ENVIRONMENT」+ 「Step 2 of 3」
- 右：ヘルプボタン（?）

#### タイトルセクション

- 大見出し：「Choose a scene」
- 小見出し：「Where does this memory live?」

#### 場所カード（3つ横並び）

- サイズ：正方形、角丸16px
- 内容：実際の写真またはイラスト
- ラベル：HOUSE / CAR / PARK
- 選択状態：オレンジの枠線 + チェックマーク

#### プレビューエリア

- 選択した場所の大きな画像
- 子供のアバター表示
- 「PREVIEW MODE」ラベル
- 角丸16px

#### 確認ボタン

- 「Confirm Selection」+ チェックマークアイコン
- オレンジ背景、白文字
- 角丸24px
- 画面下部に固定

### アセット要件

#### 必要な画像

```
assets/images/scenes/
  ├── house.jpg      # リビングルームの写真
  ├── car.jpg        # 車内の写真
  └── park.jpg       # 公園の写真
```

または、既存のアイコンベースのデザインを維持する場合：

- 背景色 + 大きなアイコンで対応

### 実装詳細

#### SceneCard ウィジェット

```dart
class SceneCard extends StatelessWidget {
  final BackgroundType type;
  final bool isSelected;
  final VoidCallback onTap;

  // カード形式のUI
  // 選択状態で枠線とチェックマーク表示
}
```

#### ScenePreview ウィジェット

```dart
class ScenePreview extends ConsumerWidget {
  final BackgroundType selectedType;

  // 大きなプレビュー画像
  // 子供のアバター重ね表示
  // PREVIEW MODE ラベル
}
```

### 想定されるリスクとエッジケース

1. **画像アセット**：実際の写真を用意するか、イラストで対応するか
2. **ファイルサイズ**：高解像度画像でAPKサイズが増加
3. **ローディング**：画像読み込み中の表示
4. **アクセシビリティ**：画像に代替テキストが必要

### 実装の流れ

1. **アセットの準備**
   - 場所ごとの画像を用意（または既存アイコンで対応）
   - pubspec.yaml に追加

2. **SceneCard ウィジェットの作成**
   - カード形式のUI
   - 選択状態の表示

3. **ScenePreview ウィジェットの作成**
   - プレビュー画像
   - アバター重ね表示

4. **BackgroundSelectionScreen の書き換え**
   - 新しいレイアウト
   - ヘッダー追加
   - 各ウィジェットの組み込み

5. **SaveRecordingScreen の調整**
   - 遷移方法の確認
   - Step 表示の追加（オプション）

## 確定事項

1. 場所の画像：一旦アイコンベースで対応（背景色 + アイコン）
2. 「Step 2 of 3」表示：不要（省略）
3. ヘルプボタン：不要（省略）
4. プレビューエリアの子供アバター：必須。中央ではなく右下に配置
5. 「PREVIEW MODE」ラベル：表示する

### UI設計（更新版）

#### ヘッダー

- 左：戻るボタン
- 中央：「ENVIRONMENT」

#### 場所選択画面

```
┌─────────────────────────────────┐
│  ←      ENVIRONMENT             │
├─────────────────────────────────┤
│                                 │
│  Choose a scene                 │
│  Where does this memory live?   │
│                                 │
│  ┌─────┐ ┌─────┐ ┌─────┐      │
│  │ 🏠  │ │ 🚗  │ │ ✓🌳│      │
│  │HOUSE│ │ CAR │ │PARK │      │
│  └─────┘ └─────┘ └─────┘      │
│                                 │
│  ┌─────────────────────────┐   │
│  │                         │   │
│  │    🌳 プレビュー        │   │
│  │              👦（右下） │   │
│  │   PREVIEW MODE          │   │
│  └─────────────────────────┘   │
│                                 │
│  [Confirm Selection ✓]          │
└─────────────────────────────────┘
```

5. 「PREVIEW MODE」ラベルは必要ですか？

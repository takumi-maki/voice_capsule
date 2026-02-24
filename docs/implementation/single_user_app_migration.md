# VoiceCapsule 1人専用アプリ化 実装方針

## 確定した要件

1. ✅ `image_picker` パッケージ追加許可
2. ✅ 既存データは削除（マイグレーション不要）
3. ✅ 写真未設定時はイニシャル表示
4. ✅ タイトルフィールドは必須
5. ✅ 背景（場所）は選択式で残す
6. ✅ 保存画面: タイトル入力 + 場所選択
7. ✅ 一覧画面: タイトル + 場所 + 日時を表示

---

## 1. 影響するレイヤー

### domain層

- `Recording` エンティティの変更
- 新規エンティティ `Child` の追加
- `BackgroundType` は残す（場所として使用）

### application層

- `RecordingProvider` の `saveRecording` メソッド変更
- 新規 `ChildProfileProvider` の追加
- `RecordingListProvider` のデータクリア処理追加

### infrastructure層

- 新規 `ChildProfileRepository` の追加
- 写真保存処理の実装
- 既存録音データの削除処理

### presentation層

- 初回起動画面の追加
- キャラクター選択画面の削除
- 保存画面の変更（タイトル入力 + 場所選択）
- 一覧画面の表示変更

---

## 2. 削除する既存機能

### 削除するファイル

1. `lib/presentation/screens/character_selection_screen.dart`

### 削除するコード

1. `lib/domain/entities/recording.dart`
   - `CharacterType` enum のみ削除
   - `BackgroundType` は残す（場所として使用）
   - `Recording.character` フィールド削除

2. `lib/application/providers/recording_provider.dart`
   - `saveRecording()` の `character` パラメータ削除

3. `lib/presentation/screens/save_recording_screen.dart`
   - キャラクター選択UI削除
   - 背景選択UIは残す（場所として）

### 削除するデータ

- SharedPreferences の既存録音データをクリア

---

## 3. 新規追加する機能

### 初回起動時

1. 子どもの名前入力（必須）
2. 子どもの写真撮影/選択（オプション）
3. プロフィール保存

### 録音保存時

1. タイトル入力（必須）
2. 場所選択（必須、既存の BackgroundType を使用）
3. 自動的に子どもに紐づけて保存

### タイムライン表示

1. 子どもの写真 or イニシャルをアイコンとして表示
2. タイトル + 場所 + 日時を表示

---

## 4. 新規作成ファイル一覧

### domain層

```
lib/domain/entities/child.dart
lib/domain/repositories/child_profile_repository.dart
```

### application層

```
lib/application/providers/child_profile_provider.dart
```

### infrastructure層

```
lib/infrastructure/repositories/child_profile_repository_impl.dart
```

### presentation層

```
lib/presentation/screens/onboarding/child_profile_setup_screen.dart
lib/presentation/widgets/child_avatar.dart
```

---

## 5. 修正が必要な既存ファイル

### domain層

1. `lib/domain/entities/recording.dart`
   - `CharacterType` enum 削除
   - `BackgroundType` enum は残す（場所として）
   - `character` フィールド削除
   - `title` フィールド追加（必須）
   - `childId` フィールド追加

### application層

1. `lib/application/providers/recording_provider.dart`
   - `saveRecording()` メソッド変更
     - `character` パラメータ削除
     - `title` パラメータ追加
     - `childId` を自動取得

2. `lib/application/providers/recording_list_provider.dart`
   - 既存データクリア処理追加
   - 永続化ロジックの調整

### presentation層

1. `lib/presentation/screens/save_recording_screen.dart`
   - キャラクター選択UI削除
   - タイトル入力UI追加
   - 背景選択を「場所選択」に名称変更
   - バリデーション追加（タイトル必須）

2. `lib/presentation/screens/background_selection_screen.dart`
   - タイトルを「場所を選択」に変更
   - UI調整（場所として適切な表現に）

3. `lib/presentation/screens/timeline_screen.dart`
   - キャラクターアイコン → 子どもの写真/イニシャル
   - 表示内容変更: タイトル + 場所 + 日時

4. `lib/main.dart`
   - 初回起動判定ロジック追加
   - プロフィール未設定時はオンボーディング画面へ遷移
   - 既存データクリア処理

---

## 6. データモデル変更点

### 新規エンティティ: Child

```dart
class Child {
  final String id;
  final String name;           // 必須
  final String? photoPath;     // オプション（nullの場合はイニシャル表示）
  final DateTime createdAt;

  // イニシャル取得用ヘルパー
  String get initials {
    if (name.isEmpty) return '?';
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
```

### 変更エンティティ: Recording

```dart
class Recording {
  final String id;
  final String filePath;
  final DateTime createdAt;
  final String title;              // 新規追加（必須）
  final BackgroundType location;   // 名称変更: background → location
  final String childId;            // 新規追加
  final int duration;

  // character フィールドは削除
}
```

### 削除: CharacterType enum

```dart
// 完全に削除
```

### 保持: BackgroundType enum（場所として使用）

```dart
enum BackgroundType {
  house,   // 家
  car,     // 車
  park,    // 公園
}
```

---

## 7. 永続化設計

### 子どもプロフィール保存

- **保存先**: `shared_preferences`
- **キー**: `child_profile`
- **データ構造**:

```json
{
  "id": "uuid",
  "name": "太郎",
  "photo_path": "/path/to/photo.jpg",
  "created_at": "2024-01-01T00:00:00.000Z"
}
```

### 写真保存

- **保存先**: `{ApplicationDocumentsDirectory}/child_profile/photo.jpg`
- **形式**: JPEG
- **サイズ**: リサイズ処理（例: 512x512）

### 録音データ保存

- **保存先**: `shared_preferences`（既存と同じ）
- **キー**: `recordings`
- **データ構造**:

```json
[
  {
    "id": "uuid",
    "file_path": "/path/to/recording.aac",
    "created_at": "2024-01-01T00:00:00.000Z",
    "title": "朝のあいさつ",
    "location": "house",
    "child_id": "child_uuid",
    "duration": 0
  }
]
```

### 既存データクリア

- アプリ起動時に `recordings` キーをクリア
- バージョン管理フラグで1回のみ実行

---

## 8. 必要なパーミッション

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSCameraUsageDescription</key>
<string>お子様の写真を撮影するためにカメラを使用します</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>お子様の写真を選択するためにフォトライブラリにアクセスします</string>
```

### パッケージ追加

```yaml
dependencies:
  image_picker: ^1.0.0
```

---

## 9. 想定されるエッジケース

### 初回起動時

1. **名前が未入力の場合**
   - バリデーションエラー表示
   - 「名前を入力してください」

2. **写真選択をスキップした場合**
   - イニシャル表示で進行
   - 後から設定画面で変更可能

3. **カメラ/フォトライブラリ権限が拒否された場合**
   - イニシャル表示で進行
   - 「設定から権限を許可してください」メッセージ表示

4. **写真選択中にキャンセルした場合**
   - イニシャル表示で進行

### 録音保存時

1. **タイトルが未入力の場合**
   - バリデーションエラー表示
   - 「タイトルを入力してください」

2. **場所が未選択の場合**
   - デフォルト値（house）を使用

3. **プロフィール未設定状態で録音した場合**
   - オンボーディング画面へ強制遷移
   - 録音データは一時保存

### データ表示時

1. **写真ファイルが削除された場合**
   - イニシャル表示にフォールバック

2. **名前が空文字の場合**
   - 「?」を表示

3. **タイトルが長すぎる場合**
   - 省略表示（...）

---

## 10. 実装ステップ順

### Phase 1: 準備（既存データクリア）

1. `main.dart` に既存データクリア処理追加
2. バージョン管理フラグ実装

### Phase 2: データモデル変更

1. `Child` エンティティ作成
2. `Recording` エンティティ変更
   - `CharacterType` 削除
   - `character` フィールド削除
   - `title` フィールド追加
   - `childId` フィールド追加
   - `background` → `location` に名称変更

### Phase 3: Infrastructure層

1. `ChildProfileRepository` インターフェース作成
2. `ChildProfileRepositoryImpl` 実装
   - SharedPreferences での永続化
   - 写真ファイル保存処理
   - `image_picker` 統合

### Phase 4: Application層

1. `ChildProfileProvider` 作成
   - プロフィール読み込み
   - プロフィール保存
   - 初回起動判定
   - 写真選択/撮影処理
2. `RecordingProvider.saveRecording()` 修正
   - `character` パラメータ削除
   - `title` パラメータ追加
   - `childId` 自動取得

### Phase 5: Presentation層（削除）

1. `CharacterSelectionScreen` 削除

### Phase 6: Presentation層（新規）

1. `ChildAvatar` ウィジェット作成
   - 写真表示
   - イニシャル表示（フォールバック）
2. `ChildProfileSetupScreen` 作成
   - 名前入力
   - 写真選択/撮影
   - バリデーション

### Phase 7: Presentation層（修正）

1. `SaveRecordingScreen` 修正
   - キャラクター選択UI削除
   - タイトル入力UI追加
   - 「背景」→「場所」に名称変更
   - バリデーション追加

2. `BackgroundSelectionScreen` 修正
   - タイトル変更: 「場所を選択」
   - 説明文調整

3. `TimelineScreen` 修正
   - `ChildAvatar` ウィジェット使用
   - 表示内容変更: タイトル + 場所 + 日時

4. `main.dart` 修正
   - 初回起動判定
   - ルーティング変更

### Phase 8: テスト・調整

1. 初回起動フロー確認
2. 写真/イニシャル表示確認
3. タイトル・場所入力確認
4. 一覧画面表示確認
5. エラーハンドリング確認

---

## UI設計メモ

### ChildAvatar ウィジェット

```dart
// 写真がある場合: CircleAvatar with Image
// 写真がない場合: CircleAvatar with Text (イニシャル)
// サイズ: 40x40 (一覧), 80x80 (詳細)
// 背景色: theme.colorScheme.primary
// テキスト色: Colors.white
```

### ChildProfileSetupScreen

```
- タイトル: 「お子様のプロフィール」
- 名前入力フィールド（必須）
- 写真選択ボタン
  - 「カメラで撮影」
  - 「ギャラリーから選択」
  - 「スキップ」
- 保存ボタン
```

### SaveRecordingScreen

```
- タイトル: 「録音を保存」
- タイトル入力フィールド（必須）
- 場所選択（必須、既存UIを流用）
- 保存ボタン
```

### TimelineScreen

```
ListTile(
  leading: ChildAvatar(child: child),
  title: Text(recording.title),
  subtitle: Text('${recording.location.displayName} • ${formatDate(recording.createdAt)}'),
  trailing: PlayButton(),
)
```

---

## 実装状況

- [x] Phase 1: 準備
- [x] Phase 2: データモデル変更
- [x] Phase 3: Infrastructure層
- [x] Phase 4: Application層
- [x] Phase 5: Presentation層（削除）
- [x] Phase 6: Presentation層（新規）
- [x] Phase 7: Presentation層（修正）
- [ ] Phase 8: テスト・調整

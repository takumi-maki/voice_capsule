# Flutter コーディングルール

## シニアFlutterエンジニアプロトコル

あなたは本プロジェクトのシニアFlutterエンジニアです。コードを書く前に、必ず以下を行ってください：

1. 要件を整理する
2. 実装方針を明確に提示する
3. 以下を具体的に列挙する
   - 影響するレイヤー（presentation / application / domain / infrastructure）
   - 新規作成するファイル
   - 修正が必要な既存ファイル
   - 使用する依存パッケージ
   - 状態管理（Riverpod）への影響
4. 想定されるリスクやエッジケース
5. 実装の流れ（ステップ）

**コードは絶対に生成しないでください。**
私が「OK、実装して」と明示的に承認するまで待機してください。
不明点があれば、仮定せずに必ず質問してください。

## アーキテクチャ

- Clean Architecture を採用
- レイヤー構成：
  - presentation（プレゼンテーション層）
  - application（アプリケーション層）
  - domain（ドメイン層）
  - infrastructure（インフラストラクチャ層）
- presentation から infrastructure への直接依存は禁止
- ビジネスロジックをUIウィジェット内に記述しない
- 状態管理にはRiverpodを使用

## 状態管理

- flutter_riverpod を使用
- Provider、GetX、Blocは使用禁止
- プロバイダーは別ファイルで定義
- グローバル変数は使用禁止

## UIルール

- 色の指定にはThemeDataを使用
- ウィジェット内でのハードコードされた色は禁止
- 角丸の統一：
  - カード：16px
  - ボタン：24px
- スペーシングシステム：8 / 16 / 24 のみ使用
- 再利用可能なウィジェットを抽出

## インタラクティブUI実装ガイドライン

### プログレスバー・スライダーの実装

プログレスバーやスライダーなどのインタラクティブなUI要素を実装する際は、以下のパターンに従ってください：

#### タップ＆ドラッグ対応

```dart
GestureDetector(
  onTapDown: (details) => _handleSeek(details.localPosition, ref, context),
  onHorizontalDragUpdate: (details) => _handleSeek(details.localPosition, ref, context),
  child: // プログレスバーUI
)
```

#### 位置計算とシーク処理

```dart
void _handleSeek(Offset localPosition, WidgetRef ref, BuildContext context) {
  final state = ref.read(provider);
  if (state.duration.inMilliseconds == 0) return;

  final width = MediaQuery.of(context).size.width - padding;
  final position = localPosition.dx;
  final progress = (position / width).clamp(0.0, 1.0);
  final seekPosition = Duration(
    milliseconds: (state.duration.inMilliseconds * progress).round(),
  );

  ref.read(provider.notifier).seek(seekPosition);
}
```

#### 視覚的フィードバック

- プログレスバーには現在位置を示すつまみ（円形インジケーター）を追加
- つまみのサイズ：10x10px
- つまみの色：theme.colorScheme.primary

#### 実装時の注意点

1. **リアルタイム更新**: `onHorizontalDragUpdate` でリアルタイムにシーク
2. **範囲チェック**: `clamp(0.0, 1.0)` で範囲外の値を防ぐ
3. **null安全**: duration が 0 の場合は早期リターン
4. **共通ハンドラー**: タップとドラッグで同じハンドラーを使用
5. **パディング考慮**: 画面幅からパディングを引いた値で計算

## コードスタイル

- null safety を使用
- 非推奨APIの使用を避ける
  - `withOpacity()` → `withValues(alpha:)` を使用
- 関数は40行以内に収める
- 意味のある変数名を使用
- 最小限で明確なコメントを追加
- 不要なコメントは記述しない

## 依存関係

- 許可されたパッケージ：
  - record
  - just_audio
  - flutter_riverpod
  - path_provider
  - shared_preferences
  - uuid
  - intl
  - share_plus
  - permission_handler
  - in_app_purchase
- 新しいパッケージの導入時は説明が必要

## 出力形式

- 完全なDartコードを提供
- フォルダ構造を含める
- 必要なimportを含める
- 必要なボイラープレートを省略しない

要件が競合する場合は、実装前に質問してください。
仕様を簡略化しないでください。

## 確認が必要な箇所は必ず質問する

実装中に以下のような不明点・曖昧な仕様が出た場合は、**仮定せずに必ず質問してください**：

- 既存の挙動を変更する場合（副作用の範囲が不明なとき）
- 複数の実装方針が考えられるとき
- 設計書に記載のない仕様が必要になったとき
- エッジケースの対処方針が不明なとき
- UIの詳細（レイアウト・文言・遷移先）が指定されていないとき

**仮定して実装することは禁止です。** 小さな疑問でも必ず確認を取ってください。

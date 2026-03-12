issueドキュメントを読んで実装し、PRを作成する。

## 引数
$ARGUMENTS にはissueファイル名（拡張子なし）を渡す。例: `stats_screen_ui`

## 手順

### 1. issueドキュメントを読む
`docs/issues/$ARGUMENTS.md` を読む。
ファイルが存在しない場合はエラーを報告して終了。

### 2. 影響ファイルを読む
issueに記載された「修正ファイル」「新規作成ファイル」を全て読んで現状を把握する。
関連する既存ファイルも必要に応じて読む。

### 3. 不明点の確認
issueに「確認事項」がある場合は実装前にユーザーに確認する。
仮定して実装しない。

### 4. featureブランチを作成
ブランチ名は `feat/` + issueファイル名をケバブケースに変換したもの。
例: `stats_screen_ui` → `feat/stats-screen-ui`

```bash
git checkout -b feat/$ARGUMENTS
```

### 5. 実装する
CLAUDE.mdのルールを厳守して実装する：
- Clean Architecture のレイヤー依存を守る
- Riverpod のみ使用（Provider/GetX/Bloc禁止）
- 色は ThemeData 経由（ハードコード禁止）
- `withOpacity()` の代わりに `withValues(alpha:)` を使う
- 角丸: カード16px / ボタン24px
- スペーシング: 8 / 16 / 24 のみ
- 関数は40行以内

### 6. コンパイルチェック
```bash
flutter analyze 2>&1
```
エラーがあれば全て修正して再度analyzeを実行。エラーが0になるまで繰り返す。

### 7. コミット
変更ファイルをステージしてコミット。

### 8. PRを作成
```bash
gh pr create --base main --title "feat: [issue名]" --body "..."
```

PRのbodyには以下を含める：
- ## Summary（実装内容の箇条書き）
- ## 変更ファイル（新規/修正の一覧）
- ## Test plan（動作確認手順）
- 参照issue: `docs/issues/$ARGUMENTS.md`

### 9. PRのURLをユーザーに報告する

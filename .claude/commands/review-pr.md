PRのコードレビューを行い、CLAUDE.mdのルールに照らして承認または修正依頼を出す。

## 引数
$ARGUMENTS にはPR番号を渡す。例: `42`

## 手順

### 1. PRの情報を取得
```bash
gh pr view $ARGUMENTS
gh pr diff $ARGUMENTS
```

### 2. CLAUDE.mdを読む
`CLAUDE.md` を読んでレビュー基準を把握する。

### 3. 以下の観点でレビューする

#### アーキテクチャ
- [ ] presentation → infrastructure の直接依存がない
- [ ] ビジネスロジックがUIウィジェット内に書かれていない
- [ ] 適切なレイヤー（presentation / application / domain / infrastructure）に配置されている

#### 状態管理
- [ ] Riverpod のみ使用（Provider / GetX / Bloc は禁止）
- [ ] Provider定義が別ファイルにある
- [ ] グローバル変数を使っていない

#### UIルール
- [ ] 色の指定に ThemeData を使っている（ハードコードされた色がない）
- [ ] `withOpacity()` を使っていない（`withValues(alpha:)` を使う）
- [ ] カードの角丸が16px
- [ ] ボタンの角丸が24px
- [ ] スペーシングが 8 / 16 / 24 のみ

#### コードスタイル
- [ ] null safety を使っている
- [ ] 非推奨APIを使っていない
- [ ] 関数が40行以内
- [ ] 意味のある変数名

#### インタラクティブUI（該当する場合）
- [ ] プログレスバー/スライダーにタップ&ドラッグ対応がある
- [ ] `clamp(0.0, 1.0)` で範囲チェックしている

### 4. 判定

**問題なし → approve:**
```bash
gh pr review $ARGUMENTS --approve --body "LGTM ✅ CLAUDE.mdのルールに準拠しています。\n\n[良かった点を具体的に記載]"
```

**問題あり → changes requested:**
```bash
gh pr review $ARGUMENTS --request-changes --body "[問題点を箇条書きで具体的に記載]\n\n修正後に再レビューします。"
```

問題点は以下の形式で記載する：
- ファイルパスと行番号を明示
- 何が問題か
- どう修正すべきか（コード例があれば記載）

### 5. 結果をユーザーに報告する
- approve / changes requested のどちらだったか
- 主な指摘事項（changes requestedの場合）

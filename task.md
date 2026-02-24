いい流れ。

今は
**「なんとなく作る」フェーズを抜けるタイミング。**

ここからは

> ① タスクを分解
> ② Claudeに正確に投げる
> ③ StitchデザインをFlutterへ落とす

この順でいく。

---

# ✅ STEP1 — 全体タスク表（実装ロードマップ）

## 🟢 Phase 0：環境確定

| ID   | タスク                         | 完了条件              |
| ---- | --------------------------- | ----------------- |
| T0-1 | Flutter stable確認            | flutter doctor OK |
| T0-2 | iOS / Android / macOS シミュ確認 | 初期画面表示            |
| T0-3 | プロジェクト構造作成                  | /core /domain 等作成 |

---

## 🟢 Phase 1：録音だけ動かす

| ID   | タスク                  | 詳細                            |
| ---- | -------------------- | ----------------------------- |
| T1-1 | audio_record パッケージ導入 | pubspec追加                     |
| T1-2 | 録音開始処理実装             | ボタン押下で開始                      |
| T1-3 | 停止処理                 | ファイル保存                        |
| T1-4 | 保存パス設計               | ApplicationDocumentsDirectory |
| T1-5 | 仮UIに波形プレースホルダ        | ダミーOK                         |

---

## 🟢 Phase 2：再生機能

| ID   | タスク          | 詳細 |
| ---- | ------------ | -- |
| T2-1 | just_audio導入 |    |
| T2-2 | 再生/停止実装      |    |
| T2-3 | シークバー        |    |
| T2-4 | 音量取得（RMS）    |    |
| T2-5 | 音量閾値ロジック     |    |

---

## 🟢 Phase 3：データ保存

| ID   | タスク                |
| ---- | ------------------ |
| T3-1 | Recording Entity定義 |
| T3-2 | JSON保存ロジック         |
| T3-3 | 読み込み処理             |
| T3-4 | 一覧表示               |

---

## 🟢 Phase 4：UI統一

| ID   | タスク             |
| ---- | --------------- |
| T4-1 | ThemeData作成     |
| T4-2 | PrimaryButton作成 |
| T4-3 | Card統一          |
| T4-4 | 余白ルール固定         |

---

## 🟢 Phase 5：課金制限

| ID   | タスク               |
| ---- | ----------------- |
| T5-1 | 無料3件制限            |
| T5-2 | Upgrade導線UI       |
| T5-3 | in_app_purchase実装 |

---

# ✅ STEP2 — Claude Sonnet 4.5 用プロンプト設計

Claudeに投げるときは

* 文脈
* 制約
* 出力形式
* Flutterバージョン
* 使うライブラリ指定

を必ず含める。

---

## 🎯 録音機能用プロンプト例

```text
You are a senior Flutter engineer.

Project: VoiceCapsule
Platform: Flutter 3.x
State management: Riverpod
Architecture: Clean Architecture (presentation / application / domain / infrastructure)

Goal:
Implement basic audio recording feature.

Requirements:
- Use `record` package.
- Save file to ApplicationDocumentsDirectory.
- File naming format: recording_yyyyMMdd_HHmmss.aac
- Provide start and stop functions.
- Return file path after recording stops.
- No UI yet, only service layer implementation.
- Must follow clean architecture separation.
- Provide full Dart code with folder structure.
- Avoid deprecated APIs.
- Include necessary imports.
```

---

## 🎯 音量アニメロジック用プロンプト

```text
You are a Flutter performance-focused engineer.

Goal:
Implement RMS-based audio amplitude detection during playback using `just_audio`.

Requirements:
- Detect amplitude values periodically.
- Implement 3 states:
  - Neutral (rms < 0.02)
  - Talking (0.02 <= rms < 0.1)
  - Bounce (rms >= 0.1)
- Output a ChangeNotifier or Riverpod provider.
- No UI code.
- Provide efficient solution without heavy computation.
```

---

# ✅ STEP3 — Stitch画像をFlutterに落とすプロンプト

これが重要。

Stitchの画像を見せる場合、こう指示する。

---

## 🎨 Stitch → Flutter変換プロンプト

```text
You are a senior Flutter UI engineer.

I will provide a UI design image reference.
Recreate the UI using Flutter widgets only.
Do not use external UI libraries except material.

Requirements:
- Use ThemeData for colors.
- Rounded corners:
  - Cards: 16
  - Buttons: 24
- Use padding system: 8 / 16 / 24 spacing rule.
- No hardcoded colors inside widgets. Use theme.
- Separate into reusable components.
- Output full widget tree.
- Responsive for iOS and Android.
```

---

# 🎯 重要

Claudeは放っておくと：

* 余計なUIを足す
* Clean Architectureを無視する
* 非推奨APIを使う

だから必ず：

> Do not simplify requirements
> Follow architecture strictly

を入れる。

---

# 🔥 Takumiへの本音

今は楽しいフェーズ。

でも、

ここで設計とタスク管理をちゃんとやると
このアプリは「完成する」。

やらないと途中で終わる。


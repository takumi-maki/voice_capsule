# タイムライン画面のUIリデザイン

## 背景

現在のタイムライン画面は「子どもの感情の記録」というアプリの主役が視覚的に伝わらない。
具体的には：
- カードの大半を占める 160px の色付きサムネイルが主張しすぎ
- 感情情報（笑い・泣き・ポイント）がカードに表示されていない
- 「Listen Now」ボタンが重く、タイムライン閲覧の体験を妨げている
- 録音が日付ごとにグループ化されておらず、時系列把握が困難

## 決定事項

| 確認事項 | 決定 |
|---------|------|
| 波形方針 | A: `Recording` に `waveformBars` を保存（録音保存時に計算） |
| AudioEvent 0件 | `+0 pt` 表示 |
| Today Summary（0件時） | 表示する |
| 複数子どもアバター | 重ねて表示（最大2個） |

## 目標UI

```
┌────────────────────────────────────┐
│  TODAY SUMMARY                     │
│  ┌────────┐ ┌────────┐ ┌────────┐ │
│  │  😆 6  │ │  😭 2  │ │ +32 pt │ │
│  └────────┘ └────────┘ └────────┘ │
│                                    │
│  Today, Thursday, October 24       │
│                                    │
│  ┌──────────────────────────────┐  │
│  │ 10:23 AM             +13 pt  │  │
│  │ 👧 Iris                      │  │
│  │ 😆 😆 😭                    │  │
│  │  ~~~ waveform bars ~~~       │  │
│  │ 02:45                    ▶   │  │
│  └──────────────────────────────┘  │
└────────────────────────────────────┘
```

## 実装方針

### 1. Recording エンティティに waveformBars を追加

`lib/domain/entities/recording.dart`
- `List<double>? waveformBars` フィールドを追加
- `toJson` / `fromJson` を更新（既存データは `null` → `[]` にフォールバック）
- `copyWith` に `waveformBars` を追加

### 2. 録音保存時に waveform 計算を追加

`lib/application/providers/recording_provider.dart` の `saveRecording` を修正。
`Recording` 作成前に `AudioAnalyzer.extractAmplitudes(filePath, 60)` を呼び出し、
得られた bars を Recording に渡す。
（YAMNet の音声分析は引き続き fire-and-forget）

```
saveRecording の処理フロー:
1. extractAmplitudes でwaveformBars を計算（await）
2. Recording オブジェクトを waveformBars 付きで作成
3. addRecording でリストに追加・永続化
4. AnalyzeRecordingUseCase.execute を fire-and-forget
```

### 3. AudioEvents per-recording の FutureProvider.family を作成

`lib/application/providers/audio_events_by_recording_provider.dart` を新規作成。

```
audioEventsByRecordingProvider(recordingId) →
  AudioEventRepositoryImpl().getEventsByRecordingId(recordingId)
```

タイムラインカードがこのプロバイダーで感情イベントを取得する。

### 4. Today Summary プロバイダー + ウィジェットを作成

`lib/application/providers/today_summary_provider.dart` を新規作成。
`recordingListProvider` を参照し、今日の録音を抽出。
各録音の AudioEvents を `AudioEventRepositoryImpl` から非同期にまとめて取得。

`lib/presentation/widgets/today_summary_card.dart` を新規作成。
表示内容: 😆 N / 😭 N / +N pt の3列。

### 5. RecordingCard の完全リデザイン

`lib/presentation/widgets/recording_card.dart` を作り直す。

**新カード構成:**
```
Card (角丸16px、タップで PlaybackScreen へ)
└─ Padding(16)
   ├─ Row: 時刻テキスト (left) + ポイントバッジ (right)
   ├─ SizedBox(height: 8)
   ├─ Row: 子どもアバター重ね + 名前テキスト
   ├─ SizedBox(height: 8)
   ├─ Row: 感情絵文字リスト（events を map して 😆/😭）
   ├─ SizedBox(height: 8)
   ├─ WaveformBars（recording.waveformBars から描画）
   ├─ SizedBox(height: 8)
   └─ Row: 録音時間テキスト (left) + 再生アイコンボタン (right)
```

**感情絵文字**: `audioEventsByRecordingProvider` で取得、ロード中は空
**WaveformBars**: `recording.waveformBars` が空なら非表示
**子どもアバター**: `childProfileProvider` から名前解決、最大2個重ねて表示
**ポイント**: `events.length` pt（0件でも `+0 pt`）
**左側の CategoryIcon は削除**

### 6. TimelineScreen の日付グループ化

`lib/presentation/screens/timeline_screen.dart` を修正。

録音リストを `createdAt` の日付でグループ化し、flat なリストに変換。
アイテム型: `_DateHeader` / `Recording` の union（sealed class or 識別用ラッパー）。
`ListView.builder` でヘッダーとカードを描画。

**ヘッダーテキスト:**
- 今日: `Today, {曜日}, {月} {日}`
- 昨日: `Yesterday, {曜日}, {月} {日}`
- それ以前: `{曜日}, {月} {日}`

最上部: `TodaySummaryCard` を `Column` の先頭に固定。

## 影響範囲

| レイヤー | ファイル | 変更内容 |
|---------|---------|---------|
| domain | `lib/domain/entities/recording.dart` | `waveformBars` フィールド追加 |
| application | `lib/application/providers/recording_provider.dart` | `saveRecording` にwaveform計算を追加 |
| application | `lib/application/providers/audio_events_by_recording_provider.dart` | **新規作成** |
| application | `lib/application/providers/today_summary_provider.dart` | **新規作成** |
| presentation | `lib/presentation/widgets/today_summary_card.dart` | **新規作成** |
| presentation | `lib/presentation/widgets/recording_card.dart` | 完全リデザイン |
| presentation | `lib/presentation/screens/timeline_screen.dart` | 日付グループ化・TodaySummary追加 |

## 新規作成ファイル

- `lib/application/providers/audio_events_by_recording_provider.dart`
- `lib/application/providers/today_summary_provider.dart`
- `lib/presentation/widgets/today_summary_card.dart`

## 修正ファイル

- `lib/domain/entities/recording.dart`
- `lib/application/providers/recording_provider.dart`
- `lib/presentation/widgets/recording_card.dart`
- `lib/presentation/screens/timeline_screen.dart`

## 使用する依存パッケージ

追加なし（既存パッケージのみ）

## Riverpod への影響

| プロバイダー | 変更 |
|------------|------|
| `recordingListProvider` | 変更なし（Recording に waveformBars が追加されるが、型変更のみ） |
| `audioEventsByRecordingProvider` | 新規（FutureProvider.family<List<AudioEvent>, String>） |
| `todaySummaryProvider` | 新規（FutureProvider<TodaySummary>） |

## リスク・エッジケース

- **既存データのマイグレーション**: `waveformBars` が `null` の既存録音 → `fromJson` で `[]` にフォールバック、カードでは波形非表示
- **音声ファイルが存在しない録音**: `extractAmplitudes` が例外をスローした場合、`[]` でフォールバックして録音保存は続行する
- **childIds が空の録音**: アバターなし・名前なしで表示（エラーにしない）
- **Today Summary の AudioEvent 取得**: 録音数が多い場合、Future.wait で並列取得
- **waveform 計算時間**: `extractAmplitudes` は WAVサンプルを読む → 長い録音で遅くなる可能性あり。60バーは���存コードと同値なので許容範囲と想定

## 実装ステップ

1. `Recording` エンティティに `waveformBars` 追加
2. `recording_provider.dart` の `saveRecording` を修正
3. `audio_events_by_recording_provider.dart` を作成
4. `today_summary_provider.dart` を作成
5. `today_summary_card.dart` を作成
6. `recording_card.dart` をリデザイン
7. `timeline_screen.dart` を日付グループ化・TodaySummary組み込みに修正

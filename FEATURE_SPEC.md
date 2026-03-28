# Mandarin Learning iPad App — Feature Spec & Phased Plan

**Target audience:** Middle schoolers, ~100 characters known, HSK 1–2 level
**Platform:** iPad (SwiftUI / UIKit)
**Design principle:** Each phase ships a self-contained usable app. Stop at any phase and it works.

---

## Product Overview

A focused Mandarin learning app for middle schoolers who have basic exposure (~100 characters). Organized around HSK 1–2 vocabulary, topic-based lessons, and short daily sessions (5–10 min). iPad-native design takes advantage of large screen for character writing and side-by-side layouts.

---

## Phase 1 — Core Vocabulary App (MVP)
**Goal:** A flashcard app that works. Usable as a standalone study tool.

### Features

#### 1.1 Vocabulary Flashcards
- Card shows: Chinese character(s), pinyin, English meaning, tone color-coding (tone 1–4 + neutral each a distinct color)
- Tap card to flip (English ↔ Chinese)
- Native speaker audio plays on card flip
- "Know it / Still learning" self-assessment buttons
- Pre-loaded HSK 1 word list (150 words)

#### 1.2 Basic SRS (Spaced Repetition)
- Simple interval scheduling: new → 1d → 3d → 7d → 14d → 30d
- "Due today" queue shown on home screen
- Words marked "still learning" resurface sooner

#### 1.3 Word List Browser
- Scrollable list of all HSK 1 words
- Filter by: due for review, learned, all
- Tap word → detail view (character, pinyin, audio, example sentence)
- Search by English or pinyin

#### 1.4 Home Screen
- Daily streak counter
- Cards due today (count + "Start Review" button)
- Words learned count (X / 150 HSK 1)
- Simple progress bar toward HSK 1 completion

#### iPad-specific
- Split-view: word list on left, card detail on right
- Large card layout — characters rendered at 80–120pt
- Landscape and portrait both work

---

## Phase 2 — Lessons & Exercises
**Goal:** Structured curriculum with interactive practice, not just flashcards.

### Features

#### 2.1 Topic-Based Lesson Units
Units (each ~5–8 lessons):
1. Greetings & introductions
2. Numbers & time
3. Family
4. Food & drink
5. School & classroom
6. Colors & descriptions
7. Places & directions
8. Daily routines

Each lesson contains: 5–8 new words + 2–3 grammar points + exercises

#### 2.2 Exercise Types
- **Word recognition** — hear audio, tap the correct character from 4 options
- **Meaning match** — match Chinese word to English meaning (drag and drop, iPad-optimized)
- **Sentence tiles** — rearrange word tiles to build a correct sentence
- **Pinyin input** — type the pinyin for a displayed character (keyboard with tone number input: ma1, ma2…)
- **Multiple choice reading** — short sentence, choose correct English translation

#### 2.3 Lesson Completion Flow
- Progress bar per lesson (X/Y exercises)
- End-of-lesson summary: score, new words learned, XP earned
- Incorrect answers reviewed at lesson end with explanation

#### 2.4 Skill Tree / Course Map
- Visual map of all units, lessons shown as nodes
- Locked/unlocked state (complete lesson N to unlock N+1)
- Tap completed lesson to "review" it

#### iPad-specific
- Drag-and-drop sentence building uses iPad pointer/touch natively
- Lesson map uses full iPad canvas (not a compressed mobile list)

---

## Phase 3 — Character Writing
**Goal:** Teach correct stroke order; build muscle memory for known characters.

### Features

#### 3.1 Stroke Order Animations
- Tap any character anywhere in the app → stroke order animation plays
- Animation shows each stroke in sequence with direction arrow
- Controls: pause, replay, step forward/back

#### 3.2 Character Tracing Practice
- Character shown as faint guide
- User traces with finger or Apple Pencil
- Stroke order is validated: wrong stroke order = visual error feedback (red flash)
- Stroke direction validated: backwards strokes flagged
- After tracing succeeds 2×, guide fades; user writes from memory

#### 3.3 Writing Deck
- Subset of learned words queued for writing practice
- SRS-integrated: writing score tracked separately from reading recognition score
- Progress: X characters can write from memory

#### iPad-specific (critical phase for iPad)
- Apple Pencil pressure sensitivity for natural stroke feel
- Large writing canvas — full A4-like area, not a small box
- Split screen: character reference on left, writing canvas on right

---

## Phase 4 — Listening & Speaking
**Goal:** Tone recognition and pronunciation practice.

### Features

#### 4.1 Tone Training Module
- Minimal pairs exercise: hear two syllables, identify which tone is which
- Tone identification: hear a word, tap the correct tone mark (ā á ǎ à)
- Tone pair drills: 1st/2nd, 2nd/3rd, 3rd/4th (the most commonly confused pairs)

#### 4.2 Listening Comprehension
- Short dialogues (2–4 lines) at HSK 1–2 level
- Two-speed playback: normal and 75% speed
- After listening: answer 2–3 comprehension questions
- Transcript reveal toggle (show/hide)

#### 4.3 Speaking Practice (Speech Recognition)
- Display a word or sentence → student reads aloud
- AVFoundation speech recognition scores the attempt
- Visual feedback: syllable-by-syllable tone accuracy (green = correct, red = wrong tone)
- Retry button; hear native speaker model after each attempt

#### iPad-specific
- Microphone access; visual waveform display while speaking
- Large transcript display for reading practice sentences

---

## Phase 5 — Gamification & Social
**Goal:** Long-term retention through motivation mechanics.

### Features

#### 5.1 Full Gamification Layer
- XP earned from every activity (lessons, reviews, writing, speaking)
- Level system (Level 1–50 with Chinese-themed level names)
- Achievement badges (First character written, 7-day streak, HSK 1 complete, etc.)
- Hearts system: start with 5 hearts, lose 1 per wrong answer, refill over time or with gems
- Gems (virtual currency) earned from streaks and achievements

#### 5.2 Daily Goals & Streaks
- Configurable daily XP goal: 10 / 20 / 30 XP
- Streak freeze (spend gems to protect streak when you miss a day)
- Weekly summary notification

#### 5.3 HSK Progress Dashboard
- Radar chart: vocabulary / listening / reading / writing / speaking
- HSK 1 readiness % with breakdown of what's left
- Personal best stats: longest streak, total characters learned, total study time

#### 5.4 Leaderboard (local/GameCenter)
- Weekly XP leaderboard via Game Center
- Friend comparison (add friends, see their streak + XP)

---

## Phase 6 — Graded Reading
**Goal:** Real reading practice in context.

### Features

#### 6.1 Story Library
- 30+ short stories at HSK 1–2 level (200–400 characters each)
- Illustrated with simple artwork
- Topics: daily life, school, family, simple adventures

#### 6.2 Interactive Reader
- Tap any character → instant popup: pinyin, meaning, audio
- Unknown word list: save tapped words → automatically added to SRS deck
- Pinyin display toggle (above each character, or hidden)
- Reading speed timer (optional) for fluency tracking

#### 6.3 Story Audio
- Full native-speaker narration per story
- Highlighted word tracks audio position (karaoke-style)
- Two-speed playback

#### 6.4 Comprehension Quizzes
- 3–5 questions after each story
- Mix of multiple choice and character recognition
- Story added to "completed" with score recorded

#### iPad-specific
- Two-column reader layout in landscape (text left, vocabulary panel right)
- Large font comfortable for extended reading

---

## Feature Summary by Phase

| Phase | Deliverable | Key Tech |
|---|---|---|
| 1 | Flashcard + SRS app | SwiftData, AVFoundation (audio) |
| 2 | Full lesson curriculum | SwiftUI drag-drop, lesson engine |
| 3 | Character writing | PencilKit, stroke validation logic |
| 4 | Listening + speaking | AVFoundation, Speech framework |
| 5 | Gamification + social | GameKit (Game Center), UserNotifications |
| 6 | Graded reading library | Custom reader engine, text highlighting |

---

## Data Model (Shared Across All Phases)

```
Word
  - id
  - hanzi (simplified)
  - pinyin (with tone numbers)
  - english
  - hsk_level (1–6)
  - audio_filename
  - stroke_order_data (JSON array of strokes)
  - example_sentence_zh
  - example_sentence_en
  - topic_tags ([food, family, …])

UserWordRecord
  - word_id
  - recognition_interval (SRS)
  - recognition_due_date
  - writing_interval (SRS, Phase 3+)
  - writing_due_date
  - times_correct
  - times_incorrect

Lesson
  - unit_id
  - lesson_number
  - title
  - word_ids []
  - grammar_points []
  - is_unlocked

UserLessonRecord
  - lesson_id
  - completed (bool)
  - score
  - completed_at

UserProfile
  - streak_count
  - streak_last_date
  - total_xp
  - level
  - hearts
  - gems
  - daily_goal_xp
```

---

## iPad UX Principles

1. **No cramped mobile layouts** — use the full canvas; characters should be large
2. **Apple Pencil first** for writing (touch fallback)
3. **Split view** wherever a list + detail pattern exists
4. **Landscape = primary orientation** for lesson/reading views
5. **Portrait = fine** for flashcard review (one-handed on couch)
6. **Avoid tiny tap targets** — middle schoolers are not precise; minimum 44pt, prefer 60pt+ for answer buttons
7. **System fonts** — SF Pro handles CJK rendering well; no custom font needed for characters

---

## Content Needed (Pre-Launch)

- [ ] HSK 1 word list with audio (150 words) — available from open datasets
- [ ] HSK 2 word list (300 words)
- [ ] Stroke order data — available from [CJK Stroke Order](https://github.com/skishore/makemeahanzi)
- [ ] 8 topic-based lesson scripts (Phase 2)
- [ ] 30 graded stories (Phase 6) — can generate/source from CC-licensed material
- [ ] Native speaker audio recordings (or TTS via AVSpeechSynthesizer zh-CN voice as placeholder)

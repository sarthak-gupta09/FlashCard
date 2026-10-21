# ⚡ Supabase Modular SQL Migrations Guide

Ye saare SQL files step-by-step modular tareeqe se alag-alag banaye gaye hain taaki aap inhe **Supabase SQL Editor** mein ek-ek karke run kar sakein ya jahan zaroorat ho wahan customize kar sakein.

---

## 📑 Migration Order (Sequence of Execution):

Run these files sequentially in **[Supabase Dashboard](https://supabase.com/dashboard) ➔ SQL Editor**:

| Step | File Name | Description |
|---|---|---|
| **1** | [`001_profiles.sql`](file:///d:/AndroidStudioProjects/SmartFlashCard/backend/mitigation/001_profiles.sql) | Enables `uuid-ossp` extension & creates `profiles` table linked to Supabase Auth. |
| **2** | [`002_decks.sql`](file:///d:/AndroidStudioProjects/SmartFlashCard/backend/mitigation/002_decks.sql) | Creates `decks` table for organizing cards by subjects (Medicine, Surgery, etc.). |
| **3** | [`003_cards.sql`](file:///d:/AndroidStudioProjects/SmartFlashCard/backend/mitigation/003_cards.sql) | Creates `cards` table for `IMAGE` & `MCQ` cards + spaced repetition fields. |
| **4** | [`004_card_options.sql`](file:///d:/AndroidStudioProjects/SmartFlashCard/backend/mitigation/004_card_options.sql) | Creates `card_options` table for 4-option MCQs (A, B, C, D). |
| **5** | [`005_review_history.sql`](file:///d:/AndroidStudioProjects/SmartFlashCard/backend/mitigation/005_review_history.sql) | Creates `review_history` audit table for tracking accuracy and response time. |
| **6** | [`006_indexes.sql`](file:///d:/AndroidStudioProjects/SmartFlashCard/backend/mitigation/006_indexes.sql) | Creates high-performance B-tree indexes for fast mobile retrieval. |
| **7** | [`007_row_level_security.sql`](file:///d:/AndroidStudioProjects/SmartFlashCard/backend/mitigation/007_row_level_security.sql) | Enables RLS & applies privacy policies so users only see their own data. |
| **8** | [`008_triggers.sql`](file:///d:/AndroidStudioProjects/SmartFlashCard/backend/mitigation/008_triggers.sql) | Auto-creates profile on signup & syncs deck `card_count`. |
| **9** | [`009_storage_bucket.sql`](file:///d:/AndroidStudioProjects/SmartFlashCard/backend/mitigation/009_storage_bucket.sql) | Creates `flashcard-images` bucket for CDN-accelerated X-rays & clinical images. |

---

*(Note: `001_initial_schema.sql` is also preserved as a combined all-in-one file if you ever want to run everything in a single click).*

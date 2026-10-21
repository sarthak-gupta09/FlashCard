# 🏥 PG & INI-CET Smart Flashcard Platform

A high-yield medical exam preparation platform built for MBBS students preparing for NEET-PG and INI-CET exams. Features active recall image recognition, AI-powered 4-option MCQ generation, and spaced repetition scheduling.

---

## 📁 Repository Structure

```
FlashCard/
│
├── 🌐 backend/                  # AI Engine, APIs & Database Migrations
│   ├── app/                     # FastAPI Application (Endpoints, Services, Schemas)
│   ├── mitigation/              # Supabase Modular PostgreSQL Migrations (001 - 009)
│   ├── supabase/functions/      # Supabase Edge Functions (generate-distractors)
│   ├── requirements.txt         # Python dependencies
│   ├── .env.example             # Environment configuration template
│   └── README.md
│
└── 📱 Smart_FlashCard/          # Android Mobile Application (Kotlin + Jetpack Compose)
    ├── app/                     # Android App Module (UI, Theme, Components)
    │   └── src/main/java/.../ui/theme/
    │       ├── Color.kt         # Pure Medical Clinical Light Palette
    │       ├── Theme.kt         # Locked Light Theme (No dark mode)
    │       └── Type.kt          # Diagnostic Precision Typography
    ├── gradle/
    ├── build.gradle.kts
    └── settings.gradle.kts
```

---

## 🚀 Quick Start Guide

### 1. Database Setup (Supabase)
Run the SQL scripts located in `backend/mitigation/` sequentially in the **Supabase SQL Editor**:
- `001_profiles.sql` to `009_storage_bucket.sql`
*(Or run `001_initial_schema.sql` for an all-in-one setup).*

### 2. Backend (FastAPI AI Proxy)
```bash
cd backend
python -m venv .venv
source .venv/bin/activate  # Or .venv\Scripts\activate on Windows
pip install -r requirements.txt
cp .env.example .env       # Add your GEMINI_API_KEY
uvicorn app.main:app --reload --port 8000
```
Interactive API documentation available at `http://localhost:8000/docs`.

### 3. Android App
1. Open Android Studio.
2. Select **Open an Existing Project** and choose the `Smart_FlashCard/` folder.
3. Sync Gradle and run on device or emulator.

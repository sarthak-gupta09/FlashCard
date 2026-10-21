# 🏥 PG & INI-CET Smart Flashcard — AI Backend

Production-grade, asynchronous FastAPI backend powering the Smart Flashcard AI distractor generation and medical intelligence.

## 📁 Architecture Overview
```
backend/
├── app/
│   ├── api/v1/endpoints/
│   │   ├── ai.py              # POST /api/v1/ai/generate-distractors
│   │   └── health.py          # GET /api/v1/health
│   ├── schemas/ai.py          # Strict Pydantic models (A-D options)
│   ├── services/ai_service.py # Gemini 1.5 Flash + Fallback engine
│   ├── config.py              # Environment configuration
│   └── main.py                # FastAPI entry point & CORS
├── requirements.txt
├── .env.example
└── README.md
```

## 🚀 Quickstart

1. **Activate Virtual Environment**:
   ```bash
   .venv\Scripts\activate      # Windows
   ```

2. **Configure Environment Variables**:
   Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
   Add your `GEMINI_API_KEY`. (Free key available at https://aistudio.google.com/)

3. **Start Development Server**:
   ```bash
   .venv\Scripts\python -m uvicorn app.main:app --reload --port 8000
   ```

4. **Access Interactive API Documentation**:
   Open browser at:
   - **Swagger UI**: `http://localhost:8000/docs`
   - **ReDoc**: `http://localhost:8000/redoc`

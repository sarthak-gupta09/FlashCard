-- ==============================================================================
-- 003_cards.sql
-- Creates Cards table supporting IMAGE & MCQ types + Spaced Repetition fields
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.cards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    deck_id UUID REFERENCES public.decks(id) ON DELETE SET NULL,
    card_type TEXT NOT NULL CHECK (card_type IN ('IMAGE', 'MCQ')),
    
    -- Content fields
    question TEXT NOT NULL,             -- MCQ question or Image prompt/clue
    image_url TEXT,                     -- Supabase Storage URL for IMAGE cards
    correct_answer TEXT NOT NULL,       -- User-provided source of truth
    explanation TEXT,                   -- High-yield clinical explanation
    
    -- Medical metadata
    subject TEXT NOT NULL,              -- Medicine, Pathology, Pharmacology, etc.
    topic TEXT,                         -- Sub-topic / chapter
    tags TEXT[] DEFAULT '{}',           -- Custom searchable tag array
    difficulty TEXT DEFAULT 'MEDIUM' CHECK (difficulty IN ('EASY', 'MEDIUM', 'HARD')),
    
    -- Spaced Repetition & Revision Tracking
    review_status TEXT DEFAULT 'NEW' CHECK (review_status IN ('NEW', 'LEARNING', 'KNOWN', 'NEEDS_REVISION')),
    review_count INT DEFAULT 0,
    correct_count INT DEFAULT 0,
    accuracy NUMERIC(5, 2) DEFAULT 0.00,
    next_review_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    ease_factor NUMERIC(4, 2) DEFAULT 2.50,
    interval_days INT DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    last_reviewed_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

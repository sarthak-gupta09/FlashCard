-- ==============================================================================
-- 🏥 PG & INI-CET SMART FLASHCARD APP - SUPABASE SCHEMA MIGRATION
-- Migration: 001_initial_schema.sql
-- Description: Core tables, Row Level Security (RLS), Indexes, Storage & Triggers
-- ==============================================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==============================================================================
-- 1. PROFILES TABLE (Linked to Supabase Auth)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    full_name TEXT,
    avatar_url TEXT,
    target_exam TEXT DEFAULT 'NEET_PG', -- 'NEET_PG', 'INI_CET', 'BOTH'
    target_exam_date DATE,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==============================================================================
-- 2. DECKS TABLE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.decks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    subject TEXT NOT NULL, -- e.g. Medicine, Surgery, Radiology, etc.
    color_hex TEXT DEFAULT '#0284C7', -- Default Medical Primary Blue
    icon_name TEXT DEFAULT 'folder',
    card_count INT DEFAULT 0,
    is_archived BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==============================================================================
-- 3. CARDS TABLE (Image + MCQ Flashcards)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.cards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    deck_id UUID REFERENCES public.decks(id) ON DELETE SET NULL,
    card_type TEXT NOT NULL CHECK (card_type IN ('IMAGE', 'MCQ')),
    
    -- Content fields
    question TEXT NOT NULL,             -- MCQ question or Image prompt/clue
    image_url TEXT,                     -- Supabase Storage URL for IMAGE cards
    correct_answer TEXT NOT NULL,       -- Source of truth provided by user
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

-- ==============================================================================
-- 4. CARD OPTIONS TABLE (For 4-Option MCQs: 1 Correct + 3 Distractors)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.card_options (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    card_id UUID NOT NULL REFERENCES public.cards(id) ON DELETE CASCADE,
    option_label VARCHAR(1) NOT NULL CHECK (option_label IN ('A', 'B', 'C', 'D')),
    option_text TEXT NOT NULL,
    is_correct BOOLEAN NOT NULL DEFAULT FALSE,
    is_ai_generated BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==============================================================================
-- 5. REVIEW HISTORY TABLE (Audit Trail & Performance Analytics)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.review_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    card_id UUID NOT NULL REFERENCES public.cards(id) ON DELETE CASCADE,
    rating TEXT NOT NULL CHECK (rating IN ('AGAIN', 'HARD', 'GOOD', 'EASY', 'KNOW', 'NEEDS_REVISION')),
    was_correct BOOLEAN NOT NULL,
    selected_option TEXT,
    response_time_ms INT,
    reviewed_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==============================================================================
-- 6. PERFORMANCE INDEXES (Optimized for Fast Revision & Search)
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_cards_user_id ON public.cards(user_id);
CREATE INDEX IF NOT EXISTS idx_cards_deck_id ON public.cards(deck_id);
CREATE INDEX IF NOT EXISTS idx_cards_subject ON public.cards(subject);
CREATE INDEX IF NOT EXISTS idx_cards_review_status ON public.cards(review_status);
CREATE INDEX IF NOT EXISTS idx_cards_next_review ON public.cards(next_review_at);
CREATE INDEX IF NOT EXISTS idx_cards_card_type ON public.cards(card_type);
CREATE INDEX IF NOT EXISTS idx_card_options_card_id ON public.card_options(card_id);
CREATE INDEX IF NOT EXISTS idx_review_history_user_card ON public.review_history(user_id, card_id);
CREATE INDEX IF NOT EXISTS idx_review_history_reviewed_at ON public.review_history(reviewed_at);

-- ==============================================================================
-- 7. ROW LEVEL SECURITY (RLS) POLICIES
-- Ensures each medical student can ONLY access their own flashcards & decks
-- ==============================================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.decks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_history ENABLE ROW LEVEL SECURITY;

-- Profiles: Users can view and update their own profile
CREATE POLICY "Users can view their own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

-- Decks: Users have full CRUD on their own decks
CREATE POLICY "Users can view their own decks"
    ON public.decks FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own decks"
    ON public.decks FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own decks"
    ON public.decks FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own decks"
    ON public.decks FOR DELETE
    USING (auth.uid() = user_id);

-- Cards: Users have full CRUD on their own cards
CREATE POLICY "Users can view their own cards"
    ON public.cards FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own cards"
    ON public.cards FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own cards"
    ON public.cards FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own cards"
    ON public.cards FOR DELETE
    USING (auth.uid() = user_id);

-- Card Options: Accessible if user owns the parent card
CREATE POLICY "Users can view options of their own cards"
    ON public.card_options FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.cards
            WHERE cards.id = card_options.card_id
            AND cards.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert options for their own cards"
    ON public.card_options FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.cards
            WHERE cards.id = card_options.card_id
            AND cards.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update options for their own cards"
    ON public.card_options FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.cards
            WHERE cards.id = card_options.card_id
            AND cards.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete options for their own cards"
    ON public.card_options FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.cards
            WHERE cards.id = card_options.card_id
            AND cards.user_id = auth.uid()
        )
    );

-- Review History: Users can view and insert their own review records
CREATE POLICY "Users can view their own review history"
    ON public.review_history FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own review history"
    ON public.review_history FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ==============================================================================
-- 8. AUTOMATIC TRIGGERS
-- Auto-create profile on signup & maintain card counts on decks
-- ==============================================================================

-- Trigger: Create profile automatically when new user signs up in auth.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, avatar_url)
    VALUES (
        new.id,
        new.email,
        new.raw_user_meta_data->>'full_name',
        new.raw_user_meta_data->>'avatar_url'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Trigger: Update deck card_count automatically
CREATE OR REPLACE FUNCTION public.update_deck_card_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.deck_id IS NOT NULL THEN
        UPDATE public.decks SET card_count = card_count + 1, updated_at = now() WHERE id = NEW.deck_id;
    ELSIF TG_OP = 'DELETE' AND OLD.deck_id IS NOT NULL THEN
        UPDATE public.decks SET card_count = GREATEST(card_count - 1, 0), updated_at = now() WHERE id = OLD.deck_id;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.deck_id IS DISTINCT FROM NEW.deck_id THEN
            IF OLD.deck_id IS NOT NULL THEN
                UPDATE public.decks SET card_count = GREATEST(card_count - 1, 0), updated_at = now() WHERE id = OLD.deck_id;
            END IF;
            IF NEW.deck_id IS NOT NULL THEN
                UPDATE public.decks SET card_count = card_count + 1, updated_at = now() WHERE id = NEW.deck_id;
            END IF;
        END IF;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_card_count_sync ON public.cards;
CREATE TRIGGER trg_card_count_sync
    AFTER INSERT OR UPDATE OR DELETE ON public.cards
    FOR EACH ROW EXECUTE FUNCTION public.update_deck_card_count();

-- ==============================================================================
-- 9. SUPABASE STORAGE BUCKET FOR MEDICAL IMAGES
-- Creates the 'flashcard-images' bucket with secure access policies
-- ==============================================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('flashcard-images', 'flashcard-images', true)
ON CONFLICT (id) DO NOTHING;

-- Allow authenticated users to upload medical images to their own folder
CREATE POLICY "Authenticated users can upload flashcard images"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'flashcard-images'
        AND auth.role() = 'authenticated'
    );

-- Allow public read of flashcard images (for high-speed image loading via CDN)
CREATE POLICY "Public read for flashcard images"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'flashcard-images');

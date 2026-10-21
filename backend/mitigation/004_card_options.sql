-- ==============================================================================
-- 004_card_options.sql
-- Creates Card Options table for 4-option MCQs (1 Correct + 3 AI Distractors)
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

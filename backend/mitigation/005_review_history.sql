-- ==============================================================================
-- 005_review_history.sql
-- Creates Review History table for tracking audit logs and revision metrics
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

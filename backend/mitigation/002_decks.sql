-- ==============================================================================
-- 002_decks.sql
-- Creates Decks table for organizing cards by subjects/topics
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.decks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    subject TEXT NOT NULL, -- e.g. Medicine, Surgery, Radiology, etc.
    color_hex TEXT DEFAULT '#0284C7', -- Medical Primary Color
    icon_name TEXT DEFAULT 'folder',
    card_count INT DEFAULT 0,
    is_archived BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

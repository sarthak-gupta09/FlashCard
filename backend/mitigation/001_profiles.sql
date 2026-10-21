-- ==============================================================================
-- 001_profiles.sql
-- Enables UUID extension & creates Profiles table linked to Supabase Auth
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

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

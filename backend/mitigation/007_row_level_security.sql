-- ==============================================================================
-- 007_row_level_security.sql
-- Enables Row Level Security (RLS) on all tables and creates privacy policies
-- ==============================================================================

-- 1. Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.decks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_history ENABLE ROW LEVEL SECURITY;

-- 2. Profiles Policies
CREATE POLICY "Users can view their own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

-- 3. Decks Policies
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

-- 4. Cards Policies
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

-- 5. Card Options Policies
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

-- 6. Review History Policies
CREATE POLICY "Users can view their own review history"
    ON public.review_history FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own review history"
    ON public.review_history FOR INSERT
    WITH CHECK (auth.uid() = user_id);

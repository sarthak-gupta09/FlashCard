-- ==============================================================================
-- 008_triggers.sql
-- Creates triggers for auto-profile creation and deck card count synchronization
-- ==============================================================================

-- 1. Trigger: Create profile automatically when user signs up in auth.users
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

-- 2. Trigger: Update deck card_count automatically on insert, delete, or deck transfer
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

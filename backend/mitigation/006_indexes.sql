-- ==============================================================================
-- 006_indexes.sql
-- Creates performance B-tree indexes for fast queries, search, and revision queues
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

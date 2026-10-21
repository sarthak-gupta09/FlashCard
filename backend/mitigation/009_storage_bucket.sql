-- ==============================================================================
-- 009_storage_bucket.sql
-- Creates the 'flashcard-images' Supabase Storage bucket & sets upload/read policies
-- ==============================================================================

-- 1. Create the flashcard-images bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('flashcard-images', 'flashcard-images', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Allow authenticated medical students to upload image files
CREATE POLICY "Authenticated users can upload flashcard images"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'flashcard-images'
        AND auth.role() = 'authenticated'
    );

-- 3. Allow public read of images via Supabase CDN for instant mobile loading
CREATE POLICY "Public read for flashcard images"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'flashcard-images');

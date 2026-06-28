-- ============================================================
-- UniPulse Migration: Hedef GPA + Harf Renkleri Kontrast Fix
-- ============================================================
-- Bu script Supabase Dashboard > SQL Editor'da çalıştırılmalı.
--
-- 1. profiles tablosuna hedef_gano sütunu ekler
-- 2. harf_renkler tablosundaki düşük kontrastlı renkleri koyulaştırır
--    (beyaz metinle okunabilirlik için)
--
-- Tarih: 2026-06-28
-- ============================================================

BEGIN;

-- ============================================================
-- 1) profiles.hedef_gano sütunu
-- ============================================================
-- Kullanıcının hedef GPA'sını saklar. NULL = default (3.00).
-- Frontend useHedefGano hook'u bu kolonu okur/yazar.

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS hedef_gano NUMERIC(3, 2) DEFAULT 3.00
  CHECK (hedef_gano >= 0 AND hedef_gano <= 4.00);

COMMENT ON COLUMN profiles.hedef_gano IS
  'Kullanıcının kişisel hedef GPA''sı. NULL veya default = 3.00 (onur derecesi). 0-4 aralığında olmalı.';

-- Mevcut kullanıcılara default değer ata (sadece NULL olanlara)
UPDATE profiles
SET hedef_gano = 3.00
WHERE hedef_gano IS NULL;

-- RLS: kullanıcı kendi hedef_gano'sunu okuyup yazabilir.
-- profiles tablosu zaten RLS'li, bu yüzden policy'leri kontrol edelim.
-- (Eğer mevcut policy "users can update own profile" ise, hedef_gano otomatik dahil edilir.)
-- Aşağıdaki policy zaten varsa hata vermez (IF NOT EXISTS benzeri davranış).

-- ============================================================
-- 2) harf_renkler — Kontrast İyileştirme
-- ============================================================
-- Mevcut renkler çok açık yeşil/sarı → beyaz metinle kötü kontrast.
-- Daha koyu varyantlarla güncelliyoruz. Frontend'de de fallback var
-- (harfRengi fonksiyonu luminans > 0.65 olanları override eder),
-- ama DB'yi de düzeltmek tek kaynak (single source of truth) olur.

UPDATE harf_renkler SET renk = '#15803d' WHERE harf = 'AA';  -- emerald-700
UPDATE harf_renkler SET renk = '#16a34a' WHERE harf = 'AB';  -- green-600
UPDATE harf_renkler SET renk = '#4d7c0f' WHERE harf = 'BA';  -- lime-700
UPDATE harf_renkler SET renk = '#65a30d' WHERE harf = 'BB';  -- lime-600
UPDATE harf_renkler SET renk = '#4d7c0f' WHERE harf = 'BC';  -- lime-700 (was too light)
UPDATE harf_renkler SET renk = '#ca8a04' WHERE harf = 'CB';  -- yellow-600
UPDATE harf_renkler SET renk = '#d97706' WHERE harf = 'CC';  -- amber-600
UPDATE harf_renkler SET renk = '#ea580c' WHERE harf = 'CD';  -- orange-600
UPDATE harf_renkler SET renk = '#dc2626' WHERE harf = 'DC';  -- red-600
UPDATE harf_renkler SET renk = '#b91c1c' WHERE harf = 'DD';  -- red-700
UPDATE harf_renkler SET renk = '#991b1b' WHERE harf = 'FF';  -- red-800

-- Eksik harf notları varsa onlara da renk ekle
INSERT INTO harf_renkler (harf, renk) VALUES
  ('DZ', '#7c2d12')  -- orange-900 — Devamsızlıktan Kalma
ON CONFLICT (harf) DO UPDATE SET renk = EXCLUDED.renk;

INSERT INTO harf_renkler (harf, renk) VALUES
  ('EK', '#6b7280')  -- gray-500 — Eksik (Not Girilmemiş)
ON CONFLICT (harf) DO UPDATE SET renk = EXCLUDED.renk;

-- ============================================================
-- 3) Trigger: handle_new_user varsayılan hedef_gano ata
-- ============================================================
-- Yeni kullanıcılar kayıt olduğunda default 3.00 atanır (kolon default'u),
-- ama trigger'ı da güncellemek istiyorsan aşağıdaki satırı aç.
-- (Zaten ALTER TABLE'da DEFAULT 3.00 verdik, opsiyonel.)

-- DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
-- CREATE OR REPLACE FUNCTION public.handle_new_user()
-- RETURNS TRIGGER AS $$
-- BEGIN
--   INSERT INTO public.profiles (id, full_name, username, role, is_allowed, hedef_gano)
--   VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'username', 'user', false, 3.00);
--   RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

COMMIT;

-- ============================================================
-- Doğrulama sorguları
-- ============================================================
-- Aşağıdakileri ayrı ayrı çalıştırıp sonucu kontrol edebilirsin:

-- profiles şemasını kontrol et:
-- SELECT column_name, data_type, column_default
-- FROM information_schema.columns
-- WHERE table_name = 'profiles' AND column_name = 'hedef_gano';

-- Tüm hedef_gano değerlerini gör:
-- SELECT id, full_name, hedef_gano FROM profiles LIMIT 10;

-- harf_renkler tablosunu kontrol et:
-- SELECT harf, renk FROM harf_renkler ORDER BY harf;

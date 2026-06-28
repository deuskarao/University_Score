-- ============================================================
-- UniPulse Migration: Üniversite Logoları (domain sütunu)
-- ============================================================
-- universities tablosuna 'domain' sütunu ekler.
-- Frontend, https://logo.clearbit.com/{domain} ile logo gösterecek.
--
-- Clearbit Logo API: Şirket/üniversite logolarını domain'den otomatik çeker.
-- Örn: https://logo.clearbit.com/itu.edu.tr → İTÜ logosu
--
-- Bu migration idempotent — tekrar çalıştırılabilir.
-- Tarih: 2026-06-28
-- ============================================================

BEGIN;

-- ============================================================
-- 1) universities tablosuna domain sütunu ekle
-- ============================================================
ALTER TABLE universities
  ADD COLUMN IF NOT EXISTS domain TEXT;

COMMENT ON COLUMN universities.domain IS
  'Üniversitenin web sitesi domaini (örn: itu.edu.tr). Logo gösterimi için Clearbit API kullanılır.';

-- ============================================================
-- 2) Her üniversiteye domain değeri ata
-- ============================================================
-- slug bazlı update — slug unique olduğu için güvenli.

UPDATE universities SET domain = 'anadolu.edu.tr' WHERE slug = 'anadolu-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'ankara.edu.tr' WHERE slug = 'ankara-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'bilkent.edu.tr' WHERE slug = 'bilkent-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'boun.edu.tr' WHERE slug = 'bogazici-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'ege.edu.tr' WHERE slug = 'ege-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'hacettepe.edu.tr' WHERE slug = 'hacettepe-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'istanbul.edu.tr' WHERE slug = 'istanbul-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'ku.edu.tr' WHERE slug = 'koc-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'metu.edu.tr' WHERE slug = 'odtu' AND domain IS NULL;
UPDATE universities SET domain = 'sabanciuniv.edu.tr' WHERE slug = 'sabanci-universitesi' AND domain IS NULL;

-- Yeni eklenen 20 üniversite
UPDATE universities SET domain = 'itu.edu.tr' WHERE slug = 'itu' AND domain IS NULL;
UPDATE universities SET domain = 'marmara.edu.tr' WHERE slug = 'marmara-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'yildiz.edu.tr' WHERE slug = 'yildiz-teknik-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'deu.edu.tr' WHERE slug = 'dokuz-eylul-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'gazi.edu.tr' WHERE slug = 'gazi-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'gtu.edu.tr' WHERE slug = 'gebze-teknik-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'eskisehir.edu.tr' WHERE slug = 'eskisehir-teknik-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'gsu.edu.tr' WHERE slug = 'galatasaray-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'iyte.edu.tr' WHERE slug = 'iyte' AND domain IS NULL;
UPDATE universities SET domain = 'akdeniz.edu.tr' WHERE slug = 'akdeniz-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'uludag.edu.tr' WHERE slug = 'bursa-uludag-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'sakarya.edu.tr' WHERE slug = 'sakarya-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'ktu.edu.tr' WHERE slug = 'karadeniz-teknik-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'cu.edu.tr' WHERE slug = 'cukurova-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'erciyes.edu.tr' WHERE slug = 'erciyes-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'atauni.edu.tr' WHERE slug = 'ataturk-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'pau.edu.tr' WHERE slug = 'pamukkale-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'kocaeli.edu.tr' WHERE slug = 'kocaeli-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'selcuk.edu.tr' WHERE slug = 'selcuk-universitesi' AND domain IS NULL;
UPDATE universities SET domain = 'gantep.edu.tr' WHERE slug = 'gaziantep-universitesi' AND domain IS NULL;

COMMIT;

-- ============================================================
-- Doğrulama
-- ============================================================
-- SELECT ad, slug, domain FROM universities ORDER BY ad;
-- Beklenen: 30 üniversite, hepsinde domain dolu.

-- ============================================================
-- UniPulse Migration: Email Doğrulama + Kullanıcı Aktifleştirme
-- ============================================================
-- Bu SQL, sabriabi@unipulse.com kullanıcısının email doğrulamasını
-- tamamlar ve giriş yapabilmesini sağlar.
--
-- Supabase Dashboard > SQL Editor'da çalıştır (service role ile çalışır).
-- Tarih: 2026-06-28
-- ============================================================

-- ============================================================
-- 1) sabriabi@unipulse.com kullanıcısını doğrula
-- ============================================================
-- auth.users tablosunda email_confirmed_at ve confirmed_at alanlarını doldur.
-- Ayrıca email_change_confirm_status varsa 1 yap.

UPDATE auth.users
SET
  email_confirmed_at = NOW(),
  confirmed_at = NOW(),
  email_change_confirm_status = COALESCE(email_change_confirm_status, 0),
  updated_at = NOW()
WHERE email = 'sabriabi@unipulse.com';

-- ============================================================
-- 2) (Opsiyonel) Tüm doğrulanmamış kullanıcıları doğrula
-- ============================================================
-- Eğer tüm kullanıcıların doğrulamaya takılmadan kayıt olmasını istersen:
-- UPDATE auth.users
-- SET
--   email_confirmed_at = COALESCE(email_confirmed_at, NOW()),
--   confirmed_at = COALESCE(confirmed_at, NOW()),
--   updated_at = NOW()
-- WHERE email_confirmed_at IS NULL;

-- ============================================================
-- 3) (Opsiyonel) Yeni kayıtlarda email doğrulamasını devre dışı bırak
-- ============================================================
-- Bu SQL ile yapılamaz. Supabase Dashboard üzerinden yap:
-- Authentication > Settings > "Enable email confirmations" → OFF
--
-- VEYA auth config tablosunu güncelle (Supabase yeni sürümlerde):
-- UPDATE auth.config SET value = 'false' WHERE key = 'mailer_otp_exp';

-- ============================================================
-- Doğrulama
-- ============================================================
-- SELECT email, email_confirmed_at, confirmed_at
-- FROM auth.users
-- WHERE email = 'sabriabi@unipulse.com';
-- Beklenen: email_confirmed_at ve confirmed_at dolu (NOW() değeri)

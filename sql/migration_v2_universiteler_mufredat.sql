-- ============================================================
-- UniPulse Migration v2: Yeni Üniversiteler + Eksik Müfredatlar
-- ============================================================
-- Bu migration:
--   1. legacy_id=0 olan kayıtları NULL yapar (constraint fix)
--   2. 20 yeni üniversite ekler (İTÜ, Marmara, Yıldız, vb.)
--   3. Her yeni üniversiteye fakülteler ekler
--   4. Fakülteleri mevcut bölümlerle eşleştirir
--   5. 56 bölümün müfredatlarını ekler (idempotent)
--      Sadece dersleri olmayan bölümlere ekleme yapar
--
-- KORUNAN BÖLÜMLER (dokunulmaz):
--   * Dış Ticaret (Anadolu Üniversitesi)
--   * Bilgisayar Programcılığı (Anadolu Üniversitesi)
--   * Özel Eğitim Öğretmenliği (Anadolu Üniversitesi)
--
-- Bu migration TEKRAR ÇALIŞTIRILABILIR (idempotent).
-- Tarih: 2026-06-28
-- ============================================================

BEGIN;

-- ============================================================
-- 1) legacy_id=0 olan kayıtları NULL yap
-- ============================================================
-- (department_id, legacy_id) unique constraint için.
-- NULL değerler unique sayılmaz, yani çakışma olmaz.
UPDATE department_courses SET legacy_id = NULL WHERE legacy_id = 0;

-- ============================================================
-- 2) 20 Yeni Üniversite Ekle
-- ============================================================
-- slug unique olduğu için ON CONFLICT (slug) DO NOTHING ile idempotent.
-- Mevcut 10 üniversite zaten DB'de var, tekrar eklenmeyecek.

INSERT INTO universities (ad, emoji, renk, slug)
VALUES
  ('İstanbul Teknik Üniversitesi (İTÜ)', '⚙️', '#0d9488', 'itu'),
  ('Marmara Üniversitesi', '🏛️', '#7c3aed', 'marmara-universitesi'),
  ('Yıldız Teknik Üniversitesi', '🔧', '#0891b2', 'yildiz-teknik-universitesi'),
  ('Dokuz Eylül Üniversitesi', '🌊', '#0ea5e9', 'dokuz-eylul-universitesi'),
  ('Gazi Üniversitesi', '🎯', '#dc2626', 'gazi-universitesi'),
  ('Gebze Teknik Üniversitesi', '🔬', '#16a34a', 'gebze-teknik-universitesi'),
  ('Eskişehir Teknik Üniversitesi', '✈️', '#4f46e5', 'eskisehir-teknik-universitesi'),
  ('Galatasaray Üniversitesi', '🔴', '#b91c1c', 'galatasaray-universitesi'),
  ('İzmir Yüksek Teknoloji Enstitüsü (İYTE)', '🌊', '#0284c7', 'iyte'),
  ('Akdeniz Üniversitesi', '🌴', '#16a34a', 'akdeniz-universitesi'),
  ('Bursa Uludağ Üniversitesi', '⛰️', '#0891b2', 'bursa-uludag-universitesi'),
  ('Sakarya Üniversitesi', '🍃', '#65a30d', 'sakarya-universitesi'),
  ('Karadeniz Teknik Üniversitesi', '🌲', '#166534', 'karadeniz-teknik-universitesi'),
  ('Çukurova Üniversitesi', '🌾', '#ca8a04', 'cukurova-universitesi'),
  ('Erciyes Üniversitesi', '🏔️', '#7c3aed', 'erciyes-universitesi'),
  ('Atatürk Üniversitesi', '🏛️', '#dc2626', 'ataturk-universitesi'),
  ('Pamukkale Üniversitesi', '🏺', '#0891b2', 'pamukkale-universitesi'),
  ('Kocaeli Üniversitesi', '⚓', '#0d9488', 'kocaeli-universitesi'),
  ('Selçuk Üniversitesi', '🕌', '#4f46e5', 'selcuk-universitesi'),
  ('Gaziantep Üniversitesi', '🏗️', '#d97706', 'gaziantep-universitesi')
ON CONFLICT (slug) DO NOTHING;

-- ============================================================
-- 3) Yeni Üniversitelere Fakülteler Ekle
-- ============================================================
-- Her fakültenin slug'ı: <fakulte-tipi>-<uni-slug>
-- Örn: 'muhendislik-itu', 'iibf-marmara-universitesi'

-- === İstanbul Teknik Üniversitesi (İTÜ) ===
INSERT INTO faculties (ad, emoji, renk, slug, university_id)
SELECT v.ad, v.emoji, v.renk, v.slug, u.id
FROM universities u
CROSS JOIN (VALUES
  ('Mühendislik Fakültesi', '⚙️', '#4f46e5', 'muhendislik-itu'),
  ('Fen-Edebiyat Fakültesi', '🔬', '#7c3aed', 'fen-edebiyat-itu'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'iibf-itu'),
  ('Mimarlık Fakültesi', '🏗️', '#d97706', 'mimarlik-itu'),
  ('Meslek Yüksekokulu', '🔧', '#64748b', 'meslek-yuksekokulu-itu')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'itu'
ON CONFLICT (slug) DO NOTHING;

-- === Marmara Üniversitesi ===
INSERT INTO faculties (ad, emoji, renk, slug, university_id)
SELECT v.ad, v.emoji, v.renk, v.slug, u.id
FROM universities u
CROSS JOIN (VALUES
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'iibf-marmara-universitesi'),
  ('Hukuk Fakültesi', '⚖️', '#0891b2', 'hukuk-marmara-universitesi'),
  ('Eğitim Fakültesi', '🎓', '#16a34a', 'egitim-marmara-universitesi'),
  ('İletişim Fakültesi', '📡', '#d97706', 'iletisim-marmara-universitesi'),
  ('Güzel Sanatlar Fakültesi', '🎨', '#dc2626', 'guzel-sanatlar-marmara-universitesi'),
  ('Tıp Fakültesi', '⚕️', '#dc2626', 'tip-marmara-universitesi'),
  ('Meslek Yüksekokulu', '🔧', '#64748b', 'meslek-yuksekokulu-marmara-universitesi')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'marmara-universitesi'
ON CONFLICT (slug) DO NOTHING;

-- === Yıldız Teknik Üniversitesi ===
INSERT INTO faculties (ad, emoji, renk, slug, university_id)
SELECT v.ad, v.emoji, v.renk, v.slug, u.id
FROM universities u
CROSS JOIN (VALUES
  ('Mühendislik Fakültesi', '⚙️', '#4f46e5', 'muhendislik-yildiz-teknik-universitesi'),
  ('Fen-Edebiyat Fakültesi', '🔬', '#7c3aed', 'fen-edebiyat-yildiz-teknik-universitesi'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'iibf-yildiz-teknik-universitesi'),
  ('Mimarlık Fakültesi', '🏗️', '#d97706', 'mimarlik-yildiz-teknik-universitesi'),
  ('Meslek Yüksekokulu', '🔧', '#64748b', 'meslek-yuksekokulu-yildiz-teknik-universitesi')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'yildiz-teknik-universitesi'
ON CONFLICT (slug) DO NOTHING;

-- === Dokuz Eylül Üniversitesi ===
INSERT INTO faculties (ad, emoji, renk, slug, university_id)
SELECT v.ad, v.emoji, v.renk, v.slug, u.id
FROM universities u
CROSS JOIN (VALUES
  ('Mühendislik Fakültesi', '⚙️', '#4f46e5', 'muhendislik-dokuz-eylul-universitesi'),
  ('Fen-Edebiyat Fakültesi', '🔬', '#7c3aed', 'fen-edebiyat-dokuz-eylul-universitesi'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'iibf-dokuz-eylul-universitesi'),
  ('Hukuk Fakültesi', '⚖️', '#0891b2', 'hukuk-dokuz-eylul-universitesi'),
  ('Eczacılık Fakültesi', '💊', '#16a34a', 'eczacilik-dokuz-eylul-universitesi'),
  ('Tıp Fakültesi', '⚕️', '#dc2626', 'tip-dokuz-eylul-universitesi'),
  ('İletişim Fakültesi', '📡', '#d97706', 'iletisim-dokuz-eylul-universitesi'),
  ('Turizm Fakültesi', '🏖️', '#0ea5e9', 'turizm-dokuz-eylul-universitesi'),
  ('Meslek Yüksekokulu', '🔧', '#64748b', 'meslek-yuksekokulu-dokuz-eylul-universitesi')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'dokuz-eylul-universitesi'
ON CONFLICT (slug) DO NOTHING;

-- === Gazi Üniversitesi ===
INSERT INTO faculties (ad, emoji, renk, slug, university_id)
SELECT v.ad, v.emoji, v.renk, v.slug, u.id
FROM universities u
CROSS JOIN (VALUES
  ('Mühendislik Fakültesi', '⚙️', '#4f46e5', 'muhendislik-gazi-universitesi'),
  ('Fen-Edebiyat Fakültesi', '🔬', '#7c3aed', 'fen-edebiyat-gazi-universitesi'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'iibf-gazi-universitesi'),
  ('Hukuk Fakültesi', '⚖️', '#0891b2', 'hukuk-gazi-universitesi'),
  ('Eğitim Fakültesi', '🎓', '#16a34a', 'egitim-gazi-universitesi'),
  ('İletişim Fakültesi', '📡', '#d97706', 'iletisim-gazi-universitesi'),
  ('Tıp Fakültesi', '⚕️', '#dc2626', 'tip-gazi-universitesi'),
  ('Meslek Yüksekokulu', '🔧', '#64748b', 'meslek-yuksekokulu-gazi-universitesi')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'gazi-universitesi'
ON CONFLICT (slug) DO NOTHING;

-- === Gebze Teknik Üniversitesi ===
INSERT INTO faculties (ad, emoji, renk, slug, university_id)
SELECT v.ad, v.emoji, v.renk, v.slug, u.id
FROM universities u
CROSS JOIN (VALUES
  ('Mühendislik Fakültesi', '⚙️', '#4f46e5', 'muhendislik-gebze-teknik-universitesi'),
  ('Fen-Edebiyat Fakültesi', '🔬', '#7c3aed', 'fen-edebiyat-gebze-teknik-universitesi'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'iibf-gebze-teknik-universitesi'),
  ('Mimarlık Fakültesi', '🏗️', '#d97706', 'mimarlik-gebze-teknik-universitesi')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'gebze-teknik-universitesi'
ON CONFLICT (slug) DO NOTHING;

-- === Eskişehir Teknik Üniversitesi ===
INSERT INTO faculties (ad, emoji, renk, slug, university_id)
SELECT v.ad, v.emoji, v.renk, v.slug, u.id
FROM universities u
CROSS JOIN (VALUES
  ('Mühendislik Fakültesi', '⚙️', '#4f46e5', 'muhendislik-eskisehir-teknik-universitesi'),
  ('Fen-Edebiyat Fakültesi', '🔬', '#7c3aed', 'fen-edebiyat-eskisehir-teknik-universitesi'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'iibf-eskisehir-teknik-universitesi'),
  ('Mimarlık Fakültesi', '🏗️', '#d97706', 'mimarlik-eskisehir-teknik-universitesi'),
  ('Turizm Fakültesi', '🏖️', '#0ea5e9', 'turizm-eskisehir-teknik-universitesi'),
  ('Meslek Yüksekokulu', '🔧', '#64748b', 'meslek-yuksekokulu-eskisehir-teknik-universitesi')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'eskisehir-teknik-universitesi'
ON CONFLICT (slug) DO NOTHING;

-- === Galatasaray Üniversitesi ===
INSERT INTO faculties (ad, emoji, renk, slug, university_id)
SELECT v.ad, v.emoji, v.renk, v.slug, u.id
FROM universities u
CROSS JOIN (VALUES
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'iibf-galatasaray-universitesi'),
  ('Hukuk Fakültesi', '⚖️', '#0891b2', 'hukuk-galatasaray-universitesi'),
  ('Fen-Edebiyat Fakültesi', '🔬', '#7c3aed', 'fen-edebiyat-galatasaray-universitesi'),
  ('İletişim Fakültesi', '📡', '#d97706', 'iletisim-galatasaray-universitesi')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'galatasaray-universitesi'
ON CONFLICT (slug) DO NOTHING;

-- === İzmir Yüksek Teknoloji Enstitüsü (İYTE) ===
INSERT INTO faculties (ad, emoji, renk, slug, university_id)
SELECT v.ad, v.emoji, v.renk, v.slug, u.id
FROM universities u
CROSS JOIN (VALUES
  ('Mühendislik Fakültesi', '⚙️', '#4f46e5', 'muhendislik-iyte'),
  ('Fen-Edebiyat Fakültesi', '🔬', '#7c3aed', 'fen-edebiyat-iyte'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'iibf-iyte'),
  ('Mimarlık Fakültesi', '🏗️', '#d97706', 'mimarlik-iyte')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'iyte'
ON CONFLICT (slug) DO NOTHING;

-- === Akdeniz Üniversitesi ===
INSERT INTO faculties (ad, emoji, renk, slug, university_id)
SELECT v.ad, v.emoji, v.renk, v.slug, u.id
FROM universities u
CROSS JOIN (VALUES
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'iibf-akdeniz-universitesi'),
  ('Hukuk Fakültesi', '⚖️', '#0891b2', 'hukuk-akdeniz-universitesi'),
  ('Eğitim Fakültesi', '🎓', '#16a34a', 'egitim-akdeniz-universitesi'),
  ('Tıp Fakültesi', '⚕️', '#dc2626', 'tip-akdeniz-universitesi'),
  ('Eczacılık Fakültesi', '💊', '#16a34a', 'eczacilik-akdeniz-universitesi'),
  ('Turizm Fakültesi', '🏖️', '#0ea5e9', 'turizm-akdeniz-universitesi'),
  ('İletişim Fakültesi', '📡', '#d97706', 'iletisim-akdeniz-universitesi'),
  ('Meslek Yüksekokulu', '🔧', '#64748b', 'meslek-yuksekokulu-akdeniz-universitesi')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'akdeniz-universitesi'
ON CONFLICT (slug) DO NOTHING;

-- === Bursa Uludağ Üniversitesi ===
INSERT INTO faculties (ad, emoji, renk, slug, university_id)
SELECT v.ad, v.emoji, v.renk, v.slug, u.id
FROM universities u
CROSS JOIN (VALUES
  ('Mühendislik Fakültesi', '⚙️', '#4f46e5', 'muhendislik-bursa-uludag-universitesi'),
  ('Fen-Edebiyat Fakültesi', '🔬', '#7c3aed', 'fen-edebiyat-bursa-uludag-universitesi'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'iibf-bursa-uludag-universitesi'),
  ('Hukuk Fakültesi', '⚖️', '#0891b2', 'hukuk-bursa-uludag-universitesi'),
  ('Eğitim Fakültesi', '🎓', '#16a34a', 'egitim-bursa-uludag-universitesi'),
  ('Tıp Fakültesi', '⚕️', '#dc2626', 'tip-bursa-uludag-universitesi'),
  ('Eczacılık Fakültesi', '💊', '#16a34a', 'eczacilik-bursa-uludag-universitesi'),
  ('Turizm Fakültesi', '🏖️', '#0ea5e9', 'turizm-bursa-uludag-universitesi'),
  ('Meslek Yüksekokulu', '🔧', '#64748b', 'meslek-yuksekokulu-bursa-uludag-universitesi')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'bursa-uludag-universitesi'
ON CONFLICT (slug) DO NOTHING;

-- === Sakarya Üniversitesi ===
INSERT INTO faculties (ad, emoji, renk, slug, university_id)
SELECT v.ad, v.emoji, v.renk, v.slug, u.id
FROM universities u
CROSS JOIN (VALUES
  ('Mühendislik Fakültesi', '⚙️', '#4f46e5', 'muhendislik-sakarya-universitesi'),
  ('Fen-Edebiyat Fakültesi', '🔬', '#7c3aed', 'fen-edebiyat-sakarya-universitesi'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'iibf-sakarya-universitesi'),
  ('Eğitim Fakültesi', '🎓', '#16a34a', 'egitim-sakarya-universitesi'),
  ('İletişim Fakültesi', '📡', '#d97706', 'iletisim-sakarya-universitesi'),
  ('Meslek Yüksekokulu', '🔧', '#64748b', 'meslek-yuksekokulu-sakarya-universitesi')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'sakarya-universitesi'
ON CONFLICT (slug) DO NOTHING;

-- === Karadeniz Teknik Üniversitesi ===
INSERT INTO faculties (ad, emoji, renk, slug, university_id)
SELECT v.ad, v.emoji, v.renk, v.slug, u.id
FROM universities u
CROSS JOIN (VALUES
  ('Mühendislik Fakültesi', '⚙️', '#4f46e5', 'muhendislik-karadeniz-teknik-universitesi'),
  ('Fen-Edebiyat Fakültesi', '🔬', '#7c3aed', 'fen-edebiyat-karadeniz-teknik-universitesi'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'iibf-karadeniz-teknik-universitesi'),
  ('Hukuk Fakültesi', '⚖️', '#0891b2', 'hukuk-karadeniz-teknik-universitesi'),
  ('Eğitim Fakültesi', '🎓', '#16a34a', 'egitim-karadeniz-teknik-universitesi'),
  ('Tıp Fakültesi', '⚕️', '#dc2626', 'tip-karadeniz-teknik-universitesi'),
  ('Eczacılık Fakültesi', '💊', '#16a34a', 'eczacilik-karadeniz-teknik-universitesi'),
  ('Meslek Yüksekokulu', '🔧', '#64748b', 'meslek-yuksekokulu-karadeniz-teknik-universitesi')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'karadeniz-teknik-universitesi'
ON CONFLICT (slug) DO NOTHING;

-- === Çukurova Üniversitesi ===
INSERT INTO faculties (ad, emoji, renk, slug, university_id)
SELECT v.ad, v.emoji, v.renk, v.slug, u.id
FROM universities u
CROSS JOIN (VALUES
  ('Mühendislik Fakültesi', '⚙️', '#4f46e5', 'muhendislik-cukurova-universitesi'),
  ('Fen-Edebiyat Fakültesi', '🔬', '#7c3aed', 'fen-edebiyat-cukurova-universitesi'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'iibf-cukurova-universitesi'),
  ('Hukuk Fakültesi', '⚖️', '#0891b2', 'hukuk-cukurova-universitesi'),
  ('Eğitim Fakültesi', '🎓', '#16a34a', 'egitim-cukurova-universitesi'),
  ('Tıp Fakültesi', '⚕️', '#dc2626', 'tip-cukurova-universitesi'),
  ('Eczacılık Fakültesi', '💊', '#16a34a', 'eczacilik-cukurova-universitesi'),
  ('Turizm Fakültesi', '🏖️', '#0ea5e9', 'turizm-cukurova-universitesi'),
  ('Meslek Yüksekokulu', '🔧', '#64748b', 'meslek-yuksekokulu-cukurova-universitesi')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'cukurova-universitesi'
ON CONFLICT (slug) DO NOTHING;

-- === Erciyes Üniversitesi ===
INSERT INTO faculties (ad, emoji, renk, slug, university_id)
SELECT v.ad, v.emoji, v.renk, v.slug, u.id
FROM universities u
CROSS JOIN (VALUES
  ('Mühendislik Fakültesi', '⚙️', '#4f46e5', 'muhendislik-erciyes-universitesi'),
  ('Fen-Edebiyat Fakültesi', '🔬', '#7c3aed', 'fen-edebiyat-erciyes-universitesi'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'iibf-erciyes-universitesi'),
  ('Hukuk Fakültesi', '⚖️', '#0891b2', 'hukuk-erciyes-universitesi'),
  ('Eğitim Fakültesi', '🎓', '#16a34a', 'egitim-erciyes-universitesi'),
  ('Tıp Fakültesi', '⚕️', '#dc2626', 'tip-erciyes-universitesi'),
  ('Eczacılık Fakültesi', '💊', '#16a34a', 'eczacilik-erciyes-universitesi'),
  ('Meslek Yüksekokulu', '🔧', '#64748b', 'meslek-yuksekokulu-erciyes-universitesi')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'erciyes-universitesi'
ON CONFLICT (slug) DO NOTHING;

-- === Atatürk Üniversitesi ===
INSERT INTO faculties (ad, emoji, renk, slug, university_id)
SELECT v.ad, v.emoji, v.renk, v.slug, u.id
FROM universities u
CROSS JOIN (VALUES
  ('Mühendislik Fakültesi', '⚙️', '#4f46e5', 'muhendislik-ataturk-universitesi'),
  ('Fen-Edebiyat Fakültesi', '🔬', '#7c3aed', 'fen-edebiyat-ataturk-universitesi'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'iibf-ataturk-universitesi'),
  ('Hukuk Fakültesi', '⚖️', '#0891b2', 'hukuk-ataturk-universitesi'),
  ('Eğitim Fakültesi', '🎓', '#16a34a', 'egitim-ataturk-universitesi'),
  ('Tıp Fakültesi', '⚕️', '#dc2626', 'tip-ataturk-universitesi'),
  ('Eczacılık Fakültesi', '💊', '#16a34a', 'eczacilik-ataturk-universitesi'),
  ('İletişim Fakültesi', '📡', '#d97706', 'iletisim-ataturk-universitesi'),
  ('Meslek Yüksekokulu', '🔧', '#64748b', 'meslek-yuksekokulu-ataturk-universitesi')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'ataturk-universitesi'
ON CONFLICT (slug) DO NOTHING;

-- === Pamukkale Üniversitesi ===
INSERT INTO faculties (ad, emoji, renk, slug, university_id)
SELECT v.ad, v.emoji, v.renk, v.slug, u.id
FROM universities u
CROSS JOIN (VALUES
  ('Mühendislik Fakültesi', '⚙️', '#4f46e5', 'muhendislik-pamukkale-universitesi'),
  ('Fen-Edebiyat Fakültesi', '🔬', '#7c3aed', 'fen-edebiyat-pamukkale-universitesi'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'iibf-pamukkale-universitesi'),
  ('Eğitim Fakültesi', '🎓', '#16a34a', 'egitim-pamukkale-universitesi'),
  ('Tıp Fakültesi', '⚕️', '#dc2626', 'tip-pamukkale-universitesi'),
  ('Turizm Fakültesi', '🏖️', '#0ea5e9', 'turizm-pamukkale-universitesi'),
  ('Meslek Yüksekokulu', '🔧', '#64748b', 'meslek-yuksekokulu-pamukkale-universitesi')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'pamukkale-universitesi'
ON CONFLICT (slug) DO NOTHING;

-- === Kocaeli Üniversitesi ===
INSERT INTO faculties (ad, emoji, renk, slug, university_id)
SELECT v.ad, v.emoji, v.renk, v.slug, u.id
FROM universities u
CROSS JOIN (VALUES
  ('Mühendislik Fakültesi', '⚙️', '#4f46e5', 'muhendislik-kocaeli-universitesi'),
  ('Fen-Edebiyat Fakültesi', '🔬', '#7c3aed', 'fen-edebiyat-kocaeli-universitesi'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'iibf-kocaeli-universitesi'),
  ('Hukuk Fakültesi', '⚖️', '#0891b2', 'hukuk-kocaeli-universitesi'),
  ('Eğitim Fakültesi', '🎓', '#16a34a', 'egitim-kocaeli-universitesi'),
  ('Tıp Fakültesi', '⚕️', '#dc2626', 'tip-kocaeli-universitesi'),
  ('İletişim Fakültesi', '📡', '#d97706', 'iletisim-kocaeli-universitesi'),
  ('Meslek Yüksekokulu', '🔧', '#64748b', 'meslek-yuksekokulu-kocaeli-universitesi')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'kocaeli-universitesi'
ON CONFLICT (slug) DO NOTHING;

-- === Selçuk Üniversitesi ===
INSERT INTO faculties (ad, emoji, renk, slug, university_id)
SELECT v.ad, v.emoji, v.renk, v.slug, u.id
FROM universities u
CROSS JOIN (VALUES
  ('Mühendislik Fakültesi', '⚙️', '#4f46e5', 'muhendislik-selcuk-universitesi'),
  ('Fen-Edebiyat Fakültesi', '🔬', '#7c3aed', 'fen-edebiyat-selcuk-universitesi'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'iibf-selcuk-universitesi'),
  ('Hukuk Fakültesi', '⚖️', '#0891b2', 'hukuk-selcuk-universitesi'),
  ('Eğitim Fakültesi', '🎓', '#16a34a', 'egitim-selcuk-universitesi'),
  ('Tıp Fakültesi', '⚕️', '#dc2626', 'tip-selcuk-universitesi'),
  ('Eczacılık Fakültesi', '💊', '#16a34a', 'eczacilik-selcuk-universitesi'),
  ('İletişim Fakültesi', '📡', '#d97706', 'iletisim-selcuk-universitesi'),
  ('Meslek Yüksekokulu', '🔧', '#64748b', 'meslek-yuksekokulu-selcuk-universitesi')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'selcuk-universitesi'
ON CONFLICT (slug) DO NOTHING;

-- === Gaziantep Üniversitesi ===
INSERT INTO faculties (ad, emoji, renk, slug, university_id)
SELECT v.ad, v.emoji, v.renk, v.slug, u.id
FROM universities u
CROSS JOIN (VALUES
  ('Mühendislik Fakültesi', '⚙️', '#4f46e5', 'muhendislik-gaziantep-universitesi'),
  ('Fen-Edebiyat Fakültesi', '🔬', '#7c3aed', 'fen-edebiyat-gaziantep-universitesi'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'iibf-gaziantep-universitesi'),
  ('Hukuk Fakültesi', '⚖️', '#0891b2', 'hukuk-gaziantep-universitesi'),
  ('Eğitim Fakültesi', '🎓', '#16a34a', 'egitim-gaziantep-universitesi'),
  ('Tıp Fakültesi', '⚕️', '#dc2626', 'tip-gaziantep-universitesi'),
  ('Eczacılık Fakültesi', '💊', '#16a34a', 'eczacilik-gaziantep-universitesi'),
  ('Meslek Yüksekokulu', '🔧', '#64748b', 'meslek-yuksekokulu-gaziantep-universitesi')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'gaziantep-universitesi'
ON CONFLICT (slug) DO NOTHING;

-- ============================================================
-- 4) Fakülteleri Bölümlerle Eşleştir (faculty_departments)
-- ============================================================
-- department_slug bazlı eşleştirme.
-- (faculty_id, department_slug) unique constraint varsa ON CONFLICT.

-- === İstanbul Teknik Üniversitesi (İTÜ) → bölüm eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'muhendislik-itu'
  AND d.slug IN ('bilgisayar-programciligi','arka-yuz-yazilim-gelistirme','oyun-gelistirme-ve-programlama','buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'fen-edebiyat-itu'
  AND d.slug IN ('felsefe','sosyoloji','psikoloji','turk-dili-ve-edebiyati','arkeoloji','sanat-tarihi','rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-itu'
  AND d.slug IN ('iktisat','isletme','maliye','calisma-ekonomisi-ve-endustri-iliskileri','bankacilik-ve-finans','muhasebe-ve-finans-yonetimi','pazarlama','siyaset-bilimi-ve-kamu-yonetimi','uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'mimarlik-itu'
  AND d.slug IN ('gorsel-iletisim-tasarimi','grafik-sanatlar','cizgi-film-ve-animasyon','dijital-oyun-tasarimi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'meslek-yuksekokulu-itu'
  AND d.slug IN ('adalet','ascilik','ofis-yonetimi-ve-sekreterlik','eczane-hizmetleri','cocuk-gelisimi','emlak-yonetimi','sac-bakimi-ve-guzellik-hizmetleri','tibbi-laboratuvar-teknikleri','dis-ticaret','bilgisayar-programciligi')
ON CONFLICT DO NOTHING;

-- === Marmara Üniversitesi → bölüm eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-marmara-universitesi'
  AND d.slug IN ('iktisat','isletme','maliye','calisma-ekonomisi-ve-endustri-iliskileri','bankacilik-ve-finans','muhasebe-ve-finans-yonetimi','pazarlama','siyaset-bilimi-ve-kamu-yonetimi','uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'hukuk-marmara-universitesi'
  AND d.slug IN ('hukuk')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'egitim-marmara-universitesi'
  AND d.slug IN ('ingilizce-ogretmenligi','almanca-ogretmenligi','fransizca-ogretmenligi','sinif-ogretmenligi','okul-oncesi-ogretmenligi','sosyal-bilgiler-ogretmenligi','ilkogretim-matematik-ogretmenligi','bilgisayar-ve-ogretim-teknolojileri','ozel-egitim-ogretmenligi','rehberlik-ve-psikolojik-danismanlik')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iletisim-marmara-universitesi'
  AND d.slug IN ('gazetecilik','radyo-televizyon-ve-sinema','halkla-iliskiler-ve-tanitim','reklamcilik','iletisim-bilimleri','gorsel-iletisim-tasarimi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'guzel-sanatlar-marmara-universitesi'
  AND d.slug IN ('resim','heykel','seramik','grafik-sanatlar','gorsel-iletisim-tasarimi','cizgi-film-ve-animasyon','dijital-oyun-tasarimi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'tip-marmara-universitesi'
  AND d.slug IN ('tibbi-laboratuvar-teknikleri','beslenme-ve-diyetetik','dil-ve-konusma-terapisi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'meslek-yuksekokulu-marmara-universitesi'
  AND d.slug IN ('adalet','ascilik','ofis-yonetimi-ve-sekreterlik','eczane-hizmetleri','cocuk-gelisimi','emlak-yonetimi','sac-bakimi-ve-guzellik-hizmetleri','tibbi-laboratuvar-teknikleri','dis-ticaret','bilgisayar-programciligi')
ON CONFLICT DO NOTHING;

-- === Yıldız Teknik Üniversitesi → bölüm eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'muhendislik-yildiz-teknik-universitesi'
  AND d.slug IN ('bilgisayar-programciligi','arka-yuz-yazilim-gelistirme','oyun-gelistirme-ve-programlama','buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'fen-edebiyat-yildiz-teknik-universitesi'
  AND d.slug IN ('felsefe','sosyoloji','psikoloji','turk-dili-ve-edebiyati','arkeoloji','sanat-tarihi','rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-yildiz-teknik-universitesi'
  AND d.slug IN ('iktisat','isletme','maliye','calisma-ekonomisi-ve-endustri-iliskileri','bankacilik-ve-finans','muhasebe-ve-finans-yonetimi','pazarlama','siyaset-bilimi-ve-kamu-yonetimi','uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'mimarlik-yildiz-teknik-universitesi'
  AND d.slug IN ('gorsel-iletisim-tasarimi','grafik-sanatlar','cizgi-film-ve-animasyon','dijital-oyun-tasarimi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'meslek-yuksekokulu-yildiz-teknik-universitesi'
  AND d.slug IN ('adalet','ascilik','ofis-yonetimi-ve-sekreterlik','eczane-hizmetleri','cocuk-gelisimi','emlak-yonetimi','sac-bakimi-ve-guzellik-hizmetleri','tibbi-laboratuvar-teknikleri','dis-ticaret','bilgisayar-programciligi')
ON CONFLICT DO NOTHING;

-- === Dokuz Eylül Üniversitesi → bölüm eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'muhendislik-dokuz-eylul-universitesi'
  AND d.slug IN ('bilgisayar-programciligi','arka-yuz-yazilim-gelistirme','oyun-gelistirme-ve-programlama','buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'fen-edebiyat-dokuz-eylul-universitesi'
  AND d.slug IN ('felsefe','sosyoloji','psikoloji','turk-dili-ve-edebiyati','arkeoloji','sanat-tarihi','rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-dokuz-eylul-universitesi'
  AND d.slug IN ('iktisat','isletme','maliye','calisma-ekonomisi-ve-endustri-iliskileri','bankacilik-ve-finans','muhasebe-ve-finans-yonetimi','pazarlama','siyaset-bilimi-ve-kamu-yonetimi','uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'hukuk-dokuz-eylul-universitesi'
  AND d.slug IN ('hukuk')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'eczacilik-dokuz-eylul-universitesi'
  AND d.slug IN ('eczacilik','eczane-hizmetleri')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'tip-dokuz-eylul-universitesi'
  AND d.slug IN ('tibbi-laboratuvar-teknikleri','beslenme-ve-diyetetik','dil-ve-konusma-terapisi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iletisim-dokuz-eylul-universitesi'
  AND d.slug IN ('gazetecilik','radyo-televizyon-ve-sinema','halkla-iliskiler-ve-tanitim','reklamcilik','iletisim-bilimleri','gorsel-iletisim-tasarimi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'turizm-dokuz-eylul-universitesi'
  AND d.slug IN ('turizm-rehberligi','turizm-ve-otel-isletmeciligi','gastronomi-ve-mutfak-sanatlari')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'meslek-yuksekokulu-dokuz-eylul-universitesi'
  AND d.slug IN ('adalet','ascilik','ofis-yonetimi-ve-sekreterlik','eczane-hizmetleri','cocuk-gelisimi','emlak-yonetimi','sac-bakimi-ve-guzellik-hizmetleri','tibbi-laboratuvar-teknikleri','dis-ticaret','bilgisayar-programciligi')
ON CONFLICT DO NOTHING;

-- === Gazi Üniversitesi → bölüm eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'muhendislik-gazi-universitesi'
  AND d.slug IN ('bilgisayar-programciligi','arka-yuz-yazilim-gelistirme','oyun-gelistirme-ve-programlama','buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'fen-edebiyat-gazi-universitesi'
  AND d.slug IN ('felsefe','sosyoloji','psikoloji','turk-dili-ve-edebiyati','arkeoloji','sanat-tarihi','rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-gazi-universitesi'
  AND d.slug IN ('iktisat','isletme','maliye','calisma-ekonomisi-ve-endustri-iliskileri','bankacilik-ve-finans','muhasebe-ve-finans-yonetimi','pazarlama','siyaset-bilimi-ve-kamu-yonetimi','uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'hukuk-gazi-universitesi'
  AND d.slug IN ('hukuk')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'egitim-gazi-universitesi'
  AND d.slug IN ('ingilizce-ogretmenligi','almanca-ogretmenligi','fransizca-ogretmenligi','sinif-ogretmenligi','okul-oncesi-ogretmenligi','sosyal-bilgiler-ogretmenligi','ilkogretim-matematik-ogretmenligi','bilgisayar-ve-ogretim-teknolojileri','ozel-egitim-ogretmenligi','rehberlik-ve-psikolojik-danismanlik')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iletisim-gazi-universitesi'
  AND d.slug IN ('gazetecilik','radyo-televizyon-ve-sinema','halkla-iliskiler-ve-tanitim','reklamcilik','iletisim-bilimleri','gorsel-iletisim-tasarimi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'tip-gazi-universitesi'
  AND d.slug IN ('tibbi-laboratuvar-teknikleri','beslenme-ve-diyetetik','dil-ve-konusma-terapisi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'meslek-yuksekokulu-gazi-universitesi'
  AND d.slug IN ('adalet','ascilik','ofis-yonetimi-ve-sekreterlik','eczane-hizmetleri','cocuk-gelisimi','emlak-yonetimi','sac-bakimi-ve-guzellik-hizmetleri','tibbi-laboratuvar-teknikleri','dis-ticaret','bilgisayar-programciligi')
ON CONFLICT DO NOTHING;

-- === Gebze Teknik Üniversitesi → bölüm eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'muhendislik-gebze-teknik-universitesi'
  AND d.slug IN ('bilgisayar-programciligi','arka-yuz-yazilim-gelistirme','oyun-gelistirme-ve-programlama','buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'fen-edebiyat-gebze-teknik-universitesi'
  AND d.slug IN ('felsefe','sosyoloji','psikoloji','turk-dili-ve-edebiyati','arkeoloji','sanat-tarihi','rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-gebze-teknik-universitesi'
  AND d.slug IN ('iktisat','isletme','maliye','calisma-ekonomisi-ve-endustri-iliskileri','bankacilik-ve-finans','muhasebe-ve-finans-yonetimi','pazarlama','siyaset-bilimi-ve-kamu-yonetimi','uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'mimarlik-gebze-teknik-universitesi'
  AND d.slug IN ('gorsel-iletisim-tasarimi','grafik-sanatlar','cizgi-film-ve-animasyon','dijital-oyun-tasarimi')
ON CONFLICT DO NOTHING;

-- === Eskişehir Teknik Üniversitesi → bölüm eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'muhendislik-eskisehir-teknik-universitesi'
  AND d.slug IN ('bilgisayar-programciligi','arka-yuz-yazilim-gelistirme','oyun-gelistirme-ve-programlama','buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'fen-edebiyat-eskisehir-teknik-universitesi'
  AND d.slug IN ('felsefe','sosyoloji','psikoloji','turk-dili-ve-edebiyati','arkeoloji','sanat-tarihi','rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-eskisehir-teknik-universitesi'
  AND d.slug IN ('iktisat','isletme','maliye','calisma-ekonomisi-ve-endustri-iliskileri','bankacilik-ve-finans','muhasebe-ve-finans-yonetimi','pazarlama','siyaset-bilimi-ve-kamu-yonetimi','uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'mimarlik-eskisehir-teknik-universitesi'
  AND d.slug IN ('gorsel-iletisim-tasarimi','grafik-sanatlar','cizgi-film-ve-animasyon','dijital-oyun-tasarimi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'turizm-eskisehir-teknik-universitesi'
  AND d.slug IN ('turizm-rehberligi','turizm-ve-otel-isletmeciligi','gastronomi-ve-mutfak-sanatlari')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'meslek-yuksekokulu-eskisehir-teknik-universitesi'
  AND d.slug IN ('adalet','ascilik','ofis-yonetimi-ve-sekreterlik','eczane-hizmetleri','cocuk-gelisimi','emlak-yonetimi','sac-bakimi-ve-guzellik-hizmetleri','tibbi-laboratuvar-teknikleri','dis-ticaret','bilgisayar-programciligi')
ON CONFLICT DO NOTHING;

-- === Galatasaray Üniversitesi → bölüm eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-galatasaray-universitesi'
  AND d.slug IN ('iktisat','isletme','maliye','calisma-ekonomisi-ve-endustri-iliskileri','bankacilik-ve-finans','muhasebe-ve-finans-yonetimi','pazarlama','siyaset-bilimi-ve-kamu-yonetimi','uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'hukuk-galatasaray-universitesi'
  AND d.slug IN ('hukuk')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'fen-edebiyat-galatasaray-universitesi'
  AND d.slug IN ('felsefe','sosyoloji','psikoloji','turk-dili-ve-edebiyati','arkeoloji','sanat-tarihi','rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iletisim-galatasaray-universitesi'
  AND d.slug IN ('gazetecilik','radyo-televizyon-ve-sinema','halkla-iliskiler-ve-tanitim','reklamcilik','iletisim-bilimleri','gorsel-iletisim-tasarimi')
ON CONFLICT DO NOTHING;

-- === İzmir Yüksek Teknoloji Enstitüsü (İYTE) → bölüm eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'muhendislik-iyte'
  AND d.slug IN ('bilgisayar-programciligi','arka-yuz-yazilim-gelistirme','oyun-gelistirme-ve-programlama','buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'fen-edebiyat-iyte'
  AND d.slug IN ('felsefe','sosyoloji','psikoloji','turk-dili-ve-edebiyati','arkeoloji','sanat-tarihi','rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-iyte'
  AND d.slug IN ('iktisat','isletme','maliye','calisma-ekonomisi-ve-endustri-iliskileri','bankacilik-ve-finans','muhasebe-ve-finans-yonetimi','pazarlama','siyaset-bilimi-ve-kamu-yonetimi','uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'mimarlik-iyte'
  AND d.slug IN ('gorsel-iletisim-tasarimi','grafik-sanatlar','cizgi-film-ve-animasyon','dijital-oyun-tasarimi')
ON CONFLICT DO NOTHING;

-- === Akdeniz Üniversitesi → bölüm eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-akdeniz-universitesi'
  AND d.slug IN ('iktisat','isletme','maliye','calisma-ekonomisi-ve-endustri-iliskileri','bankacilik-ve-finans','muhasebe-ve-finans-yonetimi','pazarlama','siyaset-bilimi-ve-kamu-yonetimi','uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'hukuk-akdeniz-universitesi'
  AND d.slug IN ('hukuk')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'egitim-akdeniz-universitesi'
  AND d.slug IN ('ingilizce-ogretmenligi','almanca-ogretmenligi','fransizca-ogretmenligi','sinif-ogretmenligi','okul-oncesi-ogretmenligi','sosyal-bilgiler-ogretmenligi','ilkogretim-matematik-ogretmenligi','bilgisayar-ve-ogretim-teknolojileri','ozel-egitim-ogretmenligi','rehberlik-ve-psikolojik-danismanlik')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'tip-akdeniz-universitesi'
  AND d.slug IN ('tibbi-laboratuvar-teknikleri','beslenme-ve-diyetetik','dil-ve-konusma-terapisi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'eczacilik-akdeniz-universitesi'
  AND d.slug IN ('eczacilik','eczane-hizmetleri')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'turizm-akdeniz-universitesi'
  AND d.slug IN ('turizm-rehberligi','turizm-ve-otel-isletmeciligi','gastronomi-ve-mutfak-sanatlari')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iletisim-akdeniz-universitesi'
  AND d.slug IN ('gazetecilik','radyo-televizyon-ve-sinema','halkla-iliskiler-ve-tanitim','reklamcilik','iletisim-bilimleri','gorsel-iletisim-tasarimi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'meslek-yuksekokulu-akdeniz-universitesi'
  AND d.slug IN ('adalet','ascilik','ofis-yonetimi-ve-sekreterlik','eczane-hizmetleri','cocuk-gelisimi','emlak-yonetimi','sac-bakimi-ve-guzellik-hizmetleri','tibbi-laboratuvar-teknikleri','dis-ticaret','bilgisayar-programciligi')
ON CONFLICT DO NOTHING;

-- === Bursa Uludağ Üniversitesi → bölüm eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'muhendislik-bursa-uludag-universitesi'
  AND d.slug IN ('bilgisayar-programciligi','arka-yuz-yazilim-gelistirme','oyun-gelistirme-ve-programlama','buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'fen-edebiyat-bursa-uludag-universitesi'
  AND d.slug IN ('felsefe','sosyoloji','psikoloji','turk-dili-ve-edebiyati','arkeoloji','sanat-tarihi','rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-bursa-uludag-universitesi'
  AND d.slug IN ('iktisat','isletme','maliye','calisma-ekonomisi-ve-endustri-iliskileri','bankacilik-ve-finans','muhasebe-ve-finans-yonetimi','pazarlama','siyaset-bilimi-ve-kamu-yonetimi','uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'hukuk-bursa-uludag-universitesi'
  AND d.slug IN ('hukuk')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'egitim-bursa-uludag-universitesi'
  AND d.slug IN ('ingilizce-ogretmenligi','almanca-ogretmenligi','fransizca-ogretmenligi','sinif-ogretmenligi','okul-oncesi-ogretmenligi','sosyal-bilgiler-ogretmenligi','ilkogretim-matematik-ogretmenligi','bilgisayar-ve-ogretim-teknolojileri','ozel-egitim-ogretmenligi','rehberlik-ve-psikolojik-danismanlik')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'tip-bursa-uludag-universitesi'
  AND d.slug IN ('tibbi-laboratuvar-teknikleri','beslenme-ve-diyetetik','dil-ve-konusma-terapisi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'eczacilik-bursa-uludag-universitesi'
  AND d.slug IN ('eczacilik','eczane-hizmetleri')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'turizm-bursa-uludag-universitesi'
  AND d.slug IN ('turizm-rehberligi','turizm-ve-otel-isletmeciligi','gastronomi-ve-mutfak-sanatlari')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'meslek-yuksekokulu-bursa-uludag-universitesi'
  AND d.slug IN ('adalet','ascilik','ofis-yonetimi-ve-sekreterlik','eczane-hizmetleri','cocuk-gelisimi','emlak-yonetimi','sac-bakimi-ve-guzellik-hizmetleri','tibbi-laboratuvar-teknikleri','dis-ticaret','bilgisayar-programciligi')
ON CONFLICT DO NOTHING;

-- === Sakarya Üniversitesi → bölüm eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'muhendislik-sakarya-universitesi'
  AND d.slug IN ('bilgisayar-programciligi','arka-yuz-yazilim-gelistirme','oyun-gelistirme-ve-programlama','buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'fen-edebiyat-sakarya-universitesi'
  AND d.slug IN ('felsefe','sosyoloji','psikoloji','turk-dili-ve-edebiyati','arkeoloji','sanat-tarihi','rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-sakarya-universitesi'
  AND d.slug IN ('iktisat','isletme','maliye','calisma-ekonomisi-ve-endustri-iliskileri','bankacilik-ve-finans','muhasebe-ve-finans-yonetimi','pazarlama','siyaset-bilimi-ve-kamu-yonetimi','uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'egitim-sakarya-universitesi'
  AND d.slug IN ('ingilizce-ogretmenligi','almanca-ogretmenligi','fransizca-ogretmenligi','sinif-ogretmenligi','okul-oncesi-ogretmenligi','sosyal-bilgiler-ogretmenligi','ilkogretim-matematik-ogretmenligi','bilgisayar-ve-ogretim-teknolojileri','ozel-egitim-ogretmenligi','rehberlik-ve-psikolojik-danismanlik')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iletisim-sakarya-universitesi'
  AND d.slug IN ('gazetecilik','radyo-televizyon-ve-sinema','halkla-iliskiler-ve-tanitim','reklamcilik','iletisim-bilimleri','gorsel-iletisim-tasarimi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'meslek-yuksekokulu-sakarya-universitesi'
  AND d.slug IN ('adalet','ascilik','ofis-yonetimi-ve-sekreterlik','eczane-hizmetleri','cocuk-gelisimi','emlak-yonetimi','sac-bakimi-ve-guzellik-hizmetleri','tibbi-laboratuvar-teknikleri','dis-ticaret','bilgisayar-programciligi')
ON CONFLICT DO NOTHING;

-- === Karadeniz Teknik Üniversitesi → bölüm eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'muhendislik-karadeniz-teknik-universitesi'
  AND d.slug IN ('bilgisayar-programciligi','arka-yuz-yazilim-gelistirme','oyun-gelistirme-ve-programlama','buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'fen-edebiyat-karadeniz-teknik-universitesi'
  AND d.slug IN ('felsefe','sosyoloji','psikoloji','turk-dili-ve-edebiyati','arkeoloji','sanat-tarihi','rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-karadeniz-teknik-universitesi'
  AND d.slug IN ('iktisat','isletme','maliye','calisma-ekonomisi-ve-endustri-iliskileri','bankacilik-ve-finans','muhasebe-ve-finans-yonetimi','pazarlama','siyaset-bilimi-ve-kamu-yonetimi','uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'hukuk-karadeniz-teknik-universitesi'
  AND d.slug IN ('hukuk')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'egitim-karadeniz-teknik-universitesi'
  AND d.slug IN ('ingilizce-ogretmenligi','almanca-ogretmenligi','fransizca-ogretmenligi','sinif-ogretmenligi','okul-oncesi-ogretmenligi','sosyal-bilgiler-ogretmenligi','ilkogretim-matematik-ogretmenligi','bilgisayar-ve-ogretim-teknolojileri','ozel-egitim-ogretmenligi','rehberlik-ve-psikolojik-danismanlik')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'tip-karadeniz-teknik-universitesi'
  AND d.slug IN ('tibbi-laboratuvar-teknikleri','beslenme-ve-diyetetik','dil-ve-konusma-terapisi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'eczacilik-karadeniz-teknik-universitesi'
  AND d.slug IN ('eczacilik','eczane-hizmetleri')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'meslek-yuksekokulu-karadeniz-teknik-universitesi'
  AND d.slug IN ('adalet','ascilik','ofis-yonetimi-ve-sekreterlik','eczane-hizmetleri','cocuk-gelisimi','emlak-yonetimi','sac-bakimi-ve-guzellik-hizmetleri','tibbi-laboratuvar-teknikleri','dis-ticaret','bilgisayar-programciligi')
ON CONFLICT DO NOTHING;

-- === Çukurova Üniversitesi → bölüm eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'muhendislik-cukurova-universitesi'
  AND d.slug IN ('bilgisayar-programciligi','arka-yuz-yazilim-gelistirme','oyun-gelistirme-ve-programlama','buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'fen-edebiyat-cukurova-universitesi'
  AND d.slug IN ('felsefe','sosyoloji','psikoloji','turk-dili-ve-edebiyati','arkeoloji','sanat-tarihi','rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-cukurova-universitesi'
  AND d.slug IN ('iktisat','isletme','maliye','calisma-ekonomisi-ve-endustri-iliskileri','bankacilik-ve-finans','muhasebe-ve-finans-yonetimi','pazarlama','siyaset-bilimi-ve-kamu-yonetimi','uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'hukuk-cukurova-universitesi'
  AND d.slug IN ('hukuk')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'egitim-cukurova-universitesi'
  AND d.slug IN ('ingilizce-ogretmenligi','almanca-ogretmenligi','fransizca-ogretmenligi','sinif-ogretmenligi','okul-oncesi-ogretmenligi','sosyal-bilgiler-ogretmenligi','ilkogretim-matematik-ogretmenligi','bilgisayar-ve-ogretim-teknolojileri','ozel-egitim-ogretmenligi','rehberlik-ve-psikolojik-danismanlik')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'tip-cukurova-universitesi'
  AND d.slug IN ('tibbi-laboratuvar-teknikleri','beslenme-ve-diyetetik','dil-ve-konusma-terapisi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'eczacilik-cukurova-universitesi'
  AND d.slug IN ('eczacilik','eczane-hizmetleri')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'turizm-cukurova-universitesi'
  AND d.slug IN ('turizm-rehberligi','turizm-ve-otel-isletmeciligi','gastronomi-ve-mutfak-sanatlari')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'meslek-yuksekokulu-cukurova-universitesi'
  AND d.slug IN ('adalet','ascilik','ofis-yonetimi-ve-sekreterlik','eczane-hizmetleri','cocuk-gelisimi','emlak-yonetimi','sac-bakimi-ve-guzellik-hizmetleri','tibbi-laboratuvar-teknikleri','dis-ticaret','bilgisayar-programciligi')
ON CONFLICT DO NOTHING;

-- === Erciyes Üniversitesi → bölüm eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'muhendislik-erciyes-universitesi'
  AND d.slug IN ('bilgisayar-programciligi','arka-yuz-yazilim-gelistirme','oyun-gelistirme-ve-programlama','buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'fen-edebiyat-erciyes-universitesi'
  AND d.slug IN ('felsefe','sosyoloji','psikoloji','turk-dili-ve-edebiyati','arkeoloji','sanat-tarihi','rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-erciyes-universitesi'
  AND d.slug IN ('iktisat','isletme','maliye','calisma-ekonomisi-ve-endustri-iliskileri','bankacilik-ve-finans','muhasebe-ve-finans-yonetimi','pazarlama','siyaset-bilimi-ve-kamu-yonetimi','uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'hukuk-erciyes-universitesi'
  AND d.slug IN ('hukuk')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'egitim-erciyes-universitesi'
  AND d.slug IN ('ingilizce-ogretmenligi','almanca-ogretmenligi','fransizca-ogretmenligi','sinif-ogretmenligi','okul-oncesi-ogretmenligi','sosyal-bilgiler-ogretmenligi','ilkogretim-matematik-ogretmenligi','bilgisayar-ve-ogretim-teknolojileri','ozel-egitim-ogretmenligi','rehberlik-ve-psikolojik-danismanlik')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'tip-erciyes-universitesi'
  AND d.slug IN ('tibbi-laboratuvar-teknikleri','beslenme-ve-diyetetik','dil-ve-konusma-terapisi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'eczacilik-erciyes-universitesi'
  AND d.slug IN ('eczacilik','eczane-hizmetleri')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'meslek-yuksekokulu-erciyes-universitesi'
  AND d.slug IN ('adalet','ascilik','ofis-yonetimi-ve-sekreterlik','eczane-hizmetleri','cocuk-gelisimi','emlak-yonetimi','sac-bakimi-ve-guzellik-hizmetleri','tibbi-laboratuvar-teknikleri','dis-ticaret','bilgisayar-programciligi')
ON CONFLICT DO NOTHING;

-- === Atatürk Üniversitesi → bölüm eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'muhendislik-ataturk-universitesi'
  AND d.slug IN ('bilgisayar-programciligi','arka-yuz-yazilim-gelistirme','oyun-gelistirme-ve-programlama','buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'fen-edebiyat-ataturk-universitesi'
  AND d.slug IN ('felsefe','sosyoloji','psikoloji','turk-dili-ve-edebiyati','arkeoloji','sanat-tarihi','rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-ataturk-universitesi'
  AND d.slug IN ('iktisat','isletme','maliye','calisma-ekonomisi-ve-endustri-iliskileri','bankacilik-ve-finans','muhasebe-ve-finans-yonetimi','pazarlama','siyaset-bilimi-ve-kamu-yonetimi','uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'hukuk-ataturk-universitesi'
  AND d.slug IN ('hukuk')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'egitim-ataturk-universitesi'
  AND d.slug IN ('ingilizce-ogretmenligi','almanca-ogretmenligi','fransizca-ogretmenligi','sinif-ogretmenligi','okul-oncesi-ogretmenligi','sosyal-bilgiler-ogretmenligi','ilkogretim-matematik-ogretmenligi','bilgisayar-ve-ogretim-teknolojileri','ozel-egitim-ogretmenligi','rehberlik-ve-psikolojik-danismanlik')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'tip-ataturk-universitesi'
  AND d.slug IN ('tibbi-laboratuvar-teknikleri','beslenme-ve-diyetetik','dil-ve-konusma-terapisi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'eczacilik-ataturk-universitesi'
  AND d.slug IN ('eczacilik','eczane-hizmetleri')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iletisim-ataturk-universitesi'
  AND d.slug IN ('gazetecilik','radyo-televizyon-ve-sinema','halkla-iliskiler-ve-tanitim','reklamcilik','iletisim-bilimleri','gorsel-iletisim-tasarimi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'meslek-yuksekokulu-ataturk-universitesi'
  AND d.slug IN ('adalet','ascilik','ofis-yonetimi-ve-sekreterlik','eczane-hizmetleri','cocuk-gelisimi','emlak-yonetimi','sac-bakimi-ve-guzellik-hizmetleri','tibbi-laboratuvar-teknikleri','dis-ticaret','bilgisayar-programciligi')
ON CONFLICT DO NOTHING;

-- === Pamukkale Üniversitesi → bölüm eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'muhendislik-pamukkale-universitesi'
  AND d.slug IN ('bilgisayar-programciligi','arka-yuz-yazilim-gelistirme','oyun-gelistirme-ve-programlama','buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'fen-edebiyat-pamukkale-universitesi'
  AND d.slug IN ('felsefe','sosyoloji','psikoloji','turk-dili-ve-edebiyati','arkeoloji','sanat-tarihi','rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-pamukkale-universitesi'
  AND d.slug IN ('iktisat','isletme','maliye','calisma-ekonomisi-ve-endustri-iliskileri','bankacilik-ve-finans','muhasebe-ve-finans-yonetimi','pazarlama','siyaset-bilimi-ve-kamu-yonetimi','uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'egitim-pamukkale-universitesi'
  AND d.slug IN ('ingilizce-ogretmenligi','almanca-ogretmenligi','fransizca-ogretmenligi','sinif-ogretmenligi','okul-oncesi-ogretmenligi','sosyal-bilgiler-ogretmenligi','ilkogretim-matematik-ogretmenligi','bilgisayar-ve-ogretim-teknolojileri','ozel-egitim-ogretmenligi','rehberlik-ve-psikolojik-danismanlik')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'tip-pamukkale-universitesi'
  AND d.slug IN ('tibbi-laboratuvar-teknikleri','beslenme-ve-diyetetik','dil-ve-konusma-terapisi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'turizm-pamukkale-universitesi'
  AND d.slug IN ('turizm-rehberligi','turizm-ve-otel-isletmeciligi','gastronomi-ve-mutfak-sanatlari')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'meslek-yuksekokulu-pamukkale-universitesi'
  AND d.slug IN ('adalet','ascilik','ofis-yonetimi-ve-sekreterlik','eczane-hizmetleri','cocuk-gelisimi','emlak-yonetimi','sac-bakimi-ve-guzellik-hizmetleri','tibbi-laboratuvar-teknikleri','dis-ticaret','bilgisayar-programciligi')
ON CONFLICT DO NOTHING;

-- === Kocaeli Üniversitesi → bölüm eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'muhendislik-kocaeli-universitesi'
  AND d.slug IN ('bilgisayar-programciligi','arka-yuz-yazilim-gelistirme','oyun-gelistirme-ve-programlama','buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'fen-edebiyat-kocaeli-universitesi'
  AND d.slug IN ('felsefe','sosyoloji','psikoloji','turk-dili-ve-edebiyati','arkeoloji','sanat-tarihi','rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-kocaeli-universitesi'
  AND d.slug IN ('iktisat','isletme','maliye','calisma-ekonomisi-ve-endustri-iliskileri','bankacilik-ve-finans','muhasebe-ve-finans-yonetimi','pazarlama','siyaset-bilimi-ve-kamu-yonetimi','uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'hukuk-kocaeli-universitesi'
  AND d.slug IN ('hukuk')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'egitim-kocaeli-universitesi'
  AND d.slug IN ('ingilizce-ogretmenligi','almanca-ogretmenligi','fransizca-ogretmenligi','sinif-ogretmenligi','okul-oncesi-ogretmenligi','sosyal-bilgiler-ogretmenligi','ilkogretim-matematik-ogretmenligi','bilgisayar-ve-ogretim-teknolojileri','ozel-egitim-ogretmenligi','rehberlik-ve-psikolojik-danismanlik')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'tip-kocaeli-universitesi'
  AND d.slug IN ('tibbi-laboratuvar-teknikleri','beslenme-ve-diyetetik','dil-ve-konusma-terapisi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iletisim-kocaeli-universitesi'
  AND d.slug IN ('gazetecilik','radyo-televizyon-ve-sinema','halkla-iliskiler-ve-tanitim','reklamcilik','iletisim-bilimleri','gorsel-iletisim-tasarimi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'meslek-yuksekokulu-kocaeli-universitesi'
  AND d.slug IN ('adalet','ascilik','ofis-yonetimi-ve-sekreterlik','eczane-hizmetleri','cocuk-gelisimi','emlak-yonetimi','sac-bakimi-ve-guzellik-hizmetleri','tibbi-laboratuvar-teknikleri','dis-ticaret','bilgisayar-programciligi')
ON CONFLICT DO NOTHING;

-- === Selçuk Üniversitesi → bölüm eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'muhendislik-selcuk-universitesi'
  AND d.slug IN ('bilgisayar-programciligi','arka-yuz-yazilim-gelistirme','oyun-gelistirme-ve-programlama','buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'fen-edebiyat-selcuk-universitesi'
  AND d.slug IN ('felsefe','sosyoloji','psikoloji','turk-dili-ve-edebiyati','arkeoloji','sanat-tarihi','rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-selcuk-universitesi'
  AND d.slug IN ('iktisat','isletme','maliye','calisma-ekonomisi-ve-endustri-iliskileri','bankacilik-ve-finans','muhasebe-ve-finans-yonetimi','pazarlama','siyaset-bilimi-ve-kamu-yonetimi','uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'hukuk-selcuk-universitesi'
  AND d.slug IN ('hukuk')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'egitim-selcuk-universitesi'
  AND d.slug IN ('ingilizce-ogretmenligi','almanca-ogretmenligi','fransizca-ogretmenligi','sinif-ogretmenligi','okul-oncesi-ogretmenligi','sosyal-bilgiler-ogretmenligi','ilkogretim-matematik-ogretmenligi','bilgisayar-ve-ogretim-teknolojileri','ozel-egitim-ogretmenligi','rehberlik-ve-psikolojik-danismanlik')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'tip-selcuk-universitesi'
  AND d.slug IN ('tibbi-laboratuvar-teknikleri','beslenme-ve-diyetetik','dil-ve-konusma-terapisi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'eczacilik-selcuk-universitesi'
  AND d.slug IN ('eczacilik','eczane-hizmetleri')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iletisim-selcuk-universitesi'
  AND d.slug IN ('gazetecilik','radyo-televizyon-ve-sinema','halkla-iliskiler-ve-tanitim','reklamcilik','iletisim-bilimleri','gorsel-iletisim-tasarimi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'meslek-yuksekokulu-selcuk-universitesi'
  AND d.slug IN ('adalet','ascilik','ofis-yonetimi-ve-sekreterlik','eczane-hizmetleri','cocuk-gelisimi','emlak-yonetimi','sac-bakimi-ve-guzellik-hizmetleri','tibbi-laboratuvar-teknikleri','dis-ticaret','bilgisayar-programciligi')
ON CONFLICT DO NOTHING;

-- === Gaziantep Üniversitesi → bölüm eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'muhendislik-gaziantep-universitesi'
  AND d.slug IN ('bilgisayar-programciligi','arka-yuz-yazilim-gelistirme','oyun-gelistirme-ve-programlama','buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'fen-edebiyat-gaziantep-universitesi'
  AND d.slug IN ('felsefe','sosyoloji','psikoloji','turk-dili-ve-edebiyati','arkeoloji','sanat-tarihi','rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-gaziantep-universitesi'
  AND d.slug IN ('iktisat','isletme','maliye','calisma-ekonomisi-ve-endustri-iliskileri','bankacilik-ve-finans','muhasebe-ve-finans-yonetimi','pazarlama','siyaset-bilimi-ve-kamu-yonetimi','uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'hukuk-gaziantep-universitesi'
  AND d.slug IN ('hukuk')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'egitim-gaziantep-universitesi'
  AND d.slug IN ('ingilizce-ogretmenligi','almanca-ogretmenligi','fransizca-ogretmenligi','sinif-ogretmenligi','okul-oncesi-ogretmenligi','sosyal-bilgiler-ogretmenligi','ilkogretim-matematik-ogretmenligi','bilgisayar-ve-ogretim-teknolojileri','ozel-egitim-ogretmenligi','rehberlik-ve-psikolojik-danismanlik')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'tip-gaziantep-universitesi'
  AND d.slug IN ('tibbi-laboratuvar-teknikleri','beslenme-ve-diyetetik','dil-ve-konusma-terapisi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'eczacilik-gaziantep-universitesi'
  AND d.slug IN ('eczacilik','eczane-hizmetleri')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'meslek-yuksekokulu-gaziantep-universitesi'
  AND d.slug IN ('adalet','ascilik','ofis-yonetimi-ve-sekreterlik','eczane-hizmetleri','cocuk-gelisimi','emlak-yonetimi','sac-bakimi-ve-guzellik-hizmetleri','tibbi-laboratuvar-teknikleri','dis-ticaret','bilgisayar-programciligi')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 5) 56 Bölümün Müfredatlarını Ekle (idempotent)
-- ============================================================
-- Her bölüm için: eğer bölümde hiç ders yoksa, tüm müfredatı ekle.
-- NOT EXISTS subquery ile kontrol edilir.
-- Tekrar çalıştırılırsa, zaten ders olan bölümler atlanır.

-- === Adalet (adalet) — 28 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Türk Hukuk Sistemi'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Anayasa Hukuku'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Medeni Hukuka Giriş'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Hukuk Başlangıcı'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Atatürk İlkeleri ve İnkılap Tarihi I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Yabancı Dil I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Bilgisayar Kullanımı'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Ceza Hukuku Genel Hükümler'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Borçlar Hukuku Genel Hükümler'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'İdare Hukuku'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Eşya Hukuku'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Atatürk İlkeleri ve İnkılap Tarihi II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Yabancı Dil II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Ceza Muhakemesi Hukuku'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Ticaret Hukuku'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Aile Hukuku'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Medeni Usul Hukuku'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Devlet Teşkilatı'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'İnfaz Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'İcra ve İflas Hukuku'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'İş Hukuku'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Kamu Hukuku Uygulamaları'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Adli Tıp'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Noterlik Hukuku'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid, 'Staj'::text, 4::int, 0::int, 0::numeric, 0.5::numeric, 0.5::numeric, 0::numeric, 4::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = 'e7c2b69f-dd0b-4aff-89a5-9656746a5a20'::uuid LIMIT 1
);

-- === Almanca Ogretmenligi (almanca-ogretmenligi) — 52 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Almanca Dilbilgisi I'::text, 4::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Almanca Okuma I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Almanca Yazma I'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Almanca Konuşma I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0.1::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Alman Edebiyatına Giriş'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Yabancı Dil I (İngilizce)'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Almanca Dilbilgisi II'::text, 4::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Almanca Okuma II'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Almanca Yazma II'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Almanca Konuşma II'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0.1::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Alman Edebiyatı Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Yabancı Dil II (İngilizce)'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Almanca Çeviri I'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Alman Edebiyatı Klasikleri'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Öğretim İlke ve Yöntemleri'::text, 4::int, 4::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Alman Kültürü ve Medeniyeti'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Almanca Sözlü İletişim'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Linguistik I'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Bilgisayar Becerileri'::text, 2::int, 2::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Almanca Çeviri II'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Çağdaş Alman Edebiyatı'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Öğretim Teknolojileri'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Alman Sineması'::text, 3::int, 3::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Linguistik II'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Sınıf Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Özel Öğretim Yöntemleri I'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Alman Edebiyatı Analizi'::text, 4::int, 4::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Çocuk Edebiyatı'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Ölçme ve Değerlendirme'::text, 4::int, 4::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Özel Öğretim Yöntemleri II'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Almanca Akademik Yazım'::text, 3::int, 3::int, 0.3::numeric, 0.4::numeric, 0::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Rehberlik'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Alman Dili ve Edebiyatı Semineri'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.2::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Karşılaştırmalı Edebiyat'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Topluma Hizmet Uygulamaları'::text, 2::int, 2::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Almanca İş Almanca'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Türk-Alman Kültürel İlişkileri'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Okuma Eğitimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Öğretmenlik Uygulaması I'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Alman Eğitim Sistemi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Çeviri Uygulamaları'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 7::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'AVrupa Birliği ve Almanya'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Bitirme Çalışması I'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Öğretmenlik Uygulaması II'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Bitirme Çalışması II'::text, 4::int, 4::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Seçmeli: Alman Felsefesi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid, 'Seçmeli: Çağdaş Alman Şiiri'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '90e1bfb5-b742-41ad-b949-c12874b99bd0'::uuid LIMIT 1
);

-- === Arka Yuz Yazilim Gelistirme (arka-yuz-yazilim-gelistirme) — 27 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'Programlamaya Giriş'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'Bilgisayar Mimarisi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'Matematik for Yazılımcılar'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'Veritabanı Yönetim Sistemleri'::text, 4::int, 3::int, 0.3::numeric, 0.2::numeric, 0.1::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'İşletim Sistemleri'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'Nesne Tabanlı Programlama'::text, 5::int, 4::int, 0.3::numeric, 0.2::numeric, 0.1::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'Veri Yapıları ve Algoritmalar'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'İlişkisel Veritabanı Tasarımı'::text, 4::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'Web Programlama I'::text, 4::int, 3::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'Bilgisayar Ağları'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'Backend Framework I (Node.js)'::text, 5::int, 4::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'RESTful API Tasarımı'::text, 4::int, 3::int, 0.2::numeric, 0.3::numeric, 0.2::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'SQL ve NoSQL Veritabanları'::text, 4::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'Git ve Sürüm Kontrol'::text, 3::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'Yazılım Mühendisliği İlkeleri'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'Bulut Bilişim Temelleri'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'Backend Framework II'::text, 5::int, 4::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'Mikroservis Mimarisi'::text, 4::int, 3::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'DevOps ve CI/CD'::text, 4::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'Güvenli Yazılım Geliştirme'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'Bitirme Projesi'::text, 5::int, 5::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'Staj'::text, 4::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('17d76800-d904-468f-9c0e-b435fe3daa25'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '17d76800-d904-468f-9c0e-b435fe3daa25'::uuid LIMIT 1
);

-- === Arkeoloji (arkeoloji) — 46 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Arkeolojiye Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Prehistorya I (Paleolitik-Neolitik)'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Klasik Arkeolojiye Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Eskiçağ Tarihi I'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Antik Coğrafya'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Prehistorya II (Kalkolitik)'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Anadolu Arkeolojisi I'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Yunan Arkeolojisi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Eskiçağ Tarihi II'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Mitoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Anadolu Arkeolojisi II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Roma Arkeolojisi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Klasik Diller I (Latince)'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Antik Sanat Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Arkeolojik Çizim'::text, 3::int, 3::int, 0.2::numeric, 0.3::numeric, 0.2::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Epigrafi I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Anadolu Arkeolojisi III'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Bizans Arkeolojisi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Klasik Diller II (Latince)'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Numismatik'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Antik Kentler'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Arkeometri'::text, 3::int, 3::int, 0.3::numeric, 0.2::numeric, 0.1::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'İslam Arkeolojisi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Türk Arkeolojisi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Klasik Diller III (Eski Yunanca)'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Arkeoloji ve Müzecilik'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Kazı Tekniği'::text, 3::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Antik Anıtlar'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Anadolu Uygarlıkları'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Klasik Diller IV (Eski Yunanca)'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Arkeolojik Araştırma Yöntemleri'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Koruma ve Restorasyon'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Antik Portre ve Heykel'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Topluma Hizmet'::text, 2::int, 2::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Bitirme Çalışması I'::text, 5::int, 5::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Alan Seçmeleri I'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Arkeolojide Bilgisayar Uygulamaları'::text, 3::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Kültürel Miras Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Bitirme Çalışması II'::text, 5::int, 5::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Alan Seçmeleri II'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Staj'::text, 5::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = 'a2034d76-1b5d-4bb4-870f-d5e35b4aa449'::uuid LIMIT 1
);

-- === Ascilik (ascilik) — 26 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Mutfak Kültürü ve Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Temel Mutfak Teknikleri I'::text, 5::int, 6::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Gıda Güvenliği ve Hijyen'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Türk Mutfağı I'::text, 4::int, 5::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Mutfak Matematiği'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Temel Mutfak Teknikleri II'::text, 5::int, 6::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Türk Mutfağı II'::text, 4::int, 5::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Hamur İşleri ve Unlu Mamuller'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Çorba ve Soslar'::text, 3::int, 4::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Avrupa Mutfağı I'::text, 5::int, 6::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Et ve Balık Hazırlama'::text, 4::int, 5::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Tatlı ve Pastacılık I'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Mutfak Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'İçecek Bilgisi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Maliyet Kontrolü'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Avrupa Mutfağı II'::text, 5::int, 6::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Dünya Mutfağı'::text, 4::int, 5::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Tatlı ve Pastacılık II'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Meniü Planlama'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Restoran Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Staj'::text, 4::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('a111f867-ff06-458e-a621-d863ac177f79'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = 'a111f867-ff06-458e-a621-d863ac177f79'::uuid LIMIT 1
);

-- === Bankacilik Ve Finans (bankacilik-ve-finans) — 44 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'İktisada Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'İşletme İlkeleri'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Muhasebeye Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Hukuk Başlangıcı'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Matematik I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Makro İktisat'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Finansal Matematik'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Genel Muhasebe'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Medeni Hukuk'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'İstatistik I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Para ve Bankacılık'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Ticaret Hukuku'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Mali Tablolar Analizi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'İşletme Finansı'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Banka Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Muhasebe Uygulamaları'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Bankacılık İşlemleri'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Kredi Yönetimi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Ticari Bankacılık'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Finansal Yönetim'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Vergi Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Ulusal ve Uluslararası Finans'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Risk Yönetimi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Bankacılıkta Bilgi Sistemleri'::text, 4::int, 3::int, 0.3::numeric, 0.2::numeric, 0.1::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Yatırım Analizi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Türev Ürünler'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Uluslararası Bankacılık'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Finansal Piyasalar'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Merkez Bankacılığı'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Fintech ve Dijital Bankacılık'::text, 4::int, 3::int, 0.3::numeric, 0.2::numeric, 0.1::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Mali Suçlar ve KYC'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Kurumsal Finans'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 7::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Sermaye Piyasası'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 7::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Bitirme Çalışması I'::text, 4::int, 4::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Staj'::text, 4::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Seçmeli: Davranışsal Finans'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Bankacılık Stratejisi'::text, 5::int, 4::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Bitirme Çalışması II'::text, 5::int, 5::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Müşteri İlişkileri Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '7cb13135-0c6d-4d5a-b3b7-06bb56b7ed05'::uuid LIMIT 1
);

-- === Beslenme Ve Diyetetik (beslenme-ve-diyetetik) — 44 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Anatomi I'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Fizyoloji I'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Genel Beslenme I'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Besin Kimyası'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Genel Biyokimya I'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Anatomi II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Fizyoloji II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Genel Beslenme II'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Besin Mikrobiyolojisi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Genel Biyokimya II'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Beslenme Biyokimyası'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Tıbbi Beslenme I'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Toplu Beslenme Sistemleri I'::text, 4::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Besin Hijyeni ve Sanitasyon'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Halk Sağlığı'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'İstatistik'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Tıbbi Beslenme II'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Toplu Beslenme Sistemleri II'::text, 4::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Diyet Tedavisi I'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Anne ve Çocuk Beslenmesi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Bireysel Beslenme Danışmanlığı'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Diyet Tedavisi II'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Sporcu Beslenmesi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Ergonomi ve Mutfak Planlama'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Besin Analiz Yöntemleri'::text, 3::int, 3::int, 0.3::numeric, 0.4::numeric, 0::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Beslenme Eğitimi'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Diyet Tedavisi III'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Geriatrik Beslenme'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Enteral ve Parenteral Beslenme'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Toplum Beslenmesi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Beslenme Epidemiyolojisi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Klinik Diyetetik Uygulaması I'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'İleri Diyet Tedavisi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 7::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Fonksiyonel Beslenme'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Araştırma Yöntemleri'::text, 3::int, 3::int, 0.3::numeric, 0.4::numeric, 0.1::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Bitirme Çalışması I'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Klinik Diyetetik Uygulaması II'::text, 6::int, 6::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Bitirme Çalışması II'::text, 4::int, 4::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Beslenme Politikaları'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '3bdceb33-10aa-4424-8946-91a6e3ca78ef'::uuid LIMIT 1
);

-- === Bilgisayar Ve Ogretim Teknolojileri (bilgisayar-ve-ogretim-teknolojileri) — 41 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Bilgisayar Donanımı'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0.1::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Programlamaya Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0.1::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Eğitim Bilimine Giriş'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Bilgisayar Ağları Temelleri'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'İşletim Sistemleri'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Web Tasarımı'::text, 4::int, 3::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Gelişim ve Öğrenme'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Veritabanı Yönetim Sistemleri'::text, 3::int, 3::int, 0.3::numeric, 0.2::numeric, 0.1::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Öğretim Teknolojileri'::text, 4::int, 3::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Web Programlama'::text, 4::int, 3::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Öğretim Desenleri'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Nesne Tabanlı Programlama'::text, 4::int, 3::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Ölçme ve Değerlendirme'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Sınıf Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Multimedia Tasarımı'::text, 4::int, 3::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Mobil Programlama'::text, 4::int, 3::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Özel Öğretim Yöntemleri I'::text, 4::int, 3::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Rehberlik'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Eğitim Yazılımı Tasarımı'::text, 3::int, 3::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'E-Öğrenme Sistemleri'::text, 4::int, 3::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Ağ Güvenliği'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Özel Öğretim Yöntemleri II'::text, 4::int, 3::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Yapay Zekaya Giriş'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Eğitimde Araştırma Yöntemleri'::text, 3::int, 3::int, 0.4::numeric, 0.3::numeric, 0::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Eğitimde Mobil Uygulamalar'::text, 4::int, 3::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Oyunlaştırma ve Eğitim'::text, 4::int, 3::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Veri Madenciliği'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Topluma Hizmet'::text, 2::int, 2::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Seçmeli: Bulut Bilişim'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Öğretmenlik Uygulaması I'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Bitirme Çalışması I'::text, 4::int, 4::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Eğitimde Proje Yönetimi'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Seçmeli: Cybersecurity'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Öğretmenlik Uygulaması II'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Bitirme Çalışması II'::text, 5::int, 5::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid, 'Seçmeli: IoT in Education'::text, 3::int, 3::int, 0.3::numeric, 0.2::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '974d11be-0b9b-4b84-ae9a-18b9432c7e39'::uuid LIMIT 1
);

-- === Ofis Yonetimi Ve Sekreterlik (ofis-yonetimi-ve-sekreterlik) — 26 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'Yöneticilik ve Sekreterlik Mesleğine Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'Büro Makineleri ve Donanımı'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'İletişim Bilgisi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'Hızlı Klavye Kullanımı I'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'İşletme Bilgisi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'Büro Yönetimi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'Mesleki Yazışma Teknikleri'::text, 4::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'Ofis Programları I (Word)'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'Hızlı Klavye Kullanımı II'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'İnsan İlişkileri'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'Ofis Programları II (Excel)'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'Sunum Teknikleri (PowerPoint)'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'Dosyalama ve Arşivleme'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'Yönetici Asistanlığı Uygulamaları'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'Ticari Yazışmalar'::text, 3::int, 3::int, 0.3::numeric, 0.4::numeric, 0::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'Toplantı ve Organizasyon'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'İleri Ofis Uygulamaları'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'E-Sekreterlik ve Dijital İletişim'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'Halkla İlişkiler'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'Müşteri İlişkileri'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'Staj'::text, 4::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '6fa78b7a-f9b8-4b87-ad2b-2758f928357d'::uuid LIMIT 1
);

-- === Buyuk Veri Analistligi (buyuk-veri-analistligi) — 26 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'Programlamaya Giriş (Python)'::text, 5::int, 4::int, 0.3::numeric, 0.2::numeric, 0.1::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'İstatistiğe Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'Veritabanı Yönetim Sistemleri'::text, 4::int, 3::int, 0.3::numeric, 0.2::numeric, 0.1::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'Veri Yapıları ve Algoritmalar'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'Matematik for Veri Bilimi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'İleri Python Programlama'::text, 5::int, 4::int, 0.2::numeric, 0.2::numeric, 0.2::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'Olasılık ve İstatistik'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'SQL ve İlişkisel Veritabanları'::text, 4::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'Veri Görselleştirme'::text, 4::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'İşletim Sistemleri (Linux)'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'Büyük Veri Mimarisi (Hadoop)'::text, 5::int, 4::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'Spark ve Dağıtık İşleme'::text, 4::int, 3::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'NoSQL Veritabanları (MongoDB)'::text, 4::int, 3::int, 0.2::numeric, 0.3::numeric, 0.2::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'Veri Madenciliğine Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'Makine Öğrenmesi Temelleri'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'Veri Hazırlama ve Temizleme'::text, 3::int, 3::int, 0.2::numeric, 0.4::numeric, 0.1::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'İleri Veri Madenciliği'::text, 5::int, 4::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'Bulut Bilişim ve Veri Depolama'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'Veri Akış İşleme (Kafka)'::text, 4::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'Bitirme Projesi'::text, 5::int, 5::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'Staj'::text, 4::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('6faa3e83-de14-404f-bf06-e922db094ed7'::uuid, 'Meslek Etiği ve Veri Gizliliği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '6faa3e83-de14-404f-bf06-e922db094ed7'::uuid LIMIT 1
);

-- === Calisma Ekonomisi Ve Endustri Iliskileri (calisma-ekonomisi-ve-endustri-iliskileri) — 41 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'İktisada Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Hukuk Başlangıcı'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Sosyoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'İşletme İlkeleri'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Makro İktisat'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Anayasa Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Çalışma Ekonomisi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'İstatistik I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'İş Hukuku I'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Endüstri İlişkileri'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Sosyal Politika'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'İş ve Sosyal Güvenlik Hukuku'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'İnsan Kaynakları Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'İş Hukuku II'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Toplu İş İlişkileri'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Sosyal Güvenlik Hukuku'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Ücret Sistemleri'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Çalışma Sosyolojisi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'İş ve Meslek Analizi'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Uluslararası Çalışma İlişkileri'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Endüstriyel Demokrasi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'İş Sağlığı ve Güvenliği'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Çalışma Psikolojisi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Sendikacılık Tarihi'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Türk Çalışma İlişkileri Sistemi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'İstihdam Politikaları'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Verimlilik Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Seçmeli: AB Sosyal Politikası'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'İleri İş Hukuku'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 7::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Grev ve Lokavt Hukuku'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 7::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Bitirme Çalışması I'::text, 4::int, 4::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Staj'::text, 4::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Seçmeli: Dijital Çalışma Hayatı'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Karşılaştırmalı Çalışma Sistemleri'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 8::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Bitirme Çalışması II'::text, 5::int, 5::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid, 'Seçmeli: Çalışma Ekonomisinde Güncel Konular'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '3c1e778a-5054-4ec8-bfde-4786f95137f7'::uuid LIMIT 1
);

-- === Cizgi Film Ve Animasyon (cizgi-film-ve-animasyon) — 43 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Çizim Temelleri I'::text, 4::int, 5::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Sanat Tarihi I'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Anatomi Çizimi'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Animasyona Giriş'::text, 4::int, 4::int, 0.4::numeric, 0.1::numeric, 0.1::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Dijital Çizim I'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 1::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Çizim Temelleri II'::text, 4::int, 5::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Sanat Tarihi II'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Perspektif ve Kompozisyon'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, '2D Animasyon I'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Dijital Çizim II'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Karakter Tasarımı'::text, 4::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, '2D Animasyon II'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Storyboard Tasarımı'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Sinema Dili ve Anlatım'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, '3D Modelleme I'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Renk Teorisi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, '3D Animasyon I'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, '3D Modelleme II'::text, 4::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Hareket Analizi'::text, 3::int, 4::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Senaryo Yazarlığı'::text, 3::int, 3::int, 0.3::numeric, 0.4::numeric, 0::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'VFX Compositing I'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, '3D Animasyon II'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Karakter Animasyonu'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Çevre Tasarımı'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Animasyon Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Ses Tasarımı'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Stop-Motion Animasyon'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Motion Graphics'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'VFX Compositing II'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Yönetmenlik Sanatı'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Staj'::text, 3::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Bitirme Projesi I'::text, 5::int, 6::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'İleri Karakter Animasyonu'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 7::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Animasyon Prodüksiyon'::text, 3::int, 3::int, 0.4::numeric, 0.3::numeric, 0::numeric, 0.3::numeric, 7::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Seçmeli: Oyun Animasyonu'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Bitirme Projesi II'::text, 6::int, 8::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Portföy Hazırlama'::text, 3::int, 3::int, 0.2::numeric, 0.4::numeric, 0.2::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid, 'Seçmeli: VR/AR Animasyon'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '45bdb622-9e0a-456a-ada5-a05316659f9b'::uuid LIMIT 1
);

-- === Cocuk Gelisimi (cocuk-gelisimi) — 26 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Çocuk Gelişimine Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Çocuk Sağlığı ve Hastalıkları'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Anatomi ve Fizyoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Çocuk Psikolojisi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Gelişim Psikolojisi I'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Gelişim Psikolojisi II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Çocuk Edebiyatı'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Çocuk Beslenmesi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Oyun ve Oyun Ortamı'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Özel Eğitime Giriş'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Bilişsel Gelişim'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Dil Gelişimi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Sosyal Duygusal Gelişim'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Motor Gelişim'::text, 3::int, 3::int, 0.3::numeric, 0.2::numeric, 0.1::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Çocuk Hakları'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'İletişim Becerileri'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Çocuk Gözlemi ve Değerlendirme'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.2::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Çocuğu Koruyucu Aile Danışmanlığı'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Özel Gelişim Destek Programları'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Çocuk Müziği ve Drama'::text, 3::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Staj'::text, 4::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('a50154fb-087a-4c32-a89c-6e87164dde18'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = 'a50154fb-087a-4c32-a89c-6e87164dde18'::uuid LIMIT 1
);

-- === Dijital Oyun Tasarimi (dijital-oyun-tasarimi) — 42 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Oyun Tasarımına Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0.1::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Programlamaya Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0.1::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Çizim Temelleri'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Dijital Grafik'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 1::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Oyun Endüstrisi Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Oyun Programlama I (Unity)'::text, 4::int, 4::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Oyun Seviye Tasarımı'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, '3D Modelleme I'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Oyun Hikayesi ve Senaryo'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Matematik for Oyunlar'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Oyun Programlama II'::text, 4::int, 4::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, '3D Modelleme II'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Karakter Tasarımı'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Oyun Fizik ve Yapay Zeka'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Oyun Ses Tasarımı'::text, 3::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'UX/UI for Oyunlar'::text, 3::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Çok Oyunculu Oyun Programlama'::text, 4::int, 4::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Mobil Oyun Geliştirme'::text, 4::int, 4::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Oyun Test ve Optimizasyon'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Oyun Animasyonu'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Bitirme Projesi I'::text, 3::int, 5::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'İleri Oyun Programlama (Unreal)'::text, 4::int, 4::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'VR/AR Oyun Geliştirme'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Oyun Ekonomisi ve Monetization'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Oyun Pazarlama ve Yayınlama'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Proje Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.3::numeric, 0::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Bitirme Projesi II'::text, 5::int, 8::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Oyun Endüstrisi ve Hukuk'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Seçmeli: Battle Royale Geliştirme'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Seçmeli: Oyun Veri Analizi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Oyun Şirketi Stajı'::text, 5::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'İleri 3D Animasyon'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Oyun Yazılım Mimarisi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Seçmeli: İndie Oyun Geliştirme'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Bitirme Projesi III'::text, 6::int, 10::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Portföy Hazırlama'::text, 3::int, 3::int, 0.2::numeric, 0.4::numeric, 0.2::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid, 'Oyun Girişimciliği'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = 'c405a12b-236d-4f7e-afe7-a4e9f6b18ef1'::uuid LIMIT 1
);

-- === Dil Ve Konusma Terapisi (dil-ve-konusma-terapisi) — 42 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Anatomi I'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Fizyoloji I'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Dilbilim Temelleri'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Ses Fizyolojisi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Genel Psikoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Anatomi II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Fizyoloji II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Sesbilim'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Çocuk Dili Edinimi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Nöroanatomi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Dil ve Konuşma Bozukluklarına Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Ses Bozuklukları'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Artikülasyon Bozuklukları'::text, 4::int, 3::int, 0.3::numeric, 0.2::numeric, 0.1::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Klinik fonetik'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Nörolojik Temeller'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Gelişim Psikolojisi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Afazi ve İlgili Bozukluklar'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Dil Gelişim Bozuklukları'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Konuşma Akışı Bozuklukları (Kekemelik)'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Yutma Bozuklukları (Disfaji)'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Ölçme ve Değerlendirme'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Çocuk Dilinde Klinik Uygulama'::text, 5::int, 4::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Erken Müdahale'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'İşitme ve Konuşma'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Kulak Burun Boğaz Hastalıkları'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Aile Danışmanlığı'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Erişkin Dilinde Klinik Uygulama'::text, 5::int, 4::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Alternatif ve Destekleyici İletişim'::text, 4::int, 3::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Ses Sağlığı ve Korunması'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Araştırma Yöntemleri'::text, 3::int, 3::int, 0.3::numeric, 0.4::numeric, 0.1::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Bitirme Çalışması I'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Klinik Staj I'::text, 6::int, 6::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'İleri Klinik Değerlendirme'::text, 4::int, 3::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Multidisipliner Yaklaşım'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Bitirme Çalışması II'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Klinik Staj II'::text, 8::int, 8::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Bitirme Çalışması III'::text, 4::int, 4::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = 'e658bb8c-964f-40d7-8cd8-fdda9d8c3f6c'::uuid LIMIT 1
);

-- === Eczacilik (eczacilik) — 44 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Anatomi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Fizyoloji'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Genel Kimya'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Organik Kimya'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Biyokimya I'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Hücre Biyolojisi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Mikrobiyoloji'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Analitik Kimya'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Biyokimya II'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Farmasötik Botanik'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Farmakoloji I'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Farmasötik Kimya I'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Farmasötik Teknoloji I'::text, 4::int, 3::int, 0.3::numeric, 0.2::numeric, 0.1::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Patoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Farmakognozi I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'İmmünoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Farmakoloji II'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Farmasötik Kimya II'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Farmasötik Teknoloji II'::text, 4::int, 3::int, 0.3::numeric, 0.2::numeric, 0.1::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Farmakognozi II'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Toksikoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Klinik Farmakoloji I'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Farmasötik Care I'::text, 4::int, 3::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Reçete Bilgisi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Biyoistatistik'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Eczacılık Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Klinik Farmakoloji II'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Farmasötik Care II'::text, 4::int, 3::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Fitoterapi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Kozmetik Eczacılık'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Halk Sağlığı ve Epidemiyoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Klinik Eczacılık Stajı I'::text, 6::int, 6::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'İlaç Etkileşimleri'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 7::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Radyofarmasi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 7::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Biyoteknoloji ve Gen Terapisi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 7::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Seçmeli: Nükleer Eczacılık'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Klinik Eczacılık Stajı II'::text, 8::int, 8::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Mezuniyet Projesi'::text, 4::int, 4::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Eczacılık Etik ve Hukuk'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('6623f593-a345-4851-990f-350903c43682'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '6623f593-a345-4851-990f-350903c43682'::uuid LIMIT 1
);

-- === Eczane Hizmetleri (eczane-hizmetleri) — 26 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Anatomi ve Fizyoloji'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Genel Kimya'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Farmasötik Botaniğe Giriş'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Eczacılık Mesleğine Giriş'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Bilgisayar Kullanımı'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Farmakolojiye Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'İlaç Tanıtımı ve Sınıflandırması'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Eczane Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Reçete Okuma ve Hazırlama'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'İlk Yardım'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Reçeteli İlaç Bilgisi I'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Hastalık Bilgisi I'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Farmasötik Teknoloji'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Eczane Uygulamaları I'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.2::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Sosyal Güvenlik ve SGK Uygulamaları'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'İletişim Becerileri'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Reçeteli İlaç Bilgisi II'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Hastalık Bilgisi II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Eczane Uygulamaları II'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.2::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Bitkisel İlaçlar ve Fitoterapi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Staj'::text, 4::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '5a92e5bc-ee20-4735-ae46-d354d03595e3'::uuid LIMIT 1
);

-- === Emlak Yonetimi (emlak-yonetimi) — 26 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Emlak Yönetimine Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'İnşaat Malzemeleri'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Yapı Bilgisi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'İşletme İlkeleri'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Hukuk Başlangıcı'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Emlak Hukuku'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Emlak Pazarlama'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Emlak Değerleme'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Ticari Hukuk'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Mimarlık ve Şehircilik Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Gayrimenkul Finansmanı'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Konut ve İşyeri Yönetimi'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Emlak Vergi Mevzuatı'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Proje Okuma ve Anlama'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Tapu ve Kadastro'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Müşteri İlişkileri Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'İleri Emlak Değerleme'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Parselasyon ve Arsa Geliştirme'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Emlak Sektöründe Bilgi Sistemleri'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Emlak Sigortacılığı'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Staj'::text, 4::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('d0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = 'd0aa1bbd-94c1-4fcd-b964-6bf4990abb50'::uuid LIMIT 1
);

-- === Felsefe (felsefe) — 40 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Felsefeye Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Antik Felsefe I'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Mantık I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Sosyoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Antik Felsefe II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Ortaçağ Felsefesi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Mantık II'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Psikoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Yeniçağ Felsefesi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Bilgi Felsefesi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Etik'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Varlık Felsefesi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'İslam Felsefesi I'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Yakınçağ Felsefesi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Siyaset Felsefesi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Bilim Felsefesi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Sanat Felsefesi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'İslam Felsefesi II'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, '20. Yüzyıl Felsefesi I'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Türk Düşünce Tarihi I'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Felsefe Seminerleri I'::text, 3::int, 3::int, 0.2::numeric, 0.4::numeric, 0.2::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Estetik'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Din Felsefesi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, '20. Yüzyıl Felsefesi II'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Türk Düşünce Tarihi II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Çağdaş Felsefe Akımları'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Felsefe Seminerleri II'::text, 3::int, 3::int, 0.2::numeric, 0.4::numeric, 0.2::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Kültür Felsefesi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Bitirme Çalışması I'::text, 5::int, 5::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Çağdaş Etik Sorunları'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Mantık Felsefesi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 7::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Seçmeli: Sinema ve Felsefe'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Bitirme Çalışması II'::text, 6::int, 6::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Seçmeli: Felsefe ve Edebiyat'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid, 'Seçmeli: Postmodern Felsefe'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '96ef9627-4ad1-4c72-b4c6-ea030298e08d'::uuid LIMIT 1
);

-- === Fransizca Ogretmenligi (fransizca-ogretmenligi) — 44 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Fransızca Dilbilgisi I'::text, 4::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Fransızca Okuma I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Fransızca Yazma I'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Fransızca Konuşma I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0.1::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Fransız Edebiyatına Giriş'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Fransızca Dilbilgisi II'::text, 4::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Fransızca Okuma II'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Fransızca Yazma II'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Fransızca Konuşma II'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0.1::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Fransız Edebiyatı Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Fransızca Çeviri I'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Fransız Edebiyatı Klasikleri'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Öğretim İlke ve Yöntemleri'::text, 4::int, 4::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Fransız Kültürü ve Medeniyeti'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Linguistik I'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Bilgisayar Becerileri'::text, 2::int, 2::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Fransızca Çeviri II'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Çağdaş Fransız Edebiyatı'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Öğretim Teknolojileri'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Fransız Sineması'::text, 3::int, 3::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Linguistik II'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Sınıf Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Fransız Edebiyatı Analizi'::text, 4::int, 4::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Çocuk Edebiyatı'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Ölçme ve Değerlendirme'::text, 4::int, 4::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Özel Öğretim Yöntemleri I'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Rehberlik'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Fransız Edebiyatı Semineri'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.2::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Karşılaştırmalı Edebiyat'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Topluma Hizmet Uygulamaları'::text, 2::int, 2::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Fransızca İş Fransızcası'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Türk-Fransız Kültürel İlişkileri'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Öğretmenlik Uygulaması I'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Fransız Eğitim Sistemi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Çeviri Uygulamaları'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 7::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Bitirme Çalışması I'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Öğretmenlik Uygulaması II'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Bitirme Çalışması II'::text, 4::int, 4::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid, 'Seçmeli: Fransız Felsefesi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '9a541aa8-998c-467e-9e27-4468e973f2f1'::uuid LIMIT 1
);

-- === Gastronomi Ve Mutfak Sanatlari (gastronomi-ve-mutfak-sanatlari) — 43 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Gastronomi Tarihine Giriş'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Mutfak Sanatları I'::text, 5::int, 6::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Gıda Güvenliği ve Hijyen'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Gıda Bilgisi ve Kimyası'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Türk Mutfağı I'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Mutfak Sanatları II'::text, 5::int, 6::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Türk Mutfağı II'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Avrupa Mutfağı I'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Pastacılık ve Ekmek'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'İçecek Bilgisi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Avrupa Mutfağı II'::text, 5::int, 6::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Asya Mutfağı'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Tatlı ve Şekerleme Sanatı'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Restoran Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Maliyet Kontrolü ve Satın Alma'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Şarap ve İçecek Eşleştirme'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Otantik Mutfaklar'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Yaratıcı Mutfak Sanatları'::text, 5::int, 6::int, 0.1::numeric, 0.2::numeric, 0.4::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Moleküler Gastronomi'::text, 3::int, 4::int, 0.3::numeric, 0.2::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Menü Planlama ve Tasarımı'::text, 3::int, 3::int, 0.3::numeric, 0.4::numeric, 0::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Gıda Fotoğrafçılığı'::text, 3::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Modern Restoran Mutfak Yönetimi'::text, 5::int, 5::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Dünya Şarap Bölgeleri'::text, 4::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Gıda Sosyolojisi ve Antropolojisi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Mutfak Liderliği ve Ekipler'::text, 3::int, 3::int, 0.4::numeric, 0.3::numeric, 0::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'İleri Pastacılık ve Çikolata'::text, 4::int, 5::int, 0.1::numeric, 0.2::numeric, 0.4::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Sürdürülebilir Gastronomi'::text, 4::int, 4::int, 0.4::numeric, 0.3::numeric, 0::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Şef Restoranı Konsept Tasarımı'::text, 4::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Girişimcilik ve İşletme Açma'::text, 3::int, 3::int, 0.4::numeric, 0.3::numeric, 0::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Bitirme Projesi I'::text, 4::int, 6::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Staj'::text, 4::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'İleri Mutfak Sanatları'::text, 5::int, 6::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 7::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Michelin Standartları'::text, 3::int, 4::int, 0.4::numeric, 0.2::numeric, 0.1::numeric, 0.3::numeric, 7::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Gıda Yazarlığı ve Eleştirisi'::text, 3::int, 3::int, 0.3::numeric, 0.4::numeric, 0::numeric, 0.3::numeric, 7::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Bitirme Projesi II'::text, 4::int, 6::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Bitirme Projesi III'::text, 6::int, 10::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Şef Portföyü ve Kişisel Marka'::text, 3::int, 3::int, 0.2::numeric, 0.4::numeric, 0.2::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('d2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid, 'Seçmeli: TV Aşçılığı'::text, 3::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = 'd2f4a517-d51a-42d7-bb79-650519ed5ed6'::uuid LIMIT 1
);

-- === Gazetecilik (gazetecilik) — 41 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Gazeteciliğe Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'İletişim Bilimlerine Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Haber Yazma Teknikleri I'::text, 4::int, 4::int, 0.3::numeric, 0.4::numeric, 0::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Türk Basın Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Sosyoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Haber Yazma Teknikleri II'::text, 4::int, 4::int, 0.3::numeric, 0.4::numeric, 0::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Haber Toplama'::text, 4::int, 4::int, 0.2::numeric, 0.4::numeric, 0.2::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'İletişim Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Fotoğrafçılık'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Haber Yazma Uygulamaları'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Dijital Gazetecilik'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Araştırma ve Röportaj Teknikleri'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Basın Etik'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Siyasal İletişim'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'İleri Haber Yazma'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Veri Gazeteciliği'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Editörlük'::text, 3::int, 3::int, 0.2::numeric, 0.5::numeric, 0::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Mobil Gazetecilik'::text, 3::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Uluslararası İletişim'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Multimedya Haberciliği'::text, 5::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Sosyal Medya Haberciliği'::text, 4::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Spor Gazeteciliği'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Ekonomi Gazeteciliği'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Staj'::text, 3::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'İnceleme Haberciliği'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Yaratıcı Yazarlık'::text, 4::int, 4::int, 0.2::numeric, 0.4::numeric, 0.2::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Kültür ve Sanat Gazeteciliği'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Bilim ve Teknoloji Gazeteciliği'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Bitirme Projesi I'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Yayın Yönetimi'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Medya Ekonomisi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Bitirme Projesi II'::text, 5::int, 5::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Seçmeli: Görsel Hikaye Anlatımı'::text, 3::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Bitirme Projesi III'::text, 6::int, 8::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Medya Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.3::numeric, 0::numeric, 0.3::numeric, 8::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid, 'Seçmeli: VR Gazeteciliği'::text, 3::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '01cbcad3-7dd2-4daa-8e1c-df02691674e0'::uuid LIMIT 1
);

-- === Gorsel Iletisim Tasarimi (gorsel-iletisim-tasarimi) — 43 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Tasarım Temelleri I'::text, 4::int, 5::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Temel Sanat Eğitimi'::text, 4::int, 5::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Tipografi I'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Fotoğraf I'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 1::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Dijital Tasarım I'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 1::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Tasarım Temelleri II'::text, 4::int, 5::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Tipografi II'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Grafik Tasarım I'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'İllüstrasyon I'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Dijital Tasarım II'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'İleri Grafik Tasarım I'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Marka Kimliği Tasarımı'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Ambalaj Tasarımı'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Web Tasarımı I'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Hareketli Grafik I'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Sanat Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'İleri Grafik Tasarım II'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Reklam Tasarımı'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'UI/UX Tasarımı'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Web Tasarımı II'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Tipografi Uygulamaları'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'İllüstrasyon II'::text, 4::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Hareketli Grafik II'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Etkileşimli Tasarım'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Tasarım Araştırması'::text, 3::int, 3::int, 0.4::numeric, 0.3::numeric, 0::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Seçmeli: 3D Modelleme'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Tasarım Stüdyosu I'::text, 5::int, 6::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Bitirme Projesi I'::text, 4::int, 5::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Sürdürülebilir Tasarım'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Seçmeli: Tipografi Atölyesi'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Seçmeli: Deneysel Tasarım'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Tasarım Stüdyosu II'::text, 5::int, 6::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Bitirme Projesi II'::text, 5::int, 6::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Tasarım Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.3::numeric, 0::numeric, 0.3::numeric, 7::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Seçmeli: Yaratıcı Kodlama'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Bitirme Projesi III'::text, 6::int, 8::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Portföy Tasarımı'::text, 3::int, 3::int, 0.2::numeric, 0.4::numeric, 0.2::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('384062a3-20d8-4f32-a45e-75da229074a5'::uuid, 'Seçmeli: Tasarım Girişimciliği'::text, 3::int, 3::int, 0.4::numeric, 0.3::numeric, 0::numeric, 0.3::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '384062a3-20d8-4f32-a45e-75da229074a5'::uuid LIMIT 1
);

-- === Grafik Sanatlar (grafik-sanatlar) — 42 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Temel Sanat Eğitimi I'::text, 4::int, 5::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Çizim I'::text, 4::int, 5::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Desen I'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Sanat Tarihi I'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Temel Sanat Eğitimi II'::text, 4::int, 5::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Çizim II'::text, 4::int, 5::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Desen II'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Sanat Tarihi II'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Baskı Sanatları I (Litografi)'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Dijital Baskı I'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Tipografi'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Grafik Tasarım I'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Anatomi'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Perspektif'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Baskı Sanatları II (Gravür)'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Serigrafi'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Grafik Tasarım II'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'İllüstrasyon'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Çağdaş Sanat'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Türk Sanatı Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'İleri Baskı Sanatları I'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Atölye Çalışması I'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Deneysel Baskı'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Sanat Felsefesi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Seçmeli: Kitap Sanatı'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'İleri Baskı Sanatları II'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Atölye Çalışması II'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Dijital Grafik'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Sanat Eleştirisi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Bitirme Projesi I'::text, 3::int, 5::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Bitirme Projesi II'::text, 5::int, 6::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Sanat Proje Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.3::numeric, 0::numeric, 0.3::numeric, 7::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Müze ve Galeri Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Seçmeli: Heykel ve Baskı'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Bitirme Projesi III'::text, 6::int, 8::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Portföy ve Sergi Hazırlama'::text, 3::int, 3::int, 0.2::numeric, 0.4::numeric, 0.2::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('517293c4-b74b-4031-90f5-74689469e7b9'::uuid, 'Seçmeli: Sanat Girişimciliği'::text, 3::int, 3::int, 0.4::numeric, 0.3::numeric, 0::numeric, 0.3::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '517293c4-b74b-4031-90f5-74689469e7b9'::uuid LIMIT 1
);

-- === Halkla Iliskiler Ve Tanitim (halkla-iliskiler-ve-tanitim) — 40 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Halkla İlişkilere Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'İletişim Bilimlerine Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Sosyoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'İşletme İlkeleri'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Halkla İlişkiler Kuramı'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Reklamcılığa Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Pazarlama İlkeleri'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Yazılı İletişim'::text, 3::int, 3::int, 0.3::numeric, 0.4::numeric, 0::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Kurumsal İletişim'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Bütünleşik Pazarlama İletişimi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Halkla İlişkiler Kampanyaları'::text, 4::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'İletişim Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Sosyal Psikoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'İtibar Yönetimi'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Kriz İletişimi'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Dijital Halkla İlişkiler'::text, 4::int, 3::int, 0.2::numeric, 0.3::numeric, 0.2::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Tüketici Davranışı'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Medya İlişkileri'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Kurumsal Sosyal Sorumluluk'::text, 5::int, 4::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'İç İletişim'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Etkinlik Yönetimi'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Lobi Faaliyetleri'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Sosyal Medya Yönetimi'::text, 3::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Halkla İlişkiler Stratejisi'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Bitirme Projesi I'::text, 4::int, 4::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Sürdürülebilirlik İletişimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Seçmeli: İnf.luencer İletişimi'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Staj'::text, 3::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Halkla İlişkiler Danışmanlığı'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 7::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Bitirme Projesi II'::text, 5::int, 5::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Medya Planlama'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Seçmeli: Politik İletişim'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Bitirme Projesi III'::text, 6::int, 6::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Halkla İlişkilerde Etik'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('d2fc3d5b-177d-44ef-9133-a2b162938367'::uuid, 'Seçmeli: Uluslararası Halkla İlişkiler'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = 'd2fc3d5b-177d-44ef-9133-a2b162938367'::uuid LIMIT 1
);

-- === Heykel (heykel) — 44 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Temel Sanat Eğitimi I'::text, 4::int, 5::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Modelaj I'::text, 4::int, 5::int, 0.3::numeric, 0.2::numeric, 0.3::numeric, 0.2::numeric, 1::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Çizim I'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Anatomi'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Sanat Tarihi I'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Temel Sanat Eğitimi II'::text, 4::int, 5::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Modelaj II'::text, 4::int, 5::int, 0.3::numeric, 0.2::numeric, 0.3::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Çizim II'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Heykel Malzemeleri'::text, 3::int, 4::int, 0.4::numeric, 0.2::numeric, 0.1::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Sanat Tarihi II'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Taş Heykel I'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Ahşap Heykel I'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Metal Heykel I'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Heykel Tasarımı'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Çağdaş Heykel'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Perspektif'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Taş Heykel II'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Ahşap Heykel II'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Metal Heykel II'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Bronz Döküm'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Seramik Heykel'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Türk Heykel Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Atölye I (Seçmeli Malzeme)'::text, 5::int, 6::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Dijital Heykel'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Sanat Felsefesi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, '3D Tasarım ve Modelleme'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Sanat Eleştirisi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Atölye II (Seçmeli Malzeme)'::text, 5::int, 6::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Bitirme Projesi I'::text, 4::int, 5::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Kamu Heykeli'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Çağdaş Sanat Akımları'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Sanat Proje Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.3::numeric, 0::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Bitirme Projesi II'::text, 5::int, 6::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Sanat Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.3::numeric, 0::numeric, 0.3::numeric, 7::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Müze ve Galeri Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Seçmeli: Enstalasyon Sanatı'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Bitirme Projesi III'::text, 6::int, 8::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Portföy ve Sergi Hazırlama'::text, 3::int, 3::int, 0.2::numeric, 0.4::numeric, 0.2::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid, 'Seçmeli: Kamu Sanatı Projeleri'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '1505fbc4-0922-405b-bb62-f6a12d17b246'::uuid LIMIT 1
);

-- === Hukuk (hukuk) — 42 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Hukuk Başlangıcı'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Anayasa Hukuku'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Medeni Hukuka Giriş'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Roma Hukuku'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Borçlar Hukuku Genel Hükümler'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Ceza Hukuku Genel Hükümler'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Anayasa Hukuku II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'İdare Hukuku'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Eşya Hukuku'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Ceza Muhakemesi Hukuku'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Medeni Usul Hukuku'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Ticaret Hukuku I'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'İdari Yargılama Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Aile Hukuku'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Miras Hukuku'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Ticaret Hukuku II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'İş Hukuku'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Devletler Özel Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Ceza Hukuku Özel Hükümler'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'İcra ve İflas Hukuku'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Kamu Hukuku Uygulamaları'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Devletler Umumi Hukuku'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'İnsan Hakları Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Borçlar Hukuku Özel Hükümler'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Ticari İşletme Hukuku'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Deniz Ticareti Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Fikri Mülkiyet Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Hukuk Felsefesi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Avrupa Birliği Hukuku'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 7::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Vergi Hukuku'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 7::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Hukuk Sosyolojisi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 7::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Bitirme Çalışması I'::text, 4::int, 4::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Seçmeli: Bankacılık Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 7::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Bitirme Çalışması II'::text, 5::int, 5::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Hukuk Etik ve Mesleki Sorumluluk'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Seçmeli: Dijital Hukuk'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 8::int, NULL::integer),
  ('791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid, 'Seçmeli: Sağlık Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '791f5137-d7b0-4ea2-92c4-8bf5d798d379'::uuid LIMIT 1
);

-- === Iktisat (iktisat) — 41 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'İktisada Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'İşletme İlkeleri'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Hukuk Başlangıcı'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Matematik I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Mikro İktisat'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Makro İktisat'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'İstatistik I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Genel Muhasebe'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'İleri Mikro İktisat'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Para ve Bankacılık'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'İktisat Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Ticaret Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Ekonometri'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'İleri Makro İktisat'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Maliye Teorisi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Uluslararası İktisat'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Kalkınma İktisadı'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Türk Ekonomisi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'İktisadi Düşünceler Tarihi'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Para Teorisi ve Politikası'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'İktisat Politikası'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Büyüme ve Kalkınma'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Çalışma Ekonomisi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Uluslararası Finans'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Vergi Ekonomisi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Endüstri İktisadı'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Tarım İktisadı'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Çevre ve Ekonomi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Bitirme Çalışması I'::text, 5::int, 5::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Staj'::text, 4::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Seçmeli: Davranışsal İktisat'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Seçmeli: Finansal Ekonometri'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Bitirme Çalışması II'::text, 6::int, 6::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Türkiye Ekonomisi Semineri'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Seçmeli: Dijital Ekonomi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid, 'Seçmeli: Küreselleşme'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '134f6095-c9b9-481e-8a5e-e9293dbdbe55'::uuid LIMIT 1
);

-- === Iletisim Bilimleri (iletisim-bilimleri) — 40 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'İletişim Bilimlerine Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Sosyoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Psikoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Türk İletişim Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'İletişim Kuramları'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Araştırma Yöntemleri'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Kitle İletişim Araçları'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Görsel İletişim'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'İletişim Sosyolojisi'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'İletişim Psikolojisi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Medya ve Toplum'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Halkla İlişkiler'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Reklamcılığa Giriş'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Medya ve Kültür'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Yeni Medya Çalışmaları'::text, 4::int, 3::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Medya Politikaları'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Medya Ekonomisi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'İletişim Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Dijital İletişim'::text, 5::int, 4::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Medya Etik'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Sosyal Medya Analizi'::text, 4::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Veri Gazeteciliği'::text, 3::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Medya ve Cinsiyet'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Medya ve Siyaset'::text, 5::int, 4::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Uluslararası İletişim'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Bitirme Projesi I'::text, 4::int, 4::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Staj'::text, 3::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Seçmeli: Dijital Pazarlama'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Bitirme Projesi II'::text, 5::int, 5::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Medya Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'İleri İletişim Araştırmaları'::text, 3::int, 3::int, 0.3::numeric, 0.4::numeric, 0.1::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Seçmeli: Stratejik İletişim'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Bitirme Projesi III'::text, 6::int, 6::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Seçmeli: VR ve İletişim'::text, 3::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid, 'Seçmeli: Transmedya Hikayeleri'::text, 3::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '76decd7e-2fbb-4738-8e5d-ef06cddbe3bf'::uuid LIMIT 1
);

-- === Ilkogretim Matematik Ogretmenligi (ilkogretim-matematik-ogretmenligi) — 41 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Analiz I'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Soyut Matematik'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Lineer Cebir I'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Eğitim Bilimine Giriş'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Bilgisayar Programlama'::text, 3::int, 3::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Analiz II'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Lineer Cebir II'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Analitik Geometri'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Gelişim ve Öğrenme'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Soyut Cebir'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Diferansiyel Denklemler'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Geometri'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Öğretim İlke ve Yöntemleri'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Matematik Felsefesi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Topoloji'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Sayı Teorisi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Olasılık ve İstatistik'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Matematik Öğretimi I'::text, 4::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Ölçme ve Değerlendirme'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Numerik Analiz'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Kompleks Analiz'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Matematik Öğretimi II'::text, 4::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Sınıf Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Rehberlik'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Matematik Tarihi'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Matematiksel Modelleme'::text, 4::int, 3::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Bilgisayar Destekli Matematik Öğretimi'::text, 4::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Bitirme Çalışması I'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Seçmeli: İstatistik Öğretimi'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Öğretmenlik Uygulaması I'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Matematik Eğitiminde Araştırma'::text, 4::int, 3::int, 0.4::numeric, 0.3::numeric, 0::numeric, 0.3::numeric, 7::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Bitirme Çalışması II'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Seçmeli: Geometri Öğretimi'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 7::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Öğretmenlik Uygulaması II'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Matematik Eğitiminde Teknoloji'::text, 4::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid, 'Seçmeli: Matematik Yarışmaları'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '4db8b14c-b6cf-43fd-a8ed-6fcd73b0e903'::uuid LIMIT 1
);

-- === Ingilizce Ogretmenligi (ingilizce-ogretmenligi) — 43 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'İleri İngilizce I (Okuma)'::text, 4::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'İleri İngilizce I (Yazma)'::text, 4::int, 4::int, 0.3::numeric, 0.4::numeric, 0::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'İleri İngilizce I (Konuşma)'::text, 3::int, 4::int, 0.4::numeric, 0.2::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'İleri İngilizce I (Dinleme)'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'İngilizce Dilbilgisi I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'İleri İngilizce II (Okuma)'::text, 4::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'İleri İngilizce II (Yazma)'::text, 4::int, 4::int, 0.3::numeric, 0.4::numeric, 0::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'İleri İngilizce II (Konuşma)'::text, 3::int, 4::int, 0.4::numeric, 0.2::numeric, 0.1::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'İleri İngilizce II (Dinleme)'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'İngilizce Dilbilgisi II'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'İngiliz Edebiyatına Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Çeviri I (İng-TR)'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Linguistik I'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Yabancı Dil Eğitimine Giriş'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Bilgisayar Becerileri'::text, 2::int, 2::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Amerikan Edebiyatı'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Çeviri II (TR-İng)'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Linguistik II'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Yabancı Dil Öğretim Yöntemleri'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'İngilizce Test Hazırlama'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'İngilizce Öğretim Materyalleri'::text, 5::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'İleri Konuşma Becerileri'::text, 4::int, 4::int, 0.4::numeric, 0.2::numeric, 0.1::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Yabancı Dil Ölçme ve Değerlendirme'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Özel Öğretim Yöntemleri I'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Sınıf Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'İngiliz Edebiyatı Klasikleri'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Çocuk Edebiyatı'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Rehberlik'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Topluma Hizmet'::text, 2::int, 2::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Özel Öğretim Yöntemleri II'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Bitirme Çalışması I'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Öğretmenlik Uygulaması I'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'İngilizce Yeterlilik Sınavları'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'İleri Yazma Becerileri'::text, 3::int, 3::int, 0.2::numeric, 0.5::numeric, 0::numeric, 0.3::numeric, 7::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Bitirme Çalışması II'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Öğretmenlik Uygulaması II'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'İngiliz Kültürü ve Medeniyeti'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('dfe24077-4674-4c90-bab5-99862a0ef729'::uuid, 'Seçmeli: İş İngilizcesi'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = 'dfe24077-4674-4c90-bab5-99862a0ef729'::uuid LIMIT 1
);

-- === Isletme (isletme) — 41 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'İşletmeye Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'İktisada Giriş'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Hukuk Başlangıcı'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Matematik I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Genel Muhasebe'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Makro İktisat'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Ticaret Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'İstatistik I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Yönetim ve Organizasyon'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Maliyet Muhasebesi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Pazarlama İlkeleri'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Finansal Yönetim I'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'İşletme Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Üretim Yönetimi'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'İnsan Kaynakları Yönetimi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Finansal Yönetim II'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Pazar Araştırması'::text, 4::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Muhasebe Uygulamaları'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Stratejik Yönetim'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Uluslararası İşletmecilik'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Yönetim Bilgi Sistemleri'::text, 4::int, 3::int, 0.3::numeric, 0.2::numeric, 0.1::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Girişimcilik'::text, 3::int, 3::int, 0.3::numeric, 0.4::numeric, 0::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Tüketici Davranışı'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Proje Yönetimi'::text, 5::int, 4::int, 0.4::numeric, 0.3::numeric, 0::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'İş Ahlakı ve Etik'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Bitirme Çalışması I'::text, 4::int, 4::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Staj'::text, 3::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Seçmeli: Dijital Pazarlama'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Bitirme Çalışması II'::text, 5::int, 5::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'İleri İşletme Semineri'::text, 4::int, 3::int, 0.4::numeric, 0.3::numeric, 0::numeric, 0.3::numeric, 7::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Seçmeli: Finansal Teknolojiler'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Seçmeli: Sürdürülebilirlik'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Bitirme Çalışması III'::text, 6::int, 6::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'İşletme Politikası'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Seçmeli: Aile İşletmeleri'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid, 'Seçmeli: İnovasyon Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '694c7fd6-a121-445e-ac5e-7c0a706fe4a1'::uuid LIMIT 1
);

-- === Maliye (maliye) — 42 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'İktisada Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Hukuk Başlangıcı'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'İşletme İlkeleri'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Matematik I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Makro İktisat'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Genel Muhasebe'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Anayasa Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'İstatistik I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Maliye Teorisi'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Vergi Hukuku I'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Para ve Bankacılık'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'İktisat Politikası'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Ticaret Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Bütçe Teorisi'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Vergi Hukuku II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Kamu Maliyesi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'İşletme Finansı'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Mali Tablolar Analizi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Devlet Bütçesi'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Vergi Muhasebesi'::text, 4::int, 3::int, 0.3::numeric, 0.2::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Maliye Politikası'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Yerel Maliye'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Uluslararası Maliye'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'İleri Vergi Mevzuatı'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Sosyal Güvenlik Kurumları'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Kamu Harcamaları'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Bitirme Çalışması I'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Seçmeli: Vergi Denetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Vergi İhtilafları Çözümü'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 7::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Mali Hukuk Uygulamaları'::text, 4::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Staj'::text, 4::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Seçmeli: Gümrük Mevzuatı'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Bitirme Çalışması II'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Bitirme Çalışması III'::text, 6::int, 6::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Türk Mali Sistemi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Seçmeli: Dijital Vergi Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid, 'Seçmeli: AB Maliyesi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '2e77abe0-ac77-433d-aa3f-f2d7fa448dc2'::uuid LIMIT 1
);

-- === Muhasebe Ve Finans Yonetimi (muhasebe-ve-finans-yonetimi) — 42 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'İktisada Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Genel Muhasebe'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'İşletme İlkeleri'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Hukuk Başlangıcı'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Matematik I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Makro İktisat'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Maliyet Muhasebesi'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Ticaret Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'İstatistik I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Finansal Muhasebe'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Finansal Yönetim I'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Vergi Hukuku I'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Para ve Bankacılık'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Muhasebe Programları'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.2::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'İleri Muhasebe'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Finansal Yönetim II'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Vergi Hukuku II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Mali Tablolar Analizi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Denetim'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Kurumsal Finans'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Uluslararası Finansal Raporlama'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Yatırım Analizi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Vergi Muhasebesi'::text, 4::int, 3::int, 0.3::numeric, 0.2::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Sermaye Piyasası'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Risk Yönetimi'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Finansal Modelleme'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.2::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Türev Ürünler'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Bitirme Çalışması I'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Staj'::text, 3::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'İleri Finansal Yönetim'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 7::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'İç Denetim ve Risk'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Bitirme Çalışması II'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Seçmeli: Bankacılık Uygulamaları'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Bitirme Çalışması III'::text, 6::int, 6::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Finansal Etik'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Seçmeli: Fintech'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 8::int, NULL::integer),
  ('fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid, 'Seçmeli: Davranışsal Finans'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = 'fea5fdbe-6afd-4254-b139-d468740c4f18'::uuid LIMIT 1
);

-- === Okul Oncesi Ogretmenligi (okul-oncesi-ogretmenligi) — 43 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Okul Öncesi Eğitime Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Çocuk Gelişimi I'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Çocuk Psikolojisi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Eğitim Bilimine Giriş'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Anatomi ve Fizyoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Çocuk Gelişimi II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Okul Öncesi Kurumlarda Yönetim'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Gelişim ve Öğrenme'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Çocuk Edebiyatı'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Müzik Eğitimi'::text, 3::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Okul Öncesi Eğitim Programları'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Çocuklarda Oyun Gelişimi'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Öğretim İlke ve Yöntemleri'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Çocuk Sağlığı ve Beslenmesi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Sanat Eğitimi'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Okul Öncesi Eğitim Uygulamaları'::text, 5::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Çocuk Drama'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Özel Eğitime Giriş'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Ölçme ve Değerlendirme'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Sınıf Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Bilgisayar Destekli Eğitim'::text, 2::int, 2::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Erken Çocukluk Eğitiminde Materyal'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Aile Eğitimi ve Katılımı'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Rehberlik'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Çocuk İstismarı ve Korunma'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Bitirme Çalışması I'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Okul Öncesi Eğitiminde Araştırma'::text, 5::int, 4::int, 0.3::numeric, 0.4::numeric, 0.1::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Karşılaştırmalı Okul Öncesi Eğitim'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Topluma Hizmet'::text, 2::int, 2::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Bitirme Çalışması II'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Seçmeli: Müze Eğitimi'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Öğretmenlik Uygulaması I'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'İleri Çocuk Gelişimi'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Seçmeli: Çocuk Filmleri'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 7::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Seçmeli: Drama Atölyesi'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Öğretmenlik Uygulaması II'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Bitirme Çalışması III'::text, 5::int, 5::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid, 'Seçmeli: özel Eğitim Uygulamaları'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = 'b0b43ae6-6052-4f5f-8e84-4a58ab064478'::uuid LIMIT 1
);

-- === Oyun Gelistirme Ve Programlama (oyun-gelistirme-ve-programlama) — 23 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, 'Programlamaya Giriş (C#)'::text, 5::int, 4::int, 0.3::numeric, 0.2::numeric, 0.1::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, 'Oyun Tasarım İlkeleri'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0.1::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, 'Bilgisayar Grafikleri Temelleri'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, 'Matematik for Oyun Geliştirme'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, 'Nesne Tabanlı Programlama'::text, 5::int, 4::int, 0.2::numeric, 0.2::numeric, 0.3::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, 'Oyun Fizik ve Simülasyon'::text, 4::int, 3::int, 0.3::numeric, 0.2::numeric, 0.3::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, '2D Oyun Geliştirme (Unity)'::text, 5::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, 'Veri Yapıları ve Algoritmalar'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, '3D Oyun Geliştirme (Unity)'::text, 6::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, 'Oyun Yapay Zekası'::text, 4::int, 3::int, 0.3::numeric, 0.2::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, 'Oyun Seviye Tasarımı'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, 'Ağ Programlama'::text, 4::int, 3::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, 'Oyun Optimizasyonu'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, 'Mobil Oyun Geliştirme'::text, 6::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, 'Çok Oyunculu Oyun Programlama'::text, 5::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, 'Oyun Test ve Debug'::text, 3::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, 'Bitirme Projesi'::text, 6::int, 6::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, 'Staj'::text, 4::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('26ccd0b9-6c89-4949-8828-e6811825a521'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '26ccd0b9-6c89-4949-8828-e6811825a521'::uuid LIMIT 1
);

-- === Pazarlama (pazarlama) — 41 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'İşletmeye Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'İktisada Giriş'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Pazarlama İlkeleri'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Genel Muhasebe'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Tüketici Davranışı'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Pazar Araştırması'::text, 4::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'İstatistik I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Pazarlama İletişimi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Ürün ve Fiyat Yönetimi'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Dağıtım Kanalları Yönetimi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Reklam Yönetimi'::text, 4::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Halkla İlişkiler'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Satış Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Marka Yönetimi'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Uluslararası Pazarlama'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Dijital Pazarlama'::text, 4::int, 3::int, 0.2::numeric, 0.3::numeric, 0.2::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Sosyal Medya Pazarlaması'::text, 3::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'B2B Pazarlama'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Stratejik Pazarlama'::text, 5::int, 4::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Pazarlama Kampanyaları'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'E-Ticaret'::text, 4::int, 3::int, 0.2::numeric, 0.3::numeric, 0.2::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Müşteri İlişkileri Yönetimi'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Hizmet Pazarlaması'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Pazarlama Analitiği'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Bitirme Çalışması I'::text, 4::int, 4::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Staj'::text, 3::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Seçmeli: Mobil Pazarlama'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Seçmeli: İçerik Pazarlaması'::text, 3::int, 3::int, 0.2::numeric, 0.4::numeric, 0.2::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Pazarlama Stratejisi Semineri'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Bitirme Çalışması II'::text, 4::int, 4::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Seçmeli: Marka Konumlandırma'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Seçmeli: Influencer Pazarlama'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Bitirme Çalışması III'::text, 6::int, 6::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Pazarlama Etik'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Seçmeli: Sürdürülebilirlik Pazarlaması'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid, 'Seçmeli: AI in Pazarlama'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '9b2d0c58-dc46-4367-9d38-e9316c8c49f3'::uuid LIMIT 1
);

-- === Psikoloji (psikoloji) — 42 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Genel Psikoloji I'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Psikolojiye Giriş'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'BiyoPsikolojiye Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Sosyoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Genel Psikoloji II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Gelişim Psikolojisi I'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'İstatistik I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Anatomi ve Fizyoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Bilişsel Psikoloji'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Sosyal Psikoloji'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Gelişim Psikolojisi II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Araştırma Yöntemleri I'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Kişilik Psikolojisi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Klinik Psikolojiye Giriş'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Ölçme ve Değerlendirme'::text, 4::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Anormal Psikoloji'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Deneysel Psikoloji'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.2::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Araştırma Yöntemleri II'::text, 3::int, 3::int, 0.3::numeric, 0.4::numeric, 0.1::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Klinik Psikoloji'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Psikolojik Testler'::text, 4::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Endüstri ve Örgüt Psikolojisi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Sağlık Psikolojisi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Çocuk Klinik Psikolojisi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Psikoterapi Kuramları'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Nöropsikoloji'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Adli Psikoloji'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Eğitim Psikolojisi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Bitirme Çalışması I'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Klinik Pratik I'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'İleri Klinik Psikoloji'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 7::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Çocuk Psikoterapisi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 7::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Bitirme Çalışması II'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Seçmeli: Pozitif Psikoloji'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Klinik Pratik II'::text, 6::int, 6::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Bitirme Çalışması III'::text, 4::int, 4::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Psikoloji Etik'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid, 'Seçmeli: Travma Psikolojisi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = 'c0bcd6d9-7821-4539-9285-fe7006dc5c21'::uuid LIMIT 1
);

-- === Radyo Televizyon Ve Sinema (radyo-televizyon-ve-sinema) — 40 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'İletişim Bilimlerine Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Radyo TV''ye Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Sinema Tarihi I'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Fotoğraf I'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 1::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Radyo TV''ye Giriş II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Sinema Tarihi II'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Senaryo Yazarlığı I'::text, 4::int, 4::int, 0.2::numeric, 0.4::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Video Kurgu I'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Radyo Program Yapımı'::text, 5::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'TV Program Yapımı'::text, 5::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Görüntü Estetiği'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Sinema Kuramları'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Belgesel Yapımı'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'İleri Kurgu Teknikleri'::text, 5::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Senaryo Yazarlığı II'::text, 4::int, 4::int, 0.2::numeric, 0.4::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Sinema Çekim Teknikleri'::text, 5::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Radyo TV Yönetmenliği'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Medya ve Toplum'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Dijital Yayıncılık'::text, 5::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'İleri Sinema Çekim'::text, 5::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Medya Hukuku'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Türk Sineması Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Medya Etik'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Bitirme Projesi I'::text, 5::int, 5::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Stüdyo Yapım'::text, 5::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Staj'::text, 3::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Seçmeli: Podcast Yapımı'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Seçmeli: VFX'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Bitirme Projesi II'::text, 6::int, 6::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'İleri Belgesel Yapımı'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Seçmeli: Streaming Yayıncılık'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Seçmeli: VR Film Yapımı'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Bitirme Projesi III'::text, 7::int, 8::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Medya Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('b213868e-b64e-4382-83fd-467af620953a'::uuid, 'Seçmeli: Dijital Dağıtım'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = 'b213868e-b64e-4382-83fd-467af620953a'::uuid LIMIT 1
);

-- === Rehberlik Ve Psikolojik Danismanlik (rehberlik-ve-psikolojik-danismanlik) — 41 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Eğitim Bilimine Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Genel Psikoloji'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Gelişim Psikolojisi I'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Bilgisayar Becerileri'::text, 2::int, 2::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Eğitim Psikolojisi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Gelişim Psikolojisi II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Rehberliğe Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Anatomi ve Fizyoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Öğretim İlke ve Yöntemleri'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Bireysel Rehberlik'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Ölçme ve Değerlendirme'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Sosyal Psikoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'İstatistik'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Grupla Rehberlik'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Mesleki Rehberlik'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Kişilik Psikolojisi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Özel Eğitime Giriş'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Sınıf Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'İleri Rehberlik Teknikleri'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Psikolojik Danışma Kuramları'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Aile Danışmanlığı'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Klinik Psikolojiye Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Çocuk ve Ergen Psikolojisi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Psikolojik Testler'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Oyun Terapisi'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Travma ve Kriz Müdahalesi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Bitirme Çalışması I'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Seçmeli: Sanat Terapisi'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Okul Uygulaması I'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'İleri Psikolojik Danışma'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 7::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Bitirme Çalışması II'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Seçmeli: Bilişsel Davranışçı Terapi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Okul Uygulaması II'::text, 6::int, 6::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Bitirme Çalışması III'::text, 4::int, 4::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Rehberlik Etik'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('d16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid, 'Seçmeli: Pozitif Psikoloji Uygulamaları'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = 'd16c80f8-f037-4e8a-9ab4-c45d12ea7149'::uuid LIMIT 1
);

-- === Reklamcilik (reklamcilik) — 37 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Reklamcılığa Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'İletişim Bilimlerine Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Pazarlama İlkeleri'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Tüketici Davranışı'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Reklam Yazarlığı I'::text, 4::int, 4::int, 0.2::numeric, 0.4::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Reklam Tasarımı I'::text, 4::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Reklam Araştırması'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Görsel İletişim'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Bütünleşik Pazarlama İletişimi'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Reklam Kampanyaları'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Medya Planlama'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Reklam Yazarlığı II'::text, 3::int, 4::int, 0.2::numeric, 0.4::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Dijital Reklamcılık'::text, 3::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Reklam Tasarımı II'::text, 5::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Marka İletişimi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Sosyal Medya Reklamları'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Mobil Pazarlama'::text, 3::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Halkla İlişkiler'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Yaratıcı Strateji'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Bitirme Projesi I'::text, 4::int, 4::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Staj'::text, 3::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Seçmeli: E-sports Pazarlama'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Bitirme Projesi II'::text, 6::int, 6::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Reklam Yönetimi'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Seçmeli: Influencer Pazarlama'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Seçmeli: İçerik Pazarlaması'::text, 3::int, 3::int, 0.2::numeric, 0.4::numeric, 0.2::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Bitirme Projesi III'::text, 6::int, 8::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Reklam Ajansı Yönetimi'::text, 4::int, 4::int, 0.4::numeric, 0.3::numeric, 0::numeric, 0.3::numeric, 7::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Seçmeli: VR Reklamcılık'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Bitirme Projesi IV'::text, 7::int, 10::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Reklam Etik'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid, 'Seçmeli: AI in Reklamcılık'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '8e579c48-c607-44ea-9fa9-311fff44f9aa'::uuid LIMIT 1
);

-- === Resim (resim) — 40 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Temel Sanat Eğitimi I'::text, 4::int, 5::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Desen I'::text, 4::int, 5::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Resim I (Yağlı Boya)'::text, 4::int, 5::int, 0.3::numeric, 0.2::numeric, 0.3::numeric, 0.2::numeric, 1::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Sanat Tarihi I'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Temel Sanat Eğitimi II'::text, 4::int, 5::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Desen II'::text, 4::int, 5::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Resim II (Yağlı Boya)'::text, 4::int, 5::int, 0.3::numeric, 0.2::numeric, 0.3::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Sanat Tarihi II'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'İleri Desen'::text, 4::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Resim III'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Anatomi'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Perspektif'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Türk Sanatı Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Resim IV'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Yağlı Boya Teknikleri'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Sulu Boya'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Karışık Teknik'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Çağdaş Sanat'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Atölye I (Seçmeli Teknik)'::text, 5::int, 6::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Dijital Resim'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Sanat Felsefesi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'İllüstrasyon'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Sanat Eleştirisi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Atölye II (Seçmeli Teknik)'::text, 5::int, 6::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Bitirme Projesi I'::text, 4::int, 5::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Deneysel Resim'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Sanat Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.3::numeric, 0::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Bitirme Projesi II'::text, 5::int, 6::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Müze ve Galeri Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Seçmeli: Soyut Resim'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Seçmeli: Portre Resim'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Bitirme Projesi III'::text, 6::int, 8::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Portföy ve Sergi Hazırlama'::text, 3::int, 3::int, 0.2::numeric, 0.4::numeric, 0.2::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Seçmeli: Sanat Girişimciliği'::text, 3::int, 3::int, 0.4::numeric, 0.3::numeric, 0::numeric, 0.3::numeric, 8::int, NULL::integer),
  ('3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid, 'Seçmeli: Dijital Sanat'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '3c57dea9-4dd2-44f0-8ce3-ee3ab18e0b49'::uuid LIMIT 1
);

-- === Rus Dili Ve Edebiyati (rus-dili-ve-edebiyati) — 40 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Rusça Dilbilgisi I'::text, 4::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Rusça Okuma I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Rusça Konuşma I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0.1::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Rus Edebiyatına Giriş'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Rusça Dilbilgisi II'::text, 4::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Rusça Okuma II'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Rusça Konuşma II'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0.1::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Rus Edebiyatı Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Rusça Çeviri I'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Rus Klasikleri'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Linguistik I'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Rus Kültürü ve Medeniyeti'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Rusça Yazma I'::text, 3::int, 3::int, 0.3::numeric, 0.4::numeric, 0::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Rusça Çeviri II'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Çağdaş Rus Edebiyatı'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Linguistik II'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Rus Sineması'::text, 3::int, 3::int, 0.3::numeric, 0.2::numeric, 0.2::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Rusça Yazma II'::text, 3::int, 3::int, 0.3::numeric, 0.4::numeric, 0::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, '19. Yüzyıl Rus Edebiyatı'::text, 5::int, 4::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Rus Şiiri'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Rus Edebiyatı Analizi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Çocuk Edebiyatı'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Rusça İş Rusçası'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, '20. Yüzyıl Rus Edebiyatı'::text, 5::int, 4::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Rus Edebiyatı Semineri'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.2::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Karşılaştırmalı Edebiyat'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Türk-Rus Kültürel İlişkileri'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Bitirme Çalışması I'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Bitirme Çalışması II'::text, 5::int, 5::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Çeviri Uygulamaları'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.2::numeric, 0.3::numeric, 7::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Seçmeli: Rus Felsefesi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Seçmeli: Slav Dilleri'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 7::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Bitirme Çalışması III'::text, 6::int, 6::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Seçmeli: Rus Tiyatrosu'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid, 'Seçmeli: Sovyet Edebiyatı'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '4bafb952-c1f4-40cc-8acb-b23860a3248a'::uuid LIMIT 1
);

-- === Sac Bakimi Ve Guzellik Hizmetleri (sac-bakimi-ve-guzellik-hizmetleri) — 23 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'Cilt Bakımına Giriş'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'Saç Bakımına Giriş'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'Anatomi ve Fizyoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'Mesleki Hijyen ve Sanitasyon'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'Cilt Bakım Uygulamaları'::text, 4::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'Saç Bakım Uygulamaları'::text, 4::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'Makyaj Teknikleri'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'Saç Tasarımı'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'İleri Cilt Bakım'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'İleri Saç Bakım'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'Kalıcı Makyaj'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'Saç Boyama Teknikleri'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'Cilt Hastalıkları'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'Epilasyon Uygulamaları'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'İleri Makyaj'::text, 4::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'Güzellik Salonu Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'Müşteri İlişkileri'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'Staj'::text, 4::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '456b97d4-1642-4ac0-8b79-a4a5116b471c'::uuid LIMIT 1
);

-- === Sanat Tarihi (sanat-tarihi) — 41 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Sanat Tarihi Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'İlkçağ Sanatı'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Arkeolojiye Giriş'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Mitoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Yunan Sanatı'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Roma Sanatı'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Erken Hristiyan ve Bizans Sanatı'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Antik Coğrafya'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'İslam Sanatı'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Avrupa Ortaçağ Sanatı'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Türk Sanatı I'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Sanat Sosyolojisi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Sanat Felsefesi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Rönesans Sanatı'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Avrupa Sanatı (15-18 YY)'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Osmanlı Sanatı'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Mimari Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Sanat Eleştirisi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, '19. Yüzyıl Sanatı'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Çağdaş Sanat Akımları I'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Türk Sanatı II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Müzecilik'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'İkonografi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, '20. Yüzyıl Sanatı'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Çağdaş Sanat Akımları II'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Türk Cumhuriyet Dönemi Sanatı'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Bitirme Çalışması I'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Seçmeli: Sinema Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Bitirme Çalışması II'::text, 5::int, 5::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Sanat Tarihi Yöntemleri'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Seçmeli: Fotoğraf Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 7::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Seçmeli: Süsleme Sanatları'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 7::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Bitirme Çalışması III'::text, 6::int, 6::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Müze ve Galeri Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Seçmeli: Sanat Piyasası'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid, 'Seçmeli: Dijital Sanat Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = 'b8461b2a-91ed-4f46-99e3-0b9a5e2cf9e8'::uuid LIMIT 1
);

-- === Seramik (seramik) — 40 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Temel Sanat Eğitimi I'::text, 4::int, 5::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Seramiğe Giriş'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 1::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Çamur Hazırlama'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Desen I'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Sanat Tarihi I'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Temel Sanat Eğitimi II'::text, 4::int, 5::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'El Şekillendirme I'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Çark Techniques'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 2::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Desen II'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Sanat Tarihi II'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Sırlama Teknikleri'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Dekoratif Teknikler'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Seramik Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Türk Seramik Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Model ve Kalıp'::text, 3::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Atölye I'::text, 5::int, 6::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Seramik Tasarımı'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Porselen Çalışmaları'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Çağdaş Seramik'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Endüstriyel Seramik'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Atölye II'::text, 5::int, 6::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Dijital Seramik Tasarım'::text, 4::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Sanat Felsefesi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Seramik Restorasyon'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Seçmeli: Mosaic Sanatı'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Atölye III'::text, 5::int, 6::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Bitirme Projesi I'::text, 4::int, 5::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Seramik Üretim Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Seçmeli: Cam Sanatı'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Bitirme Projesi II'::text, 5::int, 6::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Sanat Eleştirisi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Seçmeli: Mimari Seramik'::text, 3::int, 4::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Bitirme Projesi III'::text, 6::int, 8::int, 0::numeric, 0.3::numeric, 0.5::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Portföy ve Sergi Hazırlama'::text, 3::int, 3::int, 0.2::numeric, 0.4::numeric, 0.2::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid, 'Seçmeli: Sanat Girişimciliği'::text, 3::int, 3::int, 0.4::numeric, 0.3::numeric, 0::numeric, 0.3::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = 'a30f7767-aa27-4400-8a27-dfce36d54f16'::uuid LIMIT 1
);

-- === Siyaset Bilimi Ve Kamu Yonetimi (siyaset-bilimi-ve-kamu-yonetimi) — 41 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Siyaset Bilimine Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Hukuk Başlangıcı'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Sosyoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Anayasa Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Siyaset Kuramları'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Kamu Yönetimine Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Türk Siyasal Hayatı'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'İktisada Giriş'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Karşılaştırmalı Siyaset'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'İdare Hukuku'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Türk İdare Tarihi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Siyaset Sosyolojisi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'İstatistik'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Yerel Yönetimler'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Siyaset Felsefesi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'İdari Yargılama'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Kamu Politikası'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Araştırma Yöntemleri'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Türk Dış Politikası I'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Kamu Personel Yönetimi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Devlet Bütçesi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Avrupa Birliği Politikaları'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Sosyal Psikoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Türk Dış Politikası II'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Yönetim Bilimi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Kentleşme ve Çevre'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Bitirme Çalışması I'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Seçmeli: Dijital Devlet'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Bitirme Çalışması II'::text, 5::int, 5::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Staj'::text, 4::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Seçmeli: Karşılaştırmalı Kamu Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 7::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Seçmeli: Politika Analizi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Bitirme Çalışması III'::text, 6::int, 6::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Kamu Yönetimi Etik'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Seçmeli: İnsan Hakları'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 8::int, NULL::integer),
  ('1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid, 'Seçmeli: Çağdaş Siyasal Sistemler'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '1bf80578-8085-4fe3-ba29-f57f53f1d455'::uuid LIMIT 1
);

-- === Sinif Ogretmenligi (sinif-ogretmenligi) — 43 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Eğitim Bilimine Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Türkçe I (Okuma Yazma)'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Matematik I'::text, 4::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Fen Bilgisi I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Bilgisayar Becerileri'::text, 2::int, 2::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Gelişim ve Öğrenme'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Türkçe II'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Matematik II'::text, 4::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Fen Bilgisi II'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Sosyal Bilgiler'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Öğretim İlke ve Yöntemleri'::text, 5::int, 4::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Türkçe Öğretimi I'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Matematik Öğretimi I'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Fen Öğretimi I'::text, 3::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Sınıf Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Müzik Öğretimi'::text, 2::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Türkçe Öğretimi II'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Matematik Öğretimi II'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Fen Öğretimi II'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Sosyal Bilgiler Öğretimi'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Ölçme ve Değerlendirme'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Görsel Sanatlar Öğretimi'::text, 2::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Özel Öğretim Yöntemleri I'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Rehberlik'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Özel Eğitime Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Topluma Hizmet'::text, 2::int, 2::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Seçmeli: Drama'::text, 3::int, 3::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Özel Öğretim Yöntemleri II'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Beden Eğitimi Öğretimi'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Bitirme Çalışması I'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Seçmeli: Çocuk Edebiyatı'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Seçmeli: İlk Okuma Yazma'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Öğretmenlik Uygulaması I'::text, 6::int, 6::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Bitirme Çalışması II'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Seçmeli: Sınıf Öğretmenliğinde İnovasyon'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Öğretmenlik Uygulaması II'::text, 8::int, 8::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Bitirme Çalışması III'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid, 'Seçmeli: Kırsal Bölgelerde Eğitim'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = 'a81c81b3-37dc-4682-9129-a380d1f4bf81'::uuid LIMIT 1
);

-- === Sosyal Bilgiler Ogretmenligi (sosyal-bilgiler-ogretmenligi) — 41 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Eğitim Bilimine Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Tarih I (İlk ve Orta Çağ)'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Coğrafya I'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Vatandaşlık Bilgisi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Gelişim ve Öğrenme'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Tarih II (Yeni ve Yakın Çağ)'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Coğrafya II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Sosyolojiye Giriş'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Öğretim İlke ve Yöntemleri'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Sosyal Bilgiler Öğretimi I'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Türk İnkılap Tarihi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'İktisada Giriş'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Anayasa Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Sosyal Bilgiler Öğretimi II'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Türk Kültürü'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Felsefe'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Ölçme ve Değerlendirme'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Sınıf Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Sosyal Bilgiler Öğretim Programları'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Rehberlik'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Türk Dış Politikası'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Avrupa Birliği'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Bilgisayar Destekli Öğretim'::text, 2::int, 2::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'İleri Sosyal Bilgiler Öğretimi'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Topluma Hizmet'::text, 2::int, 2::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Bitirme Çalışması I'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Seçmeli: Coğrafi Bilgi Sistemleri'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Seçmeli: Müze Eğitimi'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Öğretmenlik Uygulaması I'::text, 6::int, 6::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Bitirme Çalışması II'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Seçmeli: Değerler Eğitimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Seçmeli: Karşılaştırmalı Eğitim'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 7::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Öğretmenlik Uygulaması II'::text, 8::int, 8::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Bitirme Çalışması III'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Seçmeli: İnsan Hakları Eğitimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid, 'Seçmeli: Halk Kültürü'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '560721d2-66cd-4e56-82fe-a8c449dd0ec9'::uuid LIMIT 1
);

-- === Sosyal Hizmet (sosyal-hizmet) — 41 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Sosyal Hizmete Giriş'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Sosyoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Psikoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Anatomi ve Fizyoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Sosyal Hizmet Tarihi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Sosyal Politika'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Sosyal Hizmet Kuramları'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'İnsan Davranışı ve Sosyal Çevre'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Sosyal Hizmette Araştırma'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Sosyal Hizmette Görüşme'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Çocuk Refahı'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Aile ve Çift Danışmanlığı'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Halk Sağlığı'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Sosyal Hizmette Etik'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Grupla Sosyal Hizmet'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Yaşlı Refahı'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Engelli Refahı'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Kadın Sorunları ve Sosyal Hizmet'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Toplumla Sosyal Hizmet'::text, 5::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Medikal Sosyal Hizmet'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Okul Sosyal Hizmeti'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Adli Sosyal Hizmet'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Krize Müdahale'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Sosyal Hizmet Uygulaması I'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Ruh Sağlığı ve Sosyal Hizmet'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Madde Bağımlılığı'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Sosyal Hizmette Proje Yönetimi'::text, 3::int, 3::int, 0.3::numeric, 0.4::numeric, 0.1::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Bitirme Çalışması I'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Sosyal Hizmet Uygulaması II'::text, 6::int, 6::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'İleri Sosyal Hizmet Semineri'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Seçmeli: Göç ve Sosyal Hizmet'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Bitirme Çalışması II'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Sosyal Hizmet Uygulaması III'::text, 8::int, 8::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Bitirme Çalışması III'::text, 4::int, 4::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Seçmeli: Sivil Toplum Kuruluşları'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('26d67854-0889-49f8-bec7-219061b74c3a'::uuid, 'Seçmeli: İnsan Hakları'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '26d67854-0889-49f8-bec7-219061b74c3a'::uuid LIMIT 1
);

-- === Sosyoloji (sosyoloji) — 41 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Sosyolojiye Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Felsefe'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Sosyal Psikoloji'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Bilgisayar Becerileri'::text, 2::int, 2::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 1::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Sosyolojik Kuramlar I'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Sosyolojik Düşünceler Tarihi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Araştırma Yöntemleri I'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'İstatistik I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Sosyolojik Kuramlar II'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Türk Toplum Yapısı'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Aile Sosyolojisi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Kent Sosyolojisi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Sanat Sosyolojisi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Karşılaştırmalı Sosyoloji'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Din Sosyolojisi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Eğitim Sosyolojisi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Siyaset Sosyolojisi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Araştırma Yöntemleri II'::text, 3::int, 3::int, 0.3::numeric, 0.4::numeric, 0.1::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Çalışma Sosyolojisi'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Kültür Sosyolojisi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Sağlık Sosyolojisi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Sosyal Hareketler'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Çevre Sosyolojisi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Türkiye''nin Sosyal Yapısı'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Azınlık Sosyolojisi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Medya Sosyolojisi'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Bitirme Çalışması I'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Seçmeli: Göç Sosyolojisi'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Bitirme Çalışması II'::text, 5::int, 5::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Sosyolojik Analiz'::text, 4::int, 3::int, 0.4::numeric, 0.3::numeric, 0::numeric, 0.3::numeric, 7::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Staj'::text, 3::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Seçmeli: Dijital Sosyoloji'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 7::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Bitirme Çalışması III'::text, 6::int, 6::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Sosyoloji Etik'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Seçmeli: Küreselleşme Sosyolojisi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('b788238e-0037-43ef-9bc1-fccfea890101'::uuid, 'Seçmeli: Cinsiyet Sosyolojisi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = 'b788238e-0037-43ef-9bc1-fccfea890101'::uuid LIMIT 1
);

-- === Tibbi Laboratuvar Teknikleri (tibbi-laboratuvar-teknikleri) — 23 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'Anatomi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'Fizyoloji'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'Genel Biyoloji'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'Genel Kimya'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'Biokimya'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'Mikrobiyoloji'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'Hematoloji I'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'Laboratuvar Cihazleri'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'Klinik Biokimya'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 3::int, NULL::integer),
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'Hematoloji II'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 3::int, NULL::integer),
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'İdrar Analizi'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'Parazitoloji'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'Tıbbi Mikrobiyoloji'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'Klinik Mikrobiyoloji'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'İmmünoloji'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'Viroloji'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'Tıbbi Patoloji'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'Staj'::text, 4::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('b5264045-5802-45d7-89da-a86f02497ded'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = 'b5264045-5802-45d7-89da-a86f02497ded'::uuid LIMIT 1
);

-- === Turizm Rehberligi (turizm-rehberligi) — 41 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Turizm İlkeleri'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Anadolu Coğrafyası'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Türk Tarihi I'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'İngilizce I'::text, 4::int, 4::int, 0.4::numeric, 0.1::numeric, 0.1::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Türk Tarihi II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Mitoloji'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Arkeoloji ve Sanat Tarihi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'İngilizce II'::text, 4::int, 4::int, 0.4::numeric, 0.1::numeric, 0.1::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Turizm Coğrafyası'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Türk Mutfağı ve Kültürü'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Rehberlik Uygulamaları I'::text, 5::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'İkinci Yabancı Dil I (Almanca)'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Halk Kültürü'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'İleri Rehberlik Uygulamaları'::text, 5::int, 5::int, 0.2::numeric, 0.2::numeric, 0.4::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Turizm Mevzuatı'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'İkinci Yabancı Dil II'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'İletişim Becerileri'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 4::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Staj'::text, 4::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'İleri İngilizce (Rehberlik)'::text, 5::int, 5::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Türk Arkeolojisi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Turizm Pazarlaması'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Türkiye''de Turizm Bölgeleri'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Müzecilik'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Bitirme Çalışması I'::text, 5::int, 5::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Doğa Turizmi ve Ekoturizm'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Turizm Sosyolojisi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Seçmeli: Kültürel Miras'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Seçmeli: Alternatif Turizm'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Bitirme Çalışması II'::text, 6::int, 6::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'İleri Rehberlik Semineri'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Seçmeli: Türk El Sanatları'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 7::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Seçmeli: Dünya Turizm Coğrafyası'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 7::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Bitirme Çalışması III'::text, 7::int, 8::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Turizm Etik'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Seçmeli: Dijital Turizm'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 8::int, NULL::integer),
  ('6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid, 'Seçmeli: Sürdürülebilir Turizm'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '6fc87e2c-31ca-4418-bd75-7114163ab606'::uuid LIMIT 1
);

-- === Turizm Ve Otel Isletmeciligi (turizm-ve-otel-isletmeciligi) — 41 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Turizme Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'İşletme İlkeleri'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Otel İşletmeciliğine Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'İngilizce I'::text, 4::int, 4::int, 0.4::numeric, 0.1::numeric, 0.1::numeric, 0.4::numeric, 1::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Turizm Ekonomisi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Ön Büro Yönetimi'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Konaklama Hizmetleri'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 2::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'İngilizce II'::text, 4::int, 4::int, 0.4::numeric, 0.1::numeric, 0.1::numeric, 0.4::numeric, 2::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Kat Hizmetleri Yönetimi'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Yiyecek İçecek Yönetimi'::text, 5::int, 5::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 3::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Turizm Pazarlaması'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Muhasebe (Turizm)'::text, 4::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'İkinci Yabancı Dil I (Almanca)'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Otel Muhasebesi'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'İleri Yiyecek İçecek'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 4::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Turizm Mevzuatı'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Müşteri İlişkileri Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 4::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'İkinci Yabancı Dil II'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Otel Yönetim Sistemleri'::text, 5::int, 4::int, 0.3::numeric, 0.3::numeric, 0.2::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Turizm Sosyolojisi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Etkinlik ve Kongre Yönetimi'::text, 4::int, 4::int, 0.2::numeric, 0.3::numeric, 0.3::numeric, 0.2::numeric, 5::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'İleri İngilizce (Turizm)'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'İnsan Kaynakları Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Bitirme Çalışması I'::text, 5::int, 5::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Stratejik Otel Yönetimi'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Staj'::text, 3::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Seçmeli: Dijital Pazarlama (Turizm)'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 6::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Seçmeli: Sürdürülebilir Turizm'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Bitirme Çalışması II'::text, 6::int, 6::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Turizmde Kalite Yönetimi'::text, 4::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Seçmeli: Kültürel Turizm'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 7::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Seçmeli: Kruvaziyer Yönetimi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Bitirme Çalışması III'::text, 7::int, 8::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Turizm Etik'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Seçmeli: Turizm Teknolojileri'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 8::int, NULL::integer),
  ('6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid, 'Seçmeli: Sağlık Turizmi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '6d070a9b-1f2f-45f0-92dc-155a106ef1fe'::uuid LIMIT 1
);

-- === Turk Dili Ve Edebiyati (turk-dili-ve-edebiyati) — 44 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Eski Türk Edebiyatı I'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Yeni Türk Edebiyatı I'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Türk Halk Edebiyatı I'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Türk Dili Tarihi I'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Osmanlı Türkçesi I'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 1::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Eski Türk Edebiyatı II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Yeni Türk Edebiyatı II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Türk Halk Edebiyatı II'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Türk Dili Tarihi II'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Osmanlı Türkçesi II'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 2::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Eski Türk Edebiyatı III'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Yeni Türk Edebiyatı III'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Türk Halk Edebiyatı III'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Türk Dili III'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Osmanlı Türkçesi III'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 3::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Edebiyat Teorisi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Eski Türk Edebiyatı IV'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Yeni Türk Edebiyatı IV'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Türk Halk Edebiyatı IV'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Türk Dili IV'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Osmanlı Türkçesi IV'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Karşılaştırmalı Edebiyat'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 4::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Eski Türk Edebiyatı V'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Yeni Türk Edebiyatı V'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 5::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Türk Dili V'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Batı Edebiyatı'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Metin İnceleme Yöntemleri'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Eski Türk Edebiyatı VI'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Yeni Türk Edebiyatı VI'::text, 5::int, 4::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Türk Dili VI'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Bitirme Çalışması I'::text, 3::int, 3::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Seçmeli: Çağdaş Türk Şiiri'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Bitirme Çalışması II'::text, 5::int, 5::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Türk Edebiyatı Semineri'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 7::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Seçmeli: Çağdaş Türk Romanı'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Seçmeli: Hikaye ve Roman İncelemesi'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Bitirme Çalışması III'::text, 6::int, 6::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Seçmeli: Çocuk Edebiyatı'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid, 'Seçmeli: Edebiyat ve Sinema'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = 'e3661e3f-f7f8-44dd-8e86-1793a77a06f7'::uuid LIMIT 1
);

-- === Uluslararasi Iliskiler (uluslararasi-iliskiler) — 41 ders ===
INSERT INTO department_courses
  (department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
SELECT v.department_id, v.ad, v.kredi, v.ders_saati, v.vize_yuzde, v.odev_yuzde, v.proje_yuzde, v.final_yuzde, v.donem, v.legacy_id
FROM (VALUES
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Uluslararası İlişkilere Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Siyaset Bilimine Giriş'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Hukuk Başlangıcı'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Siyaset Tarihi I'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Türk Dili I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Atatürk İlkeleri I'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 1::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Uluslararası İlişkiler Kuramları'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Karşılaştırmalı Siyaset'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Siyaset Tarihi II'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Anayasa Hukuku'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Türk Dili II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Atatürk İlkeleri II'::text, 2::int, 2::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 2::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Türk Dış Politikası I'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Uluslararası Hukuk I'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Uluslararası Örgütler'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Uluslararası Siyaset Ekonomisi'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Diplomasi Tarihi'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 3::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Türk Dış Politikası II'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Uluslararası Hukuk II'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Avrupa Birliği Politikaları'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Bölgesel Çalışmalar (Ortadoğu)'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Uluslararası Güvenlik'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 4::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Türk Dış Politikası III'::text, 5::int, 4::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Diplomasi ve Müzakere'::text, 4::int, 4::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 5::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Bölgesel Çalışmalar (Asya)'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'İnsan Hakları'::text, 3::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 5::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Araştırma Yöntemleri'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0::numeric, 0.4::numeric, 5::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Bitirme Çalışması I'::text, 5::int, 5::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Staj'::text, 3::int, 0::int, 0::numeric, 0.5::numeric, 0.3::numeric, 0.2::numeric, 6::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Bölgesel Çalışmalar (Avrupa)'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 6::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Seçmeli: Enerji Politikası'::text, 3::int, 3::int, 0.4::numeric, 0.1::numeric, 0::numeric, 0.5::numeric, 6::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Seçmeli: Göç Politikaları'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 6::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Bitirme Çalışması II'::text, 6::int, 6::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 7::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Bölgesel Çalışmalar (Amerika)'::text, 4::int, 3::int, 0.4::numeric, 0::numeric, 0::numeric, 0.6::numeric, 7::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Seçmeli: Çevre Politikası'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Seçmeli: Çatışma Çözümü'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 7::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Bitirme Çalışması III'::text, 7::int, 8::int, 0::numeric, 0.4::numeric, 0.4::numeric, 0.2::numeric, 8::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Uluslararası İlişkiler Etik'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Meslek Etiği'::text, 2::int, 2::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Seçmeli: Dijital Diplomasi'::text, 3::int, 3::int, 0.3::numeric, 0.3::numeric, 0.1::numeric, 0.3::numeric, 8::int, NULL::integer),
  ('043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid, 'Seçmeli: Küreselleşme'::text, 3::int, 3::int, 0.4::numeric, 0.2::numeric, 0::numeric, 0.4::numeric, 8::int, NULL::integer)
) AS v(department_id, ad, kredi, ders_saati, vize_yuzde, odev_yuzde, proje_yuzde, final_yuzde, donem, legacy_id)
WHERE NOT EXISTS (
  SELECT 1 FROM department_courses dc WHERE dc.department_id = '043d2e3b-78eb-42f0-8881-4a7aa4d0685a'::uuid LIMIT 1
);

COMMIT;

-- ============================================================
-- Doğrulama sorguları
-- ============================================================
-- Toplam üniversite sayısı (beklenen: 30):
-- SELECT COUNT(*) FROM universities;

-- Toplam fakülte sayısı:
-- SELECT COUNT(*) FROM faculties;

-- Toplam department_courses sayısı (beklenen: ~2293):
-- SELECT COUNT(*) FROM department_courses;

-- Üniversite başına fakülte sayısı:
-- SELECT u.ad, COUNT(f.id) FROM universities u
-- LEFT JOIN faculties f ON f.university_id = u.id
-- GROUP BY u.ad ORDER BY u.ad;

-- legacy_id=0 kalmış mı kontrol (0 olmalı):
-- SELECT COUNT(*) FROM department_courses WHERE legacy_id = 0;
-- ============================================================
-- UniPulse Migration: Fakülte-Bölüm Eşleştirme Düzeltmeleri
-- ============================================================
-- Bu migration:
--   1. 31 boş fakülteyi (0 bölüm) siler
--   2. Tıp Fakültesi'nden yanlış bölümleri kaldırır
--      (Tıbbi Lab, Beslenme, Dil Konuşma — bunlar Sağlık Bilimleri'ne ait)
--   3. Meslek Yüksekokulu'ndan yanlış bölümleri kaldırır
--      (Aşçılık, Çocuk Gelişimi, Saç Bakımı, Eczane Hizmetleri, vb.)
--   4. Pamukkale, Kocaeli, Selçuk, Gaziantep için doğru eşleştirme ekler
--
-- Tarih: 2026-06-28
-- ============================================================

BEGIN;

-- ============================================================
-- 1) 0 BÖLÜMLÜ FAKÜLTELERİ SİL
-- ============================================================
-- Bu fakültelerde hiç bölüm yok (eşleştirme eklenmemiş).
-- Pamukkale, Kocaeli, Selçuk, Gaziantep üniversitelerinin tüm fakülteleri.
-- Koç Tıp Fakültesi de boş (Koç'ta tıp yok, diğerleri dolu).

DELETE FROM faculties
WHERE slug IN (
  -- Pamukkale (6 fakülte, hepsi boş)
  'iibf-pamukkale-universitesi',
  'egitim-pamukkale-universitesi',
  'tip-pamukkale-universitesi',
  'turizm-pamukkale-universitesi',
  'meslek-yuksekokulu-pamukkale-universitesi',
  -- Kocaeli (8 fakülte, hepsi boş)
  'muhendislik-kocaeli-universitesi',
  'fen-edebiyat-kocaeli-universitesi',
  'iibf-kocaeli-universitesi',
  'hukuk-kocaeli-universitesi',
  'egitim-kocaeli-universitesi',
  'tip-kocaeli-universitesi',
  'iletisim-kocaeli-universitesi',
  'meslek-yuksekokulu-kocaeli-universitesi',
  -- Selçuk (9 fakülte, hepsi boş)
  'muhendislik-selcuk-universitesi',
  'fen-edebiyat-selcuk-universitesi',
  'iibf-selcuk-universitesi',
  'hukuk-selcuk-universitesi',
  'egitim-selcuk-universitesi',
  'tip-selcuk-universitesi',
  'eczacilik-selcuk-universitesi',
  'iletisim-selcuk-universitesi',
  'meslek-yuksekokulu-selcuk-universitesi',
  -- Gaziantep (7 fakülte, hepsi boş)
  'muhendislik-gaziantep-universitesi',
  'fen-edebiyat-gaziantep-universitesi',
  'iibf-gaziantep-universitesi',
  'hukuk-gaziantep-universitesi',
  'egitim-gaziantep-universitesi',
  'tip-gaziantep-universitesi',
  'eczacilik-gaziantep-universitesi',
  'meslek-yuksekokulu-gaziantep-universitesi',
  -- Koç Tıp (boş, Koç'ta tıp yok ama eklenmiş)
  'koc-tip'
);

-- ============================================================
-- 2) TIP FAKÜLTESİ'NDEN YANLIŞ BÖLÜMLERİ KALDIR
-- ============================================================
-- Tıp Fakültesi'nde sadece 'tibbi-laboratuvar-teknikleri', 'beslenme-ve-diyetetik',
-- 'dil-ve-konusma-terapisi' yanlış eklenmiş. Bunlar Sağlık Bilimleri veya MYO'ya ait.
-- Tıp Fakültesi şu an için boş kalacak (tıp bölümü DB'de yok).

DELETE FROM faculty_departments
WHERE faculty_id IN (
  SELECT id FROM faculties WHERE ad = 'Tıp Fakültesi'
)
AND department_slug IN (
  'tibbi-laboratuvar-teknikleri',
  'beslenme-ve-diyetetik',
  'dil-ve-konusma-terapisi'
);

-- ============================================================
-- 3) MESLEK YÜKSEKOKULU'NDAN YANLIŞ BÖLÜMLERİ KALDIR
-- ============================================================
-- İTÜ, Yıldız, Marmara gibi teknik üniversitelerin MYO'sunda
-- Aşçılık, Çocuk Gelişimi, Saç Bakımı, Eczane Hizmetleri olmaz.
-- Sadece aşağıdaki bölümler MYO'da olur:
--   - adalet, bilgisayar-programciligi, arka-yuz-yazilim-gelistirme,
--   - buyuk-veri-analistligi, oyun-gelistirme-ve-programlama,
--   - ofis-yonetimi-ve-sekreterlik, emlak-yonetimi, dis-ticaret
-- Diğer teknik olmayan bölümleri MYO'dan kaldır.

DELETE FROM faculty_departments
WHERE faculty_id IN (
  SELECT id FROM faculties
  WHERE ad = 'Meslek Yüksekokulu'
    AND slug IN (
      'meslek-yuksekokulu-itu',
      'meslek-yuksekokulu-yildiz-teknik-universitesi',
      'meslek-yuksekokulu-marmara-universitesi',
      'meslek-yuksekokulu-gazi-universitesi',
      'meslek-yuksekokulu-eskisehir-teknik-universitesi',
      'meslek-yuksekokulu-sakarya-universitesi',
      'meslek-yuksekokulu-karadeniz-teknik-universitesi'
    )
)
AND department_slug IN (
  'ascilik',
  'cocuk-gelisimi',
  'sac-bakimi-ve-guzellik-hizmetleri',
  'eczane-hizmetleri',
  'tibbi-laboratuvar-teknikleri',
  'beslenme-ve-diyetetik',
  'dil-ve-konusma-terapisi'
);

-- ============================================================
-- 4) EKSİK EŞLEŞTİRMELERİ EKLE
-- ============================================================
-- Pamukkale, Kocaeli, Selçuk, Gaziantep için doğru fakülte-bölüm eşleştirmesi.
-- Bu üniversitelerin fakültelerini sildik, şimdi yeniden oluşturup eşleştirelim.
-- Sadece bu 4 üniversiteye ait bölümleri ekleyeceğiz (idempotent).

-- === Pamukkale Üniversitesi ===
-- Mühendislik, Fen-Edebiyat, İİBF, Eğitim, Turizm, Meslek Yüksekokulu

-- Önce fakülteleri yeniden ekle (silinmişti)
INSERT INTO faculties (ad, emoji, renk, slug, university_id)
SELECT v.ad, v.emoji, v.renk, v.slug, u.id
FROM universities u
CROSS JOIN (VALUES
  ('Mühendislik Fakültesi', '⚙️', '#4f46e5', 'muhendislik-pamukkale-universitesi'),
  ('Fen-Edebiyat Fakültesi', '🔬', '#7c3aed', 'fen-edebiyat-pamukkale-universitesi'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'iibf-pamukkale-universitesi'),
  ('Eğitim Fakültesi', '🎓', '#16a34a', 'egitim-pamukkale-universitesi'),
  ('Turizm Fakültesi', '🏖️', '#0ea5e9', 'turizm-pamukkale-universitesi'),
  ('Meslek Yüksekokulu', '🔧', '#64748b', 'meslek-yuksekokulu-pamukkale-universitesi')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'pamukkale-universitesi'
ON CONFLICT (slug) DO NOTHING;

-- Pamukkale - bölüm eşleştirmeleri
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'muhendislik-pamukkale-universitesi'
  AND d.slug IN ('bilgisayar-programciligi', 'arka-yuz-yazilim-gelistirme', 'oyun-gelistirme-ve-programlama', 'buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'fen-edebiyat-pamukkale-universitesi'
  AND d.slug IN ('felsefe', 'sosyoloji', 'psikoloji', 'turk-dili-ve-edebiyati', 'arkeoloji', 'sanat-tarihi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-pamukkale-universitesi'
  AND d.slug IN ('iktisat', 'isletme', 'maliye', 'calisma-ekonomisi-ve-endustri-iliskileri', 'bankacilik-ve-finans', 'muhasebe-ve-finans-yonetimi', 'pazarlama', 'siyaset-bilimi-ve-kamu-yonetimi', 'uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'egitim-pamukkale-universitesi'
  AND d.slug IN ('ingilizce-ogretmenligi', 'sinif-ogretmenligi', 'okul-oncesi-ogretmenligi', 'sosyal-bilgiler-ogretmenligi', 'ilkogretim-matematik-ogretmenligi', 'bilgisayar-ve-ogretim-teknolojileri', 'ozel-egitim-ogretmenligi', 'rehberlik-ve-psikolojik-danismanlik')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'turizm-pamukkale-universitesi'
  AND d.slug IN ('turizm-rehberligi', 'turizm-ve-otel-isletmeciligi', 'gastronomi-ve-mutfak-sanatlari')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'meslek-yuksekokulu-pamukkale-universitesi'
  AND d.slug IN ('adalet', 'bilgisayar-programciligi', 'ofis-yonetimi-ve-sekreterlik', 'emlak-yonetimi')
ON CONFLICT DO NOTHING;

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
  ('İletişim Fakültesi', '📡', '#d97706', 'iletisim-kocaeli-universitesi'),
  ('Meslek Yüksekokulu', '🔧', '#64748b', 'meslek-yuksekokulu-kocaeli-universitesi')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'kocaeli-universitesi'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'muhendislik-kocaeli-universitesi'
  AND d.slug IN ('bilgisayar-programciligi', 'arka-yuz-yazilim-gelistirme', 'oyun-gelistirme-ve-programlama', 'buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'fen-edebiyat-kocaeli-universitesi'
  AND d.slug IN ('felsefe', 'sosyoloji', 'psikoloji', 'turk-dili-ve-edebiyati', 'arkeoloji', 'sanat-tarihi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-kocaeli-universitesi'
  AND d.slug IN ('iktisat', 'isletme', 'maliye', 'calisma-ekonomisi-ve-endustri-iliskileri', 'bankacilik-ve-finans', 'muhasebe-ve-finans-yonetimi', 'pazarlama', 'siyaset-bilimi-ve-kamu-yonetimi', 'uluslararasi-iliskiler')
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
  AND d.slug IN ('ingilizce-ogretmenligi', 'sinif-ogretmenligi', 'okul-oncesi-ogretmenligi', 'sosyal-bilgiler-ogretmenligi', 'ilkogretim-matematik-ogretmenligi', 'bilgisayar-ve-ogretim-teknolojileri', 'ozel-egitim-ogretmenligi', 'rehberlik-ve-psikolojik-danismanlik')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iletisim-kocaeli-universitesi'
  AND d.slug IN ('gazetecilik', 'radyo-televizyon-ve-sinema', 'halkla-iliskiler-ve-tanitim', 'reklamcilik', 'iletisim-bilimleri', 'gorsel-iletisim-tasarimi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'meslek-yuksekokulu-kocaeli-universitesi'
  AND d.slug IN ('adalet', 'bilgisayar-programciligi', 'ofis-yonetimi-ve-sekreterlik', 'emlak-yonetimi')
ON CONFLICT DO NOTHING;

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
  ('Eczacılık Fakültesi', '💊', '#16a34a', 'eczacilik-selcuk-universitesi'),
  ('İletişim Fakültesi', '📡', '#d97706', 'iletisim-selcuk-universitesi'),
  ('Meslek Yüksekokulu', '🔧', '#64748b', 'meslek-yuksekokulu-selcuk-universitesi')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'selcuk-universitesi'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'muhendislik-selcuk-universitesi'
  AND d.slug IN ('bilgisayar-programciligi', 'arka-yuz-yazilim-gelistirme', 'oyun-gelistirme-ve-programlama', 'buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'fen-edebiyat-selcuk-universitesi'
  AND d.slug IN ('felsefe', 'sosyoloji', 'psikoloji', 'turk-dili-ve-edebiyati', 'arkeoloji', 'sanat-tarihi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-selcuk-universitesi'
  AND d.slug IN ('iktisat', 'isletme', 'maliye', 'calisma-ekonomisi-ve-endustri-iliskileri', 'bankacilik-ve-finans', 'muhasebe-ve-finans-yonetimi', 'pazarlama', 'siyaset-bilimi-ve-kamu-yonetimi', 'uluslararasi-iliskiler')
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
  AND d.slug IN ('ingilizce-ogretmenligi', 'sinif-ogretmenligi', 'okul-oncesi-ogretmenligi', 'sosyal-bilgiler-ogretmenligi', 'ilkogretim-matematik-ogretmenligi', 'bilgisayar-ve-ogretim-teknolojileri', 'ozel-egitim-ogretmenligi', 'rehberlik-ve-psikolojik-danismanlik')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'eczacilik-selcuk-universitesi'
  AND d.slug IN ('eczacilik', 'eczane-hizmetleri')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iletisim-selcuk-universitesi'
  AND d.slug IN ('gazetecilik', 'radyo-televizyon-ve-sinema', 'halkla-iliskiler-ve-tanitim', 'reklamcilik', 'iletisim-bilimleri', 'gorsel-iletisim-tasarimi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'meslek-yuksekokulu-selcuk-universitesi'
  AND d.slug IN ('adalet', 'bilgisayar-programciligi', 'ofis-yonetimi-ve-sekreterlik', 'emlak-yonetimi', 'cocuk-gelisimi', 'ascilik', 'sac-bakimi-ve-guzellik-hizmetleri')
ON CONFLICT DO NOTHING;

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
  ('Eczacılık Fakültesi', '💊', '#16a34a', 'eczacilik-gaziantep-universitesi'),
  ('Meslek Yüksekokulu', '🔧', '#64748b', 'meslek-yuksekokulu-gaziantep-universitesi')
) AS v(ad, emoji, renk, slug)
WHERE u.slug = 'gaziantep-universitesi'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'muhendislik-gaziantep-universitesi'
  AND d.slug IN ('bilgisayar-programciligi', 'arka-yuz-yazilim-gelistirme', 'oyun-gelistirme-ve-programlama', 'buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'fen-edebiyat-gaziantep-universitesi'
  AND d.slug IN ('felsefe', 'sosyoloji', 'psikoloji', 'turk-dili-ve-edebiyati', 'arkeoloji', 'sanat-tarihi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'iibf-gaziantep-universitesi'
  AND d.slug IN ('iktisat', 'isletme', 'maliye', 'calisma-ekonomisi-ve-endustri-iliskileri', 'bankacilik-ve-finans', 'muhasebe-ve-finans-yonetimi', 'pazarlama', 'siyaset-bilimi-ve-kamu-yonetimi', 'uluslararasi-iliskiler')
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
  AND d.slug IN ('ingilizce-ogretmenligi', 'sinif-ogretmenligi', 'okul-oncesi-ogretmenligi', 'sosyal-bilgiler-ogretmenligi', 'ilkogretim-matematik-ogretmenligi', 'bilgisayar-ve-ogretim-teknolojileri', 'ozel-egitim-ogretmenligi', 'rehberlik-ve-psikolojik-danismanlik')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'eczacilik-gaziantep-universitesi'
  AND d.slug IN ('eczacilik', 'eczane-hizmetleri')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'meslek-yuksekokulu-gaziantep-universitesi'
  AND d.slug IN ('adalet', 'bilgisayar-programciligi', 'ofis-yonetimi-ve-sekreterlik', 'emlak-yonetimi', 'cocuk-gelisimi', 'ascilik', 'sac-bakimi-ve-guzellik-hizmetleri')
ON CONFLICT DO NOTHING;

COMMIT;

-- ============================================================
-- Doğrulama
-- ============================================================
-- 0 bölüm kalan fakülte var mı?
-- SELECT f.ad, u.ad AS uni, COUNT(fd.department_slug) AS bolum_sayisi
-- FROM faculties f
-- LEFT JOIN faculty_departments fd ON fd.faculty_id = f.id
-- LEFT JOIN universities u ON u.id = f.university_id
-- GROUP BY f.ad, u.ad
-- HAVING COUNT(fd.department_slug) = 0
-- ORDER BY u.ad, f.ad;
-- Beklenen: 0 satır (Tıp Fakültesi hariç, tıb bölümü DB'de yok)

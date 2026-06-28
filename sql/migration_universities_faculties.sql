-- ============================================================
-- UniPulse Migration: Diğer Üniversiteler İçin Fakülte + Bölüm Eşleştirme
-- ============================================================
-- Sorun: 10 üniversite var, fakülteler yalnızca Anadolu Üniversitesi'ne tanımlı.
-- Bu migration, diğer 9 üniversiteye de gerçekçi fakülteler ekler ve
-- mevcut 59 bölümü uygun fakültelere eşler.
--
-- Sonuç: Üni → Fakülte → Bölüm hiyerarşisi tüm üniversiteler için çalışır.
-- Tarih: 2026-06-28
-- ============================================================

BEGIN;

-- ============================================================
-- 0) Unique constraint ekle (ON CONFLICT için gerekli)
-- ============================================================
-- faculty_departments tablosunda (faculty_id, department_slug) ikilisi unique olmalı.
-- Bu olmadan ON CONFLICT DO NOTHING çalışmaz ve duplikatlar oluşur.
-- IF NOT EXISTS benzeri davranış için DO NOTHING kullanıyoruz.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'faculty_departments_faculty_id_department_slug_key'
  ) THEN
    ALTER TABLE faculty_departments
      ADD CONSTRAINT faculty_departments_faculty_id_department_slug_key
      UNIQUE (faculty_id, department_slug);
  END IF;
END $$;

-- ============================================================
-- 1) Diğer 9 üniversiteye fakülteler ekle
-- ============================================================
-- Her üniversiteye gerçekçi fakülteler (Mühendislik, Fen-Edebiyat, İİBF, Hukuk, Eğitim, vb.)
-- Not: Aynı fakülte adı farklı üniversitelerde farklı id'lerle kaydedilir.

-- Ankara Üniversitesi (cc0b5e6e-3165-4b3b-9f80-2f9f6b8930ed)
INSERT INTO faculties (ad, emoji, renk, slug, university_id) VALUES
  ('Hukuk Fakültesi',           '⚖️', '#4f46e5', 'ankara-hukuk',           'cc0b5e6e-3165-4b3b-9f80-2f9f6b8930ed'),
  ('Siyasal Bilgiler Fakültesi', '🏛️', '#0891b2', 'ankara-siyasal',         'cc0b5e6e-3165-4b3b-9f80-2f9f6b8930ed'),
  ('Dil Tarih Coğrafya Fakültesi','📚', '#7c3aed', 'ankara-dtc',             'cc0b5e6e-3165-4b3b-9f80-2f9f6b8930ed'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'ankara-iibf',  'cc0b5e6e-3165-4b3b-9f80-2f9f6b8930ed'),
  ('Eğitim Fakültesi',          '🎓', '#16a34a', 'ankara-egitim',          'cc0b5e6e-3165-4b3b-9f80-2f9f6b8930ed'),
  ('İletişim Fakültesi',        '📡', '#d97706', 'ankara-iletisim',        'cc0b5e6e-3165-4b3b-9f80-2f9f6b8930ed')
ON CONFLICT (slug) DO NOTHING;

-- Bilkent Üniversitesi (108cbdd3-9401-4eb7-a166-4cabbe9f0421)
INSERT INTO faculties (ad, emoji, renk, slug, university_id) VALUES
  ('Mühendislik Fakültesi',     '⚙️', '#4f46e5', 'bilkent-muhendislik',    '108cbdd3-9401-4eb7-a166-4cabbe9f0421'),
  ('İktisadi İdari ve Sosyal Bilimler Fakültesi', '💼', '#0d9488', 'bilkent-iisb', '108cbdd3-9401-4eb7-a166-4cabbe9f0421'),
  ('İnsani Bilimler ve Edebiyat Fakültesi', '📚', '#7c3aed', 'bilkent-edebiyat', '108cbdd3-9401-4eb7-a166-4cabbe9f0421'),
  ('Güzel Sanatlar Tasarım ve Mimarlık Fakültesi', '🎨', '#dc2626', 'bilkent-gsatm', '108cbdd3-9401-4eb7-a166-4cabbe9f0421'),
  ('Eğitim Fakültesi',          '🎓', '#16a34a', 'bilkent-egitim',         '108cbdd3-9401-4eb7-a166-4cabbe9f0421')
ON CONFLICT (slug) DO NOTHING;

-- Boğaziçi Üniversitesi (3ee7ea0e-5d5d-4424-8924-bc86a0cd3f09)
INSERT INTO faculties (ad, emoji, renk, slug, university_id) VALUES
  ('Mühendislik Fakültesi',     '⚙️', '#4f46e5', 'bogazici-muhendislik',   '3ee7ea0e-5d5d-4424-8924-bc86a0cd3f09'),
  ('Fen-Edebiyat Fakültesi',    '🔬', '#7c3aed', 'bogazici-fen-edebiyat',  '3ee7ea0e-5d5d-4424-8924-bc86a0cd3f09'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'bogazici-iibf', '3ee7ea0e-5d5d-4424-8924-bc86a0cd3f09'),
  ('Eğitim Fakültesi',          '🎓', '#16a34a', 'bogazici-egitim',        '3ee7ea0e-5d5d-4424-8924-bc86a0cd3f09')
ON CONFLICT (slug) DO NOTHING;

-- Ege Üniversitesi (8e2a5948-c1c9-4108-b6d1-9a7a8db49c60)
INSERT INTO faculties (ad, emoji, renk, slug, university_id) VALUES
  ('Mühendislik Fakültesi',     '⚙️', '#4f46e5', 'ege-muhendislik',        '8e2a5948-c1c9-4108-b6d1-9a7a8db49c60'),
  ('Fen-Edebiyat Fakültesi',    '🔬', '#7c3aed', 'ege-fen-edebiyat',       '8e2a5948-c1c9-4108-b6d1-9a7a8db49c60'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'ege-iibf',    '8e2a5948-c1c9-4108-b6d1-9a7a8db49c60'),
  ('Hukuk Fakültesi',           '⚖️', '#0891b2', 'ege-hukuk',              '8e2a5948-c1c9-4108-b6d1-9a7a8db49c60'),
  ('Eczacılık Fakültesi',       '💊', '#16a34a', 'ege-eczacilik',          '8e2a5948-c1c9-4108-b6d1-9a7a8db49c60'),
  ('İletişim Fakültesi',        '📡', '#d97706', 'ege-iletisim',           '8e2a5948-c1c9-4108-b6d1-9a7a8db49c60')
ON CONFLICT (slug) DO NOTHING;

-- Hacettepe Üniversitesi (b55d3958-e77f-4b80-b0c3-567e19a39463)
INSERT INTO faculties (ad, emoji, renk, slug, university_id) VALUES
  ('Mühendislik Fakültesi',     '⚙️', '#4f46e5', 'hacettepe-muhendislik',  'b55d3958-e77f-4b80-b0c3-567e19a39463'),
  ('Fen-Edebiyat Fakültesi',    '🔬', '#7c3aed', 'hacettepe-fen-edebiyat', 'b55d3958-e77f-4b80-b0c3-567e19a39463'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'hacettepe-iibf', 'b55d3958-e77f-4b80-b0c3-567e19a39463'),
  ('Hukuk Fakültesi',           '⚖️', '#0891b2', 'hacettepe-hukuk',        'b55d3958-e77f-4b80-b0c3-567e19a39463'),
  ('Eğitim Fakültesi',          '🎓', '#16a34a', 'hacettepe-egitim',       'b55d3958-e77f-4b80-b0c3-567e19a39463'),
  ('Güzel Sanatlar Fakültesi',  '🎨', '#dc2626', 'hacettepe-guzel-sanatlar', 'b55d3958-e77f-4b80-b0c3-567e19a39463')
ON CONFLICT (slug) DO NOTHING;

-- İstanbul Üniversitesi (809b9bae-b947-40ff-8407-02aa82b3503e)
INSERT INTO faculties (ad, emoji, renk, slug, university_id) VALUES
  ('Hukuk Fakültesi',           '⚖️', '#4f46e5', 'istanbul-hukuk',         '809b9bae-b947-40ff-8407-02aa82b3503e'),
  ('İktisat Fakültesi',         '💼', '#0d9488', 'istanbul-iktisat',       '809b9bae-b947-40ff-8407-02aa82b3503e'),
  ('İşletme Fakültesi',         '📊', '#0891b2', 'istanbul-isletme',       '809b9bae-b947-40ff-8407-02aa82b3503e'),
  ('Edebiyat Fakültesi',        '📚', '#7c3aed', 'istanbul-edebiyat',      '809b9bae-b947-40ff-8407-02aa82b3503e'),
  ('Siyasal Bilgiler Fakültesi','🏛️', '#16a34a', 'istanbul-siyasal',       '809b9bae-b947-40ff-8407-02aa82b3503e'),
  ('İletişim Fakültesi',        '📡', '#d97706', 'istanbul-iletisim',      '809b9bae-b947-40ff-8407-02aa82b3503e')
ON CONFLICT (slug) DO NOTHING;

-- Koç Üniversitesi (c45429da-8fd9-4dc4-bd7d-5f3dbfd535ae)
INSERT INTO faculties (ad, emoji, renk, slug, university_id) VALUES
  ('Mühendislik Fakültesi',     '⚙️', '#4f46e5', 'koc-muhendislik',        'c45429da-8fd9-4dc4-bd7d-5f3dbfd535ae'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'koc-iibf',    'c45429da-8fd9-4dc4-bd7d-5f3dbfd535ae'),
  ('Fen-Edebiyat Fakültesi',    '🔬', '#7c3aed', 'koc-fen-edebiyat',       'c45429da-8fd9-4dc4-bd7d-5f3dbfd535ae'),
  ('Hukuk Fakültesi',           '⚖️', '#0891b2', 'koc-hukuk',              'c45429da-8fd9-4dc4-bd7d-5f3dbfd535ae'),
  ('Tıp Fakültesi',             '⚕️', '#dc2626', 'koc-tip',                'c45429da-8fd9-4dc4-bd7d-5f3dbfd535ae')
ON CONFLICT (slug) DO NOTHING;

-- ODTÜ (7068ad9c-fec1-442d-a7e7-09b536ccb362)
INSERT INTO faculties (ad, emoji, renk, slug, university_id) VALUES
  ('Mühendislik Fakültesi',     '⚙️', '#4f46e5', 'odtu-muhendislik',       '7068ad9c-fec1-442d-a7e7-09b536ccb362'),
  ('Fen-Edebiyat Fakültesi',    '🔬', '#7c3aed', 'odtu-fen-edebiyat',      '7068ad9c-fec1-442d-a7e7-09b536ccb362'),
  ('İktisadi ve İdari Bilimler Fakültesi', '💼', '#0d9488', 'odtu-iibf',   '7068ad9c-fec1-442d-a7e7-09b536ccb362'),
  ('Eğitim Fakültesi',          '🎓', '#16a34a', 'odtu-egitim',            '7068ad9c-fec1-442d-a7e7-09b536ccb362'),
  ('Mimarlık Fakültesi',        '🏗️', '#d97706', 'odtu-mimarlik',          '7068ad9c-fec1-442d-a7e7-09b536ccb362')
ON CONFLICT (slug) DO NOTHING;

-- Sabancı Üniversitesi (208a8d06-a7dd-4296-957d-cc5c20c648e5)
INSERT INTO faculties (ad, emoji, renk, slug, university_id) VALUES
  ('Mühendislik ve Doğa Bilimleri Fakültesi', '⚙️', '#4f46e5', 'sabanci-muhendislik', '208a8d06-a7dd-4296-957d-cc5c20c648e5'),
  ('Yönetim Bilimleri Fakültesi','💼', '#0d9488', 'sabanci-yonetim',       '208a8d06-a7dd-4296-957d-cc5c20c648e5'),
  ('Sanat ve Sosyal Bilimler Fakültesi', '🎨', '#dc2626', 'sabanci-sanat-sosyal', '208a8d06-a7dd-4296-957d-cc5c20c648e5')
ON CONFLICT (slug) DO NOTHING;


-- ============================================================
-- 2) Bu yeni fakülteleri mevcut bölümlerle eşle
-- ============================================================
-- faculty_departments tablosu (faculty_id, department_slug) ikilisi kullanır.
-- Aynı bölüm birden fazla fakülteye bağlanabilir.

-- Yardımcı fonksiyon: slug verilen fakültenin id'sini bul
-- (Bunu SQL'de doğrudan subquery ile yapacağız)

-- === Ankara Üniversitesi eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'ankara-hukuk'
  AND d.slug IN ('hukuk')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'ankara-siyasal'
  AND d.slug IN ('siyaset-bilimi-ve-kamu-yonetimi', 'calisma-ekonomisi-ve-endustri-iliskileri', 'uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'ankara-dtc'
  AND d.slug IN ('felsefe', 'sosyoloji', 'psikoloji', 'turk-dili-ve-edebiyati', 'arkeoloji', 'sanat-tarihi', 'rus-dili-ve-edebiyati', 'almanca-ogretmenligi', 'fransizca-ogretmenligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'ankara-iibf'
  AND d.slug IN ('iktisat', 'isletme', 'maliye', 'calisma-ekonomisi-ve-endustri-iliskileri', 'bankacilik-ve-finans', 'muhasebe-ve-finans-yonetimi', 'pazarlama', 'siyaset-bilimi-ve-kamu-yonetimi', 'uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'ankara-egitim'
  AND d.slug IN ('ingilizce-ogretmenligi', 'almanca-ogretmenligi', 'fransizca-ogretmenligi', 'sinif-ogretmenligi', 'okul-oncesi-ogretmenligi', 'sosyal-bilgiler-ogretmenligi', 'ilkogretim-matematik-ogretmenligi', 'bilgisayar-ve-ogretim-teknolojileri', 'ozel-egitim-ogretmenligi', 'rehberlik-ve-psikolojik-danismanlik')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'ankara-iletisim'
  AND d.slug IN ('gazetecilik', 'radyo-televizyon-ve-sinema', 'halkla-iliskiler-ve-tanitim', 'reklamcilik', 'iletisim-bilimleri', 'gorsel-iletisim-tasarimi')
ON CONFLICT DO NOTHING;


-- === Bilkent Üniversitesi eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'bilkent-muhendislik'
  AND d.slug IN ('bilgisayar-programciligi', 'arka-yuz-yazilim-gelistirme', 'oyun-gelistirme-ve-programlama', 'buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'bilkent-iisb'
  AND d.slug IN ('iktisat', 'isletme', 'maliye', 'calisma-ekonomisi-ve-endustri-iliskileri', 'bankacilik-ve-finans', 'muhasebe-ve-finans-yonetimi', 'pazarlama', 'siyaset-bilimi-ve-kamu-yonetimi', 'uluslararasi-iliskiler', 'psikoloji')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'bilkent-edebiyat'
  AND d.slug IN ('felsefe', 'sosyoloji', 'turk-dili-ve-edebiyati', 'arkeoloji', 'sanat-tarihi', 'rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'bilkent-gsatm'
  AND d.slug IN ('resim', 'heykel', 'seramik', 'grafik-sanatlar', 'gorsel-iletisim-tasarimi', 'cizgi-film-ve-animasyon', 'dijital-oyun-tasarimi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'bilkent-egitim'
  AND d.slug IN ('ingilizce-ogretmenligi', 'sinif-ogretmenligi', 'okul-oncesi-ogretmenligi', 'sosyal-bilgiler-ogretmenligi', 'ilkogretim-matematik-ogretmenligi', 'bilgisayar-ve-ogretim-teknolojileri', 'ozel-egitim-ogretmenligi', 'rehberlik-ve-psikolojik-danismanlik')
ON CONFLICT DO NOTHING;


-- === Boğaziçi Üniversitesi eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'bogazici-muhendislik'
  AND d.slug IN ('bilgisayar-programciligi', 'arka-yuz-yazilim-gelistirme', 'oyun-gelistirme-ve-programlama', 'buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'bogazici-fen-edebiyat'
  AND d.slug IN ('felsefe', 'sosyoloji', 'psikoloji', 'turk-dili-ve-edebiyati', 'arkeoloji', 'sanat-tarihi', 'rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'bogazici-iibf'
  AND d.slug IN ('iktisat', 'isletme', 'maliye', 'calisma-ekonomisi-ve-endustri-iliskileri', 'bankacilik-ve-finans', 'muhasebe-ve-finans-yonetimi', 'pazarlama', 'siyaset-bilimi-ve-kamu-yonetimi', 'uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'bogazici-egitim'
  AND d.slug IN ('ingilizce-ogretmenligi', 'almanca-ogretmenligi', 'fransizca-ogretmenligi', 'sinif-ogretmenligi', 'okul-oncesi-ogretmenligi', 'sosyal-bilgiler-ogretmenligi', 'ilkogretim-matematik-ogretmenligi', 'bilgisayar-ve-ogretim-teknolojileri', 'ozel-egitim-ogretmenligi', 'rehberlik-ve-psikolojik-danismanlik')
ON CONFLICT DO NOTHING;


-- === Ege Üniversitesi eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'ege-muhendislik'
  AND d.slug IN ('bilgisayar-programciligi', 'arka-yuz-yazilim-gelistirme', 'oyun-gelistirme-ve-programlama', 'buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'ege-fen-edebiyat'
  AND d.slug IN ('felsefe', 'sosyoloji', 'psikoloji', 'turk-dili-ve-edebiyati', 'arkeoloji', 'sanat-tarihi', 'rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'ege-iibf'
  AND d.slug IN ('iktisat', 'isletme', 'maliye', 'calisma-ekonomisi-ve-endustri-iliskileri', 'bankacilik-ve-finans', 'muhasebe-ve-finans-yonetimi', 'pazarlama', 'siyaset-bilimi-ve-kamu-yonetimi', 'uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'ege-hukuk'
  AND d.slug IN ('hukuk')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'ege-eczacilik'
  AND d.slug IN ('eczacilik', 'eczane-hizmetleri')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'ege-iletisim'
  AND d.slug IN ('gazetecilik', 'radyo-televizyon-ve-sinema', 'halkla-iliskiler-ve-tanitim', 'reklamcilik', 'iletisim-bilimleri', 'gorsel-iletisim-tasarimi')
ON CONFLICT DO NOTHING;


-- === Hacettepe Üniversitesi eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'hacettepe-muhendislik'
  AND d.slug IN ('bilgisayar-programciligi', 'arka-yuz-yazilim-gelistirme', 'oyun-gelistirme-ve-programlama', 'buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'hacettepe-fen-edebiyat'
  AND d.slug IN ('felsefe', 'sosyoloji', 'psikoloji', 'turk-dili-ve-edebiyati', 'arkeoloji', 'sanat-tarihi', 'rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'hacettepe-iibf'
  AND d.slug IN ('iktisat', 'isletme', 'maliye', 'calisma-ekonomisi-ve-endustri-iliskileri', 'bankacilik-ve-finans', 'muhasebe-ve-finans-yonetimi', 'pazarlama', 'siyaset-bilimi-ve-kamu-yonetimi', 'uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'hacettepe-hukuk'
  AND d.slug IN ('hukuk')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'hacettepe-egitim'
  AND d.slug IN ('ingilizce-ogretmenligi', 'almanca-ogretmenligi', 'fransizca-ogretmenligi', 'sinif-ogretmenligi', 'okul-oncesi-ogretmenligi', 'sosyal-bilgiler-ogretmenligi', 'ilkogretim-matematik-ogretmenligi', 'bilgisayar-ve-ogretim-teknolojileri', 'ozel-egitim-ogretmenligi', 'rehberlik-ve-psikolojik-danismanlik')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'hacettepe-guzel-sanatlar'
  AND d.slug IN ('resim', 'heykel', 'seramik', 'grafik-sanatlar', 'gorsel-iletisim-tasarimi', 'cizgi-film-ve-animasyon', 'dijital-oyun-tasarimi')
ON CONFLICT DO NOTHING;


-- === İstanbul Üniversitesi eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'istanbul-hukuk'
  AND d.slug IN ('hukuk')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'istanbul-iktisat'
  AND d.slug IN ('iktisat', 'bankacilik-ve-finans', 'muhasebe-ve-finans-yonetimi', 'pazarlama', 'uluslararasi-iliskiler', 'calisma-ekonomisi-ve-endustri-iliskileri')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'istanbul-isletme'
  AND d.slug IN ('isletme', 'maliye', 'bankacilik-ve-finans', 'muhasebe-ve-finans-yonetimi', 'pazarlama')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'istanbul-edebiyat'
  AND d.slug IN ('felsefe', 'sosyoloji', 'psikoloji', 'turk-dili-ve-edebiyati', 'arkeoloji', 'sanat-tarihi', 'rus-dili-ve-edebiyati', 'almanca-ogretmenligi', 'fransizca-ogretmenligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'istanbul-siyasal'
  AND d.slug IN ('siyaset-bilimi-ve-kamu-yonetimi', 'calisma-ekonomisi-ve-endustri-iliskileri', 'uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'istanbul-iletisim'
  AND d.slug IN ('gazetecilik', 'radyo-televizyon-ve-sinema', 'halkla-iliskiler-ve-tanitim', 'reklamcilik', 'iletisim-bilimleri', 'gorsel-iletisim-tasarimi')
ON CONFLICT DO NOTHING;


-- === Koç Üniversitesi eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'koc-muhendislik'
  AND d.slug IN ('bilgisayar-programciligi', 'arka-yuz-yazilim-gelistirme', 'oyun-gelistirme-ve-programlama', 'buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'koc-iibf'
  AND d.slug IN ('iktisat', 'isletme', 'maliye', 'calisma-ekonomisi-ve-endustri-iliskileri', 'bankacilik-ve-finans', 'muhasebe-ve-finans-yonetimi', 'pazarlama', 'siyaset-bilimi-ve-kamu-yonetimi', 'uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'koc-fen-edebiyat'
  AND d.slug IN ('felsefe', 'sosyoloji', 'psikoloji', 'turk-dili-ve-edebiyati', 'arkeoloji', 'sanat-tarihi', 'rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'koc-hukuk'
  AND d.slug IN ('hukuk')
ON CONFLICT DO NOTHING;


-- === ODTÜ eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'odtu-muhendislik'
  AND d.slug IN ('bilgisayar-programciligi', 'arka-yuz-yazilim-gelistirme', 'oyun-gelistirme-ve-programlama', 'buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'odtu-fen-edebiyat'
  AND d.slug IN ('felsefe', 'sosyoloji', 'psikoloji', 'turk-dili-ve-edebiyati', 'arkeoloji', 'sanat-tarihi', 'rus-dili-ve-edebiyati')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'odtu-iibf'
  AND d.slug IN ('iktisat', 'isletme', 'maliye', 'calisma-ekonomisi-ve-endustri-iliskileri', 'bankacilik-ve-finans', 'muhasebe-ve-finans-yonetimi', 'pazarlama', 'siyaset-bilimi-ve-kamu-yonetimi', 'uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'odtu-egitim'
  AND d.slug IN ('ingilizce-ogretmenligi', 'almanca-ogretmenligi', 'fransizca-ogretmenligi', 'sinif-ogretmenligi', 'okul-oncesi-ogretmenligi', 'sosyal-bilgiler-ogretmenligi', 'ilkogretim-matematik-ogretmenligi', 'bilgisayar-ve-ogretim-teknolojileri', 'ozel-egitim-ogretmenligi', 'rehberlik-ve-psikolojik-danismanlik')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'odtu-mimarlik'
  AND d.slug IN ('gorsel-iletisim-tasarimi', 'grafik-sanatlar', 'cizgi-film-ve-animasyon', 'dijital-oyun-tasarimi')
ON CONFLICT DO NOTHING;


-- === Sabancı Üniversitesi eşleştirmeleri ===
INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'sabanci-muhendislik'
  AND d.slug IN ('bilgisayar-programciligi', 'arka-yuz-yazilim-gelistirme', 'oyun-gelistirme-ve-programlama', 'buyuk-veri-analistligi')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'sabanci-yonetim'
  AND d.slug IN ('iktisat', 'isletme', 'maliye', 'bankacilik-ve-finans', 'muhasebe-ve-finans-yonetimi', 'pazarlama', 'uluslararasi-iliskiler')
ON CONFLICT DO NOTHING;

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, d.slug
FROM faculties f
CROSS JOIN departments d
WHERE f.slug = 'sabanci-sanat-sosyal'
  AND d.slug IN ('felsefe', 'sosyoloji', 'psikoloji', 'turk-dili-ve-edebiyati', 'sanat-tarihi', 'resim', 'heykel', 'seramik', 'grafik-sanatlar', 'gorsel-iletisim-tasarimi', 'cizgi-film-ve-animasyon', 'dijital-oyun-tasarimi')
ON CONFLICT DO NOTHING;


COMMIT;

-- ============================================================
-- Doğrulama sorguları
-- ============================================================
-- Üniversite başına fakülte sayısı:
-- SELECT u.ad, COUNT(f.id) AS faculty_count
-- FROM universities u
-- LEFT JOIN faculties f ON f.university_id = u.id
-- GROUP BY u.ad
-- ORDER BY u.ad;

-- Fakülte başına bölüm sayısı:
-- SELECT f.ad, COUNT(fd.department_slug) AS dept_count
-- FROM faculties f
-- LEFT JOIN faculty_departments fd ON fd.faculty_id = f.id
-- GROUP BY f.ad
-- ORDER BY f.ad;

-- ============================================================
-- UniPulse Migration v3: Tüm Fakülte-Bölüm Eşleştirmelerini Sıfırla + Yeniden Yap
-- ============================================================
-- Bu migration:
--   1. Anadolu Üniversitesi'nin fakültelerini KORUR (slug prefix ile)
--   2. Diğer tüm fakülteleri ve faculty_departments kayıtlarını SİLER
--   3. Her üniversite için doğru fakülte + bölüm eşleştirmesi ekler
--   4. MYO bölümlerini her üniversite için doğru yapar
--
-- KORUNAN: Anadolu Üniversitesi (slug'lar 'anadolu', 'eskisehir-myo',
-- 'adalet-myo', 'bilisim-teknolojileri-myo', 'acikogretim-fakultesi',
-- 'yunus-emre-saglik-myo' ile başlayan veya hiç slug prefix'i olmayanlar)
--
-- Tarih: 2026-06-28
-- ============================================================

BEGIN;

-- ============================================================
-- 1) Anadolu Üniversitesi'nin fakülte ID'lerini bul (korunacak)
-- ============================================================
-- Anadolu'nun fakülteleri DB'de şu slug'lara sahip (önceki migration'lardan):
CREATE TEMP TABLE anadolu_faculties AS
SELECT id, ad, slug FROM faculties
WHERE university_id = (SELECT id FROM universities WHERE slug = 'anadolu-universitesi');

-- ============================================================
-- 2) Anadolu'nun faculty_departments kayıtlarını koru, diğerlerini sil
-- ============================================================
DELETE FROM faculty_departments
WHERE faculty_id NOT IN (SELECT id FROM anadolu_faculties);

-- ============================================================
-- 3) Anadolu HARİÇ tüm fakülteleri sil
-- ============================================================
DELETE FROM faculties
WHERE university_id != (SELECT id FROM universities WHERE slug = 'anadolu-universitesi');

-- ============================================================
-- 4) Her üniversite için doğru fakülte + bölüm eşleştirmesi ekle
-- ============================================================
-- Strateji: Her üniversite tipine göre standart fakülte seti:
--   - Teknik üniversiteler (İTÜ, Yıldız, ODTÜ, vb.): Mühendislik, Fen-Edebiyat, İİBF, Mimarlık, MYO
--   - Devlet üniversiteleri (İstanbul, Ankara, Hacettepe, vb.): Mühendislik, Fen-Edebiyat, İİBF, Hukuk, Eğitim, Tıp, Eczacılık, İletişim, MYO
--   - Vakıf üniversiteleri (Koç, Bilkent, Sabancı): Mühendislik, İİBF, Fen-Edebiyat, Hukuk, Tıp
--   - Diğer şehir üniversiteleri: Tüm fakülteler

-- Yardımcı: Fakülte-bölüm eşleştirme fonksiyonu
-- Her fakülte tipi için hangi bölümlerin olması gerektiğini tanımla

-- === FAKÜLTE TİPLERİ VE BÖLÜM LİSTESİ ===
-- Bu değerleri bir temp tabloda tutacağız, sonra her üniversite için kullanacağız.

CREATE TEMP TABLE faculty_dept_template (
  faculty_type TEXT,
  department_slug TEXT
);

-- Mühendislik Fakültesi (teknik bölümler)
INSERT INTO faculty_dept_template VALUES
  ('muhendislik', 'bilgisayar-programciligi'),
  ('muhendislik', 'arka-yuz-yazilim-gelistirme'),
  ('muhendislik', 'oyun-gelistirme-ve-programlama'),
  ('muhendislik', 'buyuk-veri-analistligi');

-- Fen-Edebiyat Fakültesi
INSERT INTO faculty_dept_template VALUES
  ('fen-edebiyat', 'felsefe'),
  ('fen-edebiyat', 'sosyoloji'),
  ('fen-edebiyat', 'psikoloji'),
  ('fen-edebiyat', 'turk-dili-ve-edebiyati'),
  ('fen-edebiyat', 'arkeoloji'),
  ('fen-edebiyat', 'sanat-tarihi'),
  ('fen-edebiyat', 'rus-dili-ve-edebiyati');

-- İİBF (İktisadi ve İdari Bilimler)
INSERT INTO faculty_dept_template VALUES
  ('iibf', 'iktisat'),
  ('iibf', 'isletme'),
  ('iibf', 'maliye'),
  ('iibf', 'calisma-ekonomisi-ve-endustri-iliskileri'),
  ('iibf', 'bankacilik-ve-finans'),
  ('iibf', 'muhasebe-ve-finans-yonetimi'),
  ('iibf', 'pazarlama'),
  ('iibf', 'siyaset-bilimi-ve-kamu-yonetimi'),
  ('iibf', 'uluslararasi-iliskiler');

-- Hukuk Fakültesi (sadece hukuk bölümü)
INSERT INTO faculty_dept_template VALUES
  ('hukuk', 'hukuk');

-- Eğitim Fakültesi (öğretmenlikler)
INSERT INTO faculty_dept_template VALUES
  ('egitim', 'ingilizce-ogretmenligi'),
  ('egitim', 'almanca-ogretmenligi'),
  ('egitim', 'fransizca-ogretmenligi'),
  ('egitim', 'sinif-ogretmenligi'),
  ('egitim', 'okul-oncesi-ogretmenligi'),
  ('egitim', 'sosyal-bilgiler-ogretmenligi'),
  ('egitim', 'ilkogretim-matematik-ogretmenligi'),
  ('egitim', 'bilgisayar-ve-ogretim-teknolojileri'),
  ('egitim', 'ozel-egitim-ogretmenligi'),
  ('egitim', 'rehberlik-ve-psikolojik-danismanlik');

-- İletişim Fakültesi
INSERT INTO faculty_dept_template VALUES
  ('iletisim', 'gazetecilik'),
  ('iletisim', 'radyo-televizyon-ve-sinema'),
  ('iletisim', 'halkla-iliskiler-ve-tanitim'),
  ('iletisim', 'reklamcilik'),
  ('iletisim', 'iletisim-bilimleri'),
  ('iletisim', 'gorsel-iletisim-tasarimi');

-- Güzel Sanatlar Fakültesi
INSERT INTO faculty_dept_template VALUES
  ('guzel-sanatlar', 'resim'),
  ('guzel-sanatlar', 'heykel'),
  ('guzel-sanatlar', 'seramik'),
  ('guzel-sanatlar', 'grafik-sanatlar'),
  ('guzel-sanatlar', 'gorsel-iletisim-tasarimi'),
  ('guzel-sanatlar', 'cizgi-film-ve-animasyon'),
  ('guzel-sanatlar', 'dijital-oyun-tasarimi');

-- Eczacılık Fakültesi
INSERT INTO faculty_dept_template VALUES
  ('eczacilik', 'eczacilik'),
  ('eczacilik', 'eczane-hizmetleri');

-- Tıp Fakültesi — şu an tıp bölümü DB'de yok, boş kalacak
-- (sadece üniversitede tıp varsa fakülte oluşturulur)

-- Turizm Fakültesi
INSERT INTO faculty_dept_template VALUES
  ('turizm', 'turizm-rehberligi'),
  ('turizm', 'turizm-ve-otel-isletmeciligi'),
  ('turizm', 'gastronomi-ve-mutfak-sanatlari');

-- Mimarlık Fakültesi
INSERT INTO faculty_dept_template VALUES
  ('mimarlik', 'gorsel-iletisim-tasarimi'),
  ('mimarlik', 'grafik-sanatlar'),
  ('mimarlik', 'cizgi-film-ve-animasyon'),
  ('mimarlik', 'dijital-oyun-tasarimi');

-- Meslek Yüksekokulu (MYO) — her üniversitede standart MYO bölümleri
INSERT INTO faculty_dept_template VALUES
  ('myo', 'adalet'),
  ('myo', 'bilgisayar-programciligi'),
  ('myo', 'ofis-yonetimi-ve-sekreterlik'),
  ('myo', 'emlak-yonetimi');

-- Sağlık Hizmetleri MYO (sağlık bölümleri)
INSERT INTO faculty_dept_template VALUES
  ('saglik-myo', 'cocuk-gelisimi'),
  ('saglik-myo', 'ascilik'),
  ('saglik-myo', 'sac-bakimi-ve-guzellik-hizmetleri'),
  ('saglik-myo', 'eczane-hizmetleri'),
  ('saglik-myo', 'tibbi-laboratuvar-teknikleri');

-- === Her üniversite için fakülte tipleri ===
CREATE TEMP TABLE uni_faculty_types (
  uni_slug TEXT,
  faculty_type TEXT
);

-- Mevcut 9 üniversite (Anadolu hariç)
INSERT INTO uni_faculty_types VALUES
  ('ankara-universitesi', 'hukuk'),
  ('ankara-universitesi', 'siyasal'),  -- Siyasal Bilgiler
  ('ankara-universitesi', 'iibf'),
  ('ankara-universitesi', 'egitim'),
  ('ankara-universitesi', 'iletisim'),
  ('ankara-universitesi', 'fen-edebiyat'),  -- DTC
  ('ankara-universitesi', 'myo'),
  ('ankara-universitesi', 'saglik-myo');

-- Bilkent (vakıf)
INSERT INTO uni_faculty_types VALUES
  ('bilkent-universitesi', 'muhendislik'),
  ('bilkent-universitesi', 'iibf'),
  ('bilkent-universitesi', 'fen-edebiyat'),
  ('bilkent-universitesi', 'guzel-sanatlar'),
  ('bilkent-universitesi', 'egitim');

-- Boğaziçi (devlet)
INSERT INTO uni_faculty_types VALUES
  ('bogazici-universitesi', 'muhendislik'),
  ('bogazici-universitesi', 'fen-edebiyat'),
  ('bogazici-universitesi', 'iibf'),
  ('bogazici-universitesi', 'egitim');

-- Ege (devlet)
INSERT INTO uni_faculty_types VALUES
  ('ege-universitesi', 'muhendislik'),
  ('ege-universitesi', 'fen-edebiyat'),
  ('ege-universitesi', 'iibf'),
  ('ege-universitesi', 'hukuk'),
  ('ege-universitesi', 'eczacilik'),
  ('ege-universitesi', 'iletisim'),
  ('ege-universitesi', 'myo'),
  ('ege-universitesi', 'saglik-myo');

-- Hacettepe (devlet)
INSERT INTO uni_faculty_types VALUES
  ('hacettepe-universitesi', 'muhendislik'),
  ('hacettepe-universitesi', 'fen-edebiyat'),
  ('hacettepe-universitesi', 'iibf'),
  ('hacettepe-universitesi', 'hukuk'),
  ('hacettepe-universitesi', 'egitim'),
  ('hacettepe-universitesi', 'guzel-sanatlar'),
  ('hacettepe-universitesi', 'myo'),
  ('hacettepe-universitesi', 'saglik-myo');

-- İstanbul (devlet)
INSERT INTO uni_faculty_types VALUES
  ('istanbul-universitesi', 'hukuk'),
  ('istanbul-universitesi', 'iibf'),  -- İktisat + İşletme
  ('istanbul-universitesi', 'fen-edebiyat'),  -- Edebiyat
  ('istanbul-universitesi', 'siyasal'),
  ('istanbul-universitesi', 'iletisim'),
  ('istanbul-universitesi', 'myo'),
  ('istanbul-universitesi', 'saglik-myo');

-- Koç (vakıf)
INSERT INTO uni_faculty_types VALUES
  ('koc-universitesi', 'muhendislik'),
  ('koc-universitesi', 'iibf'),
  ('koc-universitesi', 'fen-edebiyat'),
  ('koc-universitesi', 'hukuk');

-- ODTÜ (devlet, teknik)
INSERT INTO uni_faculty_types VALUES
  ('odtu', 'muhendislik'),
  ('odtu', 'fen-edebiyat'),
  ('odtu', 'iibf'),
  ('odtu', 'egitim'),
  ('odtu', 'mimarlik');

-- Sabancı (vakıf)
INSERT INTO uni_faculty_types VALUES
  ('sabanci-universitesi', 'muhendislik'),
  ('sabanci-universitesi', 'iibf'),
  ('sabanci-universitesi', 'guzel-sanatlar');

-- === Yeni 20 üniversite ===

-- İTÜ (teknik)
INSERT INTO uni_faculty_types VALUES
  ('itu', 'muhendislik'),
  ('itu', 'fen-edebiyat'),
  ('itu', 'iibf'),
  ('itu', 'mimarlik'),
  ('itu', 'myo');

-- Marmara
INSERT INTO uni_faculty_types VALUES
  ('marmara-universitesi', 'iibf'),
  ('marmara-universitesi', 'hukuk'),
  ('marmara-universitesi', 'egitim'),
  ('marmara-universitesi', 'iletisim'),
  ('marmara-universitesi', 'guzel-sanatlar'),
  ('marmara-universitesi', 'myo'),
  ('marmara-universitesi', 'saglik-myo');

-- Yıldız Teknik
INSERT INTO uni_faculty_types VALUES
  ('yildiz-teknik-universitesi', 'muhendislik'),
  ('yildiz-teknik-universitesi', 'fen-edebiyat'),
  ('yildiz-teknik-universitesi', 'iibf'),
  ('yildiz-teknik-universitesi', 'mimarlik'),
  ('yildiz-teknik-universitesi', 'myo');

-- Dokuz Eylül
INSERT INTO uni_faculty_types VALUES
  ('dokuz-eylul-universitesi', 'muhendislik'),
  ('dokuz-eylul-universitesi', 'fen-edebiyat'),
  ('dokuz-eylul-universitesi', 'iibf'),
  ('dokuz-eylul-universitesi', 'hukuk'),
  ('dokuz-eylul-universitesi', 'eczacilik'),
  ('dokuz-eylul-universitesi', 'iletisim'),
  ('dokuz-eylul-universitesi', 'turizm'),
  ('dokuz-eylul-universitesi', 'myo'),
  ('dokuz-eylul-universitesi', 'saglik-myo');

-- Gazi
INSERT INTO uni_faculty_types VALUES
  ('gazi-universitesi', 'muhendislik'),
  ('gazi-universitesi', 'fen-edebiyat'),
  ('gazi-universitesi', 'iibf'),
  ('gazi-universitesi', 'hukuk'),
  ('gazi-universitesi', 'egitim'),
  ('gazi-universitesi', 'iletisim'),
  ('gazi-universitesi', 'myo'),
  ('gazi-universitesi', 'saglik-myo');

-- Gebze Teknik
INSERT INTO uni_faculty_types VALUES
  ('gebze-teknik-universitesi', 'muhendislik'),
  ('gebze-teknik-universitesi', 'fen-edebiyat'),
  ('gebze-teknik-universitesi', 'iibf'),
  ('gebze-teknik-universitesi', 'mimarlik');

-- Eskişehir Teknik
INSERT INTO uni_faculty_types VALUES
  ('eskisehir-teknik-universitesi', 'muhendislik'),
  ('eskisehir-teknik-universitesi', 'fen-edebiyat'),
  ('eskisehir-teknik-universitesi', 'iibf'),
  ('eskisehir-teknik-universitesi', 'mimarlik'),
  ('eskisehir-teknik-universitesi', 'turizm'),
  ('eskisehir-teknik-universitesi', 'myo');

-- Galatasaray
INSERT INTO uni_faculty_types VALUES
  ('galatasaray-universitesi', 'iibf'),
  ('galatasaray-universitesi', 'hukuk'),
  ('galatasaray-universitesi', 'fen-edebiyat'),
  ('galatasaray-universitesi', 'iletisim');

-- İYTE
INSERT INTO uni_faculty_types VALUES
  ('iyte', 'muhendislik'),
  ('iyte', 'fen-edebiyat'),
  ('iyte', 'iibf'),
  ('iyte', 'mimarlik');

-- Akdeniz
INSERT INTO uni_faculty_types VALUES
  ('akdeniz-universitesi', 'iibf'),
  ('akdeniz-universitesi', 'hukuk'),
  ('akdeniz-universitesi', 'egitim'),
  ('akdeniz-universitesi', 'eczacilik'),
  ('akdeniz-universitesi', 'turizm'),
  ('akdeniz-universitesi', 'iletisim'),
  ('akdeniz-universitesi', 'myo'),
  ('akdeniz-universitesi', 'saglik-myo');

-- Bursa Uludağ
INSERT INTO uni_faculty_types VALUES
  ('bursa-uludag-universitesi', 'muhendislik'),
  ('bursa-uludag-universitesi', 'fen-edebiyat'),
  ('bursa-uludag-universitesi', 'iibf'),
  ('bursa-uludag-universitesi', 'hukuk'),
  ('bursa-uludag-universitesi', 'eczacilik'),
  ('bursa-uludag-universitesi', 'turizm'),
  ('bursa-uludag-universitesi', 'myo'),
  ('bursa-uludag-universitesi', 'saglik-myo');

-- Sakarya
INSERT INTO uni_faculty_types VALUES
  ('sakarya-universitesi', 'muhendislik'),
  ('sakarya-universitesi', 'fen-edebiyat'),
  ('sakarya-universitesi', 'iibf'),
  ('sakarya-universitesi', 'egitim'),
  ('sakarya-universitesi', 'iletisim'),
  ('sakarya-universitesi', 'myo'),
  ('sakarya-universitesi', 'saglik-myo');

-- Karadeniz Teknik
INSERT INTO uni_faculty_types VALUES
  ('karadeniz-teknik-universitesi', 'muhendislik'),
  ('karadeniz-teknik-universitesi', 'fen-edebiyat'),
  ('karadeniz-teknik-universitesi', 'iibf'),
  ('karadeniz-teknik-universitesi', 'hukuk'),
  ('karadeniz-teknik-universitesi', 'eczacilik'),
  ('karadeniz-teknik-universitesi', 'egitim'),
  ('karadeniz-teknik-universitesi', 'myo'),
  ('karadeniz-teknik-universitesi', 'saglik-myo');

-- Çukurova
INSERT INTO uni_faculty_types VALUES
  ('cukurova-universitesi', 'muhendislik'),
  ('cukurova-universitesi', 'fen-edebiyat'),
  ('cukurova-universitesi', 'iibf'),
  ('cukurova-universitesi', 'hukuk'),
  ('cukurova-universitesi', 'eczacilik'),
  ('cukurova-universitesi', 'turizm'),
  ('cukurova-universitesi', 'egitim'),
  ('cukurova-universitesi', 'myo'),
  ('cukurova-universitesi', 'saglik-myo');

-- Erciyes
INSERT INTO uni_faculty_types VALUES
  ('erciyes-universitesi', 'muhendislik'),
  ('erciyes-universitesi', 'fen-edebiyat'),
  ('erciyes-universitesi', 'iibf'),
  ('erciyes-universitesi', 'hukuk'),
  ('erciyes-universitesi', 'eczacilik'),
  ('erciyes-universitesi', 'egitim'),
  ('erciyes-universitesi', 'myo'),
  ('erciyes-universitesi', 'saglik-myo');

-- Atatürk
INSERT INTO uni_faculty_types VALUES
  ('ataturk-universitesi', 'muhendislik'),
  ('ataturk-universitesi', 'fen-edebiyat'),
  ('ataturk-universitesi', 'iibf'),
  ('ataturk-universitesi', 'hukuk'),
  ('ataturk-universitesi', 'eczacilik'),
  ('ataturk-universitesi', 'egitim'),
  ('ataturk-universitesi', 'iletisim'),
  ('ataturk-universitesi', 'myo'),
  ('ataturk-universitesi', 'saglik-myo');

-- Pamukkale
INSERT INTO uni_faculty_types VALUES
  ('pamukkale-universitesi', 'muhendislik'),
  ('pamukkale-universitesi', 'fen-edebiyat'),
  ('pamukkale-universitesi', 'iibf'),
  ('pamukkale-universitesi', 'egitim'),
  ('pamukkale-universitesi', 'turizm'),
  ('pamukkale-universitesi', 'myo'),
  ('pamukkale-universitesi', 'saglik-myo');

-- Kocaeli
INSERT INTO uni_faculty_types VALUES
  ('kocaeli-universitesi', 'muhendislik'),
  ('kocaeli-universitesi', 'fen-edebiyat'),
  ('kocaeli-universitesi', 'iibf'),
  ('kocaeli-universitesi', 'hukuk'),
  ('kocaeli-universitesi', 'egitim'),
  ('kocaeli-universitesi', 'iletisim'),
  ('kocaeli-universitesi', 'myo'),
  ('kocaeli-universitesi', 'saglik-myo');

-- Selçuk
INSERT INTO uni_faculty_types VALUES
  ('selcuk-universitesi', 'muhendislik'),
  ('selcuk-universitesi', 'fen-edebiyat'),
  ('selcuk-universitesi', 'iibf'),
  ('selcuk-universitesi', 'hukuk'),
  ('selcuk-universitesi', 'eczacilik'),
  ('selcuk-universitesi', 'egitim'),
  ('selcuk-universitesi', 'iletisim'),
  ('selcuk-universitesi', 'myo'),
  ('selcuk-universitesi', 'saglik-myo');

-- Gaziantep
INSERT INTO uni_faculty_types VALUES
  ('gaziantep-universitesi', 'muhendislik'),
  ('gaziantep-universitesi', 'fen-edebiyat'),
  ('gaziantep-universitesi', 'iibf'),
  ('gaziantep-universitesi', 'hukuk'),
  ('gaziantep-universitesi', 'eczacilik'),
  ('gaziantep-universitesi', 'egitim'),
  ('gaziantep-universitesi', 'myo'),
  ('gaziantep-universitesi', 'saglik-myo');

-- ============================================================
-- 5) Fakülteleri oluştur
-- ============================================================
-- Her (uni_slug, faculty_type) için bir fakülte oluştur.
-- Slug formatı: {faculty_type}-{uni_slug}

INSERT INTO faculties (ad, emoji, renk, slug, university_id)
SELECT
  CASE f_type
    WHEN 'muhendislik' THEN 'Mühendislik Fakültesi'
    WHEN 'fen-edebiyat' THEN 'Fen-Edebiyat Fakültesi'
    WHEN 'iibf' THEN 'İktisadi ve İdari Bilimler Fakültesi'
    WHEN 'hukuk' THEN 'Hukuk Fakültesi'
    WHEN 'egitim' THEN 'Eğitim Fakültesi'
    WHEN 'iletisim' THEN 'İletişim Fakültesi'
    WHEN 'guzel-sanatlar' THEN 'Güzel Sanatlar Fakültesi'
    WHEN 'eczacilik' THEN 'Eczacılık Fakültesi'
    WHEN 'turizm' THEN 'Turizm Fakültesi'
    WHEN 'mimarlik' THEN 'Mimarlık Fakültesi'
    WHEN 'myo' THEN 'Meslek Yüksekokulu'
    WHEN 'saglik-myo' THEN 'Sağlık Hizmetleri Meslek Yüksekokulu'
    WHEN 'siyasal' THEN 'Siyasal Bilgiler Fakültesi'
  END AS ad,
  CASE f_type
    WHEN 'muhendislik' THEN '⚙️'
    WHEN 'fen-edebiyat' THEN '🔬'
    WHEN 'iibf' THEN '💼'
    WHEN 'hukuk' THEN '⚖️'
    WHEN 'egitim' THEN '🎓'
    WHEN 'iletisim' THEN '📡'
    WHEN 'guzel-sanatlar' THEN '🎨'
    WHEN 'eczacilik' THEN '💊'
    WHEN 'turizm' THEN '🏖️'
    WHEN 'mimarlik' THEN '🏗️'
    WHEN 'myo' THEN '🔧'
    WHEN 'saglik-myo' THEN '🏥'
    WHEN 'siyasal' THEN '🏛️'
  END AS emoji,
  CASE f_type
    WHEN 'muhendislik' THEN '#4f46e5'
    WHEN 'fen-edebiyat' THEN '#7c3aed'
    WHEN 'iibf' THEN '#0d9488'
    WHEN 'hukuk' THEN '#0891b2'
    WHEN 'egitim' THEN '#16a34a'
    WHEN 'iletisim' THEN '#d97706'
    WHEN 'guzel-sanatlar' THEN '#dc2626'
    WHEN 'eczacilik' THEN '#16a34a'
    WHEN 'turizm' THEN '#0ea5e9'
    WHEN 'mimarlik' THEN '#d97706'
    WHEN 'myo' THEN '#64748b'
    WHEN 'saglik-myo' THEN '#0891b2'
    WHEN 'siyasal' THEN '#7c3aed'
  END AS renk,
  f_type || '-' || uft.uni_slug AS slug,
  u.id AS university_id
FROM uni_faculty_types uft
JOIN universities u ON u.slug = uft.uni_slug
CROSS JOIN LATERAL (SELECT uft.faculty_type AS f_type) AS ft
ON CONFLICT (slug) DO NOTHING;

-- ============================================================
-- 6) Fakülteleri bölümlerle eşleştir
-- ============================================================
-- Her fakülte için, faculty_dept_template'den ilgili bölümleri ekle.

INSERT INTO faculty_departments (faculty_id, department_slug)
SELECT f.id, t.department_slug
FROM faculties f
JOIN faculty_dept_template t ON (
  (f.slug LIKE 'muhendislik-%' AND t.faculty_type = 'muhendislik') OR
  (f.slug LIKE 'fen-edebiyat-%' AND t.faculty_type = 'fen-edebiyat') OR
  (f.slug LIKE 'iibf-%' AND t.faculty_type = 'iibf') OR
  (f.slug LIKE 'hukuk-%' AND t.faculty_type = 'hukuk') OR
  (f.slug LIKE 'egitim-%' AND t.faculty_type = 'egitim') OR
  (f.slug LIKE 'iletisim-%' AND t.faculty_type = 'iletisim') OR
  (f.slug LIKE 'guzel-sanatlar-%' AND t.faculty_type = 'guzel-sanatlar') OR
  (f.slug LIKE 'eczacilik-%' AND t.faculty_type = 'eczacilik') OR
  (f.slug LIKE 'turizm-%' AND t.faculty_type = 'turizm') OR
  (f.slug LIKE 'mimarlik-%' AND t.faculty_type = 'mimarlik') OR
  (f.slug LIKE 'myo-%' AND t.faculty_type = 'myo') OR
  (f.slug LIKE 'saglik-myo-%' AND t.faculty_type = 'saglik-myo') OR
  (f.slug LIKE 'siyasal-%' AND t.faculty_type = 'iibf')  -- Siyasal = İİBF bölümleri
)
JOIN departments d ON d.slug = t.department_slug
WHERE f.university_id != (SELECT id FROM universities WHERE slug = 'anadolu-universitesi')
ON CONFLICT DO NOTHING;

COMMIT;

-- ============================================================
-- Doğrulama
-- ============================================================
-- 0 bölüm kalan fakülte var mı?
-- SELECT u.ad AS uni, f.ad AS fakulte, COUNT(fd.department_slug) AS bolum_sayisi
-- FROM faculties f
-- LEFT JOIN faculty_departments fd ON fd.faculty_id = f.id
-- LEFT JOIN universities u ON u.id = f.university_id
-- GROUP BY u.ad, f.ad
-- HAVING COUNT(fd.department_slug) = 0
-- ORDER BY u.ad, f.ad;
-- Beklenen: 0 satır

-- Üniversite başına fakülte sayısı
-- SELECT u.ad, COUNT(f.id) FROM universities u
-- LEFT JOIN faculties f ON f.university_id = u.id
-- GROUP BY u.ad ORDER BY u.ad;

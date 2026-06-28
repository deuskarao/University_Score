-- ============================================================
-- UniPulse Migration v4: Mühendislik/Mimarlık'tan Önlisans Bölümleri Kaldır
-- ============================================================
-- Sorun: Mühendislik Fakültesi'nde önlisans (MYO) bölümleri görünüyordu:
--   - bilgisayar-programciligi (MYO, 4 dönem)
--   - arka-yuz-yazilim-gelistirme (MYO, 4 dönem)
--   - oyun-gelistirme-ve-programlama (MYO, 4 dönem)
--   - buyuk-veri-analistligi (MYO, 4 dönem)
--
-- Bu bölümler Mühendislik Fakültesi'nde YANLIŞ. Mühendislik Fakültesi
-- lisans bölümleri (Bilgisayar Mühendisliği, Endüstri Mühendisliği, vb.)
-- içermeli ama DB'de bu bölümler yok. Bu yüzden Mühendislik Fakültesi
-- şimdilik boş kalacak (gerçekçi — DB'de lisans mühendislik bölümleri yok).
--
-- Aynı durum Mimarlık Fakültesi için de geçerli.
--
-- Çözüm: Mühendislik ve Mimarlık fakültelerinden önlisans bölümlerini kaldır.
-- MYO ve Sağlık MYO'da bu bölümler korunsun (orada doğru).
--
-- Tarih: 2026-06-28
-- ============================================================

BEGIN;

-- ============================================================
-- 1) Mühendislik Fakültesi'nden önlisans bölümlerini kaldır
-- ============================================================
-- Bu bölümler MYO'ya ait, Mühendislik Fakültesi'nde yanlış.

DELETE FROM faculty_departments
WHERE faculty_id IN (
  SELECT id FROM faculties
  WHERE slug LIKE 'muhendislik-%'
    AND university_id != (SELECT id FROM universities WHERE slug = 'anadolu-universitesi')
)
AND department_slug IN (
  'bilgisayar-programciligi',
  'arka-yuz-yazilim-gelistirme',
  'oyun-gelistirme-ve-programlama',
  'buyuk-veri-analistligi'
);

-- ============================================================
-- 2) Mimarlık Fakültesi'nden önlisans bölümlerini kaldır
-- ============================================================
-- Mimarlık'ta da görsel ileletişim, grafik gibi bölümler yanlış.
-- Bu bölümler Güzel Sanatlar'a ait.

DELETE FROM faculty_departments
WHERE faculty_id IN (
  SELECT id FROM faculties
  WHERE slug LIKE 'mimarlik-%'
)
AND department_slug IN (
  'gorsel-iletisim-tasarimi',
  'grafik-sanatlar',
  'cizgi-film-ve-animasyon',
  'dijital-oyun-tasarimi'
);

-- ============================================================
-- 3) Bilgi: Bu bölümler MYO ve Sağlık MYO'da hâlâ var (doğru)
-- ============================================================
-- Kontrol için:
-- SELECT f.ad, fd.department_slug FROM faculty_departments fd
-- JOIN faculties f ON f.id = fd.faculty_id
-- WHERE fd.department_slug = 'bilgisayar-programciligi';
-- Beklenen: Sadece MYO fakültelerinde görünür.

COMMIT;

-- ============================================================
-- Doğrulama
-- ============================================================
-- Mühendislik Fakültesi'nde kaç bölüm kaldı?
-- SELECT u.ad AS uni, f.ad AS fakulte, COUNT(fd.department_slug) AS bolum
-- FROM faculties f
-- LEFT JOIN faculty_departments fd ON fd.faculty_id = f.id
-- LEFT JOIN universities u ON u.id = f.university_id
-- WHERE f.slug LIKE 'muhendislik-%'
-- GROUP BY u.ad, f.ad
-- ORDER BY u.ad;
-- Beklenen: 0 bölüm (Mühendislik boş, çünkü DB'de lisans mühendislik bölümü yok)

-- Hangi fakültelerde 'bilgisayar-programciligi' var?
-- SELECT u.ad, f.ad FROM faculty_departments fd
-- JOIN faculties f ON f.id = fd.faculty_id
-- JOIN universities u ON u.id = f.university_id
-- WHERE fd.department_slug = 'bilgisayar-programciligi';
-- Beklenen: Sadece Meslek Yüksekokulu'nda (MYO)

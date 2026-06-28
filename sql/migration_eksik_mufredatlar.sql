-- ============================================================
-- UniPulse Müfredat Migration — Sadece Eksik Bölümler
-- ============================================================
-- Bu migration SADECE dersleri olmayan bölümlere müfredat ekler.
--
-- DB KONTROLÜ (2026-06-28):
--   * 27 bölümde 1000 ders var (önceki migration'dan)
--   * 29 bölüm BOŞ — bu dosya onlara müfredat ekleyecek
--   * Toplam beklenen: 1000 + ~1293 = ~2293 department_courses
--
-- KORUNAN BÖLÜMLER (Anadolu Üniversitesi):
--   * Dış Ticaret, Bilgisayar Programcılığı, Özel Eğitim Öğretmenliği
--
-- Bu dosya TEKRAR ÇALIŞTIRILABILIR (idempotent).
-- WHERE NOT EXISTS ile sadece boş bölümlere ekleme yapar.
-- ============================================================

BEGIN;

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

COMMIT;

-- ============================================================
-- Doğrulama sorguları
-- ============================================================
-- Toplam ders sayısı (beklenen: ~2293):
-- SELECT COUNT(*) FROM department_courses;

-- Hangi bölümlerde kaç ders var:
-- SELECT d.ad, COUNT(dc.id) AS ders_sayisi
-- FROM departments d
-- LEFT JOIN department_courses dc ON dc.department_id = d.id
-- GROUP BY d.ad
-- ORDER BY ders_sayisi DESC;
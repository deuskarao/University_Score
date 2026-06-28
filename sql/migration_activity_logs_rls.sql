-- activity_logs tablosu için RLS policy
-- Kullanıcılar kendi activity log'larını ekleyebilir (insert)
-- Admin tüm log'ları görebilir (select)

-- RLS etkin mi kontrol et
ALTER TABLE activity_logs ENABLE ROW LEVEL SECURITY;

-- INSERT policy: kullanıcı kendi user_id'si ile log ekleyebilir
DROP POLICY IF EXISTS "Users can insert own activity logs" ON activity_logs;
CREATE POLICY "Users can insert own activity logs" ON activity_logs
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

-- SELECT policy: kullanıcı kendi log'larını görebilir, admin tümünü
DROP POLICY IF EXISTS "Users can view own activity logs" ON activity_logs;
CREATE POLICY "Users can view own activity logs" ON activity_logs
  FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
  ));

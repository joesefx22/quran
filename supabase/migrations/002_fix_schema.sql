-- ============================================================
-- 002_fix_schema.sql
-- الترقية الآمنة لتطابق الموديلز بدون مسح البيانات
-- ============================================================

-- 1. إضافة الأعمدة المفقودة في جدول users (بشرط عدم وجودها)
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone_number TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS guardian_name TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS guardian_phone TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE users ADD COLUMN IF NOT EXISTS joined_at TIMESTAMPTZ DEFAULT NOW();

-- 2. إضافة الأعمدة المفقودة في student_profiles
ALTER TABLE student_profiles ADD COLUMN IF NOT EXISTS guardian_id UUID REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE student_profiles ADD COLUMN IF NOT EXISTS weekly_points NUMERIC(10,2) DEFAULT 0;
ALTER TABLE student_profiles ADD COLUMN IF NOT EXISTS attendance_count INTEGER DEFAULT 0;
ALTER TABLE student_profiles ADD COLUMN IF NOT EXISTS absence_count INTEGER DEFAULT 0;

-- 3. إضافة أعمدة المزامنة (للمزامنة مع Isar لاحقاً)
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS is_synced BOOLEAN DEFAULT false;
ALTER TABLE session_parts ADD COLUMN IF NOT EXISTS is_synced BOOLEAN DEFAULT false;

-- ============================================================
-- 4. تصحيح سياسات RLS (الثغرة الأمنية)
-- ============================================================

-- حذف السياسات القديمة الخاطئة (آمناً لأنها موجودة)
DROP POLICY IF EXISTS "Teacher inserts sessions" ON sessions;
DROP POLICY IF EXISTS "Teacher inserts session parts" ON session_parts;

-- إعادة إنشاء سياسة إدراج الجلسات بحيث تكون مقيدة بمعرف المعلم نفسه
CREATE POLICY "Teacher inserts sessions" ON sessions
FOR INSERT
WITH CHECK (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'teacher')
  AND teacher_id = auth.uid()
);

-- إعادة إنشاء سياسة إدراج أجزاء الجلسات بحيث تتحقق من أن الجلسة مملوكة للمعلم
CREATE POLICY "Teacher inserts session parts" ON session_parts
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM sessions s
    WHERE s.id = session_id
    AND s.teacher_id = auth.uid()
  )
);

-- تأكيد أن سياسات التحديث والحذف مقيدة بنفس المنطق (موجودة بالفعل، لكن نؤكد كتابتها)
DROP POLICY IF EXISTS "Teacher can update own sessions" ON sessions;
CREATE POLICY "Teacher can update own sessions" ON sessions
FOR UPDATE
USING (teacher_id = auth.uid())
WITH CHECK (teacher_id = auth.uid());

DROP POLICY IF EXISTS "Teacher can delete own sessions" ON sessions;
CREATE POLICY "Teacher can delete own sessions" ON sessions
FOR DELETE
USING (teacher_id = auth.uid());

DROP POLICY IF EXISTS "Teacher can update own session parts" ON session_parts;
CREATE POLICY "Teacher can update own session parts" ON session_parts
FOR UPDATE
USING (
  EXISTS (SELECT 1 FROM sessions s WHERE s.id = session_id AND s.teacher_id = auth.uid())
);

DROP POLICY IF EXISTS "Teacher can delete own session parts" ON session_parts;
CREATE POLICY "Teacher can delete own session parts" ON session_parts
FOR DELETE
USING (
  EXISTS (SELECT 1 FROM sessions s WHERE s.id = session_id AND s.teacher_id = auth.uid())
);
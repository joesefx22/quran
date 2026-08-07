-- ============================================================
-- 000_full_schema_reset.sql
-- إعادة تهيئة كاملة: حذف الجداول، إنشاءها، فهارس، سياسات،
-- دوال، محفزات، وبيانات بذرة تجريبية (مدير، معلم، طالب، ولي أمر)
-- ============================================================

-- 🧹 1. حذف جميع الجداول السابقة (بترتيب عكسي لتجنب قيود المفاتيح)
DROP TABLE IF EXISTS session_parts CASCADE;
DROP TABLE IF EXISTS sessions CASCADE;
DROP TABLE IF EXISTS student_profiles CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS groups CASCADE;
DROP TABLE IF EXISTS mosques CASCADE;

-- حذف النوع ENUM إذا كان موجوداً
DROP TYPE IF EXISTS user_role CASCADE;

-- 🏗️ 2. إنشاء النوع والأدوار
DO $$ BEGIN
  CREATE TYPE user_role AS ENUM ('manager', 'teacher', 'assistant', 'student', 'guardian');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- 3. إنشاء الجداول
CREATE TABLE mosques (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE groups (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  mosque_id UUID REFERENCES mosques(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_group_name_per_mosque UNIQUE (mosque_id, name)
);

CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  full_name TEXT,
  role user_role NOT NULL DEFAULT 'student',
  group_id UUID REFERENCES groups(id) ON DELETE SET NULL,
  mosque_id UUID REFERENCES mosques(id) ON DELETE SET NULL,
  age INTEGER CHECK (age BETWEEN 4 AND 100),
  profile_completed BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE student_profiles (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  new_pages_target INTEGER DEFAULT 5 CHECK (new_pages_target >= 0),
  review_pages_target INTEGER DEFAULT 50 CHECK (review_pages_target >= 0),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  student_id UUID REFERENCES users(id) ON DELETE CASCADE,
  group_id UUID REFERENCES groups(id) ON DELETE CASCADE,
  teacher_id UUID REFERENCES users(id) ON DELETE CASCADE,
  session_date DATE NOT NULL,
  attended BOOLEAN DEFAULT true,
  early_attendance BOOLEAN DEFAULT false,
  early_recitation BOOLEAN DEFAULT false,
  on_time_departure BOOLEAN DEFAULT false,
  cumulative_done BOOLEAN DEFAULT false,
  skipped_new BOOLEAN DEFAULT false,
  skipped_review BOOLEAN DEFAULT false,
  total_points NUMERIC(6,2) DEFAULT 0 CHECK (total_points >= 0),
  attendance_points NUMERIC(6,2) DEFAULT 0 CHECK (attendance_points >= 0),
  early_attendance_points NUMERIC(6,2) DEFAULT 0 CHECK (early_attendance_points >= 0),
  early_recitation_points NUMERIC(6,2) DEFAULT 0 CHECK (early_recitation_points >= 0),
  departure_points NUMERIC(6,2) DEFAULT 0 CHECK (departure_points >= 0),
  new_points NUMERIC(6,2) DEFAULT 0 CHECK (new_points >= 0),
  extra_new_points NUMERIC(6,2) DEFAULT 0 CHECK (extra_new_points >= 0),
  review_points NUMERIC(6,2) DEFAULT 0 CHECK (review_points >= 0),
  extra_review_points NUMERIC(6,2) DEFAULT 0 CHECK (extra_review_points >= 0),
  cumulative_points NUMERIC(6,2) DEFAULT 0 CHECK (cumulative_points >= 0),
  new_pages NUMERIC(6,2) DEFAULT 0 CHECK (new_pages >= 0),
  review_pages NUMERIC(6,2) DEFAULT 0 CHECK (review_pages >= 0),
  cumulative_pages NUMERIC(6,2) DEFAULT 0 CHECK (cumulative_pages >= 0),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_student_teacher_session UNIQUE (student_id, teacher_id, session_date)
);

CREATE TABLE session_parts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('memorization', 'review')),
  sura_start INTEGER,
  aya_start INTEGER,
  sura_end INTEGER,
  aya_end INTEGER,
  pages_count NUMERIC(4,2) DEFAULT 0 CHECK (pages_count >= 0),
  evaluation TEXT,
  notes TEXT
);

-- 4. الفهارس
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_group ON users(group_id);
CREATE INDEX IF NOT EXISTS idx_users_mosque ON users(mosque_id);
CREATE INDEX IF NOT EXISTS idx_users_group_role ON users(group_id, role);
CREATE INDEX IF NOT EXISTS idx_student_profiles_user ON student_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_student ON sessions(student_id);
CREATE INDEX IF NOT EXISTS idx_sessions_date ON sessions(session_date);
CREATE INDEX IF NOT EXISTS idx_sessions_group_date ON sessions(group_id, session_date);

-- 5. تفعيل RLS
ALTER TABLE mosques ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_parts ENABLE ROW LEVEL SECURITY;

-- 6. سياسات RLS
-- المساجد والمجموعات: قراءة عامة
CREATE POLICY "Everyone can read mosques" ON mosques FOR SELECT USING (true);
CREATE POLICY "Everyone can read groups" ON groups FOR SELECT USING (true);

-- المستخدمون
CREATE POLICY "Users view own record" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Manager full select" ON users FOR SELECT USING (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'manager')
);
CREATE POLICY "Teacher sees group students" ON users FOR SELECT USING (
  EXISTS (SELECT 1 FROM users AS teacher WHERE teacher.id = auth.uid()
          AND teacher.role = 'teacher' AND users.group_id = teacher.group_id)
);
CREATE POLICY "Students can see group members names" ON users FOR SELECT USING (
  auth.uid() = id
  OR
  (group_id IS NOT NULL AND group_id = (SELECT group_id FROM users WHERE id = auth.uid()))
);

CREATE POLICY "Users insert themselves" ON users FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Manager insert users" ON users FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'manager')
);

CREATE POLICY "Users update own record" ON users FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id AND role = (SELECT role FROM users WHERE id = auth.uid()));

CREATE POLICY "Manager full update" ON users FOR UPDATE USING (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'manager')
);

CREATE POLICY "Manager delete users" ON users FOR DELETE USING (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'manager')
);

-- student_profiles
CREATE POLICY "Student view own profile" ON student_profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Student insert own profile" ON student_profiles FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Student update own profile" ON student_profiles FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Manager full access profiles" ON student_profiles FOR ALL USING (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'manager')
);
CREATE POLICY "Teacher reads group profiles" ON student_profiles FOR SELECT USING (
  EXISTS (SELECT 1 FROM users AS student JOIN users AS teacher ON teacher.id = auth.uid()
          WHERE student.id = student_profiles.user_id AND teacher.role = 'teacher'
          AND student.group_id = teacher.group_id)
);

-- sessions
CREATE POLICY "Student sees own sessions" ON sessions FOR SELECT USING (student_id = auth.uid());
CREATE POLICY "Teacher sees group sessions" ON sessions FOR SELECT USING (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'teacher' AND group_id = sessions.group_id)
);
CREATE POLICY "Teacher inserts sessions" ON sessions FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'teacher')
);
CREATE POLICY "Teacher can update own sessions" ON sessions FOR UPDATE USING (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'teacher')
  AND teacher_id = auth.uid()
);
CREATE POLICY "Teacher can delete own sessions" ON sessions FOR DELETE USING (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'teacher')
  AND teacher_id = auth.uid()
);
CREATE POLICY "Manager full access sessions" ON sessions FOR ALL USING (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'manager')
);

-- session_parts
CREATE POLICY "Users see own session parts" ON session_parts FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM sessions WHERE id = session_parts.session_id
    AND (
      student_id = auth.uid()
      OR EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'teacher' AND group_id = sessions.group_id)
      OR EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'manager')
    )
  )
);
CREATE POLICY "Teacher inserts session parts" ON session_parts FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM sessions WHERE id = session_parts.session_id
    AND EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'teacher' AND group_id = sessions.group_id)
  )
);
CREATE POLICY "Teacher can update own session parts" ON session_parts FOR UPDATE USING (
  EXISTS (
    SELECT 1 FROM sessions s JOIN users u ON u.id = auth.uid()
    WHERE s.id = session_parts.session_id AND u.role = 'teacher' AND s.teacher_id = auth.uid()
  )
);
CREATE POLICY "Teacher can delete own session parts" ON session_parts FOR DELETE USING (
  EXISTS (
    SELECT 1 FROM sessions s JOIN users u ON u.id = auth.uid()
    WHERE s.id = session_parts.session_id AND u.role = 'teacher' AND s.teacher_id = auth.uid()
  )
);
CREATE POLICY "Manager full access session parts" ON session_parts FOR ALL USING (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'manager')
);

-- 7. الدوال المساعدة
CREATE OR REPLACE FUNCTION is_manager(uid UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users WHERE id = uid AND role = 'manager'
  );
END;
$$;

-- دالة cumulative مصححة: تجلب مجموع صفحات الحفظ لآخر جلستين (وليس آخر يومين تقويميين)
CREATE OR REPLACE FUNCTION get_student_cumulative_pages(student_uuid UUID, p_target_date DATE)
RETURNS NUMERIC AS $$
DECLARE
  total_pages NUMERIC := 0;
BEGIN
  SELECT COALESCE(SUM(sp.pages_count), 0)
  INTO total_pages
  FROM sessions s
  JOIN session_parts sp ON sp.session_id = s.id
  WHERE s.student_id = student_uuid
    AND sp.type = 'memorization'
    AND s.session_date IN (
      SELECT session_date
      FROM sessions
      WHERE student_id = student_uuid
        AND session_date < p_target_date
      GROUP BY session_date
      ORDER BY session_date DESC
      LIMIT 2
    );
  RETURN total_pages;
END;
$$ LANGUAGE plpgsql;

-- 8. المحفزات (Triggers)
CREATE OR REPLACE FUNCTION enforce_registration_role()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.role IN ('teacher', 'manager', 'assistant') THEN
    IF NOT is_manager(auth.uid()) THEN
      RAISE EXCEPTION 'غير مسموح بتسجيل هذا الدور إلا من قبل المدير';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS before_user_insert ON users;
CREATE TRIGGER before_user_insert
BEFORE INSERT ON users
FOR EACH ROW
EXECUTE FUNCTION enforce_registration_role();

CREATE OR REPLACE FUNCTION protect_sensitive_fields()
RETURNS TRIGGER AS $$
BEGIN
  IF NOT is_manager(auth.uid()) THEN
    IF OLD.role IS DISTINCT FROM NEW.role THEN
      RAISE EXCEPTION 'غير مسموح بتغيير الدور';
    END IF;
    IF OLD.group_id IS DISTINCT FROM NEW.group_id THEN
      RAISE EXCEPTION 'غير مسموح بتغيير المجموعة';
    END IF;
    IF OLD.mosque_id IS DISTINCT FROM NEW.mosque_id THEN
      RAISE EXCEPTION 'غير مسموح بتغيير المسجد';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS protect_user_fields ON users;
CREATE TRIGGER protect_user_fields
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION protect_sensitive_fields();

-- 🌱 9. بيانات البذرة (Seed Data)
-- مسح المستخدمين السابقين (لتجنب التعارض)
DELETE FROM auth.users WHERE email IN ('manager@test.com', 'teacher@test.com', 'student@test.com', 'guardian@test.com');
DELETE FROM public.users WHERE email IN ('manager@test.com', 'teacher@test.com', 'student@test.com', 'guardian@test.com');

-- إنشاء مسجد ومجموعة افتراضيين
INSERT INTO mosques (id, name) VALUES ('00000000-0000-0000-0000-000000000001', 'المسجد النموذجي');
INSERT INTO groups (id, mosque_id, name) VALUES ('00000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000001', 'حلقة القرآن');

-- ⛔ تعطيل المؤقت مؤقتاً للسماح بإدخال بيانات البذرة
ALTER TABLE users DISABLE TRIGGER before_user_insert;

-- إنشاء مستخدمين في auth.users
DO $$
DECLARE
  v_manager_id UUID;
  v_teacher_id UUID;
  v_student_id UUID;
  v_guardian_id UUID;
BEGIN
  -- مدير
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data)
  VALUES ('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'manager@test.com',
          crypt('123456', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"مدير تجريبي"}')
  RETURNING id INTO v_manager_id;

  -- معلم
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data)
  VALUES ('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'teacher@test.com',
          crypt('123456', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"معلم تجريبي"}')
  RETURNING id INTO v_teacher_id;

  -- طالب
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data)
  VALUES ('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'student@test.com',
          crypt('123456', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"طالب تجريبي"}')
  RETURNING id INTO v_student_id;

  -- ولي أمر
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data)
  VALUES ('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'guardian@test.com',
          crypt('123456', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"ولي أمر تجريبي"}')
  RETURNING id INTO v_guardian_id;

  -- إدخالهم في public.users مع الأدوار والمسجد والمجموعة
  INSERT INTO public.users (id, email, full_name, role, mosque_id, group_id, profile_completed) VALUES
    (v_manager_id, 'manager@test.com', 'مدير تجريبي', 'manager', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000010', true),
    (v_teacher_id, 'teacher@test.com', 'معلم تجريبي', 'teacher', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000010', true),
    (v_student_id, 'student@test.com', 'طالب تجريبي', 'student', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000010', true),
    (v_guardian_id, 'guardian@test.com', 'ولي أمر تجريبي', 'guardian', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000010', true);

  -- إضافة ملف الطالب للطالب التجريبي
  INSERT INTO student_profiles (user_id, new_pages_target, review_pages_target) VALUES
    (v_student_id, 4, 20);

END $$;

-- ✅ إعادة تفعيل المؤقت
ALTER TABLE users ENABLE TRIGGER before_user_insert;
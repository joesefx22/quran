-- ============================================================
-- ملف SQL متكامل لقاعدة بيانات تطبيق حلقة القرآن
-- يُنشئ الجداول والفهارس، مع بيانات أساسية للمساجد والمجموعات
-- يمكن تشغيله مباشرة على قاعدة بيانات فارغة (Supabase)
-- ============================================================

-- 🏗️ 1. إنشاء الجداول (بدون حذف)

-- المساجد
CREATE TABLE IF NOT EXISTS mosques (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- المجموعات
CREATE TABLE IF NOT EXISTS groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mosque_id UUID REFERENCES mosques(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_group_name_per_mosque UNIQUE (mosque_id, name)
);

-- المستخدمون (مرتبط بـ auth.users)
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  full_name TEXT,
  role TEXT NOT NULL DEFAULT 'student', -- 'manager','teacher','assistant','student','guardian'
  group_id UUID REFERENCES groups(id) ON DELETE SET NULL,
  mosque_id UUID REFERENCES mosques(id) ON DELETE SET NULL,
  age INTEGER CHECK (age BETWEEN 4 AND 100),
  profile_completed BOOLEAN DEFAULT FALSE,
  phone_number TEXT,
  guardian_name TEXT,
  guardian_phone TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ملفات الطلاب
CREATE TABLE IF NOT EXISTS student_profiles (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  new_pages_target INTEGER DEFAULT 5 CHECK (new_pages_target >= 0),
  review_pages_target INTEGER DEFAULT 50 CHECK (review_pages_target >= 0),
  weekly_points NUMERIC(6,2) DEFAULT 0,
  attendance_count INTEGER DEFAULT 0,
  absence_count INTEGER DEFAULT 0,
  guardian_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- الجلسات
CREATE TABLE IF NOT EXISTS sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES users(id) ON DELETE CASCADE,
  group_id UUID REFERENCES groups(id) ON DELETE CASCADE,
  teacher_id UUID REFERENCES users(id) ON DELETE CASCADE,
  session_date DATE NOT NULL,
  attended BOOLEAN DEFAULT TRUE,
  early_attendance BOOLEAN DEFAULT FALSE,
  early_recitation BOOLEAN DEFAULT FALSE,
  on_time_departure BOOLEAN DEFAULT FALSE,
  cumulative_done BOOLEAN DEFAULT FALSE,
  skipped_new BOOLEAN DEFAULT FALSE,
  skipped_review BOOLEAN DEFAULT FALSE,
  new_pages NUMERIC(6,2) DEFAULT 0,
  review_pages NUMERIC(6,2) DEFAULT 0,
  cumulative_pages NUMERIC(6,2) DEFAULT 0,
  new_points NUMERIC(6,2) DEFAULT 0,
  review_points NUMERIC(6,2) DEFAULT 0,
  cumulative_points NUMERIC(6,2) DEFAULT 0,
  extra_new_points NUMERIC(6,2) DEFAULT 0,
  extra_review_points NUMERIC(6,2) DEFAULT 0,
  attendance_points NUMERIC(6,2) DEFAULT 0,
  total_points NUMERIC(6,2) DEFAULT 0,
  early_attendance_points NUMERIC(6,2) DEFAULT 0,
  early_recitation_points NUMERIC(6,2) DEFAULT 0,
  departure_points NUMERIC(6,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_student_teacher_session UNIQUE (student_id, teacher_id, session_date)
);

-- أجزاء الجلسة
CREATE TABLE IF NOT EXISTS session_parts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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

-- 2. الفهارس (للسرعة)
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_group ON users(group_id);
CREATE INDEX IF NOT EXISTS idx_users_mosque ON users(mosque_id);
CREATE INDEX IF NOT EXISTS idx_users_group_role ON users(group_id, role);
CREATE INDEX IF NOT EXISTS idx_student_profiles_user ON student_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_student ON sessions(student_id);
CREATE INDEX IF NOT EXISTS idx_sessions_date ON sessions(session_date);
CREATE INDEX IF NOT EXISTS idx_sessions_group_date ON sessions(group_id, session_date);

-- 3. إلغاء تفعيل RLS (تبسيط الأمان)
ALTER TABLE mosques DISABLE ROW LEVEL SECURITY;
ALTER TABLE groups DISABLE ROW LEVEL SECURITY;
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE student_profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE sessions DISABLE ROW LEVEL SECURITY;
ALTER TABLE session_parts DISABLE ROW LEVEL SECURITY;

-- 4. بيانات أساسية (مسجد ومجموعة فقط) – لا تعتمد على auth.users
INSERT INTO mosques (id, name) VALUES 
  ('11111111-1111-1111-1111-111111111111', 'مسجد الفتح')
ON CONFLICT (id) DO NOTHING;

INSERT INTO groups (id, mosque_id, name) VALUES 
  ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'مجموعة التحفيظ الأولى')
ON CONFLICT (id) DO NOTHING;

-- ✅ لإنشاء مستخدمين تجريبيين:
-- 1. اذهب إلى Authentication > Users في Supabase
-- 2. أنشئ مستخدم جديد (Add user) وسجل البريد والرقم السري
-- 3. استخدم الـ ID الناتج في INSERT INTO users هنا (اختياري)
-- 4. أو ببساطة استخدم واجهة التطبيق لتسجيل مستخدم جديد

-- ============================================================
-- انتهى الملف
-- ============================================================
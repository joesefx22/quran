-- ============================================================
-- ملف SQL متكامل لقاعدة بيانات تطبيق حلقة القرآن
-- يعتمد على النماذج المقدمة من المطور، مع إلغاء RLS للتبسيط
-- ============================================================

-- 🧹 1. حذف الجداول القديمة (إن وجدت)
DROP TABLE IF EXISTS session_parts CASCADE;
DROP TABLE IF EXISTS sessions CASCADE;
DROP TABLE IF EXISTS student_profiles CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS groups CASCADE;
DROP TABLE IF EXISTS mosques CASCADE;

-- 🏗️ 2. إنشاء الجداول

-- المساجد
CREATE TABLE mosques (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- المجموعات
CREATE TABLE groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mosque_id UUID REFERENCES mosques(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_group_name_per_mosque UNIQUE (mosque_id, name)
);

-- المستخدمون (مرتبط بـ auth.users)
CREATE TABLE users (
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
CREATE TABLE student_profiles (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  new_pages_target INTEGER DEFAULT 5 CHECK (new_pages_target >= 0),
  review_pages_target INTEGER DEFAULT 50 CHECK (review_pages_target >= 0),
  weekly_points NUMERIC(6,2) DEFAULT 0,
  attendance_count INTEGER DEFAULT 0,
  absence_count INTEGER DEFAULT 0,
  guardian_user_id UUID REFERENCES users(id) ON DELETE SET NULL, -- ولي الأمر (اختياري)
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- الجلسات
CREATE TABLE sessions (
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
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_student_teacher_session UNIQUE (student_id, teacher_id, session_date)
);

-- أجزاء الجلسة
CREATE TABLE session_parts (
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

-- 3. الفهارس (للسرعة)
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_group ON users(group_id);
CREATE INDEX idx_users_mosque ON users(mosque_id);
CREATE INDEX idx_users_group_role ON users(group_id, role);
CREATE INDEX idx_student_profiles_user ON student_profiles(user_id);
CREATE INDEX idx_sessions_student ON sessions(student_id);
CREATE INDEX idx_sessions_date ON sessions(session_date);
CREATE INDEX idx_sessions_group_date ON sessions(group_id, session_date);

-- 4. إلغاء تفعيل RLS (تبسيط الأمان)
ALTER TABLE mosques DISABLE ROW LEVEL SECURITY;
ALTER TABLE groups DISABLE ROW LEVEL SECURITY;
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE student_profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE sessions DISABLE ROW LEVEL SECURITY;
ALTER TABLE session_parts DISABLE ROW LEVEL SECURITY;

-- 5. بيانات تجريبية (Seed Data)
-- مسجد
INSERT INTO mosques (id, name) VALUES 
  ('11111111-1111-1111-1111-111111111111', 'مسجد الفتح')
ON CONFLICT (id) DO NOTHING;

-- مجموعة
INSERT INTO groups (id, mosque_id, name) VALUES 
  ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'مجموعة التحفيظ الأولى')
ON CONFLICT (id) DO NOTHING;

-- ملاحظة: يجب أن يكون المستخدمون مسجلين في auth.users أولاً، لكننا نضيفهم هنا كمرجع.
-- يمكنك تعديل هذه المعرفات إذا كنت تريد استخدام مستخدمين حقيقيين.
-- نقوم بإدراجهم باستخدام ON CONFLICT لتجنب الأخطاء إن وجدت.

-- مدير
INSERT INTO users (id, email, full_name, role, group_id, mosque_id, profile_completed) VALUES 
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'admin@example.com', 'أحمد المدير', 'manager', NULL, '11111111-1111-1111-1111-111111111111', TRUE)
ON CONFLICT (id) DO NOTHING;

-- معلم
INSERT INTO users (id, email, full_name, role, group_id, mosque_id, profile_completed) VALUES 
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'teacher@example.com', 'خالد المعلم', 'teacher', '22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', TRUE)
ON CONFLICT (id) DO NOTHING;

-- طالب
INSERT INTO users (id, email, full_name, role, group_id, mosque_id, profile_completed) VALUES 
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'student@example.com', 'سعيد الطالب', 'student', '22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', TRUE)
ON CONFLICT (id) DO NOTHING;

-- ولي أمر
INSERT INTO users (id, email, full_name, role, group_id, mosque_id, profile_completed) VALUES 
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'guardian@example.com', 'محمد الولي', 'guardian', NULL, '11111111-1111-1111-1111-111111111111', TRUE)
ON CONFLICT (id) DO NOTHING;

-- ملف الطالب
INSERT INTO student_profiles (user_id, new_pages_target, review_pages_target, guardian_user_id) VALUES 
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 4, 20, 'dddddddd-dddd-dddd-dddd-dddddddddddd')
ON CONFLICT (user_id) DO NOTHING;

-- جلسة تجريبية للطالب
INSERT INTO sessions (
  id, student_id, group_id, teacher_id, session_date,
  attended, early_attendance, early_recitation, on_time_departure,
  cumulative_done, skipped_new, skipped_review,
  new_pages, review_pages, cumulative_pages,
  new_points, review_points, cumulative_points,
  extra_new_points, extra_review_points,
  attendance_points, total_points
) VALUES (
  'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
  'cccccccc-cccc-cccc-cccc-cccccccccccc',
  '22222222-2222-2222-2222-222222222222',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  CURRENT_DATE,
  TRUE, TRUE, FALSE, TRUE,
  FALSE, FALSE, FALSE,
  3.0, 10.0, 0,
  2.5, 1.2, 0,
  1.0, 0.5,
  2.0, 7.2
)
ON CONFLICT (id) DO NOTHING;

-- أجزاء الجلسة (مثال: جزء حفظ جديد)
INSERT INTO session_parts (session_id, type, sura_start, aya_start, sura_end, aya_end, pages_count, evaluation, notes) VALUES 
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'memorization', 1, 1, 1, 7, 1.0, 'ممتاز', 'من أول الفاتحة إلى الآية 7')
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- انتهى الملف
-- ============================================================
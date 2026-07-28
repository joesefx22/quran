-- إنشاء جدول المساجد
CREATE TABLE public.mosques (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- جدول المجموعات
CREATE TABLE public.groups (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  mosque_id UUID REFERENCES public.mosques(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- جدول المستخدمين
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  full_name TEXT,
  role TEXT NOT NULL CHECK (role IN ('manager', 'teacher', 'assistant', 'student', 'guardian')),
  group_id UUID REFERENCES public.groups(id) ON DELETE SET NULL,
  mosque_id UUID REFERENCES public.mosques(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ملفات الطالب
CREATE TABLE public.student_profiles (
  user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  new_pages_target INTEGER DEFAULT 5,
  review_pages_target INTEGER DEFAULT 50,
  cumulative_pages_target INTEGER DEFAULT 10, -- قد لا تستخدم مباشرة
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- بيانات القرآن
CREATE TABLE public.quran_metadata (
  id BIGSERIAL PRIMARY KEY,
  sora INTEGER,
  aya_no INTEGER,
  page INTEGER,
  jozz INTEGER,
  sora_name_ar TEXT
);

-- الجلسات
CREATE TABLE public.sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  student_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  group_id UUID REFERENCES public.groups(id) ON DELETE CASCADE,
  teacher_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  session_date DATE NOT NULL,
  early_attendance BOOLEAN DEFAULT FALSE,
  on_time_departure BOOLEAN DEFAULT FALSE,
  early_recitation BOOLEAN DEFAULT FALSE,
  cumulative_done BOOLEAN DEFAULT FALSE,
  total_points REAL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- أجزاء الجلسة
CREATE TABLE public.session_parts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id UUID REFERENCES public.sessions(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('new', 'extra_new', 'review', 'extra_review')),
  sura_start INTEGER,
  aya_start INTEGER,
  sura_end INTEGER,
  aya_end INTEGER,
  pages_count REAL DEFAULT 0,
  is_extra BOOLEAN DEFAULT FALSE,
  evaluation TEXT,
  notes TEXT
);
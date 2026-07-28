-- تفعيل RLS على الجداول
ALTER TABLE public.mosques ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.session_parts ENABLE ROW LEVEL SECURITY;

-- سياسة: المستخدم يرى بياناته فقط
CREATE POLICY "Users can view own data" ON public.users
  FOR SELECT USING (auth.uid() = id);

-- سياسة: المدير يرى كل شيء
CREATE POLICY "Manager sees all users" ON public.users
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'manager')
  );

-- (نكتفي بهذا القدر، ويمكن إضافة سياسات أكثر تفصيلاً)
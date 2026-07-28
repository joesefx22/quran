-- دالة لجلب آخر جلستين لطالب معين لحساب ورد التراكمي المقترح
CREATE OR REPLACE FUNCTION get_student_cumulative_target(student_uuid UUID, current_date DATE)
RETURNS TABLE (sura_start INT, aya_start INT, sura_end INT, aya_end INT, pages INT) AS $$
BEGIN
  RETURN QUERY
  WITH last_two_sessions AS (
    SELECT s.id AS session_id
    FROM public.sessions s
    WHERE s.student_id = student_uuid AND s.session_date < current_date
    ORDER BY s.session_date DESC
    LIMIT 2
  ),
  new_memorization AS (
    SELECT sp.sura_start, sp.aya_start, sp.sura_end, sp.aya_end
    FROM public.session_parts sp
    JOIN last_two_sessions l ON sp.session_id = l.session_id
    WHERE sp.type = 'new' AND sp.is_extra = false
  )
  SELECT nm.sura_start, nm.aya_start, nm.sura_end, nm.aya_end,
         (MAX(q.page) - MIN(q.page) + 1)::INT AS pages
  FROM new_memorization nm
  JOIN public.quran_metadata q ON (q.sora, q.aya_no) BETWEEN (nm.sura_start, nm.aya_start) AND (nm.sura_end, nm.aya_end)
  GROUP BY nm.sura_start, nm.aya_start, nm.sura_end, nm.aya_end;
END;
$$ LANGUAGE plpgsql;
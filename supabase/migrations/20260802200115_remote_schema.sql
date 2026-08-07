drop extension if exists "pg_net";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.enforce_registration_role()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.role IN ('teacher', 'manager', 'assistant') THEN
    IF NOT is_manager(auth.uid()) THEN
      RAISE EXCEPTION 'غير مسموح بتسجيل هذا الدور إلا من قبل المدير';
    END IF;
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_student_cumulative_pages(student_uuid uuid, p_target_date date)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.is_manager(uid uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users WHERE id = uid AND role = 'manager'
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.protect_sensitive_fields()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

grant delete on table "public"."groups" to "anon";

grant insert on table "public"."groups" to "anon";

grant select on table "public"."groups" to "anon";

grant update on table "public"."groups" to "anon";

grant delete on table "public"."groups" to "authenticated";

grant insert on table "public"."groups" to "authenticated";

grant select on table "public"."groups" to "authenticated";

grant update on table "public"."groups" to "authenticated";

grant delete on table "public"."groups" to "service_role";

grant insert on table "public"."groups" to "service_role";

grant select on table "public"."groups" to "service_role";

grant update on table "public"."groups" to "service_role";

grant delete on table "public"."mosques" to "anon";

grant insert on table "public"."mosques" to "anon";

grant select on table "public"."mosques" to "anon";

grant update on table "public"."mosques" to "anon";

grant delete on table "public"."mosques" to "authenticated";

grant insert on table "public"."mosques" to "authenticated";

grant select on table "public"."mosques" to "authenticated";

grant update on table "public"."mosques" to "authenticated";

grant delete on table "public"."mosques" to "service_role";

grant insert on table "public"."mosques" to "service_role";

grant select on table "public"."mosques" to "service_role";

grant update on table "public"."mosques" to "service_role";

grant delete on table "public"."session_parts" to "anon";

grant insert on table "public"."session_parts" to "anon";

grant select on table "public"."session_parts" to "anon";

grant update on table "public"."session_parts" to "anon";

grant delete on table "public"."session_parts" to "authenticated";

grant insert on table "public"."session_parts" to "authenticated";

grant select on table "public"."session_parts" to "authenticated";

grant update on table "public"."session_parts" to "authenticated";

grant delete on table "public"."session_parts" to "service_role";

grant insert on table "public"."session_parts" to "service_role";

grant select on table "public"."session_parts" to "service_role";

grant update on table "public"."session_parts" to "service_role";

grant delete on table "public"."sessions" to "anon";

grant insert on table "public"."sessions" to "anon";

grant select on table "public"."sessions" to "anon";

grant update on table "public"."sessions" to "anon";

grant delete on table "public"."sessions" to "authenticated";

grant insert on table "public"."sessions" to "authenticated";

grant select on table "public"."sessions" to "authenticated";

grant update on table "public"."sessions" to "authenticated";

grant delete on table "public"."sessions" to "service_role";

grant insert on table "public"."sessions" to "service_role";

grant select on table "public"."sessions" to "service_role";

grant update on table "public"."sessions" to "service_role";

grant delete on table "public"."student_profiles" to "anon";

grant insert on table "public"."student_profiles" to "anon";

grant select on table "public"."student_profiles" to "anon";

grant update on table "public"."student_profiles" to "anon";

grant delete on table "public"."student_profiles" to "authenticated";

grant insert on table "public"."student_profiles" to "authenticated";

grant select on table "public"."student_profiles" to "authenticated";

grant update on table "public"."student_profiles" to "authenticated";

grant delete on table "public"."student_profiles" to "service_role";

grant insert on table "public"."student_profiles" to "service_role";

grant select on table "public"."student_profiles" to "service_role";

grant update on table "public"."student_profiles" to "service_role";

grant delete on table "public"."users" to "anon";

grant insert on table "public"."users" to "anon";

grant select on table "public"."users" to "anon";

grant update on table "public"."users" to "anon";

grant delete on table "public"."users" to "authenticated";

grant insert on table "public"."users" to "authenticated";

grant select on table "public"."users" to "authenticated";

grant update on table "public"."users" to "authenticated";

grant delete on table "public"."users" to "service_role";

grant insert on table "public"."users" to "service_role";

grant select on table "public"."users" to "service_role";

grant update on table "public"."users" to "service_role";



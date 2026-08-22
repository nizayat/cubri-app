-- CUBRÍ V10.3 — flujo real de turnos
alter table public.shifts add column if not exists location_lat double precision;
alter table public.shifts add column if not exists location_lng double precision;
alter table public.shifts add column if not exists requires_experience boolean not null default false;
alter table public.shifts add column if not exists notes text;
create unique index if not exists shift_applications_shift_worker_uidx on public.shift_applications(shift_id, worker_user_id);
create unique index if not exists attendance_shift_worker_uidx on public.attendance(shift_id, worker_user_id);
-- Las políticas RLS complementarias fueron aplicadas al proyecto Supabase de producción.

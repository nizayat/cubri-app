-- CUBRÍ MVP V10 — Base de datos inicial

create extension if not exists pgcrypto;

create type public.account_type as enum ('company','worker');

create type public.shift_status as enum (
  'draft',
  'open',
  'confirmed',
  'active',
  'completed',
  'cancelled'
);

create type public.application_status as enum (
  'applied',
  'selected',
  'confirmed',
  'declined',
  'cancelled'
);

-- =========================
-- PERFILES
-- =========================

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  account_type public.account_type not null,
  email text,
  full_name text,
  phone text,
  city text,
  created_at timestamptz not null default now()
);

create table public.worker_profiles (
  user_id uuid primary key
    references public.profiles(id) on delete cascade,

  primary_role text,
  years_experience int default 0
    check (years_experience >= 0),

  food_handler_verified boolean not null default false,
  identity_verified boolean not null default false,
  available_now boolean not null default false,

  radius_km int not null default 5
    check (radius_km between 1 and 100),

  cubri_score int not null default 50
    check (cubri_score between 0 and 100)
);

create table public.company_profiles (
  user_id uuid primary key
    references public.profiles(id) on delete cascade,

  trading_name text not null,
  establishment_type text,
  tax_id text,
  city text
);

-- =========================
-- TURNOS
-- =========================

create table public.shifts (
  id uuid primary key default gen_random_uuid(),

  company_user_id uuid not null
    references public.profiles(id),

  role text not null,

  slots int not null
    check (slots > 0),

  starts_at timestamptz not null,
  ends_at timestamptz not null,

  pay_amount numeric(12,2) not null
    check (pay_amount >= 0),

  location_name text not null,

  requires_food_handler boolean not null default false,

  priority text not null default 'normal',

  status public.shift_status not null default 'open',

  created_at timestamptz not null default now(),

  check (ends_at > starts_at)
);

-- =========================
-- POSTULACIONES
-- =========================

create table public.shift_applications (
  id uuid primary key default gen_random_uuid(),

  shift_id uuid not null
    references public.shifts(id) on delete cascade,

  worker_user_id uuid not null
    references public.profiles(id) on delete cascade,

  status public.application_status not null default 'applied',

  applied_at timestamptz not null default now(),

  unique (shift_id, worker_user_id)
);

-- =========================
-- CHECK-IN / CHECK-OUT
-- =========================

create table public.attendance (
  id uuid primary key default gen_random_uuid(),

  shift_id uuid not null
    references public.shifts(id) on delete cascade,

  worker_user_id uuid not null
    references public.profiles(id) on delete cascade,

  check_in_at timestamptz,
  check_out_at timestamptz,

  unique (shift_id, worker_user_id)
);

-- =========================
-- CALIFICACIONES
-- =========================

create table public.ratings (
  id uuid primary key default gen_random_uuid(),

  shift_id uuid not null
    references public.shifts(id) on delete cascade,

  author_user_id uuid not null
    references public.profiles(id),

  target_user_id uuid not null
    references public.profiles(id),

  score int not null
    check (score between 1 and 5),

  would_rehire boolean,

  comment text,

  created_at timestamptz not null default now(),

  unique (
    shift_id,
    author_user_id,
    target_user_id
  )
);

-- =========================
-- SEGURIDAD RLS
-- =========================

alter table public.profiles
enable row level security;

alter table public.worker_profiles
enable row level security;

alter table public.company_profiles
enable row level security;

alter table public.shifts
enable row level security;

alter table public.shift_applications
enable row level security;

alter table public.attendance
enable row level security;

alter table public.ratings
enable row level security;

-- =========================
-- POLÍTICAS DE PERFILES
-- =========================

create policy "profile self read"
on public.profiles
for select
to authenticated
using (
  id = auth.uid()
);

create policy "profile self insert"
on public.profiles
for insert
to authenticated
with check (
  id = auth.uid()
);

create policy "profile self update"
on public.profiles
for update
to authenticated
using (
  id = auth.uid()
)
with check (
  id = auth.uid()
);

-- =========================
-- POLÍTICAS DE TURNOS
-- =========================

create policy "workers read open shifts"
on public.shifts
for select
to authenticated
using (
  status in ('open','confirmed','active')
  or company_user_id = auth.uid()
);

create policy "companies create shifts"
on public.shifts
for insert
to authenticated
with check (
  company_user_id = auth.uid()

  and exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.account_type = 'company'
  )
);

create policy "companies update own shifts"
on public.shifts
for update
to authenticated
using (
  company_user_id = auth.uid()
)
with check (
  company_user_id = auth.uid()
);

-- =========================
-- POLÍTICAS DE POSTULACIONES
-- =========================

create policy "worker own applications read"
on public.shift_applications
for select
to authenticated
using (
  worker_user_id = auth.uid()

  or exists (
    select 1
    from public.shifts s
    where s.id = shift_id
      and s.company_user_id = auth.uid()
  )
);

create policy "worker applies self"
on public.shift_applications
for insert
to authenticated
with check (
  worker_user_id = auth.uid()

  and exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.account_type = 'worker'
  )
);

create policy "application parties update"
on public.shift_applications
for update
to authenticated
using (
  worker_user_id = auth.uid()

  or exists (
    select 1
    from public.shifts s
    where s.id = shift_id
      and s.company_user_id = auth.uid()
  )
);

-- =========================
-- POLÍTICAS DE ASISTENCIA
-- =========================

create policy "attendance parties read"
on public.attendance
for select
to authenticated
using (
  worker_user_id = auth.uid()

  or exists (
    select 1
    from public.shifts s
    where s.id = shift_id
      and s.company_user_id = auth.uid()
  )
);

create policy "worker attendance insert"
on public.attendance
for insert
to authenticated
with check (
  worker_user_id = auth.uid()
);

create policy "worker attendance update"
on public.attendance
for update
to authenticated
using (
  worker_user_id = auth.uid()
)
with check (
  worker_user_id = auth.uid()
);

-- =========================
-- POLÍTICAS DE RATINGS
-- =========================

create policy "ratings parties read"
on public.ratings
for select
to authenticated
using (
  author_user_id = auth.uid()
  or target_user_id = auth.uid()
);

create policy "ratings author insert"
on public.ratings
for insert
to authenticated
with check (
  author_user_id = auth.uid()
);

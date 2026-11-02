-- CampusHub Supabase schema
-- Run this file in Supabase Dashboard > SQL Editor.
-- IMPORTANT: Supabase Auth is the source of student identity. Never expose service_role keys in Vite.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'student' check (role in ('student', 'admin')),
  name text not null,
  school text not null,
  class text check (class in ('1','2','3','4','5','6','7','8','9','10')),
  created_at timestamptz not null default now()
);

create table if not exists public.materials (
  id uuid primary key default gen_random_uuid(),
  class text not null check (class in ('1','2','3','4','5','6','7','8','9','10')),
  subject text not null,
  type text not null check (type in ('Lectures', 'Notes', 'Videos')),
  content text not null,
  created_at timestamptz not null default now()
);

create index if not exists materials_class_created_at_idx
  on public.materials (class, created_at desc);

alter table public.profiles enable row level security;
alter table public.materials enable row level security;

-- Users can read their own profile. Students can update only non-role fields through
-- application policy design; the trigger below prevents role changes from student updates.
drop policy if exists "Users can read own profile" on public.profiles;
create policy "Users can read own profile"
  on public.profiles for select to authenticated
  using (auth.uid() = id);

drop policy if exists "Users can insert own student profile" on public.profiles;
create policy "Users can insert own student profile"
  on public.profiles for insert to authenticated
  with check (auth.uid() = id and role = 'student');

drop policy if exists "Users can update own profile fields" on public.profiles;
create policy "Users can update own profile fields"
  on public.profiles for update to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id and role = 'student');

-- Students can only see material for the class stored on their own profile.
drop policy if exists "Students can read materials for their class" on public.materials;
create policy "Students can read materials for their class"
  on public.materials for select to authenticated
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid()
        and p.role = 'student'
        and p.class = materials.class
    )
  );

-- Teacher management is intentionally based on a trusted JWT app_metadata claim.
-- Do NOT use user-editable user_metadata for admin authorization.
-- Set app_metadata.role = "admin" for a trusted teacher account using a secure
-- server-side Admin API or Supabase Dashboard. Never put a service_role key in frontend code.
drop policy if exists "Admins can manage materials" on public.materials;
create policy "Admins can manage materials"
  on public.materials for all to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
  with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

-- Admins may read profiles for classroom support.
drop policy if exists "Admins can read all profiles" on public.profiles;
create policy "Admins can read all profiles"
  on public.profiles for select to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

-- NOTE ABOUT ADMIN LOGIN:
-- The requested admin@gmail.com demo bypass in the UI is demo-only and is not
-- secure authorization. A frontend bypass cannot satisfy the JWT admin policies above.
-- For production, create a real Supabase Auth user and set app_metadata.role = 'admin'
-- from a trusted server/Admin API. Never grant admin from the browser.

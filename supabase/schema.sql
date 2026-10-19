create extension if not exists pgcrypto;
create table if not exists public.user_roles (user_id uuid primary key references auth.users(id) on delete cascade, role text not null default 'member' check (role in ('member','admin')), created_at timestamptz not null default now());
create table if not exists public.matrimonial_profiles (
 id uuid primary key default gen_random_uuid(), user_id uuid not null unique references auth.users(id) on delete cascade,
 full_name text not null check (char_length(full_name) between 2 and 100), gender text not null check (gender in ('groom','bride')),
 date_of_birth date not null check (date_of_birth <= current_date - interval '18 years'),
 marital_status text not null default 'never_married' check (marital_status in ('never_married','widowed')),
 height text check (char_length(height) <= 30), education text check (char_length(education) <= 150), profession text check (char_length(profession) <= 120),
 city text check (char_length(city) <= 100), religious_practice text check (char_length(religious_practice) <= 100), about text check (char_length(about) <= 1200),
 status text not null default 'pending' check (status in ('pending','approved','rejected')), reviewed_at timestamptz, reviewed_by uuid references auth.users(id) on delete set null,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now());
create table if not exists public.private_contacts (user_id uuid primary key references auth.users(id) on delete cascade, guardian_email text check (char_length(guardian_email) <= 254), phone text check (char_length(phone) <= 30), updated_at timestamptz not null default now());
create table if not exists public.match_requests (id uuid primary key default gen_random_uuid(), requester_id uuid not null references auth.users(id) on delete cascade, target_profile_id uuid not null references public.matrimonial_profiles(id) on delete cascade, message text check (char_length(message) <= 500), status text not null default 'pending' check (status in ('pending','accepted','declined')), created_at timestamptz not null default now(), unique(requester_id,target_profile_id));
create index if not exists profiles_approved_gender on public.matrimonial_profiles(status,gender);
create index if not exists profiles_city on public.matrimonial_profiles(city);
create index if not exists requests_requester on public.match_requests(requester_id,created_at desc);
create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from public.user_roles where user_id=auth.uid() and role='admin'); $$;
revoke all on function public.is_admin() from public, anon;
grant execute on function public.is_admin() to authenticated;
alter table public.user_roles enable row level security;
alter table public.matrimonial_profiles enable row level security;
alter table public.private_contacts enable row level security;
alter table public.match_requests enable row level security;
create policy "read own role or admin" on public.user_roles for select to authenticated using (user_id=auth.uid() or public.is_admin());
create policy "approved profiles visible to signed in users" on public.matrimonial_profiles for select to authenticated using (status='approved' or user_id=auth.uid() or public.is_admin());
create policy "create own profile" on public.matrimonial_profiles for insert to authenticated with check (user_id=auth.uid() and status='pending' and reviewed_by is null and reviewed_at is null);
create policy "edit own pending or rejected profile" on public.matrimonial_profiles for update to authenticated using (user_id=auth.uid() and status in ('pending','rejected')) with check (user_id=auth.uid() and status in ('pending','rejected') and reviewed_by is null and reviewed_at is null);
create policy "admin reviews profiles" on public.matrimonial_profiles for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "private contacts own or admin only" on public.private_contacts for all to authenticated using (user_id=auth.uid() or public.is_admin()) with check (user_id=auth.uid() or public.is_admin());
create policy "create own match request" on public.match_requests for insert to authenticated with check (requester_id=auth.uid() and exists(select 1 from public.matrimonial_profiles p where p.id=target_profile_id and p.status='approved' and p.user_id<>auth.uid()));
create policy "view requests sent by me" on public.match_requests for select to authenticated using (requester_id=auth.uid() or public.is_admin());
create policy "admin updates match requests" on public.match_requests for update to authenticated using (public.is_admin()) with check (public.is_admin());
grant usage on schema public to authenticated;
grant select on public.user_roles to authenticated;
grant select,insert,update on public.matrimonial_profiles to authenticated;
grant select,insert,update on public.private_contacts to authenticated;
grant select,insert,update on public.match_requests to authenticated;

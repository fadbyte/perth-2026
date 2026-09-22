-- Perth trip — shared travellers list
-- Paste this whole file into Supabase → SQL Editor → Run. Safe to run more than once.
-- BEFORE running: change the passcode on the line marked >>> below.

-- 1. The travellers table -------------------------------------------------
create table if not exists public.travellers (
  id           bigint generated always as identity primary key,
  family       text not null check (char_length(family) between 1 and 40),
  family_code  text check (family_code is null or char_length(family_code) <= 3),
  name         text not null check (char_length(name) between 1 and 40),
  age          int  check (age is null or age between 0 and 120),
  role         text not null check (role in ('adult', 'child')),
  sort         int  not null default 0,
  updated_at   timestamptz not null default now()
);

-- Anyone may READ. Nobody may write directly — writes only go through the
-- passcode-checked functions further down.
-- Explicit grants, so this works whether or not "Automatically expose new
-- tables" was ticked when the project was created.
grant select on public.travellers to anon, authenticated;
revoke insert, update, delete, truncate on public.travellers from anon, authenticated;
alter table public.travellers enable row level security;
drop policy if exists "public read travellers" on public.travellers;
create policy "public read travellers" on public.travellers
  for select to anon, authenticated using (true);

-- 2. The passcode, stored where the public can't read it ------------------
create table if not exists public.trip_settings (
  key   text primary key,
  value text not null
);
revoke all on public.trip_settings from anon, authenticated;
alter table public.trip_settings enable row level security;
-- No grants and no policies on purpose: the page can never read this table.

-- >>> CHANGE THIS before running. Use 8+ characters, not a birthday.
insert into public.trip_settings (key, value)
values ('edit_passcode', 'CHANGE-ME-before-running')
on conflict (key) do update set value = excluded.value;

-- 3. Functions the page calls ---------------------------------------------
create or replace function public.check_passcode(p text)
returns boolean
language sql security definer set search_path = public stable as $$
  select exists (select 1 from trip_settings where key = 'edit_passcode' and value = p);
$$;

create or replace function public.add_traveller(
  p_passcode text, p_family text, p_family_code text,
  p_name text, p_age int, p_role text)
returns bigint
language plpgsql security definer set search_path = public as $$
declare new_id bigint;
begin
  if not check_passcode(p_passcode) then
    raise exception 'Wrong passcode';
  end if;
  if (select count(*) from travellers) >= 30 then
    raise exception 'List is full (30 max)';
  end if;
  insert into travellers (family, family_code, name, age, role, sort)
  values (trim(p_family), nullif(upper(trim(coalesce(p_family_code, ''))), ''),
          trim(p_name), p_age, p_role,
          coalesce((select max(sort) + 1 from travellers where family = trim(p_family)), 0))
  returning id into new_id;
  return new_id;
end $$;

create or replace function public.update_traveller(
  p_passcode text, p_id bigint, p_family text, p_family_code text,
  p_name text, p_age int, p_role text)
returns void
language plpgsql security definer set search_path = public as $$
begin
  if not check_passcode(p_passcode) then
    raise exception 'Wrong passcode';
  end if;
  update travellers
     set family = trim(p_family),
         family_code = nullif(upper(trim(coalesce(p_family_code, ''))), ''),
         name = trim(p_name), age = p_age, role = p_role, updated_at = now()
   where id = p_id;
end $$;

create or replace function public.delete_traveller(p_passcode text, p_id bigint)
returns void
language plpgsql security definer set search_path = public as $$
begin
  if not check_passcode(p_passcode) then
    raise exception 'Wrong passcode';
  end if;
  delete from travellers where id = p_id;
end $$;

revoke all on function public.check_passcode(text) from public;
revoke all on function public.add_traveller(text, text, text, text, int, text) from public;
revoke all on function public.update_traveller(text, bigint, text, text, text, int, text) from public;
revoke all on function public.delete_traveller(text, bigint) from public;
grant execute on function public.check_passcode(text) to anon, authenticated;
grant execute on function public.add_traveller(text, text, text, text, int, text) to anon, authenticated;
grant execute on function public.update_traveller(text, bigint, text, text, text, int, text) to anon, authenticated;
grant execute on function public.delete_traveller(text, bigint) to anon, authenticated;

-- 4. Starting list — only added if the table is empty ---------------------
insert into public.travellers (family, family_code, name, age, role, sort)
select * from (values
  ('Fad Family',  'F', 'Fad',    43,        'adult', 0),
  ('Fad Family',  'F', 'Siti',   42,        'adult', 1),
  ('Fad Family',  'F', 'Kyl',    10,        'child', 2),
  ('Fad Family',  'F', 'Kyen',   7,         'child', 3),
  ('Rafi Family', 'R', 'Rafi',   null::int, 'adult', 0),
  ('Rafi Family', 'R', 'Aishah', null::int, 'adult', 1),
  ('Rafi Family', 'R', 'Nureen', 11,        'child', 2),
  ('Rafi Family', 'R', 'Naura',  9,         'child', 3),
  ('Rafi Family', 'R', 'Rates',  4,         'child', 4)
) as seed(family, family_code, name, age, role, sort)
where not exists (select 1 from public.travellers);

-- OPTIONAL: only needed if you want data shared across devices (Supabase mode).
-- Without it, cabin-ledger.html runs in local mode and saves to the browser.
--
-- Run once in your Supabase project: SQL Editor -> New query -> paste all -> Run.
-- Then: Authentication -> Users -> Add user (create a login for yourself and each person
-- who should have access), and Authentication -> Providers -> Email -> turn OFF
-- "Allow new users to sign up" so strangers can't create accounts.

create table bookings (
  id uuid primary key default gen_random_uuid(),
  guest text not null,
  phone text,
  cabin text not null,
  check_in date not null,
  check_out date not null,
  guests integer not null default 1,
  total integer not null,
  channel text,
  payment_method text,
  notes text,
  check (check_out > check_in)
);

create table expenses (
  id uuid primary key default gen_random_uuid(),
  date date not null,
  category text not null,
  description text not null,
  amount integer not null,
  accrual_months integer
);

-- key is one of: 'cabins', 'channels', 'categories'
create table config (
  key text primary key,
  items jsonb not null default '[]'::jsonb
);

-- Guest names and phone numbers are personal data, so unlike a no-login tool these
-- policies require a signed-in user. The app shows a login screen in Supabase mode.
alter table bookings enable row level security;
alter table expenses enable row level security;
alter table config enable row level security;

create policy "signed-in users - bookings" on bookings for all to authenticated using (true) with check (true);
create policy "signed-in users - expenses" on expenses for all to authenticated using (true) with check (true);
create policy "signed-in users - config" on config for all to authenticated using (true) with check (true);

-- LIEN HOA ACCOUNTING AI — initial commercial foundation
-- PostgreSQL 17 / Supabase. All monetary values use NUMERIC, never float.
create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table public.organizations (
  id uuid primary key default gen_random_uuid(),
  legal_name text not null,
  display_name text not null,
  entity_type text not null check (entity_type in ('enterprise','household_business')),
  tax_code text,
  accounting_regime text not null,
  base_currency char(3) not null default 'VND',
  fiscal_year_start_month smallint not null default 1 check (fiscal_year_start_month between 1 and 12),
  created_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.tenant_memberships (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('owner','admin','accountant','approver','viewer','auditor')),
  status text not null default 'active' check (status in ('invited','active','suspended')),
  invited_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  unique (tenant_id,user_id)
);
create index tenant_memberships_user_status_idx on public.tenant_memberships(user_id,status,tenant_id);

create table public.accounting_profiles (
  tenant_id uuid primary key references public.organizations(id) on delete cascade,
  accounting_regime text not null,
  chart_template text not null,
  fiscal_year_start_month smallint not null default 1 check (fiscal_year_start_month between 1 and 12),
  base_currency char(3) not null default 'VND',
  setup_status text not null default 'draft' check (setup_status in ('draft','ready','locked')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.fiscal_periods (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.organizations(id) on delete cascade,
  period_code text not null,
  starts_on date not null,
  ends_on date not null,
  status text not null default 'open' check (status in ('open','closing','closed')),
  closed_at timestamptz,
  closed_by uuid references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  check (ends_on >= starts_on),
  unique (tenant_id,period_code),
  unique (tenant_id,id)
);
create index fiscal_periods_tenant_dates_idx on public.fiscal_periods(tenant_id,starts_on,ends_on);

create table public.chart_of_accounts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.organizations(id) on delete cascade,
  account_code text not null,
  account_name text not null,
  account_name_en text,
  account_type text not null check (account_type in ('asset','liability','equity','revenue','expense','other_income','other_expense')),
  parent_account_id uuid,
  normal_balance text not null check (normal_balance in ('debit','credit')),
  is_postable boolean not null default true,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (tenant_id,account_code),
  unique (tenant_id,id),
  foreign key (tenant_id,parent_account_id) references public.chart_of_accounts(tenant_id,id) on delete restrict
);
create index chart_of_accounts_tenant_type_idx on public.chart_of_accounts(tenant_id,account_type,is_active);

create table public.journal_entries (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.organizations(id) on delete restrict,
  period_id uuid not null,
  entry_no text not null,
  entry_date date not null,
  description text not null,
  source_type text not null default 'manual',
  source_reference text,
  status text not null default 'draft' check (status in ('draft','posted','reversed')),
  currency char(3) not null default 'VND',
  exchange_rate numeric(20,8) not null default 1 check (exchange_rate > 0),
  created_by uuid not null references auth.users(id) on delete restrict,
  posted_by uuid references auth.users(id) on delete restrict,
  posted_at timestamptz,
  reverses_entry_id uuid references public.journal_entries(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id,entry_no),
  unique (tenant_id,id),
  foreign key (tenant_id,period_id) references public.fiscal_periods(tenant_id,id) on delete restrict
);
create index journal_entries_tenant_date_idx on public.journal_entries(tenant_id,entry_date desc);
create index journal_entries_tenant_status_idx on public.journal_entries(tenant_id,status,entry_date);

create table public.journal_lines (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  journal_entry_id uuid not null,
  line_no integer not null check (line_no > 0),
  account_id uuid not null,
  description text,
  debit numeric(20,4) not null default 0 check (debit >= 0),
  credit numeric(20,4) not null default 0 check (credit >= 0),
  created_at timestamptz not null default now(),
  check ((debit > 0 and credit = 0) or (credit > 0 and debit = 0)),
  unique (journal_entry_id,line_no),
  foreign key (tenant_id,journal_entry_id) references public.journal_entries(tenant_id,id) on delete restrict,
  foreign key (tenant_id,account_id) references public.chart_of_accounts(tenant_id,id) on delete restrict
);
create index journal_lines_tenant_account_idx on public.journal_lines(tenant_id,account_id,journal_entry_id);

create table public.audit_events (
  id bigint generated always as identity primary key,
  tenant_id uuid not null references public.organizations(id) on delete restrict,
  actor_user_id uuid references auth.users(id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create index audit_events_tenant_created_idx on public.audit_events(tenant_id,created_at desc);

create or replace function public.is_tenant_member(p_tenant_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.tenant_memberships m
    where m.tenant_id = p_tenant_id
      and m.user_id = (select auth.uid())
      and m.status = 'active'
  );
$$;

create or replace function public.has_tenant_role(p_tenant_id uuid, p_roles text[])
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.tenant_memberships m
    where m.tenant_id = p_tenant_id
      and m.user_id = (select auth.uid())
      and m.status = 'active'
      and m.role = any(p_roles)
  );
$$;

revoke all on function public.is_tenant_member(uuid) from public;
revoke all on function public.has_tenant_role(uuid,text[]) from public;
grant execute on function public.is_tenant_member(uuid) to authenticated;
grant execute on function public.has_tenant_role(uuid,text[]) to authenticated;

create or replace function public.prevent_posted_journal_mutation()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_status text;
begin
  select status into v_status
  from public.journal_entries
  where id = coalesce(old.journal_entry_id,new.journal_entry_id)
    and tenant_id = coalesce(old.tenant_id,new.tenant_id);
  if v_status is distinct from 'draft' then
    raise exception 'Posted or reversed journal lines are immutable';
  end if;
  return coalesce(new,old);
end;
$$;

create trigger journal_lines_draft_only
before insert or update or delete on public.journal_lines
for each row execute function public.prevent_posted_journal_mutation();

create or replace function public.prevent_posted_entry_mutation()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if old.status in ('posted','reversed') then
    raise exception 'Posted or reversed journal entries are immutable; use reversal workflow';
  end if;
  return new;
end;
$$;
create trigger journal_entry_immutable
before update or delete on public.journal_entries
for each row execute function public.prevent_posted_entry_mutation();

create or replace function public.post_journal(p_tenant_id uuid,p_entry_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_entry public.journal_entries%rowtype;
  v_period public.fiscal_periods%rowtype;
  v_count integer;
  v_debit numeric(20,4);
  v_credit numeric(20,4);
begin
  if not public.has_tenant_role(p_tenant_id,array['owner','admin','accountant','approver']) then
    raise exception 'Insufficient permission to post journal';
  end if;

  select * into v_entry
  from public.journal_entries
  where id = p_entry_id and tenant_id = p_tenant_id
  for update;

  if not found then raise exception 'Journal entry not found'; end if;
  if v_entry.status <> 'draft' then raise exception 'Only draft journals can be posted'; end if;

  select * into v_period
  from public.fiscal_periods
  where id = v_entry.period_id and tenant_id = p_tenant_id
  for share;

  if not found or v_period.status <> 'open' then
    raise exception 'Fiscal period is not open';
  end if;
  if v_entry.entry_date < v_period.starts_on or v_entry.entry_date > v_period.ends_on then
    raise exception 'Journal date is outside the fiscal period';
  end if;

  select count(*),coalesce(sum(debit),0),coalesce(sum(credit),0)
  into v_count,v_debit,v_credit
  from public.journal_lines
  where tenant_id = p_tenant_id and journal_entry_id = p_entry_id;

  if v_count < 2 then raise exception 'A journal requires at least two lines'; end if;
  if v_debit <= 0 or v_debit <> v_credit then
    raise exception 'Journal is not balanced: debit % / credit %',v_debit,v_credit;
  end if;

  update public.journal_entries
  set status = 'posted',posted_by = (select auth.uid()),posted_at = now(),updated_at = now()
  where id = p_entry_id and tenant_id = p_tenant_id;

  insert into public.audit_events(tenant_id,actor_user_id,action,entity_type,entity_id,metadata)
  values (p_tenant_id,(select auth.uid()),'journal.post','journal_entry',p_entry_id,
          jsonb_build_object('debit_total',v_debit,'credit_total',v_credit,'period_id',v_period.id));

  return jsonb_build_object('journal_entry_id',p_entry_id,'status','posted','debit_total',v_debit,'credit_total',v_credit);
end;
$$;

revoke all on function public.post_journal(uuid,uuid) from public;
grant execute on function public.post_journal(uuid,uuid) to authenticated;

-- Explicit grants: all access remains subject to RLS.
revoke all on public.organizations,public.tenant_memberships,public.accounting_profiles,
  public.fiscal_periods,public.chart_of_accounts,public.journal_entries,
  public.journal_lines,public.audit_events from anon,authenticated;
grant select,insert,update on public.organizations to authenticated;
grant select,insert,update,delete on public.tenant_memberships to authenticated;
grant select,insert,update on public.accounting_profiles,public.fiscal_periods,public.chart_of_accounts to authenticated;
grant select,insert,update on public.journal_entries,public.journal_lines to authenticated;
grant select on public.audit_events to authenticated;

alter table public.organizations enable row level security;
alter table public.tenant_memberships enable row level security;
alter table public.accounting_profiles enable row level security;
alter table public.fiscal_periods enable row level security;
alter table public.chart_of_accounts enable row level security;
alter table public.journal_entries enable row level security;
alter table public.journal_lines enable row level security;
alter table public.audit_events enable row level security;

create policy organizations_member_select on public.organizations
for select to authenticated using (public.is_tenant_member(id));
create policy organizations_owner_insert on public.organizations
for insert to authenticated with check (created_by = (select auth.uid()));
create policy organizations_admin_update on public.organizations
for update to authenticated using (public.has_tenant_role(id,array['owner','admin']))
with check (public.has_tenant_role(id,array['owner','admin']));

create policy memberships_member_select on public.tenant_memberships
for select to authenticated using (public.is_tenant_member(tenant_id));
create policy memberships_admin_manage on public.tenant_memberships
for all to authenticated
using (public.has_tenant_role(tenant_id,array['owner','admin']))
with check (public.has_tenant_role(tenant_id,array['owner','admin']));

create policy accounting_profiles_member on public.accounting_profiles
for select to authenticated using (public.is_tenant_member(tenant_id));
create policy accounting_profiles_admin_manage on public.accounting_profiles
for all to authenticated using (public.has_tenant_role(tenant_id,array['owner','admin']))
with check (public.has_tenant_role(tenant_id,array['owner','admin']));

create policy fiscal_periods_member_select on public.fiscal_periods
for select to authenticated using (public.is_tenant_member(tenant_id));
create policy fiscal_periods_accountant_manage on public.fiscal_periods
for all to authenticated using (public.has_tenant_role(tenant_id,array['owner','admin','accountant']))
with check (public.has_tenant_role(tenant_id,array['owner','admin','accountant']));

create policy accounts_member_select on public.chart_of_accounts
for select to authenticated using (public.is_tenant_member(tenant_id));
create policy accounts_accountant_manage on public.chart_of_accounts
for all to authenticated using (public.has_tenant_role(tenant_id,array['owner','admin','accountant']))
with check (public.has_tenant_role(tenant_id,array['owner','admin','accountant']));

create policy journals_member_select on public.journal_entries
for select to authenticated using (public.is_tenant_member(tenant_id));
create policy journals_accountant_insert on public.journal_entries
for insert to authenticated with check (
  public.has_tenant_role(tenant_id,array['owner','admin','accountant'])
  and created_by = (select auth.uid()) and status = 'draft'
);
create policy journals_draft_update on public.journal_entries
for update to authenticated using (
  status = 'draft' and public.has_tenant_role(tenant_id,array['owner','admin','accountant'])
) with check (
  status = 'draft' and public.has_tenant_role(tenant_id,array['owner','admin','accountant'])
);

create policy journal_lines_member_select on public.journal_lines
for select to authenticated using (public.is_tenant_member(tenant_id));
create policy journal_lines_draft_insert on public.journal_lines
for insert to authenticated with check (
  public.has_tenant_role(tenant_id,array['owner','admin','accountant'])
  and exists (select 1 from public.journal_entries e where e.id = journal_entry_id
    and e.tenant_id = tenant_id and e.status = 'draft')
);
create policy journal_lines_draft_update on public.journal_lines
for update to authenticated using (
  public.has_tenant_role(tenant_id,array['owner','admin','accountant'])
  and exists (select 1 from public.journal_entries e where e.id = journal_entry_id
    and e.tenant_id = tenant_id and e.status = 'draft')
) with check (
  public.has_tenant_role(tenant_id,array['owner','admin','accountant'])
);
create policy journal_lines_draft_delete on public.journal_lines
for delete to authenticated using (
  public.has_tenant_role(tenant_id,array['owner','admin','accountant'])
  and exists (select 1 from public.journal_entries e where e.id = journal_entry_id
    and e.tenant_id = tenant_id and e.status = 'draft')
);

create policy audit_events_member_select on public.audit_events
for select to authenticated using (public.is_tenant_member(tenant_id));

create trigger organizations_updated_at before update on public.organizations
for each row execute function public.set_updated_at();
create trigger accounting_profiles_updated_at before update on public.accounting_profiles
for each row execute function public.set_updated_at();
create trigger journal_entries_updated_at before update on public.journal_entries
for each row execute function public.set_updated_at();

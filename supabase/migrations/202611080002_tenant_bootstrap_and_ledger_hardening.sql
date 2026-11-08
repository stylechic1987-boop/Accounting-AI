-- Hardening patch: owner bootstrap and immutable journal-line trigger semantics.
create or replace function public.bootstrap_tenant_owner()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.tenant_memberships(tenant_id,user_id,role,status)
  values (new.id,new.created_by,'owner','active');
  return new;
end;
$$;

create trigger organizations_bootstrap_owner
after insert on public.organizations
for each row execute function public.bootstrap_tenant_owner();

create or replace function public.prevent_posted_journal_mutation()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_status text;
begin
  if tg_op = 'INSERT' then
    select e.status into v_status
    from public.journal_entries e
    where e.id = new.journal_entry_id and e.tenant_id = new.tenant_id;
    if v_status is distinct from 'draft' then
      raise exception 'Journal lines can only be inserted into draft entries';
    end if;
    return new;
  elsif tg_op = 'UPDATE' then
    select e.status into v_status
    from public.journal_entries e
    where e.id = old.journal_entry_id and e.tenant_id = old.tenant_id;
    if v_status is distinct from 'draft' then
      raise exception 'Posted or reversed journal lines are immutable';
    end if;
    select e.status into v_status
    from public.journal_entries e
    where e.id = new.journal_entry_id and e.tenant_id = new.tenant_id;
    if v_status is distinct from 'draft' then
      raise exception 'Journal lines can only be moved to draft entries';
    end if;
    return new;
  else
    select e.status into v_status
    from public.journal_entries e
    where e.id = old.journal_entry_id and e.tenant_id = old.tenant_id;
    if v_status is distinct from 'draft' then
      raise exception 'Posted or reversed journal lines are immutable';
    end if;
    return old;
  end if;
end;
$$;

drop policy if exists journal_lines_draft_insert on public.journal_lines;
create policy journal_lines_draft_insert on public.journal_lines
for insert to authenticated with check (
  public.has_tenant_role(journal_lines.tenant_id,array['owner','admin','accountant'])
  and exists (
    select 1 from public.journal_entries e
    where e.id = journal_lines.journal_entry_id
      and e.tenant_id = journal_lines.tenant_id
      and e.status = 'draft'
  )
);

drop policy if exists journal_lines_draft_update on public.journal_lines;
create policy journal_lines_draft_update on public.journal_lines
for update to authenticated using (
  public.has_tenant_role(journal_lines.tenant_id,array['owner','admin','accountant'])
  and exists (
    select 1 from public.journal_entries e
    where e.id = journal_lines.journal_entry_id
      and e.tenant_id = journal_lines.tenant_id
      and e.status = 'draft'
  )
) with check (
  public.has_tenant_role(journal_lines.tenant_id,array['owner','admin','accountant'])
  and exists (
    select 1 from public.journal_entries e
    where e.id = journal_lines.journal_entry_id
      and e.tenant_id = journal_lines.tenant_id
      and e.status = 'draft'
  )
);

drop policy if exists journal_lines_draft_delete on public.journal_lines;
create policy journal_lines_draft_delete on public.journal_lines
for delete to authenticated using (
  public.has_tenant_role(journal_lines.tenant_id,array['owner','admin','accountant'])
  and exists (
    select 1 from public.journal_entries e
    where e.id = journal_lines.journal_entry_id
      and e.tenant_id = journal_lines.tenant_id
      and e.status = 'draft'
  )
);

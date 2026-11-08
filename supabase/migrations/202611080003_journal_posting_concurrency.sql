-- Concurrency hardening: serialize journal-line edits with posting.
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
    where e.id = new.journal_entry_id and e.tenant_id = new.tenant_id
    for key share;
    if v_status is distinct from 'draft' then
      raise exception 'Journal lines can only be inserted into draft entries';
    end if;
    return new;
  elsif tg_op = 'UPDATE' then
    select e.status into v_status
    from public.journal_entries e
    where e.id = old.journal_entry_id and e.tenant_id = old.tenant_id
    for key share;
    if v_status is distinct from 'draft' then
      raise exception 'Posted or reversed journal lines are immutable';
    end if;
    select e.status into v_status
    from public.journal_entries e
    where e.id = new.journal_entry_id and e.tenant_id = new.tenant_id
    for key share;
    if v_status is distinct from 'draft' then
      raise exception 'Journal lines can only be moved to draft entries';
    end if;
    return new;
  else
    select e.status into v_status
    from public.journal_entries e
    where e.id = old.journal_entry_id and e.tenant_id = old.tenant_id
    for key share;
    if v_status is distinct from 'draft' then
      raise exception 'Posted or reversed journal lines are immutable';
    end if;
    return old;
  end if;
end;
$$;

-- Atomic tenant workspace bootstrap for authenticated users.
-- The caller cannot choose tenant owner or role: auth.uid() is always the creator.
create or replace function public.create_tenant_workspace(
  p_legal_name text,
  p_display_name text,
  p_entity_type text,
  p_tax_code text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_tenant_id uuid;
  v_regime text;
  v_chart_template text;
  v_year_start date;
begin
  if v_user_id is null then
    raise exception 'Authentication required';
  end if;

  if nullif(btrim(p_legal_name), '') is null
     or nullif(btrim(p_display_name), '') is null then
    raise exception 'Legal name and display name are required';
  end if;

  if p_entity_type not in ('enterprise', 'household_business') then
    raise exception 'Unsupported entity type';
  end if;

  if p_entity_type = 'enterprise' then
    v_regime := 'TT99_2025';
    v_chart_template := 'enterprise_tt99_2025_v1';
  else
    v_regime := 'TT152_2025';
    v_chart_template := 'household_tt152_2025_v1';
  end if;

  v_year_start := make_date(extract(year from current_date)::integer, 1, 1);

  insert into public.organizations (
    legal_name, display_name, entity_type, tax_code, accounting_regime, created_by
  ) values (
    btrim(p_legal_name),
    btrim(p_display_name),
    p_entity_type,
    nullif(btrim(coalesce(p_tax_code, '')), ''),
    v_regime,
    v_user_id
  )
  returning id into v_tenant_id;

  -- organizations_bootstrap_owner creates the owner membership in the same transaction.
  insert into public.accounting_profiles (
    tenant_id, accounting_regime, chart_template, setup_status
  ) values (
    v_tenant_id, v_regime, v_chart_template, 'draft'
  );

  insert into public.fiscal_periods (
    tenant_id, period_code, starts_on, ends_on, status
  ) values (
    v_tenant_id,
    extract(year from current_date)::integer::text,
    v_year_start,
    (v_year_start + interval '1 year - 1 day')::date,
    'open'
  );

  insert into public.audit_events (
    tenant_id, actor_user_id, action, entity_type, entity_id, metadata
  ) values (
    v_tenant_id, v_user_id, 'tenant.create', 'organization', v_tenant_id,
    jsonb_build_object('entity_type', p_entity_type, 'accounting_regime', v_regime)
  );

  return v_tenant_id;
end;
$$;

revoke all on function public.create_tenant_workspace(text,text,text,text) from public;
revoke all on function public.create_tenant_workspace(text,text,text,text) from anon;
grant execute on function public.create_tenant_workspace(text,text,text,text) to authenticated;

-- Remove anonymous execution from privileged functions.
-- Trigger execution is unaffected by revoking direct EXECUTE from API roles.
revoke all on function public.bootstrap_tenant_owner() from public, anon, authenticated;

revoke all on function public.is_tenant_member(uuid) from anon;
revoke all on function public.has_tenant_role(uuid,text[]) from anon;
revoke all on function public.post_journal(uuid,uuid) from anon;
revoke all on function public.create_tenant_workspace(text,text,text,text) from anon;

grant execute on function public.is_tenant_member(uuid) to authenticated;
grant execute on function public.has_tenant_role(uuid,text[]) to authenticated;
grant execute on function public.post_journal(uuid,uuid) to authenticated;
grant execute on function public.create_tenant_workspace(text,text,text,text) to authenticated;

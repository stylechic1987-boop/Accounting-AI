"use server";

import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export async function createWorkspace(formData: FormData) {
  const legalName = String(formData.get("legalName") || "").trim();
  const displayName = String(formData.get("displayName") || "").trim();
  const entityType = String(formData.get("entityType") || "");
  const taxCode = String(formData.get("taxCode") || "").trim();

  if (!legalName || !displayName || !["enterprise", "household_business"].includes(entityType)) {
    redirect("/onboarding?error=invalid");
  }

  const supabase = await createClient();
  const { data: claimsData, error: claimsError } = await supabase.auth.getClaims();
  if (claimsError || !claimsData?.claims) redirect("/login");

  const { data, error } = await supabase.rpc("create_tenant_workspace", {
    p_legal_name: legalName,
    p_display_name: displayName,
    p_entity_type: entityType,
    p_tax_code: taxCode || null
  });

  if (error || !data) redirect("/onboarding?error=create");
  redirect("/workspace");
}

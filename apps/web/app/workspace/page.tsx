import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { signOut } from "@/app/auth/actions";

type Organization = {
  id: string;
  legal_name: string;
  display_name: string;
  entity_type: "enterprise" | "household_business";
  accounting_regime: string;
};

export default async function WorkspacePage() {
  const supabase = await createClient();
  const { data: claimsData, error: claimsError } = await supabase.auth.getClaims();
  if (claimsError || !claimsData?.claims) redirect("/login");

  const { data, error } = await supabase
    .from("organizations")
    .select("id, legal_name, display_name, entity_type, accounting_regime")
    .order("created_at", { ascending: true });

  const organizations = (data || []) as Organization[];

  return (
    <main className="onboarding-shell">
      <header className="onboarding-top">
        <Link href="/" className="brand-inline">LIÊN HOA <span>ACCOUNTING AI</span></Link>
        <div className="top-actions"><span>{String(claimsData.claims.email || "Tài khoản")}</span><form action={signOut}><button className="text-button">Đăng xuất</button></form></div>
      </header>
      <section className="workspace-content">
        <div className="workspace-heading"><div><span className="eyebrow">KHU VỰC QUẢN TRỊ</span><h1>Đơn vị kế toán</h1><p className="auth-muted">Chọn đơn vị làm việc hoặc tạo đơn vị mới.</p></div><Link className="auth-button-link" href="/onboarding">+ Thêm đơn vị</Link></div>
        {error && <p className="form-error">Chưa tải được danh sách đơn vị. Hãy tải lại trang.</p>}
        {organizations.length === 0 ? (
          <div className="empty-state"><h2>Chưa có đơn vị nào</h2><p>Tạo hồ sơ doanh nghiệp hoặc hộ kinh doanh để bắt đầu.</p><Link className="auth-button-link" href="/onboarding">Thiết lập đơn vị đầu tiên</Link></div>
        ) : (
          <div className="organization-grid">
            {organizations.map((org) => (
              <article className="organization-card" key={org.id}>
                <span className="eyebrow">{org.entity_type === "enterprise" ? "DOANH NGHIỆP" : "HỘ KINH DOANH"}</span>
                <h2>{org.display_name}</h2><p>{org.legal_name}</p>
                <small>{org.accounting_regime} · VND</small>
                <div className="organization-id">Mã đơn vị: {org.id.slice(0, 8).toUpperCase()}</div>
                <span className="module-link">Đang khởi tạo nghiệp vụ</span>
              </article>
            ))}
          </div>
        )}
      </section>
    </main>
  );
}

import { redirect } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { createWorkspace } from "./actions";
import { signOut } from "@/app/auth/actions";

export default async function OnboardingPage({ searchParams }: { searchParams: Promise<{ error?: string }> }) {
  const supabase = await createClient();
  const { data, error } = await supabase.auth.getClaims();
  if (error || !data?.claims) redirect("/login");
  const { error: formError } = await searchParams;

  return (
    <main className="onboarding-shell">
      <header className="onboarding-top"><Link href="/workspace" className="brand-inline">LIÊN HOA <span>ACCOUNTING AI</span></Link><form action={signOut}><button className="text-button">Đăng xuất</button></form></header>
      <section className="onboarding-card">
        <span className="eyebrow">THIẾT LẬP KHÔNG GIAN KẾ TOÁN</span>
        <h1>Tạo đơn vị đầu tiên</h1>
        <p className="auth-muted">Chọn đúng loại hình để hệ thống áp dụng bộ quy tắc kế toán riêng. Có thể bổ sung chi tiết sau.</p>
        {formError && <p className="form-error">Không thể tạo đơn vị. Kiểm tra thông tin và thử lại.</p>}
        <form action={createWorkspace} className="auth-form">
          <label htmlFor="entityType">Loại hình</label>
          <select id="entityType" name="entityType" defaultValue="enterprise" required>
            <option value="enterprise">Doanh nghiệp</option>
            <option value="household_business">Hộ kinh doanh</option>
          </select>
          <label htmlFor="legalName">Tên pháp lý</label>
          <input id="legalName" name="legalName" placeholder="Tên trên giấy đăng ký kinh doanh" required />
          <label htmlFor="displayName">Tên hiển thị</label>
          <input id="displayName" name="displayName" placeholder="Tên dùng trong phần mềm" required />
          <label htmlFor="taxCode">Mã số thuế (nếu có)</label>
          <input id="taxCode" name="taxCode" inputMode="numeric" />
          <button type="submit">Tạo không gian kế toán</button>
        </form>
        <p className="onboarding-note">Doanh nghiệp và hộ kinh doanh được tách bộ quy tắc; dữ liệu được cô lập theo từng đơn vị.</p>
      </section>
    </main>
  );
}

import Link from "next/link";
import { signIn } from "@/app/auth/actions";

const messages: Record<string, string> = {
  missing: "Vui lòng nhập email và mật khẩu.",
  credentials: "Email hoặc mật khẩu chưa chính xác.",
  confirmation: "Liên kết xác thực không hợp lệ hoặc đã hết hạn."
};

export default async function LoginPage({ searchParams }: { searchParams: Promise<{ error?: string }> }) {
  const { error } = await searchParams;
  return (
    <main className="auth-shell">
      <section className="auth-brand">
        <div className="brand-mark">LH</div>
        <p className="eyebrow gold">LIÊN HOA GLOBAL EDUCATION</p>
        <h1>ACCOUNTING AI</h1>
        <p>Nền tảng kế toán và quản trị tài chính dành cho doanh nghiệp Việt Nam.</p>
        <span className="auth-foot">SECURE BUSINESS FINANCE PLATFORM</span>
      </section>
      <section className="auth-panel">
        <div className="auth-card">
          <span className="eyebrow">KHÔNG GIAN LÀM VIỆC</span>
          <h2>Đăng nhập</h2>
          <p className="auth-muted">Truy cập hệ thống kế toán Liên Hoa.</p>
          {error && <p className="form-error" role="alert">{messages[error] || "Không thể đăng nhập. Vui lòng thử lại."}</p>}
          <form action={signIn} className="auth-form">
            <label htmlFor="email">Email</label>
            <input id="email" name="email" type="email" autoComplete="email" required />
            <label htmlFor="password">Mật khẩu</label>
            <input id="password" name="password" type="password" autoComplete="current-password" required />
            <button type="submit">Đăng nhập hệ thống</button>
          </form>
          <p className="auth-switch">Chưa có tài khoản? <Link href="/signup">Đăng ký</Link></p>
          <Link className="back-link" href="/">← Trang giới thiệu</Link>
        </div>
      </section>
    </main>
  );
}

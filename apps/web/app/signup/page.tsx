import Link from "next/link";
import { signUp } from "@/app/auth/actions";

export default async function SignupPage({ searchParams }: { searchParams: Promise<{ error?: string }> }) {
  const { error } = await searchParams;
  return (
    <main className="auth-shell">
      <section className="auth-brand">
        <div className="brand-mark">LH</div>
        <p className="eyebrow gold">LIÊN HOA GLOBAL EDUCATION</p>
        <h1>ACCOUNTING AI</h1>
        <p>Tạo tài khoản quản trị, sau đó thiết lập doanh nghiệp hoặc hộ kinh doanh của bạn.</p>
        <span className="auth-foot">SECURE BUSINESS FINANCE PLATFORM</span>
      </section>
      <section className="auth-panel">
        <div className="auth-card">
          <span className="eyebrow">BẮT ĐẦU SỬ DỤNG</span>
          <h2>Tạo tài khoản</h2>
          <p className="auth-muted">Dùng email công việc để đăng ký.</p>
          {error && <p className="form-error" role="alert">Thông tin chưa hợp lệ hoặc email đã được sử dụng. Mật khẩu tối thiểu 10 ký tự.</p>}
          <form action={signUp} className="auth-form">
            <label htmlFor="fullName">Họ và tên</label>
            <input id="fullName" name="fullName" autoComplete="name" required />
            <label htmlFor="email">Email</label>
            <input id="email" name="email" type="email" autoComplete="email" required />
            <label htmlFor="password">Mật khẩu</label>
            <input id="password" name="password" type="password" minLength={10} autoComplete="new-password" required />
            <button type="submit">Tạo tài khoản</button>
          </form>
          <p className="auth-switch">Đã có tài khoản? <Link href="/login">Đăng nhập</Link></p>
          <Link className="back-link" href="/">← Trang giới thiệu</Link>
        </div>
      </section>
    </main>
  );
}

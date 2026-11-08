import Link from "next/link";

export default function CheckEmailPage() {
  return (
    <main className="auth-shell">
      <section className="auth-panel auth-panel-full">
        <div className="auth-card">
          <span className="eyebrow">XÁC THỰC TÀI KHOẢN</span>
          <h2>Kiểm tra email</h2>
          <p className="auth-muted">Liên Hoa đã gửi liên kết xác thực. Mở email, xác nhận tài khoản rồi quay lại đăng nhập.</p>
          <Link className="auth-button-link" href="/login">Đi tới đăng nhập</Link>
        </div>
      </section>
    </main>
  );
}

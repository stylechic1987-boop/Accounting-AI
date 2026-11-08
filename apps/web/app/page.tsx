const modules = [
  ["Sổ cái", "Hệ thống tài khoản, nhật ký chung và bút toán"],
  ["Chứng từ", "Tiếp nhận, kiểm tra và phê duyệt chứng từ"],
  ["Tiền & ngân hàng", "Thu chi, sao kê và đối chiếu"],
  ["Bán hàng & công nợ", "Hóa đơn, phải thu và phải trả"],
  ["Kho hàng", "Nhập xuất, tồn kho và giá vốn"],
  ["Thuế & hóa đơn", "Hồ sơ theo kỳ và kết nối đối tác"],
  ["AI kế toán", "Đọc chứng từ và đề xuất định khoản"],
  ["Quản trị doanh nghiệp", "Người dùng, phân quyền và chi nhánh"]
];

export default function Home() {
  return (
    <main className="shell">
      <aside className="sidebar">
        <div className="brand-mark">LH</div>
        <div className="brand-name">LIÊN HOA <span>ACCOUNTING AI</span></div>
        <div className="side-label">KHÔNG GIAN LÀM VIỆC</div>
        <button className="nav-item active">Tổng quan</button>
        <button className="nav-item">Kế toán</button>
        <button className="nav-item">Tài chính</button>
        <button className="nav-item">Thuế & hóa đơn</button>
        <button className="nav-item">Trợ lý AI</button>
        <button className="nav-item">Quản trị</button>
        <div className="sidebar-foot">COMMERCIAL FOUNDATION · 0.1.0</div>
      </aside>
      <section className="workspace">
        <header className="topbar">
          <div><span className="eyebrow">NỀN TẢNG QUẢN TRỊ TÀI CHÍNH</span><h1>Tổng quan</h1></div>
          <div className="auth-entry"><a href="/login">Đăng nhập</a><a href="/signup">Tạo tài khoản</a></div>
        </header>
        <section className="welcome">
          <div>
            <span className="eyebrow gold">LIÊN HOA GLOBAL EDUCATION</span>
            <h2>Nền tảng kế toán<br />cho doanh nghiệp Việt.</h2>
            <p>Không gian thương mại đang được khởi tạo. Đăng ký tài khoản để tạo hồ sơ doanh nghiệp hoặc hộ kinh doanh. Dữ liệu kế toán chỉ được truy cập theo quyền của từng đơn vị.</p>
          </div>
          <div className="welcome-symbol">LH<span>ACCOUNTING AI</span></div>
        </section>
        <div className="section-heading"><div><span className="eyebrow">HỆ THỐNG PHÂN HỆ</span><h2>Các nghiệp vụ chính</h2></div><span className="status">ĐANG PHÁT TRIỂN</span></div>
        <div className="module-grid">
          {modules.map(([title, description], index) => (
            <article className="module-card" key={title}>
              <div className="module-index">{String(index + 1).padStart(2, "0")}</div>
              <h3>{title}</h3>
              <p>{description}</p>
              <span className="module-link">Sắp triển khai <b>↗</b></span>
            </article>
          ))}
        </div>
        <footer>© LIÊN HOA ACCOUNTING AI · NỀN TẢNG THUỘC SỞ HỮU LIÊN HOA GLOBAL EDUCATION</footer>
      </section>
    </main>
  );
}

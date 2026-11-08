# LIÊN HOA ACCOUNTING AI — Investor Demo

Bản demo giao diện web tương tác phục vụ giới thiệu sản phẩm và trao đổi với nhà đầu tư.

## Chạy thử
- Mở `index.html` trực tiếp bằng trình duyệt; không cần cài đặt package.
- Hoặc bật GitHub Pages từ Settings → Pages → Deploy from a branch → `main` → `/ (root)`.

## Các khu vực trình diễn
- Dashboard tổng quan tài chính
- Chứng từ kế toán
- Thu chi và ngân hàng
- Bán hàng và công nợ
- Hàng tồn kho
- Sổ sách và báo cáo
- Trợ lý AI kế toán (mô phỏng)
- Trung tâm thuế (mô phỏng)
- Đối tác và White-label

## Phạm vi và giới hạn
Đây là **prototype giao diện**, không phải phần mềm kế toán vận hành. Số liệu, chứng từ, khách hàng, đối tác và trạng thái đều là dữ liệu giả lập. Chưa có backend, đăng nhập, cơ sở dữ liệu, AI thật, chữ ký số, kết nối ngân hàng, hóa đơn điện tử hay kết nối cơ quan thuế.

Các tích hợp thuế, hóa đơn điện tử, chữ ký số, ngân hàng và BHXH cần được triển khai thông qua nhà cung cấp/đối tác phù hợp, có hợp đồng, quyền truy cập và kiểm thử. Không sử dụng bản demo để ghi sổ, kê khai hoặc nộp thuế thực tế.

## Định hướng kiến trúc bản thương mại
- Web: Next.js + TypeScript
- Mobile: React Native / Expo
- Backend: NestJS modular monolith
- Database: PostgreSQL, tenant isolation và audit trail
- Integration Hub: adapter cho đối tác hóa đơn điện tử, T-VAN, CA và ngân hàng
- AI: OCR và trợ lý kế toán theo nguyên tắc AI đề xuất, người có thẩm quyền phê duyệt

## Thương hiệu và sở hữu
Sản phẩm định hướng do LIÊN HOA GLOBAL EDUCATION phát triển và sở hữu nền tảng lõi. Mô hình SaaS và White-label sẽ được hoàn thiện sau giai đoạn kiểm chứng sản phẩm, nghiệp vụ, pháp lý và bảo mật.

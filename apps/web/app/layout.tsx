import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "LIÊN HOA ACCOUNTING AI",
  description: "Nền tảng kế toán, tài chính và thuế thông minh cho doanh nghiệp Việt Nam."
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="vi">
      <body>{children}</body>
    </html>
  );
}

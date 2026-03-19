# Hướng dẫn Triển khai ThinkAI Frontend (Next.js) lên Vercel

Tài liệu này hướng dẫn chi tiết các bước để đưa giao diện người dùng (Frontend) lên môi trường Production sử dụng Vercel.

## 1. Chuẩn bị trước khi triển khai
- **Repository:** Code đã được push lên GitHub (nhánh `main`).
- **Backend URL:** Đảm bảo Backend đã chạy trên Oracle Cloud tại địa chỉ `http://159.13.48.35:8081`.
- **Google Client ID:** Đã chuẩn bị sẵn từ Google Cloud Console.

## 2. Quy trình triển khai trên Vercel Dashboard

### Bước 1: Import dự án
1. Truy cập [Vercel Dashboard](https://vercel.com/dashboard).
2. Nhấn **Add New** -> **Project**.
3. Kết nối với GitHub và chọn repository `thinkai-frontend`.

### Bước 2: Cấu hình Biến môi trường (Environment Variables)
Trong mục **Environment Variables**, bạn PHẢI thêm các biến sau:
- `NEXT_PUBLIC_API_URL`: `http://159.13.48.35:8081` (Đây là địa chỉ Backend chúng ta vừa tạo trên OCI).
- `NEXT_PUBLIC_GOOGLE_CLIENT_ID`: Dán ID Client của bạn vào đây.

> [!IMPORTANT]
> Lưu ý không được có dấu gạch chéo `/` ở cuối URL của API.

### Bước 3: Deploy
1. Giữ nguyên các cấu hình Build (Next.js tự động nhận diện).
2. Nhấn nút **Deploy**. 
3. Sau khoảng 1-2 phút, bạn sẽ nhận được một domain miễn phí (ví dụ: `thinkai-frontend.vercel.app`).

## 3. Cấu hình Google Cloud Console (Bắt buộc nếu dùng Login)
Sau khi có domain từ Vercel, bạn phải cập nhật lại cấu hình trong [Google Cloud Console](https://console.cloud.google.com/):

1. Vào mục **APIs & Services** -> **Credentials**.
2. Sửa Client ID đang dùng.
3. **Authorized JavaScript origins:** Thêm URL của Vercel (ví dụ: `https://thinkai-frontend.vercel.app`).
4. **Authorized redirect URIs:** Thêm `https://thinkai-frontend.vercel.app/api/auth/callback/google`.

## 4. Kiểm tra cục bộ trước khi Push
Chạy lệnh sau trên máy Fedora để đảm bảo code không có lỗi build:
```bash
npm run build
```
Nếu hiện "Export successful", bạn có thể yên tâm push code.

---
*Cập nhật lần cuối: 17/03/2026*

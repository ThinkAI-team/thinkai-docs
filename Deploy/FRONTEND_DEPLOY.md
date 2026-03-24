# Hướng dẫn Triển khai ThinkAI Frontend (Next.js) lên Vercel

Tài liệu này hướng dẫn chi tiết các bước để đưa giao diện người dùng (Frontend) lên môi trường Production sử dụng Vercel.

## 1. Chuẩn bị trước khi triển khai

- **Repository:** Code đã được push lên GitHub (nhánh `main`).
- **Backend URL:** Đảm bảo Backend đã chạy trên Railway tại địa chỉ `https://thinkai-backend-production.up.railway.app`.
- **Google Client ID:** Đã chuẩn bị sẵn từ Google Cloud Console.

## 2. Quy trình triển khai trên Vercel Dashboard

### Bước 1: Import dự án
1. Truy cập [Vercel Dashboard](https://vercel.com/dashboard).
2. Nhấn **Add New** -> **Project**.
3. Kết nối với GitHub và chọn repository `thinkai-frontend`.

### Bước 2: Cấu hình Biến môi trường (Environment Variables)
Trong mục **Environment Variables**, bạn PHẢI thêm các biến sau:

| Variable | Value |
|----------|-------|
| `NEXT_PUBLIC_API_URL` | `https://thinkai-backend-production.up.railway.app` |
| `NEXT_PUBLIC_GOOGLE_CLIENT_ID` | `<YOUR_GOOGLE_CLIENT_ID>` |

> [!IMPORTANT]
> - **PHẢI** có `https://` đầy đủ trong API URL (không có sẽ bị lỗi 404)
> - Không được có dấu gạch chéo `/` ở cuối URL của API

### Bước 3: Deploy
1. Giữ nguyên các cấu hình Build (Next.js tự động nhận diện).
2. Nhấn nút **Deploy**.
3. Sau khoảng 1-2 phút, bạn sẽ nhận được một domain miễn phí (ví dụ: `thinkai-frontend-psi.vercel.app`).

### Bước 4: Redeploy sau khi thay đổi Environment Variables
Mỗi khi thay đổi biến môi trường (đặc biệt `NEXT_PUBLIC_API_URL`):
1. Vào **Deployments** tab
2. Click **Redeploy** ở bản gần nhất
3. Chờ deploy hoàn tất

## 3. Cấu hình Google Cloud Console (Bắt buộc nếu dùng Login)

Sau khi có domain từ Vercel, bạn phải cập nhật lại cấu hình trong [Google Cloud Console](https://console.cloud.google.com/):

1. Vào mục **APIs & Services** -> **Credentials**.
2. Sửa Client ID đang dùng.
3. **Authorized JavaScript origins:** Thêm URL của Vercel (ví dụ: `https://thinkai-frontend-psi.vercel.app`).
4. **Authorized redirect URIs:** Thêm `https://thinkai-frontend-psi.vercel.app/api/auth/callback/google`.

## 4. Kiểm tra cục bộ trước khi Push

Chạy lệnh sau trên máy để đảm bảo code không có lỗi build:
```bash
cd /home/binhminh/Developer/DA/thinkai-frontend
npm run build
```
Nếu hiện "Export successful", bạn có thể yên tâm push code.

## 5. Xử lý sự cố

### Lỗi "JSON.parse: unexpected character"
- Kiểm tra `NEXT_PUBLIC_API_URL` trong Vercel - phải có `https://` đầy đủ
- Redeploy frontend sau khi thay đổi biến

### Kiểm tra Network trong DevTools
1. Mở trình duyệt, bấm **F12** -> tab **Network**
2. Thực hiện đăng nhập
3. Request phải đi đến: `https://thinkai-backend-production.up.railway.app/...`
- Nếu request đi đến `thinkai-frontend-psi.vercel.app/...` -> chưa đúng API URL

---
*Cập nhật lần cuối: 24/03/2026*

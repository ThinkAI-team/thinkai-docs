# Hướng dẫn Triển khai ThinkAI Backend lên Railway

Tài liệu này hướng dẫn các bước để triển khai ThinkAI Backend lên Railway với database Aiven MySQL.

## 1. Thông tin hạ tầng

- **Backend:** Railway - `thinkai-backend-production.up.railway.app`
- **Database:** Aiven MySQL - `thinkai-database-thinkai-db.c.aivencloud.com:25733`
- **Port:** 8081

## 2. Quy trình Triển khai Backend lên Railway

### Bước 1: Cập nhật code (nếu cần)

```bash
cd /home/binhminh/Developer/DA/thinkai-backend

# Pull code mới nhất
git pull origin main
```

### Bước 2: Build Docker Image

```bash
docker build -t minhtuyetvoi/thinkai-backend:latest .
```

### Bước 3: Push lên Docker Hub

```bash
docker push minhtuyetvoi/thinkai-backend:latest
```

### Bước 4: Deploy trên Railway

1. Truy cập [Railway Dashboard](https://railway.app/dashboard)
2. Chọn project **ThinkAI**
3. Click **Deploy** để pull image mới từ Docker Hub

### Bước 5: Cấu hình Environment Variables trên Railway

Vào **Railway Dashboard** → Backend Service → **Variables**, đảm bảo có:

| Variable | Value |
|----------|-------|
| `DB_URL` | `jdbc:mysql://avnadmin:YOUR_PASSWORD@thinkai-database-thinkai-db.c.aivencloud.com:25733/defaultdb?ssl-mode=REQUIRED` |
| `DB_USERNAME` | `avnadmin` |
| `DB_PASSWORD` | `<YOUR_AIVEN_PASSWORD>` |
| `JWT_SECRET` | `<JWT_SECRET_MIN_32_CHARS>` |
| `SPRING_PROFILES_ACTIVE` | `staging` |
| `GOOGLE_CLIENT_ID` | `<YOUR_GOOGLE_CLIENT_ID>` |
| `MAIL_USERNAME` | `<YOUR_GMAIL>` |
| `MAIL_PASSWORD` | `<YOUR_GMAIL_APP_PASSWORD>` |
| `MAIL_HOST` | `smtp.gmail.com` |
| `MAIL_PORT` | `587` |
| `FRONTEND_URL` | `https://thinkai-frontend-psi.vercel.app` |
| `CORS_ORIGINS` | `https://thinkai-frontend-psi.vercel.app` |
| `PORT` | `8081` |
| `SPRING_JPA_HIBERNATE_DDL_AUTO` | `update` |

### Bước 6: Kiểm tra Backend

Sau khi deploy, kiểm tra tại:
- `https://thinkai-backend-production.up.railway.app/actuator/health`

---

## 3. Database Aiven MySQL

### Thông tin kết nối

- **Host:** `thinkai-database-thinkai-db.c.aivencloud.com`
- **Port:** 25733
- **Database:** `defaultdb`
- **User:** `avnadmin`
- **Password:** Lấy từ Aiven Dashboard → ThinkAI Database → Get Password

### Lưu ý

- `ddl-auto: update` đã được cấu hình trong `application-staging.yml`, Hibernate sẽ tự tạo các bảng khi ứng dụng khởi động.
- Nếu cần import schema thủ công, xem file `thinkai-docs/database/thinkai_schema.sql`

---

## 4. Xử lý sự cố

### Lỗi "Access denied for user 'avnadmin'"
- Kiểm tra lại DB_PASSWORD trong Railway
- Đảm bảo user có quyền truy cập database trên Aiven

### Lỗi JWT "key byte array is 184 bits"
- JWT_SECRET phải có độ dài ≥32 ký tự (≥256 bits)
- Tạo secret mới và cập nhật trong Railway

### Lỗi CORS
- Đảm bảo `CORS_ORIGINS` trong Railway trùng với frontend URL

---
*Cập nhật lần cuối: 24/03/2026*

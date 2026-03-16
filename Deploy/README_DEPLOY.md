# Hướng dẫn Triển khai ThinkAI Backend lên Oracle Cloud

Tài liệu này tổng hợp các bước cần thiết để đưa mã nguồn từ GitHub lên máy chủ Oracle Cloud sau khi kết thúc quá trình phát triển.

## 1. Thông tin hạ tầng đã thiết lập
- **IP Public của Backend:** `159.13.48.35`
- **Hệ điều hành:** Ubuntu 24.04 LTS
- **User truy cập:** `ubuntu`
- **SSH Key:** `/home/binhminh/Downloads/ssh-key-2026-03-16.key` (đã chmod 400)

## 2. Quy trình Triển khai (Sau khi Merge Main)

### Bước 1: SSH vào máy chủ
Mở terminal trên Fedora và gõ:
```bash
ssh -i /home/binhminh/Downloads/ssh-key-2026-03-16.key ubuntu@159.13.48.35
```

### Bước 2: Cập nhật mã nguồn
```bash
# Lần đầu tiên
git clone <URL_GITHUB_BACKEND_CUA_BAN>
cd thinkai-backend

# Những lần sau
git pull origin main
```

### Bước 3: Cấu hình Biến môi trường (.env)
Tạo hoặc sửa file `.env` trong thư mục dự án:
```bash
nano .env
```
Nội dung cần điền:
```env
DB_URL=jdbc:mysql://<IP_NỘI_BỘ_DATABASE>:3306/thinkai_db?useSSL=false&allowPublicKeyRetrieval=true
DB_USERNAME=<USERNAME_DATABSE>
DB_PASSWORD=<PASSWORD_DATABASE>
JWT_SECRET=<CHUỖI_BẢO_MẬT_BẤT_KỲ>
```

### Bước 4: Chạy ứng dụng bằng Docker
```bash
# Dừng container cũ (nếu có)
docker compose down

# Build và chạy lại
docker compose up -d --build
```

## 3. Các cấu hình mạng cần lưu ý (OCI Console)

### Security List (Public Subnet)
- Phải mở cổng **22** (TCP) cho IP của bạn (đã làm).
- Phải mở cổng **8081** (TCP) cho `0.0.0.0/0` để cho phép truy cập API từ Internet.

### Security List (Private Subnet - Database)
- Phải mở cổng **3306** (TCP) cho nguồn từ `10.0.0.0/16` (để Backend gọi được Database).

---
*Cập nhật lần cuối: 17/03/2026*

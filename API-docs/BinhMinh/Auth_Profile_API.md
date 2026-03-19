# 📋 ThinkAI — API Documentation: Authentication & User Profile
**Thành viên:** Bình Minh  
**Module:** Authentication & User Profile  
**Base URL:** `http://localhost:8081`  
**Auth:** `Authorization: Bearer <access_token>` (trừ Auth endpoints)  
**Last Updated:** 2026-03-19

---

## 📌 Tổng quan 5 tính năng

| # | Tính năng | Mô tả | Số API |
|---|-----------|-------|--------|
| 1 | Đăng ký tài khoản | Tạo tài khoản mới (mặc định role STUDENT) | 1 |
| 2 | Đăng nhập | Xác thực email/password, trả JWT token | 1 |
| 3 | Đăng nhập Google OAuth | Đăng nhập bằng tài khoản Google | 1 |
| 4 | Quên / Đặt lại mật khẩu | Gửi email reset link + xử lý đặt lại | 2 |
| 5 | Xem & Cập nhật hồ sơ | Xem và chỉnh sửa thông tin cá nhân | 2 |
| 6 | Đổi mật khẩu | Đổi mật khẩu khi đã đăng nhập | 1 |

---

## ① Đăng ký tài khoản

### 1.1 Đăng ký

| Field | Value |
|-------|-------|
| **Method** | `POST` |
| **Endpoint** | `/auth/register` |
| **Auth** | Public |

**Request Body:**
```json
{
  "firstName": "Bình",
  "lastName": "Minh",
  "email": "binhminh@thinkai.com",
  "password": "Password@123",
  "confirmPassword": "Password@123"
}
```

| Field | Type | Validation | Mô tả |
|-------|------|------------|-------|
| `firstName` | String | @NotBlank, max 50 | Họ |
| `lastName` | String | @NotBlank, max 50 | Tên |
| `email` | String | @NotBlank, @Email | Email đăng ký |
| `password` | String | @NotBlank, min 8 | Mật khẩu |
| `confirmPassword` | String | @NotBlank | Xác nhận mật khẩu |

**Response `200 OK`:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "email": "binhminh@thinkai.com",
  "fullName": "Bình Minh",
  "role": "STUDENT"
}
```

**Business Logic:**
1. Validate `password == confirmPassword` → `400` nếu không khớp
2. Normalize email: `trim().toLowerCase()`
3. Check email chưa tồn tại → `409` nếu trùng
4. Hash password bằng BCrypt
5. Tạo user với `role = STUDENT`, `isActive = true`
6. Generate JWT token chứa `email`, `role`, `fullName`

**Error Responses:**
| Status | Message |
|--------|---------|
| `400` | Mật khẩu xác nhận không khớp |
| `409` | Email đã được sử dụng |

### Files

| File | Type |
|------|------|
| `dto/RegisterRequest.java` | DTO đăng ký với validation |
| `dto/AuthResponse.java` | DTO response chứa token + user info |
| `service/AuthService.java` | register() |
| `controller/AuthController.java` | POST /auth/register |

---

## ② Đăng nhập

### 2.1 Đăng nhập

| Field | Value |
|-------|-------|
| **Method** | `POST` |
| **Endpoint** | `/auth/login` |
| **Auth** | Public |

**Request Body:**
```json
{
  "email": "binhminh@thinkai.com",
  "password": "Password@123"
}
```

| Field | Type | Validation | Mô tả |
|-------|------|------------|-------|
| `email` | String | @NotBlank, @Email | Email đăng nhập |
| `password` | String | @NotBlank | Mật khẩu |

**Response `200 OK`:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "email": "binhminh@thinkai.com",
  "fullName": "Bình Minh",
  "role": "STUDENT"
}
```

**Business Logic:**
1. Tìm user bằng email (normalize trước) → `401` nếu không tìm thấy
2. Check `isActive == true` → `403` nếu bị khóa
3. Verify password bằng BCrypt → `401` nếu sai
4. Generate JWT token
5. **Security:** Login sai email hoặc password đều trả cùng 1 message → chống enumeration

**Error Responses:**
| Status | Message |
|--------|---------|
| `401` | Email hoặc mật khẩu không đúng |
| `403` | Tài khoản đã bị khóa |

### Files

| File | Type |
|------|------|
| `dto/LoginRequest.java` | DTO đăng nhập |
| `dto/AuthResponse.java` | DTO response |
| `service/AuthService.java` | login() |
| `controller/AuthController.java` | POST /auth/login |

---

## ③ Đăng nhập Google OAuth

### 3.1 Đăng nhập Google

| Field | Value |
|-------|-------|
| **Method** | `POST` |
| **Endpoint** | `/auth/google` |
| **Auth** | Public |

**Request Body:**
```json
{
  "idToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

| Field | Type | Validation | Mô tả |
|-------|------|------------|-------|
| `idToken` | String | @NotBlank | Google ID Token từ frontend |

**Response `200 OK`:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "email": "binhminh@gmail.com",
  "fullName": "Bình Minh",
  "role": "STUDENT",
  "hasPassword": false,
  "isGoogleUser": true,
  "avatarUrl": "https://lh3.googleusercontent.com/..."
}
```

| Field | Type | Mô tả |
|-------|------|-------|
| `token` | String | JWT token |
| `email` | String | Email Google |
| `fullName` | String | Tên từ Google |
| `role` | String | Vai trò (mặc định STUDENT) |
| `hasPassword` | Boolean | User có password hay không |
| `isGoogleUser` | Boolean | User đăng nhập bằng Google |
| `avatarUrl` | String | Ảnh đại diện Google |

**Business Logic:**
1. Verify ID token với Google (sử dụng GoogleIdTokenVerifier)
2. Lấy thông tin user từ token (email, name, picture)
3. Tìm user theo `googleId` - nếu chưa có → tạo mới
4. Nếu email đã tồn tại (đăng ký bằng email trước đó) → liên kết Google vào tài khoản hiện có
5. Check `isActive == true` → `403` nếu bị khóa
6. Generate JWT token

**Config Required:**
```properties
google.client-id=YOUR_GOOGLE_CLIENT_ID
```

**Error Responses:**
| Status | Message |
|--------|---------|
| `401` | Google token không hợp lệ hoặc đã hết hạn |
| `403` | Tài khoản đã bị khóa |
| `503` | Google OAuth chưa được cấu hình |

### Files

| File | Type |
|------|------|
| `dto/GoogleLoginRequest.java` | DTO Google login |
| `service/GoogleAuthService.java` | loginWithGoogle() |
| `controller/AuthController.java` | POST /auth/google |

### 3.2 Lấy thông tin user hiện tại

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Endpoint** | `/auth/me` |
| **Auth** | Bearer Token (Authenticated) |

**Response `200 OK`:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "email": "binhminh@thinkai.com",
  "fullName": "Bình Minh",
  "role": "STUDENT",
  "hasPassword": true,
  "isGoogleUser": false
}
```

**Business Logic:** Lấy thông tin user từ token đang登录 (dùng cho kiểm tra trạng thái auth)

---

## ④ Quên / Đặt lại mật khẩu

### 3.1 Quên mật khẩu (Gửi email reset)

| Field | Value |
|-------|-------|
| **Method** | `POST` |
| **Endpoint** | `/auth/forgot-password` |
| **Auth** | Public |

**Request Body:**
```json
{
  "email": "binhminh@thinkai.com"
}
```

| Field | Type | Validation | Mô tả |
|-------|------|------------|-------|
| `email` | String | @NotBlank, @Email | Email đã đăng ký |

**Response `200 OK`:**
```json
{
  "message": "Nếu email tồn tại, chúng tôi đã gửi link đặt lại mật khẩu."
}
```

**Business Logic:**
1. Luôn trả `200` dù email có tồn tại hay không → chống enumeration
2. Nếu email tồn tại → kiểm tra rate limit (max 3 lần/giờ)
3. Tạo token UUID, hạn 30 phút
4. Gửi email chứa reset link đến người dùng

**Error Responses:**
| Status | Message |
|--------|---------|
| `429` | Bạn đã yêu cầu quá nhiều lần. Vui lòng thử lại sau 1 giờ. |

### 3.2 Đặt lại mật khẩu

| Field | Value |
|-------|-------|
| **Method** | `POST` |
| **Endpoint** | `/auth/reset-password` |
| **Auth** | Public |

**Request Body:**
```json
{
  "token": "a1b2c3d4-e5f6-...",
  "newPassword": "NewPassword@456",
  "confirmPassword": "NewPassword@456"
}
```

| Field | Type | Validation | Mô tả |
|-------|------|------------|-------|
| `token` | String | @NotBlank | Token từ email |
| `newPassword` | String | @NotBlank, min 8 | Mật khẩu mới |
| `confirmPassword` | String | @NotBlank | Xác nhận mật khẩu mới |

**Response `200 OK`:**
```json
{
  "message": "Đặt lại mật khẩu thành công. Vui lòng đăng nhập."
}
```

**Business Logic:**
1. Validate `newPassword == confirmPassword` → `400` nếu không khớp
2. Tìm token trong DB → `400` nếu không tồn tại
3. Check token chưa được sử dụng → `400` nếu đã dùng
4. Check token chưa hết hạn (30 phút) → `400` nếu hết hạn
5. Hash password mới và update user
6. Đánh dấu token `used = true`

**Error Responses:**
| Status | Message |
|--------|---------|
| `400` | Mật khẩu xác nhận không khớp |
| `400` | Link đặt lại mật khẩu không hợp lệ |
| `400` | Link đặt lại mật khẩu đã được sử dụng |
| `400` | Link đặt lại mật khẩu đã hết hạn. Vui lòng yêu cầu lại. |

### Files

| File | Type |
|------|------|
| `dto/ForgotPasswordRequest.java` | DTO quên mật khẩu |
| `dto/ResetPasswordRequest.java` | DTO đặt lại mật khẩu |
| `entity/PasswordResetToken.java` | Entity token reset |
| `repository/PasswordResetTokenRepository.java` | CRUD token + rate limit query |
| `service/PasswordResetService.java` | requestReset() + resetPassword() |
| `service/EmailService.java` | sendResetPasswordEmail() |
| `controller/AuthController.java` | POST /auth/forgot-password, POST /auth/reset-password |

---

## ⑤ Xem & Cập nhật hồ sơ

### 4.1 Xem hồ sơ cá nhân

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Endpoint** | `/users/me` |
| **Auth** | Bearer Token (Authenticated) |

**Response `200 OK`:**
```json
{
  "email": "binhminh@thinkai.com",
  "fullName": "Bình Minh",
  "phoneNumber": "0912345678",
  "avatarUrl": "https://...",
  "role": "STUDENT",
  "createdAt": "2026-03-01T10:00:00"
}
```

### 4.2 Cập nhật hồ sơ

| Field | Value |
|-------|-------|
| **Method** | `PUT` |
| **Endpoint** | `/users/me` |
| **Auth** | Bearer Token (Authenticated) |

**Request Body:**
```json
{
  "fullName": "Nguyễn Bình Minh",
  "phoneNumber": "0912345678"
}
```

| Field | Type | Validation | Mô tả |
|-------|------|------------|-------|
| `fullName` | String | @NotBlank, max 100 | Họ tên đầy đủ |
| `phoneNumber` | String | max 20 (optional) | Số điện thoại |

**Response `200 OK`:**
```json
{
  "email": "binhminh@thinkai.com",
  "fullName": "Nguyễn Bình Minh",
  "phoneNumber": "0912345678",
  "avatarUrl": "https://...",
  "role": "STUDENT",
  "createdAt": "2026-03-01T10:00:00"
}
```

**Error Responses:**
| Status | Message |
|--------|---------|
| `401` | Token không hợp lệ hoặc hết hạn |
| `404` | Không tìm thấy người dùng |

### Files

| File | Type |
|------|------|
| `dto/ProfileResponse.java` | DTO hồ sơ |
| `dto/UpdateProfileRequest.java` | DTO cập nhật hồ sơ |
| `service/UserService.java` | getProfile() + updateProfile() |
| `controller/UserController.java` | GET /users/me, PUT /users/me |

---

## ⑥ Đổi mật khẩu

### 5.1 Đổi mật khẩu

| Field | Value |
|-------|-------|
| **Method** | `PUT` |
| **Endpoint** | `/users/me/password` |
| **Auth** | Bearer Token (Authenticated) |

**Request Body:**
```json
{
  "currentPassword": "Password@123",
  "newPassword": "NewPassword@456",
  "confirmNewPassword": "NewPassword@456"
}
```

| Field | Type | Validation | Mô tả |
|-------|------|------------|-------|
| `currentPassword` | String | @NotBlank | Mật khẩu hiện tại |
| `newPassword` | String | @NotBlank, min 8 | Mật khẩu mới |
| `confirmNewPassword` | String | @NotBlank | Xác nhận mật khẩu mới |

**Response `200 OK`:**
```json
{
  "message": "Đổi mật khẩu thành công"
}
```

**Business Logic:**
1. Validate `newPassword == confirmNewPassword` → `400` nếu không khớp
2. Validate mật khẩu mới khác mật khẩu hiện tại → `400` nếu giống
3. Verify mật khẩu hiện tại bằng BCrypt → `400` nếu sai
4. Hash và update mật khẩu mới

**Error Responses:**
| Status | Message |
|--------|---------|
| `400` | Mật khẩu xác nhận không khớp |
| `400` | Mật khẩu mới phải khác mật khẩu hiện tại |
| `400` | Mật khẩu hiện tại không đúng |
| `401` | Token không hợp lệ hoặc hết hạn |

### Files

| File | Type |
|------|------|
| `dto/ChangePasswordRequest.java` | DTO đổi mật khẩu |
| `service/UserService.java` | changePassword() |
| `controller/UserController.java` | PUT /users/me/password |

---

## 🗄️ Database Schema (Bảng liên quan)

### `users`
| Column | Type | Mô tả |
|--------|------|-------|
| `id` | BIGINT PK | ID |
| `email` | VARCHAR(255) UNIQUE | Email đăng nhập |
| `password_hash` | VARCHAR(255) | Mật khẩu đã hash (BCrypt) |
| `full_name` | VARCHAR(100) | Họ tên đầy đủ |
| `phone_number` | VARCHAR(20) | Số điện thoại |
| `avatar_url` | VARCHAR(500) | URL ảnh đại diện |
| `role` | ENUM: `STUDENT`, `TEACHER`, `ADMIN` | Vai trò |
| `is_active` | BOOLEAN | Trạng thái tài khoản |
| `created_at` | DATETIME | Ngày tạo |

### `password_reset_tokens`
| Column | Type | Mô tả |
|--------|------|-------|
| `id` | BIGINT PK | ID |
| `token` | VARCHAR(255) UNIQUE | UUID token |
| `user_id` | BIGINT FK → users | Người yêu cầu |
| `expires_at` | DATETIME | Hạn token (30 phút) |
| `used` | BOOLEAN | Đã sử dụng chưa |
| `created_at` | DATETIME | Ngày tạo |

> **Rate limit:** Mỗi user tối đa 3 request reset/giờ (`countByUserAndCreatedAtAfter`)

---

## 🔐 Xác thực & Phân quyền

### Security Config

| Endpoint | Auth |
|----------|------|
| `POST /auth/register` | Public (permitAll) |
| `POST /auth/login` | Public (permitAll) |
| `POST /auth/forgot-password` | Public (permitAll) |
| `POST /auth/reset-password` | Public (permitAll) |
| `GET /users/me` | Authenticated (Bearer Token) |
| `PUT /users/me` | Authenticated (Bearer Token) |
| `PUT /users/me/password` | Authenticated (Bearer Token) |

### JWT Token
- **Algorithm:** HS256
- **Secret:** Cấu hình qua `jwt.secret` (min 256-bit)
- **Expiry:** 24h (`86400000` ms)
- **Payload:** `sub` (email), `role`, `fullName`

### Security Annotations có sẵn
| Annotation | Mô tả |
|------------|-------|
| `@AdminOnly` | `hasRole('ADMIN')` |
| `@TeacherOnly` | `hasRole('TEACHER')` |
| `@StudentOnly` | `hasRole('STUDENT')` |
| `@TeacherOrAdmin` | `hasAnyRole('TEACHER', 'ADMIN')` |

> **Lưu ý:** `GlobalSecurityConfig.java` được "đóng băng" — chỉ Bình Minh (Auth/DevOps) được sửa.

---

## 🧪 Cách test nhanh

```bash
# 1. Đăng ký
curl -X POST http://localhost:8081/auth/register \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Test","lastName":"User","email":"test@t.com","password":"Password@123","confirmPassword":"Password@123"}'

# 2. Đăng nhập
curl -X POST http://localhost:8081/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@t.com","password":"Password@123"}'

# 3. Xem hồ sơ (cần token)
curl http://localhost:8081/users/me \
  -H "Authorization: Bearer <token>"

# 4. Cập nhật hồ sơ
curl -X PUT http://localhost:8081/users/me \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"fullName":"Test Updated","phoneNumber":"0912345678"}'

# 5. Đổi mật khẩu
curl -X PUT http://localhost:8081/users/me/password \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"currentPassword":"Password@123","newPassword":"NewPass@456","confirmNewPassword":"NewPass@456"}'

# 6. Quên mật khẩu
curl -X POST http://localhost:8081/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{"email":"test@t.com"}'
```

---

> **Thực hiện bởi:** Bình Minh  
> **Ngày hoàn thành:** 16/03/2026

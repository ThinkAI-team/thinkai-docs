# 📋 ThinkAI — API Documentation: Admin Panel
**Thành viên:** Thái Nguyên  
**Module:** Admin Panel  
**Base URL:** `http://localhost:8081`  
**Auth:** `Authorization: Bearer <access_token>` (role `ADMIN`)  
**Last Updated:** 2026-03-16

---

## 📌 Tổng quan 5 tính năng

| # | Tính năng | Mô tả | Số API |
|---|-----------|-------|--------|
| 1 | Admin Dashboard | Thống kê tổng hệ thống | 1 |
| 2 | Quản lý Users | Danh sách, khóa/mở tài khoản | 2 |
| 3 | Quản lý Khóa học | Tạo/Cập nhật/Xóa | 3 |
| 4 | Cấu hình AI Prompts | Cập nhật prompt hệ thống cho AI | 1 |
| 5 | Đánh giá & Nhận xét khóa học | Rating & Review (theo kế hoạch tính năng) | 2 |

---

## ① Admin Dashboard

### 1.1 Lấy thống kê tổng hệ thống

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Endpoint** | `/admin/dashboard` |
| **Auth** | Bearer Token (ADMIN) |

**Response `200 OK`:**
```json
{
  "status": 200,
  "message": "Success",
  "data": {
    "totalUsers": 0,
    "totalCourses": 0,
    "totalEnrollments": 0,
    "activeStudents": 0,
    "activeTeachers": 0,
    "aiChatsToday": 0
  }
}
```

**Nguồn dữ liệu:** View `v_admin_dashboard`

---

## ② Quản lý Users

### 2.1 Danh sách users

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Endpoint** | `/admin/users` |
| **Auth** | Bearer Token (ADMIN) |

**Query Parameters:** `page`, `size`, `keyword`, `role`, `isActive`

**Response `200 OK`:**
```json
{
  "status": 200,
  "message": "Success",
  "data": {
    "content": [
      {
        "id": 1,
        "fullName": "Admin",
        "email": "admin@thinkai.com",
        "role": "ADMIN",
        "isActive": true
      }
    ],
    "page": 0,
    "size": 10,
    "totalElements": 1,
    "totalPages": 1
  }
}
```

### 2.2 Khóa/Mở khóa tài khoản

| Field | Value |
|-------|-------|
| **Method** | `PUT` |
| **Endpoint** | `/admin/users/{userId}/status` |
| **Auth** | Bearer Token (ADMIN) |

**Request Body:**
```json
{
  "isActive": false
}
```

**Response `200 OK`:**
```json
{
  "status": 200,
  "message": "Success",
  "data": {
    "userId": 5,
    "isActive": false
  }
}
```

---

## ③ Quản lý Khóa học

### 3.1 Thêm khóa học mới

| Field | Value |
|-------|-------|
| **Method** | `POST` |
| **Endpoint** | `/admin/courses` |
| **Auth** | Bearer Token (ADMIN) |

**Request Body:**
```json
{
  "title": "ReactJS Advanced",
  "description": "Khóa học nâng cao...",
  "price": 500000,
  "instructorId": 5
}
```

**Response `201 Created`:**
```json
{
  "status": 201,
  "message": "Course created",
  "data": {
    "courseId": 101
  }
}
```

### 3.2 Cập nhật khóa học

| Field | Value |
|-------|-------|
| **Method** | `PUT` |
| **Endpoint** | `/admin/courses/{courseId}` |
| **Auth** | Bearer Token (ADMIN) |

### 3.3 Xóa khóa học

| Field | Value |
|-------|-------|
| **Method** | `DELETE` |
| **Endpoint** | `/admin/courses/{courseId}` |
| **Auth** | Bearer Token (ADMIN) |

---

## ④ Cấu hình AI Prompts

### 4.1 Cập nhật prompts

| Field | Value |
|-------|-------|
| **Method** | `PUT` |
| **Endpoint** | `/admin/settings/ai-prompts` |
| **Auth** | Bearer Token (ADMIN) |

**Request Body:**
```json
{
  "tutorSystemPrompt": "Bạn là gia sư AI của ThinkAI...",
  "examGeneratorPrompt": "Tạo câu hỏi trắc nghiệm format JSON..."
}
```

**Response `200 OK`:**
```json
{
  "status": 200,
  "message": "Success",
  "data": true
}
```

---

## ⑤ Đánh giá & Nhận xét khóa học

> Theo kế hoạch tính năng, hệ thống cần rating & review. API chi tiết sẽ được đồng bộ thêm vào API_SPEC khi hoàn tất.

### 5.1 Tạo đánh giá

| Field | Value |
|-------|-------|
| **Method** | `POST` |
| **Endpoint** | `/courses/{id}/reviews` |
| **Auth** | Bearer Token (STUDENT) |

### 5.2 Danh sách đánh giá

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Endpoint** | `/courses/{id}/reviews` |
| **Auth** | Public |

---

## 🗄️ Database Schema (Bảng liên quan)

### `course_reviews`
| Column | Type | Mô tả |
|--------|------|------|
| `id` | BIGINT PK | ID |
| `course_id` | BIGINT FK → courses | Khóa học |
| `user_id` | BIGINT FK → users | Người đánh giá |
| `rating` | INT | 1–5 sao |
| `review_text` | TEXT | Nội dung nhận xét |
| `is_approved` | BOOLEAN | Admin duyệt |

### `ai_settings`
| Column | Type | Mô tả |
|--------|------|------|
| `id` | BIGINT PK | ID |
| `key` | VARCHAR | Tên setting |
| `value` | LONGTEXT | Nội dung prompt |

### `system_logs`
| Column | Type | Mô tả |
|--------|------|------|
| `id` | BIGINT PK | ID |
| `user_id` | BIGINT FK → users | Người thao tác |
| `action` | VARCHAR | LOGIN/CREATE/UPDATE/DELETE |
| `entity_type` | VARCHAR | users/courses/exams... |
| `entity_id` | BIGINT | ID entity |
| `details` | JSON | Chi tiết |
| `ip_address` | VARCHAR | IP |

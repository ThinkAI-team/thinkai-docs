# 📋 ThinkAI — API Documentation: Learning Room & Progress
**Thành viên:** Anh Khoa  
**Module:** Learning Room & Progress  
**Base URL:** `http://localhost:8081`  
**Auth:** `Authorization: Bearer <access_token>` (trừ Auth endpoints)  
**Last Updated:** 2026-03-16

---

## 📌 Tổng quan 5 tính năng

| # | Tính năng | Mô tả | Số API |
|---|-----------|-------|--------|
| 1 | Learning Room Layout | Hiển thị phòng học (video/PDF + sidebar danh sách bài) | 2 |
| 2 | Video Player | Lưu tuỳ chọn player & tiến độ xem video | 2 |
| 3 | PDF Viewer | Theo dõi tiến độ đọc PDF, khôi phục vị trí | 3 |
| 4 | Đánh dấu hoàn thành | Đánh dấu bài học đã hoàn thành & cập nhật % khoá học | 1 |
| 5 | Dashboard Sinh viên | Trang tổng quan: thống kê, khoá học, gợi ý | 1 |

---

## ① Learning Room Layout

> Layout phòng học dùng dữ liệu từ API Course/Lesson có sẵn, **không tạo API mới** riêng cho layout.  
> Frontend gọi 2 API sau để render giao diện:

### 1.1 Lấy thông tin khoá học + danh sách bài

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Endpoint** | `/courses/{courseId}` |
| **Auth** | Bearer Token (STUDENT) |

**Response `200 OK`:**
```json
{
  "status": 200,
  "data": {
    "id": 1,
    "title": "TOEIC Listening Mastery",
    "description": "Khoá học luyện nghe TOEIC từ cơ bản đến nâng cao",
    "thumbnailUrl": "https://...",
    "instructorName": "Nguyễn Văn A",
    "lessons": [
      {
        "id": 10,
        "title": "Introduction to TOEIC",
        "type": "VIDEO",
        "durationSeconds": 600,
        "orderIndex": 1,
        "isCompleted": true
      },
      {
        "id": 11,
        "title": "Part 1: Photographs",
        "type": "PDF",
        "durationSeconds": 15,
        "orderIndex": 2,
        "isCompleted": false
      }
    ]
  }
}
```

### 1.2 Lấy chi tiết bài học

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Endpoint** | `/courses/lessons/{lessonId}` |
| **Auth** | Bearer Token (STUDENT) |

**Response `200 OK`:**
```json
{
  "status": 200,
  "data": {
    "id": 10,
    "title": "Introduction to TOEIC",
    "type": "VIDEO",
    "contentUrl": "https://youtube.com/watch?v=...",
    "contentText": "Nội dung text cho AI Tutor context...",
    "durationSeconds": 600,
    "orderIndex": 1,
    "courseId": 1
  }
}
```

**Lỗi thường gặp:**
| Status | Message |
|--------|---------|
| `403` | Bạn chưa đăng ký khoá học này |
| `404` | Bài học không tồn tại |

---

## ② Video Player

> Video Player chủ yếu là frontend (play/pause/seek/speed do trình duyệt xử lý).  
> Backend chỉ cần 2 API: lưu tuỳ chọn người dùng và cập nhật tiến độ xem.

### 2.1 Lưu/Lấy tuỳ chọn Video Player

| Field | Value |
|-------|-------|
| **Method** | `PUT` / `GET` |
| **Endpoint** | `/users/me/preferences` |
| **Auth** | Bearer Token (STUDENT) |

**Request Body (PUT):**
```json
{
  "playbackSpeed": 1.5,
  "autoPlay": true,
  "defaultQuality": "720p"
}
```

| Field | Type | Validation | Mô tả |
|-------|------|------------|-------|
| `playbackSpeed` | Float | 0.25 – 3.0 | Tốc độ phát mặc định |
| `autoPlay` | Boolean | — | Tự động phát bài kế tiếp |
| `defaultQuality` | String | `360p`, `480p`, `720p`, `1080p` | Chất lượng mặc định |

**Response `200 OK` (cả PUT và GET):**
```json
{
  "status": 200,
  "data": {
    "playbackSpeed": 1.5,
    "autoPlay": true,
    "defaultQuality": "720p"
  }
}
```

### 2.2 Cập nhật tiến độ xem video

| Field | Value |
|-------|-------|
| **Method** | `PUT` |
| **Endpoint** | `/courses/lessons/{lessonId}/progress` |
| **Auth** | Bearer Token (STUDENT) |

**Request Body:**
```json
{
  "watchTimeSeconds": 320
}
```

| Field | Type | Validation | Mô tả |
|-------|------|------------|-------|
| `watchTimeSeconds` | Integer | >= 0 | Số giây đã xem (frontend gửi định kỳ mỗi 10-30s) |

**Response `200 OK`:**
```json
{
  "status": 200,
  "data": {
    "lessonId": 10,
    "watchTimeSeconds": 320,
    "totalDuration": 600,
    "watchPercentage": 53.33,
    "isCompleted": false,
    "lastAccessedAt": "2026-03-14T10:30:00"
  }
}
```

**Logic tự động hoàn thành:** Khi `watchTimeSeconds >= 90% * durationSeconds` → `isCompleted = true`.

**Lỗi thường gặp:**
| Status | Message |
|--------|---------|
| `403` | Bạn chưa đăng ký khoá học này |
| `404` | Bài học không tồn tại |

---

## ③ PDF Viewer

> PDF Viewer render trong browser (dùng pdf.js ở frontend).  
> Backend cung cấp metadata, theo dõi trang đang đọc, khôi phục vị trí khi quay lại.

### 3.1 Lấy metadata bài PDF

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Endpoint** | `/courses/lessons/{lessonId}/pdf` |
| **Auth** | Bearer Token (STUDENT) |

**Response `200 OK`:**
```json
{
  "status": 200,
  "data": {
    "lessonId": 11,
    "title": "Part 1: Photographs",
    "contentUrl": "https://storage.example.com/toeic-part1.pdf",
    "totalPages": 15,
    "courseId": 1,
    "orderIndex": 2
  }
}
```

**Logic xác thực:**
1. Kiểm tra lesson tồn tại → `404` nếu không
2. Kiểm tra `type == PDF` → `400` nếu không phải PDF
3. Kiểm tra user đã enroll khoá học → `403` nếu chưa

### 3.2 Cập nhật tiến độ đọc PDF

| Field | Value |
|-------|-------|
| **Method** | `POST` |
| **Endpoint** | `/courses/lessons/{lessonId}/pdf/progress` |
| **Auth** | Bearer Token (STUDENT) |

**Request Body:**
```json
{
  "currentPage": 5,
  "totalPages": 15
}
```

| Field | Type | Validation | Mô tả |
|-------|------|------------|-------|
| `currentPage` | Integer | >= 1, <= totalPages | Trang đang đọc |
| `totalPages` | Integer | >= 1 | Tổng số trang PDF |

**Response `200 OK`:**
```json
{
  "status": 200,
  "data": {
    "lessonId": 11,
    "currentPage": 5,
    "totalPages": 15,
    "readingPercentage": 33.33,
    "isCompleted": false,
    "lastAccessedAt": "2026-03-14T23:38:57"
  }
}
```

**Logic tự động hoàn thành:** Khi `currentPage == totalPages` → `isCompleted = true`.

### 3.3 Khôi phục vị trí đọc cuối

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Endpoint** | `/courses/lessons/{lessonId}/pdf/progress` |
| **Auth** | Bearer Token (STUDENT) |

**Response `200 OK`:**
```json
{
  "status": 200,
  "data": {
    "lessonId": 11,
    "currentPage": 5,
    "totalPages": 15,
    "readingPercentage": 33.33,
    "isCompleted": false,
    "lastAccessedAt": "2026-03-14T23:38:57"
  }
}
```

> Frontend dùng API này khi user mở lại bài → tự động scroll đến trang cuối đã đọc.

**Lỗi thường gặp:**
| Status | Message |
|--------|---------|
| `400` | Bài học này không phải dạng PDF |
| `400` | currentPage không được lớn hơn totalPages |
| `403` | Bạn chưa đăng ký khoá học này |
| `404` | Bài học không tồn tại |

---

## ④ Đánh dấu hoàn thành bài học

### 4.1 Đánh dấu hoàn thành

| Field | Value |
|-------|-------|
| **Method** | `POST` |
| **Endpoint** | `/courses/lessons/{lessonId}/complete` |
| **Auth** | Bearer Token (STUDENT) |

**Request Body:** Không cần (empty body)

**Response `200 OK`:**
```json
{
  "status": 200,
  "data": {
    "lessonId": 10,
    "isCompleted": true,
    "completedAt": "2026-03-14T10:35:00",
    "courseProgress": {
      "completedLessons": 3,
      "totalLessons": 10,
      "progressPercent": 30
    }
  }
}
```

**Business Logic:**
1. Cập nhật `lesson_progress.is_completed = true` và `completed_at = NOW()`
2. Đếm lại số bài đã hoàn thành trong khoá học
3. Tính lại `enrollments.progress_percent` = `(completedLessons / totalLessons) * 100`
4. Nếu tất cả bài đã hoàn thành → cập nhật `enrollments.completed_at = NOW()`

**Lỗi thường gặp:**
| Status | Message |
|--------|---------|
| `403` | Bạn chưa đăng ký khoá học này |
| `404` | Bài học không tồn tại |
| `409` | Bài học đã được đánh dấu hoàn thành trước đó |

---

## ⑤ Dashboard Sinh viên

### 5.1 Lấy tổng quan dashboard

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Endpoint** | `/users/me/dashboard` |
| **Auth** | Bearer Token (STUDENT) |

**Response `200 OK`:**
```json
{
  "status": 200,
  "data": {
    "student": {
      "fullName": "Anh Khoa",
      "email": "anhkhoa@thinkai.com",
      "avatarUrl": "https://..."
    },
    "stats": {
      "totalEnrolledCourses": 3,
      "completedCourses": 1,
      "averageProgress": 65.5,
      "totalStudyTimeMinutes": 480
    },
    "recentCourses": [
      {
        "courseId": 1,
        "title": "TOEIC Listening Mastery",
        "thumbnailUrl": "https://...",
        "progressPercent": 80,
        "lastAccessedAt": "2026-03-14T10:30:00"
      }
    ],
    "nextLesson": {
      "lessonId": 12,
      "title": "Part 2: Question-Response",
      "courseTitle": "TOEIC Listening Mastery",
      "type": "VIDEO"
    }
  }
}
```

**Dữ liệu trả về:**

| Field | Nguồn | Mô tả |
|-------|-------|-------|
| `student` | Bảng `users` | Thông tin cá nhân |
| `stats.totalEnrolledCourses` | `COUNT(enrollments)` | Số khoá đang học |
| `stats.completedCourses` | `COUNT(enrollments WHERE completed_at IS NOT NULL)` | Số khoá đã hoàn thành |
| `stats.averageProgress` | `AVG(enrollments.progress_percent)` | % trung bình |
| `stats.totalStudyTimeMinutes` | `SUM(lesson_progress.watch_time_seconds) / 60` | Tổng thời gian học |
| `recentCourses` | `enrollments ORDER BY last_accessed DESC LIMIT 5` | 5 khoá gần đây |
| `nextLesson` | Bài đầu tiên chưa hoàn thành trong khoá gần nhất | Gợi ý bài tiếp theo |

---

## 🗄️ Database Schema (Bảng liên quan)

### `lesson_progress`
| Column | Type | Mô tả |
|--------|------|-------|
| `id` | BIGINT PK | ID |
| `user_id` | BIGINT FK → users | Học viên |
| `lesson_id` | BIGINT FK → lessons | Bài học |
| `is_completed` | BOOLEAN | Đã hoàn thành |
| `watch_time_seconds` | INT | Video: giây đã xem / PDF: trang đang đọc |
| `last_accessed_at` | DATETIME | Lần truy cập cuối |
| `completed_at` | DATETIME | Ngày hoàn thành |

> **Unique constraint:** `(user_id, lesson_id)` — mỗi user chỉ có 1 record tiến độ cho mỗi bài.

### `lessons`
| Column | Type | Mô tả |
|--------|------|-------|
| `id` | BIGINT PK | ID |
| `course_id` | BIGINT FK → courses | Khoá học chứa bài |
| `title` | VARCHAR(255) | Tên bài |
| `type` | ENUM: `VIDEO`, `PDF`, `QUIZ` | Loại bài |
| `content_url` | VARCHAR(500) | URL video/PDF |
| `duration_seconds` | INT | Video: thời lượng (giây) / PDF: tổng số trang |
| `order_index` | INT | Thứ tự trong khoá |

### `enrollments`
| Column | Type | Mô tả |
|--------|------|-------|
| `id` | BIGINT PK | ID |
| `user_id` | BIGINT FK → users | Học viên |
| `course_id` | BIGINT FK → courses | Khoá học |
| `progress_percent` | INT (0-100) | Tiến độ khoá học |
| `enrolled_at` | DATETIME | Ngày đăng ký |
| `completed_at` | DATETIME | Ngày hoàn thành (null nếu chưa xong) |

---

## 🔐 Xác thực & Phân quyền

- **Tất cả API** đều yêu cầu `Authorization: Bearer <jwt_token>`
- **Role:** Chỉ `STUDENT` mới được truy cập các API này (annotation `@StudentOnly`)
- **Enrollment check:** User phải đã đăng ký khoá học mới được xem bài / cập nhật tiến độ

---

## 🧪 Cách test nhanh

```bash
# 1. Đăng ký user
curl -X POST http://localhost:8081/auth/register \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Test","lastName":"User","email":"test@t.com","password":"Password@123","confirmPassword":"Password@123"}'

# 2. Dùng token trả về để gọi API
curl http://localhost:8081/courses/lessons/888/pdf \
  -H "Authorization: Bearer <token>"

# 3. Cập nhật tiến độ đọc PDF
curl -X POST http://localhost:8081/courses/lessons/888/pdf/progress \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"currentPage":5,"totalPages":10}'
```

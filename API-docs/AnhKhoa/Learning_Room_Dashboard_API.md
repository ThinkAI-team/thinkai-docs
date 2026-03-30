# 📋 ThinkAI — API Documentation: Learning Room & Student Dashboard
**Thành viên:** Nguyễn Anh Khoa  
**Module:** Learning Room & Student Dashboard  
**Base URL:** `http://localhost:8081`  
**Auth:** `Authorization: Bearer <access_token>` (STUDENT role)  
**Last Updated:** 2026-03-28

---

## 📌 Tổng quan 4 tính năng

| # | Tính năng | Mô tả | Số API |
|---|-----------|-------|--------|
| 1 | Dashboard Sinh viên | Xem tiến độ học tập, các khóa học đang tham gia và gợi ý bài học | 1 |
| 2 | Learning Room Layout | Lấy thông tin tổng quan khóa học trong chế độ phòng học (danh sách bài học) | 1 |
| 3 | Chi tiết bài học | Lấy nội dung chi tiết bài (Video, PDF) & thông tin tiến độ hiện tại | 1 |
| 4 | Cập nhật & Đồng bộ tiến độ | Cập nhật thời gian xem video, tự động đánh dấu hoàn thành & tính % khóa học | 1 |

---

## ① Dashboard Sinh viên

### 1.1 Tổng quan Dashboard

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Endpoint** | `/users/me/dashboard` |
| **Auth** | Bearer Token (STUDENT) |

**Response `200 OK`:**
```json
{
  "status": 200,
  "message": "Success",
  "data": {
    "greeting": "Chào buổi chiều, Nguyễn Anh Khoa! 👋",
    "totalEnrolledCourses": 2,
    "averageProgress": 45.5,
    "enrolledCourses": [
      {
        "courseId": 1,
        "title": "ThinkAI React Native Course",
        "thumbnailUrl": "https://...",
        "progressPercent": 60,
        "totalLessons": 10,
        "completedLessons": 6,
        "lastAccessedAt": "2026-03-18T16:40:49"
      }
    ],
    "nextLesson": {
      "lessonId": 2,
      "lessonTitle": "State and Props",
      "courseTitle": "ThinkAI React Native Course",
      "type": "VIDEO"
    }
  }
}
```

**Business Logic:**
1. Lấy thông tin User hiện tại từ token.
2. Lấy danh sách `Enrollment` của User.
3. Tính toán tổng tiến độ trung bình (`averageProgress`) dựa trên `progressPercent` của các khóa đã tham gia.
4. Gợi ý `nextLesson` bằng cách tìm bài học cuối cùng được truy cập từ `LessonProgress`.

**Error Responses:**
| Status | Message |
|--------|---------|
| `401` | Token không hợp lệ hoặc hết hạn |
| `403` | Không có quyền truy cập (không phải STUDENT) |

### Files

| File | Type |
|------|------|
| `dto/DashboardResponse.java` | DTO bao quát Dashboard |
| `service/DashboardService.java` | Xử lý logic Dashboard, tính tiến độ |
| `controller/DashboardController.java` | GET /users/me/dashboard |

---

## ② Learning Room Layout

### 2.1 Cấu trúc phòng học

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Endpoint** | `/courses/{courseId}/learn` |
| **Auth** | Bearer Token (STUDENT) |

**Path Variables:**
- `courseId` (Long): ID khóa học.

**Response `200 OK`:**
```json
{
  "status": 200,
  "message": "Success",
  "data": {
    "id": 1,
    "title": "ThinkAI React Native Course",
    "description": "Build mobile apps with React Native",
    "thumbnailUrl": "https://...",
    "progressPercent": 60,
    "lessons": [
      {
        "id": 1,
        "title": "Introduction to React Native",
        "type": "VIDEO",
        "duration": "10 min",
        "isCompleted": true,
        "orderIndex": 1
      }
    ]
  }
}
```

**Business Logic:**
1. Check quyền truy cập khóa học (phải có `Enrollment`).
2. Trả về thông tin khóa học kèm danh sách bài học sắp xếp theo `orderIndex`.
3. Kiểm tra từng bài học với `LessonProgress` để xác định trạng thái `isCompleted`.

**Error Responses:**
| Status | Message |
|--------|---------|
| `403` | Bạn chưa đăng ký khóa học này |
| `404` | Khóa học không tồn tại |

### Files

| File | Type |
|------|------|
| `dto/CourseDetailResponse.java` | DTO cấu trúc khóa học |
| `dto/LessonResponse.java` | DTO danh sách bài học thu gọn |
| `service/LearningRoomService.java` | getCourseWithLessons() |
| `controller/LearningRoomController.java` | GET /courses/{courseId}/learn |

---

## ③ Chi tiết bài học

### 3.1 Nội dung chi tiết bài học

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Endpoint** | `/courses/lessons/{lessonId}` |
| **Auth** | Bearer Token (STUDENT) |

**Path Variables:**
- `lessonId` (Long): ID bài học.

**Response `200 OK`:**
```json
{
  "status": 200,
  "message": "Success",
  "data": {
    "id": 1,
    "title": "Introduction to React Native",
    "type": "VIDEO",
    "contentUrl": "https://www.youtube.com/watch?v=...",
    "contentText": null,
    "durationSeconds": 600,
    "orderIndex": 1,
    "isCompleted": true,
    "watchTimeSeconds": 120,
    "currentTimeSeconds": 120,
    "lessonProgressPercent": 20.0,
    "courseId": 1,
    "courseTitle": "ThinkAI React Native Course",
    "previousLessonId": null,
    "nextLessonId": 2
  }
}
```

**Business Logic:**
1. Nếu User chưa có `LessonProgress` cho bài này, tạo mới (watchTime = 0).
2. Tự động cập nhật `lastAccessedAt = now()` để phục vụ tính năng `nextLesson` (resume khóa học).
3. Auto-detect `previousLessonId` và `nextLessonId` để giao diện hiển thị nút Chuyển Bài.
4. Trả về `currentTimeSeconds` kèm `lessonProgressPercent` để Frontend khôi phục vị trí Video và hiển thị phần trăm học.

**Error Responses:**
| Status | Message |
|--------|---------|
| `403` | Bạn chưa đăng ký khóa học này |
| `404` | Bài học không tồn tại |

### Files

| File | Type |
|------|------|
| `dto/LessonDetailResponse.java` | DTO chi tiết bài học |
| `service/LearningRoomService.java` | getLessonDetail() |
| `controller/LearningRoomController.java` | GET /courses/lessons/{lessonId} |

---

## ④ Cập nhật & Đồng bộ tiến độ

### 4.1 Cập nhật tiến độ Video

| Field | Value |
|-------|-------|
| **Method** | `PUT` |
| **Endpoint** | `/courses/lessons/{lessonId}/progress` |
| **Auth** | Bearer Token (STUDENT) |

**Request Body:**
```json
{
  "watchTimeSeconds": 550,
  "currentTimeSeconds": 550
}
```

| Field | Type | Validation | Mô tả |
|-------|------|------------|-------|
| `watchTimeSeconds` | Integer | @NotNull, >= 0 | Thời gian đã xem thực sự |
| `currentTimeSeconds` | Integer | >= 0 | Vị trí dừng tạm thời của Video (Resume Playback) |

**Response `200 OK`:**
```json
{
  "status": 200,
  "message": "Success",
  "data": {
    "lessonId": 1,
    "watchTimeSeconds": 550,
    "currentTimeSeconds": 550,
    "isCompleted": true,
    "lessonProgressPercent": 91.6,
    "courseProgressPercent": 10.0
  }
}
```

**Business Logic:**
1. Frontend API định kỳ (setInterval) gọi endpoint này mỗi 10 giây khi xem Video.
2. Lưu `watchTimeSeconds`, `currentTimeSeconds` và cập nhật `lastAccessedAt`.
3. Tính `% bài học`. Nếu độ dài xem video đạt **>= 90%** thời lượng gốc -> `isCompleted = true` (Đánh dấu hoàn thành tự động) và set `completedAt = now()`.
4. Tính lại `% khóa học` bằng công thức: `(Số bài đã xong / Tổng số bài) * 100`.
5. Cập nhật con số `%` này vào bảng `Enrollment` (trường `progressPercent`). Nếu đạt 100% thì gán `completedAt` cho Enrollment để tốt nghiệp khóa học.
6. Trả lại thông số `% mới nhất` để Frontend vẽ realtime thanh Progress Bar trên giao diện.

**Error Responses:**
| Status | Message |
|--------|---------|
| `400` | Validation errors (watchTimeSeconds < 0...) |
| `403` | Bạn chưa đăng ký khóa học này |
| `404` | Bài học không tồn tại |

### Files

| File | Type |
|------|------|
| `dto/UpdateProgressRequest.java` | Request DTO |
| `dto/UpdateProgressResponse.java` | Response DTO |
| `service/VideoProgressService.java` | updateProgress(), Auto-complete logic, Enrollment recalculation |
| `controller/VideoProgressController.java` | PUT /courses/lessons/{lessonId}/progress |

---

## 🗄️ Database Schema (Bảng liên quan)

### `enrollments`
| Column | Type | Mô tả |
|--------|------|-------|
| `id` | BIGINT PK | ID đăng ký |
| `user_id` | BIGINT | ID Sinh viên |
| `course_id` | BIGINT | ID Khóa học |
| `progress_percent`| INT | Tiến độ hoàn thành khóa học (%) |
| `enrolled_at` | DATETIME | Ngày tham gia |
| `completed_at` | DATETIME | Ngày hoàn thành 100% khóa học |

### `lesson_progress`
| Column | Type | Mô tả |
|--------|------|-------|
| `id` | BIGINT PK | ID tiến độ |
| `user_id` | BIGINT | ID Sinh viên |
| `lesson_id` | BIGINT | ID Bài học |
| `is_completed` | BOOLEAN | Trạng thái tự động hoàn thành (>= 90%) |
| `watch_time_seconds`| INT | Tổng thời gian thực tế đã xem |
| `current_time_seconds`| INT | Vị trí tạm dừng video lần cuối |
| `last_accessed_at`| DATETIME | Thời điểm truy cập gần nhất (cho cấu hình Next Lesson) |
| `completed_at` | DATETIME | Thời điểm xem xong |

---

## 🔐 Xác thực & Phân quyền

### Security Config

| Endpoint | Auth |
|----------|------|
| `GET /users/me/dashboard` | Authenticated (`@StudentOnly`) |
| `GET /courses/{courseId}/learn` | Authenticated (`@StudentOnly`) |
| `GET /courses/lessons/{lessonId}` | Authenticated (`@StudentOnly`) |
| `PUT /courses/lessons/{lessonId}/progress` | Authenticated (`@StudentOnly`) |

### Security Annotations có sẵn
- Sử dụng `@StudentOnly` cho tất cả các thiết lập endpoint thuộc phạm vi Student Dashboard và Learning Room.
- Luôn kiểm tra tính xác thực (bằng bảng `enrollments`) giữa User và Course thì mới được phép thao tác.

---

> **Thực hiện bởi:** Nguyễn Anh Khoa  
> **Ngày cập nhật gần nhất:** 28/03/2026

# 📋 ThinkAI — API Documentation: Learning Room & Student Dashboard
**Thành viên:** Nguyễn Anh Khoa  
**Module:** Learning Room & Student Dashboard  
**Base URL:** `http://localhost:8081`  
**Auth:** `Authorization: Bearer <access_token>` (STUDENT role)  
**Last Updated:** 2026-03-30

---

## 📌 Tổng quan 5 tính năng

| # | Tính năng | Mô tả | Số API |
|---|-----------|-------|--------|
| 1 | Dashboard Sinh viên | Xem tiến độ học tập, tổng quan khóa học đang tham gia và gợi ý bài tiếp theo | 1 |
| 2 | Learning Room Layout | Lấy thông tin cấu trúc khóa học (danh sách bài học) trong phòng học | 1 |
| 3 | Trình phát Video (Video Player) | Lấy chi tiết bài học đa phương tiện (Video) và đồng bộ trình chiếu | 1 |
| 4 | Trình xem Tài liệu (PDF Viewer) | Lấy nội dung chi tiết bài học văn bản (PDF, Text) để hiển thị iframe | 1 |
| 5 | Cập nhật & Đồng bộ Tiến độ | Lưu vết thời gian xem video, tự động đánh dấu hoàn thành & tính % khóa học | 1 |

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
4. Gợi ý `nextLesson` bằng cách tìm bài học cuối cùng được truy cập dựa vào bảng `LessonProgress`.

**Error Responses:**
| Status | Message |
|--------|---------|
| `401` | Token không hợp lệ hoặc hết hạn |
| `403` | Không có quyền truy cập (không phải STUDENT) |

### Files

| File | Type |
|------|------|
| `dto/DashboardResponse.java` | DTO bao quát Dashboard |
| `service/DashboardService.java` | Xử lý logic Dashboard, tính trung bình tiến độ |
| `controller/DashboardController.java` | Cung cấp Endpoint GET /users/me/dashboard |

---

## ② Learning Room Layout (Danh sách bài học)

### 2.1 Cấu trúc phòng học

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Endpoint** | `/courses/{courseId}/learn` |
| **Auth** | Bearer Token (STUDENT) |

**Path Variables:**
- `courseId` (Long): ID khóa học cần vào phòng.

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
1. Check quyền truy cập khóa học (phải có bản ghi `Enrollment`).
2. Trả về thông tin khóa học kèm danh sách bài học, được sắp xếp thứ tự chuẩn chỉ theo `orderIndex`.
3. Kiểm tra từng bài học với bảng `LessonProgress` của người dùng đó để gán cờ `isCompleted = true/false` vào sidebar.

**Error Responses:**
| Status | Message |
|--------|---------|
| `403` | Bạn chưa đăng ký khóa học này |
| `404` | Khóa học không tồn tại |

### Files

| File | Type |
|------|------|
| `dto/CourseDetailResponse.java` | DTO cấu trúc toàn cục khóa học và thanh Sidebar |
| `dto/LessonResponse.java` | DTO từng List Item của bài học thu gọn |
| `service/LearningRoomService.java` | Xử lý getCourseWithLessons() |
| `controller/LearningRoomController.java` | Cung cấp Endpoint GET /courses/{courseId}/learn |

---

## ③ Trình phát Video (Video Player)

### 3.1 Nhận dữ liệu phát đa phương tiện

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Endpoint** | `/courses/lessons/{lessonId}` *(khi type = VIDEO)* |
| **Auth** | Bearer Token (STUDENT) |

**Path Variables:**
- `lessonId` (Long): ID bài học định dạng Video.

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

**Business Logic Phía Frontend/Trình Phát:**
1. Phân loại cấu trúc: Nếu `type = VIDEO`, Frontend sẽ hiển thị Player (có thể là mã nguồn nhúng YouTube hoặc tag `<video>` chuẩn HTML5 nếu link direct).
2. Khi bật lại bài, Player sẽ tự động dò `currentTimeSeconds` trả từ Server để **Resume Playback** ngay tại thời điểm ngừng xem lần trước.
3. Server tự động tính mốc `lastAccessedAt = now()` để đánh dấu đây là Video mới xem nhất.
4. Auto-detect bài trước (`previousLessonId`) và bài tiếp theo (`nextLessonId`) để render nút Chuyển Bài qua lại.

**Error Responses:**
| Status | Message |
|--------|---------|
| `403` | Bạn chưa đăng ký khóa học này |
| `404` | Bài học không tồn tại |

### Files

| File | Type |
|------|------|
| `dto/LessonDetailResponse.java` | DTO dùng chung chi tiết cho Video/PDF/Text |
| `service/LearningRoomService.java` | Logic chính getLessonDetail() cấp data phát |
| `controller/LearningRoomController.java` | GET /courses/lessons/{lessonId} |

---

## ④ Trình xem Tài liệu (PDF Viewer & Text)

### 4.1 Nhận dữ liệu văn bản, tải file PDF

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Endpoint** | `/courses/lessons/{lessonId}` *(khi type = PDF / TEXT)* |
| **Auth** | Bearer Token (STUDENT) |

**Path Variables:**
- `lessonId` (Long): ID bài học định dạng Tài liệu/Văn bản.

**Response `200 OK`:**
```json
{
  "status": 200,
  "message": "Success",
  "data": {
    "id": 3,
    "title": "React Native Document Setup",
    "type": "PDF",
    "contentUrl": "https://res.cloudinary.com/.../document.pdf",
    "contentText": "Vui lòng đọc file PDF phía bên dưới...",
    "durationSeconds": null,
    "orderIndex": 3,
    "isCompleted": false,
    "watchTimeSeconds": 0,
    "currentTimeSeconds": 0,
    "lessonProgressPercent": 0.0,
    "courseId": 1,
    "courseTitle": "ThinkAI React Native Course",
    "previousLessonId": 2,
    "nextLessonId": 4
  }
}
```

**Business Logic Phía Frontend/Trình Xem:**
1. Phân loại cấu trúc:
   - Nếu `type = PDF`: Frontend lấy URL tĩnh từ nguồn trả về ngàm vào tag `<object>` hoặc thư viện Document Render để ép đọc trực tiếp chứ chặn tải xuống trực tiếp.
   - Nếu `type = TEXT`: Component sẽ parse nội dung `contentText` từ mảng Markdown để hiện nguyên bản HTML cho user đọc lý thuyết.
2. Với các bài dạng này, không có logic 90% như Video mà phần lớn đòi hỏi có nút "Tôi đã đọc xong điểm danh".

---

## ⑤ Cập nhật & Đồng bộ Tiến độ

### 5.1 Cập nhật liên tục Tiến độ Video

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
| `watchTimeSeconds` | Integer | @NotNull, >= 0 | Thời gian xem luỹ kế của Sinh viên |
| `currentTimeSeconds` | Integer | >= 0 | Vị trí tạm dừng hiện tại của Video (Cho việc Resume) |

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

**Business Logic Auto-Complete:**
1. Mọi Frontend Component Player (như YouTube) sẽ setInterval gọi Endpoint này theo nhịp mỗi **10 giây**.
2. Service cập nhật `watchTimeSeconds`, định vị lưu vết `currentTimeSeconds` và làm tươi `lastAccessedAt`.
3. Logic cốt lõi: So tỷ lệ `% bài học`. Nếu thời lượng xem video luỹ kế chạm ngưỡng **>= 90%** độ dài chuẩn -> Auto Set `isCompleted = true` (Tự động gạch ngang đánh dấu bài học hoàn thành) và set `completedAt = now()`.
4. Sau đó Trigger vòng lặp tính toán lại `% Khóa Học` của tài khoản đó (`(Số bài xong / Tổng bài khóa đó) * 100`).
5. Overwrite con số `%` mới vào bảng trung gian `Enrollments` (trường `progressPercent`). Nếu đạt đúng 100% thì cấp bằng (set `completedAt` cho Enrollment).
6. Trả lại thông số `% mới nhất` (như trên Json) để Frontend vẽ realtime thanh Progress Bar trên Navbar ngay lập tức mà không cần F5.

**Error Responses:**
| Status | Message |
|--------|---------|
| `400` | Validation errors (watchTimeSeconds < 0...) |
| `403` | Bạn chưa đăng ký khóa học này |
| `404` | Bài học không tồn tại |

### Files

| File | Type |
|------|------|
| `dto/UpdateProgressRequest.java` | DTO Hứng tọa độ Update |
| `dto/UpdateProgressResponse.java` | DTO Trả về bộ tham số % hoàn thành |
| `service/VideoProgressService.java` | Xử lý Core Business `updateProgress()` - AutoComplete & Recalculate Enrollment % |
| `controller/VideoProgressController.java` | Cung cấp Endpoint PUT /courses/lessons/{lessonId}/progress |

---

## 🗄️ Database Schema & Entities

### Bảng `enrollments`
| Column | Type | Mô tả |
|--------|------|-------|
| `id` | BIGINT PK | ID đăng ký |
| `user_id` | BIGINT FK | Sinh viên theo học |
| `course_id` | BIGINT FK | Khóa học theo học |
| `progress_percent`| INT | **Trung tâm lưu tiến độ tổng (%)** |
| `enrolled_at` | DATETIME | Ngày nhấp đăng ký tham gia |
| `completed_at` | DATETIME | Ngày hoàn thành toàn bộ khóa học |

### Bảng `lesson_progress`
| Column | Type | Mô tả |
|--------|------|-------|
| `id` | BIGINT PK | ID tiến độ |
| `user_id` | BIGINT FK | ID Sinh viên |
| `lesson_id` | BIGINT FK | ID Bài học cụ thể |
| `is_completed` | BOOLEAN | Cờ hoàn thành tự động hoặc bằng tay |
| `watch_time_seconds`| INT | Số giây đã xem thực sự để check auto-complete |
| `current_time_seconds`| INT | Bookmark vị trí giây video đang xem cho lần sau |
| `last_accessed_at`| DATETIME | Thời khóa biểu cập nhật mới nhất để AI suggest Next Lesson |
| `completed_at` | DATETIME | Thời điểm nhấp/xoay qua mốc 90% |

---

## 🔐 Xác thực & Phân quyền

### Quy ước Security
1. Toàn bộ các API Learning Room và Update Progress bên trên đều được ghim cứng với `@StudentOnly`. Tức chỉ có JWT chứa Role User là STUDENT mới được gọi.
2. Các Role ADMIN, TEACHER không được gọi các đường đẫn này vì đây là cổng chấm điểm cho học sinh.
3. Ở lớp Service, mọi Action từ token JWT phải map đối chiếu xuống Cơ Sở Dữ Liệu xem User này đã khởi tạo kết nối thông qua bảng `enrollments` tới `courseId` mẹ đó chưa, nếu chưa sẽ ném Exception (403).

---

> **Thực hiện bởi:** Nguyễn Anh Khoa  
> **Ngày cập nhật gần nhất:** 30/03/2026

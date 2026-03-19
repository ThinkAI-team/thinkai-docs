# 📚 API Documentation — Nguyễn Anh Khoa

> **Module:** Learning Room & Student Dashboard
> **Backend:** Spring Boot 4.0.2 / Java 25 / MySQL 8.0
> **Cập nhật:** 19/03/2026

---

## Tính năng 1: Dashboard Sinh viên (Trang tổng quan)

Giao diện tổng quan cho sinh viên giúp theo dõi tiến độ học tập, các khóa học đang tham gia và gợi ý bài học tiếp theo.

| Field        | Value                         |
| ------------ | ----------------------------- |
| **Method**   | `GET`                         |
| **Endpoint** | `/users/me/dashboard`         |
| **Auth**     | Bearer Token (**STUDENT**)    |
| **Branch**   | `feature/learning-room/student-dashboard` |

### Response: `200 OK`

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

### Files

| File | Type |
|------|------|
| `dto/DashboardResponse.java` | DTO bao quát Dashboard |
| `dto/EnrolledCourseDto.java` | Thông tin khóa học đã đăng ký |
| `dto/NextLessonDto.java` | Thông tin bài học tiếp theo |
| `service/DashboardService.java` | Xử lý logic Dashboard, tính tiến độ trung bình |
| `controller/DashboardController.java` | Endpoint GET /users/me/dashboard |

---

## Tính năng 2: Learning Room Layout (Cấu trúc phòng học)

Lấy thông tin tổng quan của khóa học trong chế độ phòng học (màn hình chính khi vào học).

| Field        | Value                         |
| ------------ | ----------------------------- |
| **Method**   | `GET`                         |
| **Endpoint** | `/courses/{courseId}/learn`   |
| **Auth**     | Bearer Token (**STUDENT**)    |
| **Branch**   | `feature/learning-room/layout` |

### Path Variables

- `courseId`: ID của khóa học muốn xem nội dung học.

### Response: `200 OK`

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

---

## Tính năng 3 & 4: Chi tiết bài học (Video Player / PDF Viewer)

Lấy nội dung chi tiết của một bài học để hiển thị lên trình phát Video hoặc xem nội dung PDF/Văn bản.

| Field        | Value                         |
| ------------ | ----------------------------- |
| **Method**   | `GET`                         |
| **Endpoint** | `/courses/lessons/{lessonId}` |
| **Auth**     | Bearer Token (**STUDENT**)    |
| **Branch**   | `feature/learning-room/video-player`, `feature/learning-room/pdf-viewer` |

### Path Variables

- `lessonId`: ID của bài học cần lấy nội dung.

### Response: `200 OK`

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
    "courseId": 1,
    "courseTitle": "ThinkAI React Native Course",
    "previousLessonId": null,
    "nextLessonId": 2
  }
}
```

### Business Logic

1. Nếu `type = VIDEO`: Frontend dùng `contentUrl` để hiển thị trình phát Video.
2. Nếu `type = PDF`: Frontend dùng `contentUrl` để hiển thị PDF Viewer.
3. Nếu `type = TEXT`: Hiển thị nội dung từ `contentText`.
4. API tự động trả về `previousLessonId` và `nextLessonId` để điều hướng nội dung.

### Files

| File | Type |
|------|------|
| `dto/LessonDetailResponse.java` | DTO chi tiết bài học đầy đủ thông tin nội dung |
| `service/LearningRoomService.java` | Lấy chi tiết bài học + Navigation info |
| `controller/LearningRoomController.java` | Endpoint GET /courses/lessons/{lessonId} |

---

## Tính năng 5: Đánh dấu hoàn thành bài học

Cập nhật trạng thái đã học của một bài học và đồng bộ tiến độ vào khóa học.

| Field        | Value                                 |
| ------------ | ------------------------------------- |
| **Method**   | `POST`                                |
| **Endpoint** | `/courses/lessons/{lessonId}/complete` |
| **Auth**     | Bearer Token (**STUDENT**)            |
| **Branch**   | `feature/learning-room/lesson-complete` |

### Request Body

```json
{
  "watchTimeSeconds": 600
}
```

### Response: `200 OK`

```json
{
  "status": 200,
  "message": "Lesson marked as completed",
  "data": {
    "lessonId": 1,
    "isCompleted": true,
    "courseProgress": 70
  }
}
```

### Business Logic

1. Kiểm tra tồn tại liên kết Enrollment.
2. Lưu/Cập nhật bản ghi `LessonProgress` là `isCompleted = true`.
3. Tính toán lại tổng số bài học đã hoàn thành / tổng số bài học của khóa học.
4. Cập nhật `progress_percent` trong bảng `Enrollment`.
5. Trả về tiến độ mới nhất của toàn khóa học.

### Files

| File | Type |
|------|------|
| `dto/LessonCompleteRequest.java` | Request DTO chứa thời gian đã xem |
| `dto/LessonCompleteResponse.java` | Response DTO chứa tiến độ khóa học mới |
| `service/LessonProgressService.java` | Logic chính xử lý hoàn thành bài học và tính lại % |
| `controller/LessonProgressController.java` | Endpoint POST /courses/lessons/{lessonId}/complete |

---

## Tổng kết Repository đã tạo

Hệ thống Learning Room sử dụng các Repository quan trọng sau:

| Repository | Mục đích chính |
|------------|----------------|
| `EnrollmentRepository` | Quản lý việc đăng ký và cập nhật tiến độ phần trăm (`progressPercent`) |
| `CourseRepository` | Truy vấn thông tin cơ bản về khóa học |
| `LessonRepository` | Truy vấn danh sách bài học theo `courseId` và sắp xếp theo `orderIndex` |
| `LessonProgressRepository` | Theo dõi trạng thái hoàn thành (`isCompleted`) và thời gian truy cập cuối cùng của từng bài học |

---

> **Thực hiện bởi:** Nguyễn Anh Khoa
> **Ngày hoàn thành:** 19/03/2026

# 📚 API Documentation — Lại Vũ Hoàng Minh

> **Module:** Course Catalog & Enrollment
> **Backend:** Spring Boot 4.0.2 / Java 25 / MySQL 8.0
> **Cập nhật:** 16/03/2026

---

## Tính năng 1: Danh sách khóa học

| Field        | Value      |
| ------------ | ---------- |
| **Method**   | `GET`      |
| **Endpoint** | `/courses` |
| **Auth**     | Public     |
| **Branch**   | `feature/course-catalog/course-list` |

### Query Parameters

| Param      | Type   | Default     | Description              |
| ---------- | ------ | ----------- | ------------------------ |
| `page`     | int    | 0           | Số trang (0-indexed)     |
| `size`     | int    | 10          | Số items/trang (max: 50) |
| `keyword`  | string |             | Tìm theo tên khóa học    |
| `priceMin` | number |             | Giá tối thiểu            |
| `priceMax` | number |             | Giá tối đa               |
| `sortBy`   | string | `createdAt` | Field để sort            |
| `sortDir`  | string | `desc`      | `asc` hoặc `desc`        |

### Response: `200 OK`

```json
{
  "status": 200,
  "message": "Success",
  "data": {
    "content": [
      {
        "id": 1,
        "title": "TOEIC Beginner 450+",
        "thumbnail": "https://...",
        "price": 299000,
        "instructor": {
          "id": 5,
          "fullName": "Nguyễn Văn Giáo"
        },
        "lessonsCount": 15,
        "enrolledCount": 1200
      }
    ],
    "page": 0,
    "size": 10,
    "totalElements": 50,
    "totalPages": 5
  }
}
```

### Files

| File | Type |
|------|------|
| `dto/ApiResponse.java` | Response wrapper `{status, message, data}` |
| `dto/CourseListResponse.java` | DTO danh sách khóa học |
| `repository/CourseRepository.java` | JPQL search + filter + paginate |
| `repository/LessonRepository.java` | Count lessons per course |
| `repository/EnrollmentRepository.java` | Count enrollments per course |
| `service/CourseService.java` | getPublishedCourses() |
| `controller/CourseController.java` | GET /courses |
| `config/GlobalSecurityConfig.java` | Thêm `/courses/**` vào permitAll |

---

## Tính năng 2: Chi tiết khóa học

| Field        | Value                |
| ------------ | -------------------- |
| **Method**   | `GET`                |
| **Endpoint** | `/courses/{courseId}` |
| **Auth**     | Optional (Bearer)    |
| **Branch**   | `feature/course-catalog/course-detail` |

### Response: `200 OK`

```json
{
  "status": 200,
  "message": "Success",
  "data": {
    "id": 1,
    "title": "TOEIC Beginner 450+",
    "description": "Khóa học luyện thi TOEIC cơ bản...",
    "thumbnail": "https://...",
    "price": 299000,
    "instructor": {
      "id": 5,
      "fullName": "Nguyễn Văn Giáo",
      "avatarUrl": "https://..."
    },
    "isEnrolled": false,
    "progressPercent": 0,
    "lessons": [
      {
        "id": 1,
        "title": "Bài 1: Giới thiệu TOEIC",
        "type": "VIDEO",
        "duration": "10:30",
        "isCompleted": false,
        "orderIndex": 1
      }
    ]
  }
}
```

### Error Responses

| Status | Trường hợp |
|--------|------------|
| `404`  | Không tìm thấy khóa học |

### Ghi chú

- Nếu **không gửi token**: `isEnrolled = false`, `progressPercent = 0`
- Nếu **có token**: trả đúng trạng thái enrollment + progress của user
- Lessons sắp xếp theo `orderIndex` tăng dần

### Files

| File | Type |
|------|------|
| `dto/CourseDetailResponse.java` | DTO chi tiết khóa học + InstructorInfo |
| `dto/LessonResponse.java` | DTO bài học |
| `repository/CourseRepository.java` | findById |
| `repository/LessonRepository.java` | findByCourseIdOrderByOrderIndexAsc |
| `repository/EnrollmentRepository.java` | findByUserIdAndCourseId |
| `service/CourseService.java` | getCourseDetail() |
| `controller/CourseController.java` | GET /courses/{courseId} |

---

## Tính năng 3: Đăng ký khóa học

| Field        | Value                        |
| ------------ | ---------------------------- |
| **Method**   | `POST`                       |
| **Endpoint** | `/courses/{courseId}/enroll`  |
| **Auth**     | Bearer Token (**STUDENT**)   |
| **Branch**   | `feature/course-catalog/enrollment` |

### Response: `201 Created`

```json
{
  "status": 201,
  "message": "Enrolled successfully",
  "data": {
    "enrollmentId": 500,
    "courseId": 1,
    "enrolledAt": "2026-03-16T16:40:49"
  }
}
```

### Error Responses

| Status | Trường hợp |
|--------|------------|
| `403`  | Không có token hoặc không phải STUDENT |
| `404`  | Không tìm thấy khóa học |
| `400`  | Khóa học chưa được công bố (isPublished=false hoặc status≠APPROVED) |
| `409`  | Đã đăng ký khóa học này rồi |

### Business Logic

1. Validate user từ JWT token
2. Validate course tồn tại
3. Check `isPublished = true` AND `status = APPROVED`
4. Check chưa đăng ký trùng (`existsByUserIdAndCourseId`)
5. Tạo `Enrollment` mới → trả 201

### Files

| File | Type |
|------|------|
| `dto/EnrollmentResponse.java` | DTO enrollment |
| `repository/CourseRepository.java` | findById |
| `repository/EnrollmentRepository.java` | existsByUserIdAndCourseId |
| `service/CourseService.java` | enrollCourse() |
| `controller/CourseController.java` | POST /courses/{id}/enroll + @StudentOnly |

---

## Tính năng 4: Khóa học của tôi

| Field        | Value              |
| ------------ | ------------------ |
| **Method**   | `GET`              |
| **Endpoint** | `/users/me/courses` |
| **Auth**     | Bearer Token       |
| **Branch**   | (cùng enrollment)  |

### Response: `200 OK`

```json
{
  "status": 200,
  "message": "Success",
  "data": [
    {
      "id": 1,
      "title": "TOEIC Beginner 450+",
      "thumbnail": "https://...",
      "price": 299000,
      "progressPercent": 45,
      "enrolledAt": "2026-03-16T16:40:49",
      "nextLesson": {
        "id": 2,
        "title": "Bài 2: Listening Part 1"
      }
    }
  ]
}
```

---

## Cấu hình chung

### Response Wrapper

Tất cả API đều trả format:

```json
{
  "status": <HTTP_CODE>,
  "message": "<message>",
  "data": <payload>
}
```

### Security

| Endpoint | Auth |
|----------|------|
| `GET /courses` | Public (permitAll) |
| `GET /courses/{id}` | Optional (JWT nếu có) |
| `POST /courses/{id}/enroll` | **@StudentOnly** (JWT bắt buộc) |
| `GET /users/me/courses` | Authenticated |

### Yêu cầu môi trường

File `.env` cần có:

```env
JWT_SECRET=<your-secret-key-min-256-bits>
MAIL_USERNAME=<email>
MAIL_PASSWORD=<password>
```

---

> **Thực hiện bởi:** Lại Vũ Hoàng Minh
> **Ngày hoàn thành:** 16/03/2026

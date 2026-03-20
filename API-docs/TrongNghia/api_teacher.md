# Hướng Dẫn Test Postman - Teacher Portal APIs

Tài liệu này hướng dẫn cách test các API của Module Teacher Portal trên Postman.

## 1. Môi trường & Authentication

- **Base URL:** `http://localhost:8081` (hoặc port bạn đang chạy)
- **Authentication:** Các API này yêu cầu Header `Authorization: Bearer <your_jwt_token>`
  - Đảm bảo tài khoản đăng nhập có role `TEACHER` hoặc `ADMIN` để có quyền truy cập.

---

## 2. Tổng quan API

- Dashboard
  - GET `/teacher/dashboard`
- Khóa học
  - POST `/teacher/courses`
  - GET `/teacher/courses` (paging)
  - GET `/teacher/courses/{id}`
  - PUT `/teacher/courses/{id}`
  - DELETE `/teacher/courses/{id}`
  - PUT `/teacher/courses/{id}/publish`
- Bài học
  - POST `/teacher/courses/{courseId}/lessons`
  - POST `/teacher/courses/{courseId}/lessons/upload`
  - PUT `/teacher/courses/{courseId}/lessons/order`
- Ngân hàng câu hỏi
  - POST `/teacher/questions`
  - POST `/teacher/questions/import`
  - GET `/teacher/questions/bank` (paging)
  - GET `/teacher/questions/{id}`
- Bài thi
  - POST `/teacher/exams`
  - GET `/teacher/exams` (paging)

---

## 3. Dashboard (Teacher)

### GET `/teacher/dashboard`

- Header: `Authorization: Bearer <token>`
- Response 200: `DashboardStatsResponse`
  - `totalCourses` (long)
  - `totalStudents` (long)
  - `completedStudents` (long)
  - `completionRate` (double)

```json
{
  "totalCourses": 5,
  "totalStudents": 120,
  "completedStudents": 45,
  "completionRate": 37.5
}
```

---

## 4. Course (TeacherCourseController)

### POST `/teacher/courses`

- Request body: `CourseRequest`
  - `title`: string, required
  - `description`: string
  - `thumbnailUrl`: string
  - `price`: number (BigDecimal), required, >= 0
- Response 201: entity `Course`
  - `id`, `title`, `description`, `thumbnailUrl`, `price`
  - `instructorId`, `isPublished`, `status` (DRAFT/PENDING/APPROVED/REJECTED)
  - `createdAt`, `updatedAt`

```json
{
  "title": "TOEIC 700+ Mastery",
  "description": "Khóa học luyện thi TOEIC chuyên sâu trong 2 tháng.",
  "thumbnailUrl": "https://example.com/toeic.png",
  "price": 500000
}
```

### GET `/teacher/courses`

- Query params: `page`, `size`, `sort` (Spring Pageable)
- Response 200: `Page<Course>`
  - `content`: array courses
  - `totalElements`, `totalPages`, `size`, `number`, `first`, `last`, `numberOfElements`

### GET `/teacher/courses/{id}`

- Response 200: `Course`

### PUT `/teacher/courses/{id}`

- Request body: `CourseRequest`
- Response 200: updated `Course`

### DELETE `/teacher/courses/{id}`

- Response 204

### PUT `/teacher/courses/{id}/publish`

- Response 200: updated `Course` với `status` chuyển sang `PENDING`

---

## 5. Lesson (TeacherLessonController)

### POST `/teacher/courses/{courseId}/lessons`

- Request body: `LessonRequest`
  - `title`: string, required
  - `type`: enum VIDEO/PDF/QUIZ, required
  - `contentUrl`: string
  - `contentText`: string
  - `durationSeconds`: integer
  - `orderIndex`: integer
- Response 201: entity `Lesson`
  - `id`, `courseId`, `title`, `type`, `contentUrl`, `contentText`, `durationSeconds`, `orderIndex`, `createdAt`, `updatedAt`

```json
{
  "title": "Bài 1: Thì Hiện Tại Đơn",
  "type": "VIDEO",
  "durationSeconds": 600,
  "orderIndex": 1
}
```

### POST `/teacher/courses/{courseId}/lessons/upload`

- Request: form-data, key `file` (multipart)
- Response 200:

```json
{ "url": "https://example.com/files/lesson-1.mp4" }
```

### PUT `/teacher/courses/{courseId}/lessons/order`

- Request body: `LessonOrderRequest`
  - `lessonOrders`: list `LessonOrderUpdate` {lessonId, orderIndex}
- Response 200:

```json
{ "message": "Lessons reordered successfully" }
```

---

## 6. Question Bank (TeacherQuestionBankController)

### POST `/teacher/questions`

- Request body: `QuestionBankRequest`
  - `examType`: enum (TOEIC/IELTS/...)
  - `section`: enum (LISTENING/READING/...)
  - `part`: enum (PART_1/PART_2/...)
  - `content`: string, required
  - `options`: string (JSON text array)
  - `correctAnswer`: string, required
  - `explanation`, `audioUrl`, `imageUrl`: string
  - `difficulty`: enum EASY/MEDIUM/HARD, required
  - `tags`: array string
- Response 201: entity `QuestionBank`
  - `id`, `examType`, `section`, `part`, `content`, `options`, `correctAnswer`, `explanation`, `audioUrl`, `imageUrl`, `difficulty`, `tags`, `createdBy`, `createdAt`

```json
{
  "examType": "TOEIC",
  "section": "READING",
  "part": "PART_5",
  "content": "The manager _____ to the meeting yesterday.",
  "options": "[\"go\", \"goes\", \"went\", \"gone\"]",
  "correctAnswer": "went",
  "difficulty": "EASY",
  "tags": ["grammar", "past-tense"]
}
```

### POST `/teacher/questions/import`

- Request: form-data, key `file` (CSV upload)
- Response 200:

```json
{
  "message": "Import successful",
  "count": 120
}
```

### GET `/teacher/questions/bank`

- Query params: `page`, `size`, `sort`
- Response 200: `Page<QuestionBank>`

### GET `/teacher/questions/{id}`

- Response 200: `QuestionBank`

---

## 7. Exam (TeacherExamController)

### POST `/teacher/exams`

- Request body: `ExamRequest`
  - `courseId`: number, required
  - `title`: string, required
  - `examType`: enum
  - `description`: string
  - `timeLimitMinutes`: integer, required
  - `passingScore`: integer, required
  - `isRandomOrder`: boolean
  - `partConfig`: object map string->int
- Response 201: entity `Exam`
  - `id`, `courseId`, `title`, `examType`, `description`, `timeLimitMinutes`, `passingScore`, `isRandomOrder`, `partConfig`, `createdBy`, `createdAt`

```json
{
  "courseId": 1,
  "title": "Mock Test TOEIC 01",
  "examType": "TOEIC",
  "description": "Bài thi thử TOEIC Format mới",
  "timeLimitMinutes": 120,
  "passingScore": 60,
  "isRandomOrder": true,
  "partConfig": {
    "PART_1": 6,
    "PART_2": 25,
    "PART_5": 30
  }
}
```

### GET `/teacher/exams`

- Query params: `page`, `size`, `sort`
- Response 200: `Page<Exam>`

---

## 8. Lỗi thông dụng

- 400 Bad Request: validation fails
- 401 Unauthorized: token bị thiếu hoặc invalid
- 403 Forbidden: không có quyền TEACHER/ADMIN
- 404 Not Found: resource không tồn tại

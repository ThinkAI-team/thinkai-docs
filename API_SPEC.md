# 🔌 ThinkAI - RESTful API Specification

**Version:** 1.0.0  
**Last Updated:** 2026-01-25  
**Base URL:** `http://localhost:8080/api/v1`  
**Content-Type:** `application/json`

---

## 🛡️ 1. Quy Chuẩn Chung (Standards)

### 1.1. Authentication (Xác thực)

Tất cả các API (trừ Auth public) đều yêu cầu Header:

```
Authorization: Bearer <access_token>
```

### 1.2. Định Dạng Phản Hồi (Response Wrapper)

Tất cả API sẽ trả về dữ liệu theo cấu trúc chuẩn sau:

**Thành công (HTTP 200/201):**

```json
{
  "status": 200,
  "message": "Success",
  "data": { ... }
}
```

**Thất bại (HTTP 400/401/403/500):**

```json
{
  "status": 400,
  "message": "Invalid input data",
  "errors": ["Email không đúng định dạng", "Mật khẩu quá ngắn"]
}
```

### 1.3. HTTP Status Codes

| Code  | Meaning           | Use Case                   |
| ----- | ----------------- | -------------------------- |
| `200` | OK                | Read/Update thành công     |
| `201` | Created           | Tạo mới thành công         |
| `204` | No Content        | Delete thành công          |
| `400` | Bad Request       | Request không hợp lệ       |
| `401` | Unauthorized      | Token không hợp lệ/hết hạn |
| `403` | Forbidden         | Không có quyền truy cập    |
| `404` | Not Found         | Resource không tồn tại     |
| `422` | Unprocessable     | Validation error           |
| `429` | Too Many Requests | Rate limit exceeded        |
| `500` | Internal Error    | Lỗi server                 |

---

## 🔐 2. Authentication Module

### 2.1. Đăng ký tài khoản

| Field        | Value            |
| ------------ | ---------------- |
| **Method**   | `POST`           |
| **Endpoint** | `/auth/register` |
| **Auth**     | Public           |

**Request Body:**

```json
{
  "email": "student@thinkai.com",
  "password": "Password@123",
  "fullName": "Nguyễn Văn A",
  "role": "STUDENT"
}
```

**Validation Rules:**

| Field      | Rules                                                   |
| ---------- | ------------------------------------------------------- |
| `email`    | Required, Valid email format, Unique                    |
| `password` | Required, Min 8 chars, 1 uppercase, 1 number, 1 special |
| `fullName` | Required, 2-100 chars                                   |
| `role`     | Required, Enum: `STUDENT`, `TEACHER`                    |

**Response:** `201 Created`

```json
{
  "status": 201,
  "message": "Registration successful",
  "data": {
    "id": 1,
    "email": "student@thinkai.com",
    "fullName": "Nguyễn Văn A",
    "role": "STUDENT"
  }
}
```

---

### 2.2. Đăng nhập

| Field        | Value         |
| ------------ | ------------- |
| **Method**   | `POST`        |
| **Endpoint** | `/auth/login` |
| **Auth**     | Public        |

**Request Body:**

```json
{
  "email": "student@thinkai.com",
  "password": "Password@123"
}
```

**Response:** `200 OK`

```json
{
  "status": 200,
  "message": "Login successful",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "dTsG5KxR...",
    "expiresIn": 3600,
    "userInfo": {
      "id": 1,
      "email": "student@thinkai.com",
      "fullName": "Nguyễn Văn A",
      "role": "STUDENT",
      "avatarUrl": null
    }
  }
}
```

---

### 2.3. Làm mới Token

| Field        | Value                 |
| ------------ | --------------------- |
| **Method**   | `POST`                |
| **Endpoint** | `/auth/refresh-token` |
| **Auth**     | Public                |

**Request Body:**

```json
{
  "refreshToken": "dTsG5KxR..."
}
```

**Response:** `200 OK`

```json
{
  "status": 200,
  "message": "Token refreshed",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600
  }
}
```

---

### 2.4. Logout

| Field        | Value          |
| ------------ | -------------- |
| **Method**   | `POST`         |
| **Endpoint** | `/auth/logout` |
| **Auth**     | Bearer Token   |

**Response:** `204 No Content`

---

## 👤 3. User Module

### 3.1. Lấy thông tin cá nhân

| Field        | Value        |
| ------------ | ------------ |
| **Method**   | `GET`        |
| **Endpoint** | `/users/me`  |
| **Auth**     | Bearer Token |

**Response:** `200 OK`

```json
{
  "status": 200,
  "message": "Success",
  "data": {
    "id": 1,
    "email": "student@thinkai.com",
    "fullName": "Nguyễn Văn A",
    "avatarUrl": "https://...",
    "phoneNumber": "0987654321",
    "role": "STUDENT",
    "createdAt": "2026-01-01T00:00:00Z"
  }
}
```

---

### 3.2. Cập nhật hồ sơ

| Field        | Value        |
| ------------ | ------------ |
| **Method**   | `PUT`        |
| **Endpoint** | `/users/me`  |
| **Auth**     | Bearer Token |

**Request Body:**

```json
{
  "fullName": "Nguyễn Văn B",
  "avatarUrl": "https://...",
  "phoneNumber": "0987654321"
}
```

**Response:** `200 OK`

---

### 3.3. Đổi mật khẩu

| Field        | Value                |
| ------------ | -------------------- |
| **Method**   | `PUT`                |
| **Endpoint** | `/users/me/password` |
| **Auth**     | Bearer Token         |

**Request Body:**

```json
{
  "currentPassword": "OldPassword@123",
  "newPassword": "NewPassword@456"
}
```

**Response:** `200 OK`

---

## 📚 4. Course Module

### 4.1. Lấy danh sách khóa học

| Field        | Value      |
| ------------ | ---------- |
| **Method**   | `GET`      |
| **Endpoint** | `/courses` |
| **Auth**     | Optional   |

**Query Parameters:**

| Param      | Type   | Default     | Description              |
| ---------- | ------ | ----------- | ------------------------ |
| `page`     | int    | 0           | Số trang (0-indexed)     |
| `size`     | int    | 10          | Số items/trang (max: 50) |
| `keyword`  | string |             | Tìm theo tên khóa học    |
| `priceMin` | number |             | Giá tối thiểu            |
| `priceMax` | number |             | Giá tối đa               |
| `sortBy`   | string | `createdAt` | Field để sort            |
| `sortDir`  | string | `desc`      | `asc` hoặc `desc`        |

**Response:** `200 OK`

```json
{
  "status": 200,
  "message": "Success",
  "data": {
    "content": [
      {
        "id": 101,
        "title": "Java Spring Boot Basic",
        "thumbnail": "https://...",
        "price": 0,
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

---

### 4.2. Chi tiết khóa học

| Field        | Value                 |
| ------------ | --------------------- |
| **Method**   | `GET`                 |
| **Endpoint** | `/courses/{courseId}` |
| **Auth**     | Optional              |

**Response:** `200 OK`

```json
{
  "status": 200,
  "message": "Success",
  "data": {
    "id": 101,
    "title": "Java Spring Boot Basic",
    "description": "Khóa học căn bản về Spring Boot...",
    "thumbnail": "https://...",
    "price": 0,
    "instructor": {
      "id": 5,
      "fullName": "Nguyễn Văn Giáo",
      "avatarUrl": "https://..."
    },
    "isEnrolled": true,
    "progressPercent": 45,
    "lessons": [
      {
        "id": 1,
        "title": "Bài 1: Giới thiệu Spring",
        "type": "VIDEO",
        "duration": "10:30",
        "isCompleted": true,
        "orderIndex": 1
      },
      {
        "id": 2,
        "title": "Bài 2: Dependency Injection",
        "type": "PDF",
        "isCompleted": false,
        "orderIndex": 2
      }
    ]
  }
}
```

---

### 4.3. Đăng ký khóa học

| Field        | Value                        |
| ------------ | ---------------------------- |
| **Method**   | `POST`                       |
| **Endpoint** | `/courses/{courseId}/enroll` |
| **Auth**     | Bearer Token (STUDENT)       |

**Response:** `201 Created`

```json
{
  "status": 201,
  "message": "Enrolled successfully",
  "data": {
    "enrollmentId": 500,
    "courseId": 101,
    "enrolledAt": "2026-01-25T10:00:00Z"
  }
}
```

---

### 4.4. Cập nhật tiến độ học

| Field        | Value                                  |
| ------------ | -------------------------------------- |
| **Method**   | `POST`                                 |
| **Endpoint** | `/courses/lessons/{lessonId}/complete` |
| **Auth**     | Bearer Token (STUDENT)                 |

**Request Body:**

```json
{
  "watchTimeSeconds": 630
}
```

**Response:** `200 OK`

```json
{
  "status": 200,
  "message": "Progress updated",
  "data": {
    "lessonId": 1,
    "isCompleted": true,
    "courseProgress": 10
  }
}
```

---

## 🤖 5. AI Tutor Module

### 5.1. Chat với AI Tutor

| Field          | Value              |
| -------------- | ------------------ |
| **Method**     | `POST`             |
| **Endpoint**   | `/ai/chat`         |
| **Auth**       | Bearer Token       |
| **Rate Limit** | 30 requests/minute |

**Request Body:**

```json
{
  "courseId": 101,
  "lessonId": 2,
  "message": "Dependency Injection hoạt động như thế nào?"
}
```

**Response:** `200 OK`

```json
{
  "status": 200,
  "message": "Success",
  "data": {
    "reply": "Dependency Injection (DI) là một design pattern quan trọng trong Spring...",
    "citations": [
      {
        "source": "Slide bài giảng",
        "page": 5
      }
    ],
    "suggestedQuestions": [
      "Inversion of Control là gì?",
      "Cho ví dụ về @Autowired"
    ]
  }
}
```

---

### 5.2. Tóm tắt bài học

| Field        | Value           |
| ------------ | --------------- |
| **Method**   | `POST`          |
| **Endpoint** | `/ai/summarize` |
| **Auth**     | Bearer Token    |

**Request Body:**

```json
{
  "lessonId": 2
}
```

**Response:** `200 OK`

```json
{
  "status": 200,
  "message": "Success",
  "data": {
    "summary": "## Tóm tắt bài học\n\n1. **Dependency Injection (DI)** là pattern...\n2. **@Autowired** annotation...",
    "keyPoints": [
      "DI giúp giảm coupling",
      "Spring Container quản lý beans",
      "Constructor injection được khuyến khích"
    ]
  }
}
```

---

## 📝 6. Smart Exam Module

### 6.1. Tạo đề thi tự động (AI Generate)

| Field        | Value                         |
| ------------ | ----------------------------- |
| **Method**   | `POST`                        |
| **Endpoint** | `/exams/generate`             |
| **Auth**     | Bearer Token (TEACHER, ADMIN) |

**Request Body:**

```json
{
  "courseId": 101,
  "topic": "Spring Security",
  "difficulty": "MEDIUM",
  "numberOfQuestions": 10
}
```

**Validation:**

| Field               | Rules                                    |
| ------------------- | ---------------------------------------- |
| `courseId`          | Required, Must exist                     |
| `topic`             | Optional, Max 200 chars                  |
| `difficulty`        | Required, Enum: `EASY`, `MEDIUM`, `HARD` |
| `numberOfQuestions` | Required, 5-50                           |

**Response:** `201 Created`

```json
{
  "status": 201,
  "message": "Exam generated successfully",
  "data": {
    "examId": 5005,
    "title": "Bài kiểm tra Spring Security",
    "questionsCount": 10,
    "timeLimit": 30
  }
}
```

---

### 6.2. Bắt đầu làm bài thi

| Field        | Value                   |
| ------------ | ----------------------- |
| **Method**   | `POST`                  |
| **Endpoint** | `/exams/{examId}/start` |
| **Auth**     | Bearer Token (STUDENT)  |

**Response:** `200 OK`

```json
{
  "status": 200,
  "message": "Exam started",
  "data": {
    "attemptId": 10001,
    "examId": 5005,
    "title": "Bài kiểm tra Spring Security",
    "timeLimit": 30,
    "startedAt": "2026-01-25T10:00:00Z",
    "questions": [
      {
        "id": 1,
        "content": "Annotation nào dùng để kích hoạt bảo mật trong Spring?",
        "options": [
          "@EnableWebSecurity",
          "@SpringBootApplication",
          "@Controller",
          "@RestController"
        ],
        "type": "SINGLE_CHOICE"
      }
    ]
  }
}
```

> **Note:** Đáp án đúng KHÔNG được trả về ở bước này để tránh gian lận.

---

### 6.3. Nộp bài thi

| Field        | Value                    |
| ------------ | ------------------------ |
| **Method**   | `POST`                   |
| **Endpoint** | `/exams/{examId}/submit` |
| **Auth**     | Bearer Token (STUDENT)   |

**Request Body:**

```json
{
  "attemptId": 10001,
  "answers": [
    { "questionId": 1, "selectedOption": "A" },
    { "questionId": 2, "selectedOption": "C" }
  ]
}
```

**Response:** `200 OK`

```json
{
  "status": 200,
  "message": "Exam submitted",
  "data": {
    "attemptId": 10001,
    "score": 8.5,
    "totalQuestions": 10,
    "correctCount": 8,
    "passingScore": 6.0,
    "isPassed": true,
    "aiFeedback": "Bạn nắm vững kiến thức cơ bản. Tuy nhiên, cần ôn lại phần JWT Authentication.",
    "details": [
      {
        "questionId": 1,
        "selectedOption": "A",
        "correctOption": "A",
        "isCorrect": true,
        "explanation": "@EnableWebSecurity là annotation bắt buộc..."
      },
      {
        "questionId": 2,
        "selectedOption": "C",
        "correctOption": "B",
        "isCorrect": false,
        "explanation": "JWT token nên được verify..."
      }
    ]
  }
}
```

---

### 6.4. Lịch sử làm bài

| Field        | Value                  |
| ------------ | ---------------------- |
| **Method**   | `GET`                  |
| **Endpoint** | `/exams/history`       |
| **Auth**     | Bearer Token (STUDENT) |

**Query Parameters:**

| Param      | Type | Default | Description       |
| ---------- | ---- | ------- | ----------------- |
| `page`     | int  | 0       | Trang             |
| `size`     | int  | 10      | Items/trang       |
| `courseId` | long |         | Lọc theo khóa học |

**Response:** `200 OK`

```json
{
  "status": 200,
  "message": "Success",
  "data": {
    "content": [
      {
        "attemptId": 10001,
        "examTitle": "Bài kiểm tra Spring Security",
        "score": 8.5,
        "isPassed": true,
        "submittedAt": "2026-01-25T10:30:00Z"
      }
    ],
    "totalElements": 15,
    "totalPages": 2
  }
}
```

---

## 🛠️ 7. Admin Module

> **Auth:** Tất cả endpoints trong module này yêu cầu role `ADMIN`.

### 7.1. Quản lý người dùng

#### Danh sách users

| Field        | Value          |
| ------------ | -------------- |
| **Method**   | `GET`          |
| **Endpoint** | `/admin/users` |

**Query Parameters:** `page`, `size`, `keyword`, `role`, `isActive`

#### Khóa/Mở khóa tài khoản

| Field        | Value                          |
| ------------ | ------------------------------ |
| **Method**   | `PUT`                          |
| **Endpoint** | `/admin/users/{userId}/status` |

**Body:** `{ "isActive": false }`

---

### 7.2. Quản lý khóa học

#### Thêm khóa học mới

| Field        | Value            |
| ------------ | ---------------- |
| **Method**   | `POST`           |
| **Endpoint** | `/admin/courses` |

**Request Body:**

```json
{
  "title": "ReactJS Advanced",
  "description": "Khóa học nâng cao...",
  "price": 500000,
  "instructorId": 5
}
```

#### Cập nhật khóa học

| Field        | Value                       |
| ------------ | --------------------------- |
| **Method**   | `PUT`                       |
| **Endpoint** | `/admin/courses/{courseId}` |

#### Xóa khóa học

| Field        | Value                       |
| ------------ | --------------------------- |
| **Method**   | `DELETE`                    |
| **Endpoint** | `/admin/courses/{courseId}` |

---

### 7.3. Upload tài liệu bài học

| Field            | Value                   |
| ---------------- | ----------------------- |
| **Method**       | `POST`                  |
| **Endpoint**     | `/admin/lessons/upload` |
| **Content-Type** | `multipart/form-data`   |

**Form Data:**

| Field        | Type   | Description              |
| ------------ | ------ | ------------------------ |
| `file`       | Binary | File PDF/MP4 (max 100MB) |
| `courseId`   | long   | ID khóa học              |
| `title`      | string | Tên bài học              |
| `type`       | string | `VIDEO` hoặc `PDF`       |
| `orderIndex` | int    | Thứ tự bài học           |

**Response:** `201 Created`

```json
{
  "status": 201,
  "message": "Lesson uploaded",
  "data": {
    "lessonId": 50,
    "contentUrl": "https://storage.thinkai.com/lessons/50.mp4"
  }
}
```

---

### 7.4. Quản lý AI Prompts

| Field        | Value                        |
| ------------ | ---------------------------- |
| **Method**   | `PUT`                        |
| **Endpoint** | `/admin/settings/ai-prompts` |

**Request Body:**

```json
{
  "tutorSystemPrompt": "Bạn là gia sư AI của ThinkAI...",
  "examGeneratorPrompt": "Tạo câu hỏi trắc nghiệm format JSON..."
}
```

---

## 8. Error Codes Reference

| Code         | HTTP Status | Description               |
| ------------ | ----------- | ------------------------- |
| `AUTH_001`   | 401         | Token không hợp lệ        |
| `AUTH_002`   | 401         | Token đã hết hạn          |
| `AUTH_003`   | 400         | Email đã tồn tại          |
| `USER_001`   | 404         | User không tồn tại        |
| `COURSE_001` | 404         | Khóa học không tồn tại    |
| `COURSE_002` | 400         | Đã đăng ký khóa học này   |
| `EXAM_001`   | 404         | Bài thi không tồn tại     |
| `EXAM_002`   | 400         | Bài thi đã được nộp       |
| `AI_001`     | 429         | Vượt quá rate limit AI    |
| `AI_002`     | 503         | AI service không khả dụng |

---

## 9. Rate Limiting

| Endpoint Group  | Limit | Window   |
| --------------- | ----- | -------- |
| Auth endpoints  | 10    | 1 minute |
| AI endpoints    | 30    | 1 minute |
| General API     | 100   | 1 minute |
| Admin endpoints | 200   | 1 minute |

**Response khi bị rate limit:** `429 Too Many Requests`

```json
{
  "status": 429,
  "message": "Rate limit exceeded",
  "retryAfter": 45
}
```

# 📋 ThinkAI — API Documentation: Smart Exam (Làm bài thi)
**Thành viên:** Mai Pháp  
**Module:** Smart Exam (Làm bài thi)  
**Base URL:** `http://localhost:8081`  
**Auth:** `Authorization: Bearer <access_token>`  
**Last Updated:** 2026-03-18

---

## 📌 Tổng quan 5 tính năng

| # | Tính năng | Mô tả | Số API |
|---|-----------|-------|--------|
| 1 | Danh sách bài thi của khóa học | Giúp học viên xem danh sách các bài thi thuộc một khóa học | 1 |
| 2 | Giao diện làm bài TOEIC/IELTS | Bắt đầu làm bài thi (Listening + Reading) | 1 |
| 3 | Nộp bài thi | Nộp bài thi và tính điểm | 1 |
| 4 | Xem kết quả + AI Feedback | Xem chi tiết kết quả bài làm và nhận nhận xét từ AI | 1 |
| 5 | Lịch sử làm bài | Xem lại lịch sử các bài thi đã làm | 1 |

---

## ① Danh sách bài thi của khóa học

### 1.1 Lấy danh sách bài thi

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Endpoint** | `/exams/{id}/exams` |
| **Auth** | Bearer Token (Authenticated) |

**Path Variables:**
| Name | Type | Validation | Mô tả |
|------|------|------------|-------|
| `id` | Long | @NotNull | ID của khóa học |

**Response `200 OK`:**
```json
[
  {
    "id": 1,
    "title": "TOEIC Full Test 1",
    "description": "Bài thi thử TOEIC chuẩn format mới",
    "durationMinutes": 120,
    "totalQuestions": 200,
    "createdAt": "2026-03-18T10:00:00"
  }
]
```

---

## ② Giao diện làm bài TOEIC/IELTS

### 2.1 Bắt đầu làm bài thi

| Field | Value |
|-------|-------|
| **Method** | `POST` |
| **Endpoint** | `/exams/{id}/start` |
| **Auth** | Bearer Token (Authenticated, Role: STUDENT) |

**Path Variables:**
| Name | Type | Validation | Mô tả |
|------|------|------------|-------|
| `id` | Long | @NotNull | ID của bài thi |

**Response `200 OK`:**
```json
{
  "examSessionId": 101,
  "examId": 1,
  "startTime": "2026-03-18T10:05:00",
  "questions": [
    {
      "id": 1,
      "content": "...",
      "type": "MULTIPLE_CHOICE",
      "options": ["A", "B", "C", "D"]
    }
  ]
}
```

---

## ③ Nộp bài thi

### 3.1 Nộp bài thi

| Field | Value |
|-------|-------|
| **Method** | `POST` |
| **Endpoint** | `/exams/{id}/submit` |
| **Auth** | Bearer Token (Authenticated, Role: STUDENT) |

**Path Variables:**
| Name | Type | Validation | Mô tả |
|------|------|------------|-------|
| `id` | Long | @NotNull | ID của bài thi / session |

**Request Body:**
```json
{
  "examSessionId": 101,
  "answers": [
    {
      "questionId": 1,
      "selectedOption": "A"
    }
  ]
}
```

**Response `200 OK`:**
```json
{
  "resultId": 501,
  "examId": 1,
  "score": 850,
  "correctAnswers": 180,
  "totalQuestions": 200,
  "message": "Nộp bài thành công"
}
```

---

## ④ Xem kết quả + AI Feedback

### 4.1 Xem chi tiết kết quả

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Endpoint** | `/exams/results/{resultId}` |
| **Auth** | Bearer Token (Authenticated, Role: STUDENT) |

**Path Variables:**
| Name | Type | Validation | Mô tả |
|------|------|------------|-------|
| `resultId` | Long | @NotNull | ID của kết quả bài thi |

**Response `200 OK`:**
```json
{
  "resultId": 501,
  "score": 850,
  "details": [
    {
      "questionId": 1,
      "userAnswer": "A",
      "correctAnswer": "A",
      "isCorrect": true,
      "explanation": "..."
    }
  ],
  "aiFeedback": "Phần Reading của bạn rất tốt, tuy nhiên cần cải thiện Listening Part 3..."
}
```

---

## ⑤ Lịch sử làm bài

### 5.1 Lịch sử các bài thi đã làm

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Endpoint** | `/exams/history` |
| **Auth** | Bearer Token (Authenticated) |

**Response `200 OK`:**
```json
[
  {
    "resultId": 501,
    "examTitle": "TOEIC Full Test 1",
    "score": 850,
    "completedAt": "2026-03-18T12:05:00"
  }
]
```

---

## 🗄️ Database Schema (Dự kiến)

### `exams`
| Column | Type | Mô tả |
|--------|------|-------|
| `id` | BIGINT PK | ID |
| `course_id` | BIGINT FK | Khóa học chứa bài thi |
| `title` | VARCHAR(255) | Tên bài thi |
| `duration_minutes` | INT | Thời gian làm bài |
| `total_questions` | INT | Tổng số câu hỏi |

### `exam_sessions`
| Column | Type | Mô tả |
|--------|------|-------|
| `id` | BIGINT PK | ID phiên làm bài |
| `user_id` | BIGINT FK | Người làm bài |
| `exam_id` | BIGINT FK | Bài thi |
| `start_time` | DATETIME | Bắt đầu lúc |
| `end_time` | DATETIME | Kết thúc lúc |
| `score` | INT | Điểm số |
| `ai_feedback` | TEXT | Nhận xét từ AI |

---

## 🔐 Xác thực & Phân quyền

| Endpoint | Auth |
|----------|------|
| `GET /exams/{id}/exams` | Authenticated (Bearer Token) |
| `POST /exams/{id}/start` | Authenticated (StudentOnly) |
| `POST /exams/{id}/submit` | Authenticated (StudentOnly) |
| `GET /exams/results/{resultId}` | Authenticated (StudentOnly) |
| `GET /exams/history` | Authenticated (Bearer Token) |

---

> **Thực hiện bởi:** Mai Pháp  
> **Ngày cập nhật:** 18/03/2026

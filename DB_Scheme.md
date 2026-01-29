# 🗄️ ThinkAI - Database Schema Design

**Version:** 1.1.0  
**Last Updated:** 2026-01-30  
**Database:** MySQL 8.0  
**SQL File:** [thinkai_schema.sql](database/thinkai_schema.sql)

---

## 1. Entity Relationship Diagram (ERD)

```mermaid
erDiagram
    USERS ||--o{ ENROLLMENTS : "enrolls in"
    USERS ||--o{ EXAM_ATTEMPTS : "takes"
    USERS ||--o{ AI_CHAT_LOGS : "chats"
    USERS ||--o{ COURSES : "teaches"
    USERS ||--o{ COURSE_REVIEWS : "reviews"
    USERS ||--o{ REFRESH_TOKENS : "has"

    COURSES ||--o{ ENROLLMENTS : "has"
    COURSES ||--o{ LESSONS : "contains"
    COURSES ||--o{ EXAMS : "has"
    COURSES ||--o{ COURSE_REVIEWS : "reviewed by"

    LESSONS ||--o{ LESSON_PROGRESS : "tracked by"
    LESSONS ||--o{ AI_CHAT_LOGS : "context for"
    LESSONS ||--o{ AI_SUMMARIES : "summarized in"

    EXAMS ||--o{ QUESTIONS : "contains"
    EXAMS ||--o{ EXAM_ATTEMPTS : "attempted by"

    EXAM_ATTEMPTS ||--o{ EXAM_ANSWERS : "includes"
    QUESTIONS ||--o{ EXAM_ANSWERS : "answered in"

    USERS {
        bigint id PK
        varchar email UK
        varchar password_hash
        varchar full_name
        varchar avatar_url
        varchar phone_number
        varchar google_id UK
        enum role "STUDENT, TEACHER, ADMIN"
        boolean is_active
        datetime created_at
        datetime updated_at
    }

    REFRESH_TOKENS {
        bigint id PK
        bigint user_id FK
        varchar token UK
        datetime expires_at
        datetime created_at
    }

    COURSES {
        bigint id PK
        varchar title
        text description
        varchar thumbnail_url
        decimal price
        bigint instructor_id FK
        boolean is_published
        enum status "DRAFT, PENDING, APPROVED, REJECTED"
        datetime created_at
        datetime updated_at
    }

    LESSONS {
        bigint id PK
        bigint course_id FK
        varchar title
        enum type "VIDEO, PDF, QUIZ"
        varchar content_url
        text content_text
        int duration_seconds
        int order_index
        datetime created_at
        datetime updated_at
    }

    ENROLLMENTS {
        bigint id PK
        bigint user_id FK
        bigint course_id FK
        int progress_percent
        datetime enrolled_at
        datetime completed_at
    }

    LESSON_PROGRESS {
        bigint id PK
        bigint user_id FK
        bigint lesson_id FK
        boolean is_completed
        int watch_time_seconds
        datetime last_accessed_at
        datetime completed_at
    }

    EXAMS {
        bigint id PK
        bigint course_id FK
        varchar title
        enum difficulty "EASY, MEDIUM, HARD"
        int time_limit_minutes
        int passing_score
        boolean is_ai_generated
        bigint created_by FK
        datetime created_at
    }

    QUESTIONS {
        bigint id PK
        bigint exam_id FK
        text content
        json options
        varchar correct_option
        enum type "SINGLE_CHOICE, MULTIPLE_CHOICE"
        text explanation
        int order_index
    }

    EXAM_ATTEMPTS {
        bigint id PK
        bigint user_id FK
        bigint exam_id FK
        decimal score
        int correct_count
        int total_questions
        boolean is_passed
        text ai_feedback
        datetime started_at
        datetime submitted_at
    }

    EXAM_ANSWERS {
        bigint id PK
        bigint attempt_id FK
        bigint question_id FK
        varchar selected_option
        boolean is_correct
    }

    AI_CHAT_LOGS {
        bigint id PK
        bigint user_id FK
        bigint course_id FK
        bigint lesson_id FK
        text user_message
        text ai_response
        json citations
        int response_time_ms
        datetime created_at
    }

    AI_SUMMARIES {
        bigint id PK
        bigint lesson_id FK
        text summary_text
        json key_points
        bigint generated_by FK
        datetime created_at
    }

    COURSE_REVIEWS {
        bigint id PK
        bigint course_id FK
        bigint user_id FK
        tinyint rating "1-5"
        text review_text
        boolean is_approved
        datetime created_at
        datetime updated_at
    }

    AI_SETTINGS {
        bigint id PK
        varchar setting_key UK
        text setting_value
        varchar description
        bigint updated_by FK
        datetime created_at
        datetime updated_at
    }

    SYSTEM_LOGS {
        bigint id PK
        bigint user_id FK
        varchar action
        varchar entity_type
        bigint entity_id
        json details
        varchar ip_address
        varchar user_agent
        datetime created_at
    }
```

---

## 2. Chi Tiết Bảng Dữ Liệu

### 2.1. `users` - Người dùng

| Column          | Type         | Constraints        | Description                   |
| --------------- | ------------ | ------------------ | ----------------------------- |
| `id`            | BIGINT       | PK, AUTO_INCREMENT | ID người dùng                 |
| `email`         | VARCHAR(255) | UNIQUE, NOT NULL   | Email đăng nhập               |
| `password_hash` | VARCHAR(255) | NOT NULL           | Mật khẩu mã hóa BCrypt        |
| `full_name`     | VARCHAR(100) | NOT NULL           | Họ tên đầy đủ                 |
| `avatar_url`    | VARCHAR(500) | NULL               | URL ảnh đại diện              |
| `phone_number`  | VARCHAR(20)  | NULL               | Số điện thoại                 |
| `role`          | ENUM         | NOT NULL           | `STUDENT`, `TEACHER`, `ADMIN` |
| `is_active`     | BOOLEAN      | DEFAULT TRUE       | Trạng thái tài khoản          |
| `created_at`    | DATETIME     | NOT NULL           | Ngày tạo                      |
| `updated_at`    | DATETIME     | NOT NULL           | Ngày cập nhật                 |

**Indexes:**

- `idx_users_email` ON `email`
- `idx_users_role` ON `role`

---

### 2.2. `courses` - Khóa học

| Column          | Type          | Constraints        | Description    |
| --------------- | ------------- | ------------------ | -------------- |
| `id`            | BIGINT        | PK, AUTO_INCREMENT | ID khóa học    |
| `title`         | VARCHAR(255)  | NOT NULL           | Tên khóa học   |
| `description`   | TEXT          | NULL               | Mô tả chi tiết |
| `thumbnail_url` | VARCHAR(500)  | NULL               | Ảnh thumbnail  |
| `price`         | DECIMAL(10,2) | DEFAULT 0          | Giá (VND)      |
| `instructor_id` | BIGINT        | FK → users.id      | Giảng viên     |
| `is_published`  | BOOLEAN       | DEFAULT FALSE      | Đã xuất bản    |
| `created_at`    | DATETIME      | NOT NULL           | Ngày tạo       |
| `updated_at`    | DATETIME      | NOT NULL           | Ngày cập nhật  |

**Indexes:**

- `idx_courses_instructor` ON `instructor_id`
- `idx_courses_published` ON `is_published`
- `FULLTEXT idx_courses_search` ON (`title`, `description`)

---

### 2.3. `lessons` - Bài học

| Column             | Type         | Constraints        | Description                    |
| ------------------ | ------------ | ------------------ | ------------------------------ |
| `id`               | BIGINT       | PK, AUTO_INCREMENT | ID bài học                     |
| `course_id`        | BIGINT       | FK → courses.id    | Khóa học chứa bài              |
| `title`            | VARCHAR(255) | NOT NULL           | Tên bài học                    |
| `type`             | ENUM         | NOT NULL           | `VIDEO`, `PDF`, `QUIZ`         |
| `content_url`      | VARCHAR(500) | NULL               | URL video/PDF                  |
| `content_text`     | TEXT         | NULL               | Nội dung text (cho AI context) |
| `duration_seconds` | INT          | DEFAULT 0          | Thời lượng (giây)              |
| `order_index`      | INT          | NOT NULL           | Thứ tự trong khóa học          |
| `created_at`       | DATETIME     | NOT NULL           | Ngày tạo                       |
| `updated_at`       | DATETIME     | NOT NULL           | Ngày cập nhật                  |

**Indexes:**

- `idx_lessons_course` ON `course_id`
- `idx_lessons_order` ON (`course_id`, `order_index`)

---

### 2.4. `enrollments` - Đăng ký học

| Column             | Type     | Constraints        | Description     |
| ------------------ | -------- | ------------------ | --------------- |
| `id`               | BIGINT   | PK, AUTO_INCREMENT | ID đăng ký      |
| `user_id`          | BIGINT   | FK → users.id      | Học viên        |
| `course_id`        | BIGINT   | FK → courses.id    | Khóa học        |
| `progress_percent` | INT      | DEFAULT 0          | Tiến độ (0-100) |
| `enrolled_at`      | DATETIME | NOT NULL           | Ngày đăng ký    |
| `completed_at`     | DATETIME | NULL               | Ngày hoàn thành |

**Indexes:**

- `UNIQUE idx_enrollment_unique` ON (`user_id`, `course_id`)

---

### 2.5. `lesson_progress` - Tiến độ bài học

| Column               | Type     | Constraints        | Description       |
| -------------------- | -------- | ------------------ | ----------------- |
| `id`                 | BIGINT   | PK, AUTO_INCREMENT | ID                |
| `user_id`            | BIGINT   | FK → users.id      | Học viên          |
| `lesson_id`          | BIGINT   | FK → lessons.id    | Bài học           |
| `is_completed`       | BOOLEAN  | DEFAULT FALSE      | Đã hoàn thành     |
| `watch_time_seconds` | INT      | DEFAULT 0          | Thời gian xem     |
| `last_accessed_at`   | DATETIME | NULL               | Lần truy cập cuối |
| `completed_at`       | DATETIME | NULL               | Ngày hoàn thành   |

**Indexes:**

- `UNIQUE idx_progress_unique` ON (`user_id`, `lesson_id`)

---

### 2.6. `exams` - Bài thi

| Column               | Type         | Constraints        | Description              |
| -------------------- | ------------ | ------------------ | ------------------------ |
| `id`                 | BIGINT       | PK, AUTO_INCREMENT | ID bài thi               |
| `course_id`          | BIGINT       | FK → courses.id    | Khóa học                 |
| `title`              | VARCHAR(255) | NOT NULL           | Tên bài thi              |
| `difficulty`         | ENUM         | NOT NULL           | `EASY`, `MEDIUM`, `HARD` |
| `time_limit_minutes` | INT          | DEFAULT 30         | Thời gian làm bài        |
| `passing_score`      | INT          | DEFAULT 60         | Điểm đạt (%)             |
| `is_ai_generated`    | BOOLEAN      | DEFAULT FALSE      | Tạo bởi AI               |
| `created_at`         | DATETIME     | NOT NULL           | Ngày tạo                 |

**Indexes:**

- `idx_exams_course` ON `course_id`

---

### 2.7. `questions` - Câu hỏi

| Column           | Type        | Constraints        | Description                        |
| ---------------- | ----------- | ------------------ | ---------------------------------- |
| `id`             | BIGINT      | PK, AUTO_INCREMENT | ID câu hỏi                         |
| `exam_id`        | BIGINT      | FK → exams.id      | Bài thi                            |
| `content`        | TEXT        | NOT NULL           | Nội dung câu hỏi                   |
| `options`        | JSON        | NOT NULL           | Các đáp án `["A", "B", "C", "D"]`  |
| `correct_option` | VARCHAR(10) | NOT NULL           | Đáp án đúng                        |
| `type`           | ENUM        | NOT NULL           | `SINGLE_CHOICE`, `MULTIPLE_CHOICE` |
| `explanation`    | TEXT        | NULL               | Giải thích đáp án                  |
| `order_index`    | INT         | NOT NULL           | Thứ tự câu hỏi                     |

**Indexes:**

- `idx_questions_exam` ON `exam_id`

---

### 2.8. `exam_attempts` - Lịch sử làm bài

| Column            | Type         | Constraints        | Description     |
| ----------------- | ------------ | ------------------ | --------------- |
| `id`              | BIGINT       | PK, AUTO_INCREMENT | ID lần thi      |
| `user_id`         | BIGINT       | FK → users.id      | Học viên        |
| `exam_id`         | BIGINT       | FK → exams.id      | Bài thi         |
| `score`           | DECIMAL(5,2) | NULL               | Điểm số         |
| `correct_count`   | INT          | DEFAULT 0          | Số câu đúng     |
| `total_questions` | INT          | NOT NULL           | Tổng số câu     |
| `ai_feedback`     | TEXT         | NULL               | Nhận xét AI     |
| `started_at`      | DATETIME     | NOT NULL           | Bắt đầu làm bài |
| `submitted_at`    | DATETIME     | NULL               | Nộp bài         |

**Indexes:**

- `idx_attempts_user` ON `user_id`
- `idx_attempts_exam` ON `exam_id`

---

### 2.9. `exam_answers` - Chi tiết câu trả lời

| Column            | Type        | Constraints           | Description    |
| ----------------- | ----------- | --------------------- | -------------- |
| `id`              | BIGINT      | PK, AUTO_INCREMENT    | ID             |
| `attempt_id`      | BIGINT      | FK → exam_attempts.id | Lần thi        |
| `question_id`     | BIGINT      | FK → questions.id     | Câu hỏi        |
| `selected_option` | VARCHAR(10) | NULL                  | Đáp án đã chọn |
| `is_correct`      | BOOLEAN     | DEFAULT FALSE         | Đúng/Sai       |

**Indexes:**

- `UNIQUE idx_answer_unique` ON (`attempt_id`, `question_id`)

---

### 2.10. `ai_chat_logs` - Log chat AI

| Column         | Type     | Constraints        | Description        |
| -------------- | -------- | ------------------ | ------------------ |
| `id`           | BIGINT   | PK, AUTO_INCREMENT | ID                 |
| `user_id`      | BIGINT   | FK → users.id      | Người dùng         |
| `course_id`    | BIGINT   | FK → courses.id    | Khóa học context   |
| `lesson_id`    | BIGINT   | FK → lessons.id    | Bài học context    |
| `user_message` | TEXT     | NOT NULL           | Câu hỏi người dùng |
| `ai_response`  | TEXT     | NOT NULL           | Câu trả lời AI     |
| `citations`    | JSON     | NULL               | Trích dẫn nguồn    |
| `created_at`   | DATETIME | NOT NULL           | Thời gian          |

**Indexes:**

- `idx_chat_user` ON `user_id`
- `idx_chat_lesson` ON `lesson_id`
- `idx_chat_created` ON `created_at`

---

## 3. Foreign Key Constraints

```sql
-- Courses
ALTER TABLE courses
  ADD CONSTRAINT fk_courses_instructor
  FOREIGN KEY (instructor_id) REFERENCES users(id) ON DELETE SET NULL;

-- Lessons
ALTER TABLE lessons
  ADD CONSTRAINT fk_lessons_course
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE;

-- Enrollments
ALTER TABLE enrollments
  ADD CONSTRAINT fk_enrollments_user
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE enrollments
  ADD CONSTRAINT fk_enrollments_course
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE;

-- Lesson Progress
ALTER TABLE lesson_progress
  ADD CONSTRAINT fk_progress_user
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE lesson_progress
  ADD CONSTRAINT fk_progress_lesson
  FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE;

-- Exams
ALTER TABLE exams
  ADD CONSTRAINT fk_exams_course
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE;

-- Questions
ALTER TABLE questions
  ADD CONSTRAINT fk_questions_exam
  FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE;

-- Exam Attempts
ALTER TABLE exam_attempts
  ADD CONSTRAINT fk_attempts_user
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE exam_attempts
  ADD CONSTRAINT fk_attempts_exam
  FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE;

-- Exam Answers
ALTER TABLE exam_answers
  ADD CONSTRAINT fk_answers_attempt
  FOREIGN KEY (attempt_id) REFERENCES exam_attempts(id) ON DELETE CASCADE;
ALTER TABLE exam_answers
  ADD CONSTRAINT fk_answers_question
  FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE;

-- AI Chat Logs
ALTER TABLE ai_chat_logs
  ADD CONSTRAINT fk_chat_user
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE ai_chat_logs
  ADD CONSTRAINT fk_chat_course
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE SET NULL;
ALTER TABLE ai_chat_logs
  ADD CONSTRAINT fk_chat_lesson
  FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE SET NULL;
```

---

## 4. Indexing Strategy

| Index Type            | Use Case                               |
| --------------------- | -------------------------------------- |
| **Primary Key**       | Unique identifier, JOIN operations     |
| **Unique Index**      | Prevent duplicates (email, enrollment) |
| **Foreign Key Index** | Relationship queries                   |
| **Composite Index**   | Multi-column WHERE/ORDER BY            |
| **Fulltext Index**    | Search functionality                   |

---

## 5. Data Types Decision

| Decision                   | Rationale                              |
| -------------------------- | -------------------------------------- |
| **BIGINT for IDs**         | Future-proof, supports large scale     |
| **DATETIME vs TIMESTAMP**  | DATETIME for explicit timezone control |
| **ENUM for fixed values**  | Type safety, storage efficiency        |
| **JSON for flexible data** | Dynamic options, citations             |
| **TEXT for long content**  | No VARCHAR limit issues                |
| **DECIMAL for scores**     | Precision for calculations             |

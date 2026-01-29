-- ============================================================================
-- THINKAI DATABASE SCHEMA - MySQL 8.0
-- Version: 1.1.0
-- Created: 2026-01-30
-- ============================================================================

-- Xóa database cũ nếu tồn tại (CHỈ DÙNG KHI DEVELOPMENT)
-- DROP DATABASE IF EXISTS thinkai_db;

-- Tạo database
CREATE DATABASE IF NOT EXISTS thinkai_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE thinkai_db;

-- ============================================================================
-- 1. USERS - Người dùng
-- ============================================================================
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    avatar_url VARCHAR(500) NULL,
    phone_number VARCHAR(20) NULL,
    role ENUM('STUDENT', 'TEACHER', 'ADMIN') NOT NULL DEFAULT 'STUDENT',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    google_id VARCHAR(255) NULL COMMENT 'Google OAuth ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_users_email (email),
    UNIQUE KEY uk_users_google_id (google_id),
    INDEX idx_users_role (role),
    INDEX idx_users_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 2. REFRESH_TOKENS - Token làm mới (JWT)
-- ============================================================================
CREATE TABLE refresh_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token VARCHAR(500) NOT NULL,
    expires_at DATETIME NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_refresh_token (token),
    INDEX idx_refresh_user (user_id),
    INDEX idx_refresh_expires (expires_at),
    
    CONSTRAINT fk_refresh_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 3. COURSES - Khóa học
-- ============================================================================
CREATE TABLE courses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NULL,
    thumbnail_url VARCHAR(500) NULL,
    price DECIMAL(12, 2) NOT NULL DEFAULT 0.00 COMMENT 'Giá VND',
    instructor_id BIGINT NULL,
    is_published BOOLEAN NOT NULL DEFAULT FALSE,
    status ENUM('DRAFT', 'PENDING', 'APPROVED', 'REJECTED') NOT NULL DEFAULT 'DRAFT',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_courses_instructor (instructor_id),
    INDEX idx_courses_published (is_published),
    INDEX idx_courses_status (status),
    FULLTEXT INDEX ft_courses_search (title, description),
    
    CONSTRAINT fk_courses_instructor FOREIGN KEY (instructor_id) 
        REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 4. LESSONS - Bài học
-- ============================================================================
CREATE TABLE lessons (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    course_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    type ENUM('VIDEO', 'PDF', 'QUIZ') NOT NULL,
    content_url VARCHAR(500) NULL COMMENT 'URL video hoặc PDF',
    content_text TEXT NULL COMMENT 'Nội dung text cho AI context',
    duration_seconds INT NOT NULL DEFAULT 0,
    order_index INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_lessons_course (course_id),
    INDEX idx_lessons_order (course_id, order_index),
    
    CONSTRAINT fk_lessons_course FOREIGN KEY (course_id) 
        REFERENCES courses(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 5. ENROLLMENTS - Đăng ký khóa học
-- ============================================================================
CREATE TABLE enrollments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    progress_percent INT NOT NULL DEFAULT 0 COMMENT '0-100',
    enrolled_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME NULL,
    
    UNIQUE KEY uk_enrollment (user_id, course_id),
    INDEX idx_enrollments_user (user_id),
    INDEX idx_enrollments_course (course_id),
    
    CONSTRAINT fk_enrollments_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_enrollments_course FOREIGN KEY (course_id) 
        REFERENCES courses(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 6. LESSON_PROGRESS - Tiến độ bài học
-- ============================================================================
CREATE TABLE lesson_progress (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    lesson_id BIGINT NOT NULL,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    watch_time_seconds INT NOT NULL DEFAULT 0,
    last_accessed_at DATETIME NULL,
    completed_at DATETIME NULL,
    
    UNIQUE KEY uk_progress (user_id, lesson_id),
    INDEX idx_progress_user (user_id),
    INDEX idx_progress_lesson (lesson_id),
    
    CONSTRAINT fk_progress_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_progress_lesson FOREIGN KEY (lesson_id) 
        REFERENCES lessons(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 7. EXAMS - Bài thi
-- ============================================================================
CREATE TABLE exams (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    course_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    difficulty ENUM('EASY', 'MEDIUM', 'HARD') NOT NULL DEFAULT 'MEDIUM',
    time_limit_minutes INT NOT NULL DEFAULT 30,
    passing_score INT NOT NULL DEFAULT 60 COMMENT 'Điểm đạt (%)',
    is_ai_generated BOOLEAN NOT NULL DEFAULT FALSE,
    created_by BIGINT NULL COMMENT 'Teacher/Admin tạo',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_exams_course (course_id),
    INDEX idx_exams_creator (created_by),
    
    CONSTRAINT fk_exams_course FOREIGN KEY (course_id) 
        REFERENCES courses(id) ON DELETE CASCADE,
    CONSTRAINT fk_exams_creator FOREIGN KEY (created_by) 
        REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 8. QUESTIONS - Câu hỏi
-- ============================================================================
CREATE TABLE questions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    exam_id BIGINT NOT NULL,
    content TEXT NOT NULL,
    options JSON NOT NULL COMMENT '["Option A", "Option B", "Option C", "Option D"]',
    correct_option VARCHAR(10) NOT NULL COMMENT 'A, B, C, D hoặc A,B cho multi',
    type ENUM('SINGLE_CHOICE', 'MULTIPLE_CHOICE') NOT NULL DEFAULT 'SINGLE_CHOICE',
    explanation TEXT NULL COMMENT 'Giải thích đáp án',
    order_index INT NOT NULL DEFAULT 0,
    
    INDEX idx_questions_exam (exam_id),
    INDEX idx_questions_order (exam_id, order_index),
    
    CONSTRAINT fk_questions_exam FOREIGN KEY (exam_id) 
        REFERENCES exams(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 9. EXAM_ATTEMPTS - Lịch sử làm bài
-- ============================================================================
CREATE TABLE exam_attempts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    exam_id BIGINT NOT NULL,
    score DECIMAL(5, 2) NULL COMMENT 'Điểm số 0-100',
    correct_count INT NOT NULL DEFAULT 0,
    total_questions INT NOT NULL,
    is_passed BOOLEAN NULL,
    ai_feedback TEXT NULL COMMENT 'Nhận xét từ AI',
    started_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    submitted_at DATETIME NULL,
    
    INDEX idx_attempts_user (user_id),
    INDEX idx_attempts_exam (exam_id),
    INDEX idx_attempts_submitted (submitted_at),
    
    CONSTRAINT fk_attempts_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_attempts_exam FOREIGN KEY (exam_id) 
        REFERENCES exams(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 10. EXAM_ANSWERS - Chi tiết câu trả lời
-- ============================================================================
CREATE TABLE exam_answers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    attempt_id BIGINT NOT NULL,
    question_id BIGINT NOT NULL,
    selected_option VARCHAR(10) NULL COMMENT 'Đáp án đã chọn',
    is_correct BOOLEAN NOT NULL DEFAULT FALSE,
    
    UNIQUE KEY uk_answer (attempt_id, question_id),
    INDEX idx_answers_attempt (attempt_id),
    
    CONSTRAINT fk_answers_attempt FOREIGN KEY (attempt_id) 
        REFERENCES exam_attempts(id) ON DELETE CASCADE,
    CONSTRAINT fk_answers_question FOREIGN KEY (question_id) 
        REFERENCES questions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 11. AI_CHAT_LOGS - Log chat AI Tutor
-- ============================================================================
CREATE TABLE ai_chat_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    course_id BIGINT NULL,
    lesson_id BIGINT NULL,
    user_message TEXT NOT NULL,
    ai_response TEXT NOT NULL,
    citations JSON NULL COMMENT '[{"source": "Slide", "page": 5}]',
    response_time_ms INT NULL COMMENT 'Thời gian phản hồi (ms)',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_chat_user (user_id),
    INDEX idx_chat_course (course_id),
    INDEX idx_chat_lesson (lesson_id),
    INDEX idx_chat_created (created_at),
    
    CONSTRAINT fk_chat_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_chat_course FOREIGN KEY (course_id) 
        REFERENCES courses(id) ON DELETE SET NULL,
    CONSTRAINT fk_chat_lesson FOREIGN KEY (lesson_id) 
        REFERENCES lessons(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 12. AI_SUMMARIES - Tóm tắt bài học bởi AI
-- ============================================================================
CREATE TABLE ai_summaries (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    lesson_id BIGINT NOT NULL,
    summary_text TEXT NOT NULL,
    key_points JSON NULL COMMENT '["Point 1", "Point 2"]',
    generated_by BIGINT NULL COMMENT 'User yêu cầu tóm tắt',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_summary_lesson (lesson_id),
    
    CONSTRAINT fk_summary_lesson FOREIGN KEY (lesson_id) 
        REFERENCES lessons(id) ON DELETE CASCADE,
    CONSTRAINT fk_summary_user FOREIGN KEY (generated_by) 
        REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 13. COURSE_REVIEWS - Đánh giá khóa học (Thái Nguyên)
-- ============================================================================
CREATE TABLE course_reviews (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    course_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    rating TINYINT NOT NULL COMMENT '1-5 sao',
    review_text TEXT NULL,
    is_approved BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_review (course_id, user_id) COMMENT 'Mỗi user chỉ review 1 lần/course',
    INDEX idx_reviews_course (course_id),
    INDEX idx_reviews_user (user_id),
    INDEX idx_reviews_rating (rating),
    
    CONSTRAINT fk_reviews_course FOREIGN KEY (course_id) 
        REFERENCES courses(id) ON DELETE CASCADE,
    CONSTRAINT fk_reviews_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT chk_rating CHECK (rating >= 1 AND rating <= 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 14. AI_SETTINGS - Cấu hình AI Prompts (Admin)
-- ============================================================================
CREATE TABLE ai_settings (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL,
    setting_value TEXT NOT NULL,
    description VARCHAR(500) NULL,
    updated_by BIGINT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_setting_key (setting_key),
    
    CONSTRAINT fk_settings_user FOREIGN KEY (updated_by) 
        REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default AI prompts
INSERT INTO ai_settings (setting_key, setting_value, description) VALUES
('TUTOR_SYSTEM_PROMPT', 
 'Bạn là ThinkAI Tutor - gia sư ảo thông minh. Hãy trả lời câu hỏi của học viên dựa trên nội dung bài học được cung cấp. Luôn trích dẫn nguồn từ bài giảng.', 
 'System prompt cho AI Tutor chat'),
('EXAM_GENERATOR_PROMPT', 
 'Tạo câu hỏi trắc nghiệm theo format JSON. Mỗi câu hỏi có 4 đáp án A, B, C, D. Bao gồm giải thích cho đáp án đúng.', 
 'Prompt tạo đề thi tự động'),
('SUMMARY_PROMPT', 
 'Tóm tắt nội dung bài học thành các điểm chính. Output dạng markdown với bullet points.', 
 'Prompt tóm tắt bài học'),
('FEEDBACK_PROMPT', 
 'Phân tích kết quả thi của học viên. Chỉ ra điểm mạnh, điểm yếu và gợi ý bài học cần ôn lại.', 
 'Prompt feedback kết quả thi');

-- ============================================================================
-- 15. SYSTEM_LOGS - Log hệ thống (Optional - cho Admin)
-- ============================================================================
CREATE TABLE system_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NULL COMMENT 'users, courses, exams...',
    entity_id BIGINT NULL,
    details JSON NULL,
    ip_address VARCHAR(45) NULL,
    user_agent VARCHAR(500) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_logs_user (user_id),
    INDEX idx_logs_action (action),
    INDEX idx_logs_entity (entity_type, entity_id),
    INDEX idx_logs_created (created_at),
    
    CONSTRAINT fk_logs_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- VIEWS - Các view tiện ích
-- ============================================================================

-- View: Thống kê khóa học
CREATE OR REPLACE VIEW v_course_stats AS
SELECT 
    c.id AS course_id,
    c.title,
    c.instructor_id,
    u.full_name AS instructor_name,
    COUNT(DISTINCT e.id) AS enrolled_count,
    COUNT(DISTINCT l.id) AS lessons_count,
    COALESCE(AVG(r.rating), 0) AS avg_rating,
    COUNT(DISTINCT r.id) AS reviews_count
FROM courses c
LEFT JOIN users u ON c.instructor_id = u.id
LEFT JOIN enrollments e ON c.id = e.course_id
LEFT JOIN lessons l ON c.id = l.course_id
LEFT JOIN course_reviews r ON c.id = r.course_id AND r.is_approved = TRUE
GROUP BY c.id, c.title, c.instructor_id, u.full_name;

-- View: Dashboard Student
CREATE OR REPLACE VIEW v_student_dashboard AS
SELECT 
    e.user_id,
    COUNT(DISTINCT e.course_id) AS total_courses,
    AVG(e.progress_percent) AS avg_progress,
    SUM(CASE WHEN e.completed_at IS NOT NULL THEN 1 ELSE 0 END) AS completed_courses,
    COUNT(DISTINCT ea.id) AS total_exams_taken
FROM enrollments e
LEFT JOIN courses c ON e.course_id = c.id
LEFT JOIN exams ex ON c.id = ex.course_id
LEFT JOIN exam_attempts ea ON ex.id = ea.exam_id AND ea.user_id = e.user_id
GROUP BY e.user_id;

-- View: Dashboard Teacher
CREATE OR REPLACE VIEW v_teacher_dashboard AS
SELECT 
    c.instructor_id AS teacher_id,
    COUNT(DISTINCT c.id) AS total_courses,
    COUNT(DISTINCT e.user_id) AS total_students,
    COUNT(DISTINCT l.id) AS total_lessons,
    COUNT(DISTINCT ex.id) AS total_exams
FROM courses c
LEFT JOIN enrollments e ON c.id = e.course_id
LEFT JOIN lessons l ON c.id = l.course_id
LEFT JOIN exams ex ON c.id = ex.course_id
WHERE c.instructor_id IS NOT NULL
GROUP BY c.instructor_id;

-- View: Dashboard Admin
CREATE OR REPLACE VIEW v_admin_dashboard AS
SELECT 
    (SELECT COUNT(*) FROM users WHERE role = 'STUDENT' AND is_active = TRUE) AS total_students,
    (SELECT COUNT(*) FROM users WHERE role = 'TEACHER' AND is_active = TRUE) AS total_teachers,
    (SELECT COUNT(*) FROM courses WHERE is_published = TRUE) AS published_courses,
    (SELECT COUNT(*) FROM courses WHERE status = 'PENDING') AS pending_courses,
    (SELECT COUNT(*) FROM enrollments) AS total_enrollments,
    (SELECT COUNT(*) FROM exam_attempts) AS total_exam_attempts,
    (SELECT COUNT(*) FROM ai_chat_logs WHERE DATE(created_at) = CURDATE()) AS ai_chats_today;

-- ============================================================================
-- SAMPLE DATA (Development only)
-- ============================================================================

-- Admin account (password: Admin@123)
INSERT INTO users (email, password_hash, full_name, role) VALUES
('admin@thinkai.com', '$2a$10$N9qo8uLOickgx2ZMRZoMy.MqjRNMT.ZJlNZl3K6gXF1lFkL3SvOVq', 'ThinkAI Admin', 'ADMIN');

-- Teacher account (password: Teacher@123)
INSERT INTO users (email, password_hash, full_name, role) VALUES
('teacher@thinkai.com', '$2a$10$N9qo8uLOickgx2ZMRZoMy.MqjRNMT.ZJlNZl3K6gXF1lFkL3SvOVq', 'Nguyễn Văn Giáo', 'TEACHER');

-- Student account (password: Student@123)
INSERT INTO users (email, password_hash, full_name, role) VALUES
('student@thinkai.com', '$2a$10$N9qo8uLOickgx2ZMRZoMy.MqjRNMT.ZJlNZl3K6gXF1lFkL3SvOVq', 'Trần Văn Học', 'STUDENT');

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================

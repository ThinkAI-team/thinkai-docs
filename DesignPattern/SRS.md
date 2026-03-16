# 📄 ThinkAI - Software Requirements Specification (SRS)

**Version:** 1.0.0  
**Last Updated:** 2026-01-25  
**Project:** ThinkAI - Smart Education Platform

---

## 1. Giới Thiệu

### 1.1. Mục Đích

Tài liệu này mô tả chi tiết các yêu cầu chức năng và phi chức năng của hệ thống ThinkAI - nền tảng E-learning tích hợp AI.

### 1.2. Phạm Vi

ThinkAI cung cấp:

- **AI Tutor:** Gia sư ảo hỗ trợ học viên 24/7
- **Smart Exam:** Tự động tạo đề thi và phân tích kết quả bằng AI
- **Learning Management:** Quản lý khóa học và tiến độ học tập

### 1.3. Đối Tượng Người Dùng

| Role        | Mô Tả                                       |
| ----------- | ------------------------------------------- |
| **Student** | Học viên đăng ký và học các khóa học        |
| **Teacher** | Giảng viên tạo và quản lý nội dung khóa học |
| **Admin**   | Quản trị viên toàn hệ thống                 |

---

## 2. Phân Hệ Người Dùng (Student)

### 2.1. Nhóm Authentication & Account

#### UC-S01: Đăng ký tài khoản

| Thuộc tính        | Giá trị                                                                                                                              |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| **Actor**         | Guest                                                                                                                                |
| **Precondition**  | Email chưa tồn tại trong hệ thống                                                                                                    |
| **Main Flow**     | 1. Nhập email, password, họ tên<br>2. Validate dữ liệu<br>3. Mã hóa password<br>4. Tạo tài khoản<br>5. Gửi email xác nhận (optional) |
| **Postcondition** | Tài khoản được tạo với role STUDENT                                                                                                  |

**Yêu cầu chi tiết:**

- [ ] Đăng ký bằng Email/Password
- [ ] Đăng ký bằng Google OAuth (Phase 2)
- [ ] Validation: Email format, password strength
- [ ] Hiển thị lỗi rõ ràng khi email đã tồn tại

#### UC-S02: Đăng nhập

| Thuộc tính    | Giá trị                                                                                                |
| ------------- | ------------------------------------------------------------------------------------------------------ |
| **Actor**     | Guest                                                                                                  |
| **Main Flow** | 1. Nhập email, password<br>2. Verify credentials<br>3. Generate JWT tokens<br>4. Redirect to Dashboard |

**Yêu cầu chi tiết:**

- [ ] Đăng nhập Email/Password
- [ ] Đăng nhập Google OAuth (Phase 2)
- [ ] Remember me (7 ngày)
- [ ] Lock account sau 5 lần sai

#### UC-S03: Quản lý Profile

**Yêu cầu chi tiết:**

- [ ] Xem thông tin cá nhân
- [ ] Cập nhật họ tên, SĐT, avatar
- [ ] Đổi mật khẩu
- [ ] Xem lịch sử học tập

---

### 2.2. Nhóm Học Tập (Learning)

#### UC-S04: Dashboard

```
┌─────────────────────────────────────────────────────────────┐
│  Dashboard                                                   │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │ Khóa học     │  │ Tiến độ      │  │ Bài học      │       │
│  │ đang học: 3  │  │ trung bình   │  │ tiếp theo    │       │
│  │              │  │     65%      │  │ [Xem ngay]   │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│                                                              │
│  Khóa học của tôi                                           │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ [Thumbnail] Java Spring Boot           Progress: 45%   ││
│  │ [Thumbnail] React Advanced             Progress: 20%   ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

**Yêu cầu chi tiết:**

- [ ] Hiển thị số khóa học đang học
- [ ] Hiển thị tiến độ trung bình
- [ ] Gợi ý bài học tiếp theo (AI suggestion - Phase 2)
- [ ] Quick access đến khóa học gần đây

#### UC-S05: Danh sách khóa học

**Yêu cầu chi tiết:**

- [ ] Hiển thị grid/list khóa học
- [ ] Bộ lọc: Danh mục, Giá, Độ khó
- [ ] Tìm kiếm theo tên khóa học
- [ ] Phân trang (10 items/page)
- [ ] Sort: Mới nhất, Phổ biến, Giá

#### UC-S06: Chi tiết khóa học

**Yêu cầu chi tiết:**

- [ ] Thông tin khóa học: Tên, mô tả, giảng viên
- [ ] Danh sách bài học (Collapse/Expand)
- [ ] Tiến độ học (nếu đã đăng ký)
- [ ] Nút Đăng ký / Tiếp tục học
- [ ] Đánh giá và nhận xét (Phase 2)

#### UC-S07: Learning Room (Phòng học)

```
┌─────────────────────────────────────────────────────────────┐
│  ┌─────────────────────────────────┐  ┌──────────────────┐  │
│  │                                 │  │ Danh sách bài    │  │
│  │         VIDEO PLAYER            │  │                  │  │
│  │                                 │  │ ✓ Bài 1: Intro   │  │
│  │         (Hoặc PDF Viewer)       │  │ ○ Bài 2: Setup   │  │
│  │                                 │  │ ○ Bài 3: Basic   │  │
│  └─────────────────────────────────┘  │                  │  │
│                                       │ [Bài tiếp theo]  │  │
│  ┌─────────────────────────────────┐  └──────────────────┘  │
│  │ 💬 AI Tutor                [▼] │                        │
│  │ Hỏi bất cứ điều gì về bài học  │                        │
│  └─────────────────────────────────┘                        │
└─────────────────────────────────────────────────────────────┘
```

**Yêu cầu chi tiết:**

- [ ] Video Player với controls (Play, Pause, Seek, Speed)
- [ ] PDF Viewer cho tài liệu PDF
- [ ] Sidebar: Danh sách bài học với trạng thái hoàn thành
- [ ] Nút "Đánh dấu hoàn thành"
- [ ] **AI Chat Widget:** Floating button mở chat AI

---

### 2.3. Nhóm AI Tutor

#### UC-S08: Chat với AI Tutor

| Thuộc tính       | Giá trị                                                                                                             |
| ---------------- | ------------------------------------------------------------------------------------------------------------------- |
| **Actor**        | Student (đã đăng ký khóa học)                                                                                       |
| **Precondition** | Đang trong Learning Room                                                                                            |
| **Main Flow**    | 1. Student đặt câu hỏi<br>2. System lấy context bài học<br>3. Gọi Gemini API<br>4. Hiển thị câu trả lời + citations |

**Yêu cầu chi tiết:**

- [ ] Chat realtime (hoặc loading state)
- [ ] Context-aware: Trả lời dựa trên nội dung bài học
- [ ] Hiển thị citations (nguồn tham khảo)
- [ ] Gợi ý câu hỏi tiếp theo
- [ ] Lịch sử chat trong session
- [ ] Rate limit: 30 messages/phút

#### UC-S09: Tóm tắt bài học

**Yêu cầu chi tiết:**

- [ ] Nút "Tóm tắt bài học" trong Learning Room
- [ ] AI tóm tắt nội dung chính
- [ ] Hiển thị key points dạng bullet
- [ ] Có thể copy/save summary

---

### 2.4. Nhóm Khảo Thí (Examination)

#### UC-S10: Làm bài thi

```
┌─────────────────────────────────────────────────────────────┐
│  Bài kiểm tra: Spring Security           ⏱️ 25:30          │
├─────────────────────────────────────────────────────────────┤
│  Câu 3/10                                                    │
│                                                              │
│  Annotation nào dùng để kích hoạt bảo mật trong Spring?     │
│                                                              │
│  ○ A. @EnableWebSecurity                                    │
│  ○ B. @SpringBootApplication                                │
│  ○ C. @Controller                                           │
│  ○ D. @RestController                                       │
│                                                              │
│  [◀ Câu trước]                              [Câu sau ▶]    │
│                                                              │
│  ○ ● ● ○ ○ ○ ○ ○ ○ ○                      [Nộp bài]        │
└─────────────────────────────────────────────────────────────┘
```

**Yêu cầu chi tiết:**

- [ ] Hiển thị câu hỏi (Single/Multiple choice)
- [ ] Countdown timer
- [ ] Navigation giữa các câu hỏi
- [ ] Progress indicator
- [ ] Tự động nộp khi hết giờ
- [ ] Confirm trước khi nộp bài

#### UC-S11: Xem kết quả thi

**Yêu cầu chi tiết:**

- [ ] Hiển thị điểm số
- [ ] Chi tiết từng câu: Đúng/Sai + Giải thích
- [ ] **AI Feedback:** Nhận xét điểm mạnh/yếu
- [ ] Gợi ý bài học cần ôn lại
- [ ] Có thể làm lại bài thi

---

## 3. Phân Hệ Giảng Viên (Teacher)

### 3.1. Quản lý Khóa học

#### UC-T01: Tạo khóa học mới

**Yêu cầu chi tiết:**

- [ ] Nhập thông tin: Tên, mô tả, thumbnail
- [ ] Cài đặt giá (miễn phí hoặc có phí)
- [ ] Thêm/Sắp xếp bài học
- [ ] Preview trước khi publish
- [ ] Lưu nháp

#### UC-T02: Upload nội dung bài học

**Yêu cầu chi tiết:**

- [ ] Upload video (MP4, max 500MB)
- [ ] Upload PDF (max 50MB)
- [ ] Nhập tiêu đề, mô tả bài học
- [ ] Drag & drop để sắp xếp thứ tự
- [ ] Progress bar khi upload

#### UC-T03: Tạo bài thi

**Yêu cầu chi tiết:**

- [ ] Tạo thủ công: Nhập từng câu hỏi
- [ ] **AI Generate:** Tự động tạo từ nội dung

---

### 3.2. Thống kê

#### UC-T04: Dashboard Giảng viên

**Yêu cầu chi tiết:**

- [ ] Tổng học viên đăng ký
- [ ] Tiến độ trung bình của học viên
- [ ] Điểm thi trung bình
- [ ] Câu hỏi được hỏi nhiều nhất (từ AI Chat)

---

## 4. Phân Hệ Quản Trị (Admin)

### 4.1. Quản lý Người dùng

#### UC-A01: Danh sách Users

**Yêu cầu chi tiết:**

- [ ] Tìm kiếm theo email, tên
- [ ] Lọc theo role, trạng thái
- [ ] Khóa/Mở khóa tài khoản
- [ ] Xem chi tiết hoạt động

### 4.2. Quản lý Khóa học

#### UC-A02: Quản lý tất cả khóa học

**Yêu cầu chi tiết:**

- [ ] Duyệt/Từ chối khóa học
- [ ] Xóa khóa học vi phạm
- [ ] Xem thống kê toàn hệ thống

### 4.3. Cấu hình AI

#### UC-A03: Prompt Management

**Yêu cầu chi tiết:**

- [ ] Cấu hình System Prompt cho AI Tutor
- [ ] Cấu hình Prompt tạo đề thi
- [ ] Test prompt trước khi apply

---

## 5. User Role - Feature Matrix

| Feature            | Student | Teacher | Admin |
| ------------------ | :-----: | :-----: | :---: |
| Đăng ký/Đăng nhập  |   ✅    |   ✅    |  ✅   |
| Xem khóa học       |   ✅    |   ✅    |  ✅   |
| Đăng ký khóa học   |   ✅    |   ❌    |  ❌   |
| Học bài            |   ✅    |   ❌    |  ❌   |
| Chat AI Tutor      |   ✅    |   ✅    |  ✅   |
| Làm bài thi        |   ✅    |   ❌    |  ❌   |
| Tạo khóa học       |   ❌    |   ✅    |  ✅   |
| Upload nội dung    |   ❌    |   ✅    |  ✅   |
| Tạo đề thi (AI)    |   ❌    |   ✅    |  ✅   |
| Quản lý users      |   ❌    |   ❌    |  ✅   |
| Cấu hình AI Prompt |   ❌    |   ❌    |  ✅   |

---

## 6. Yêu Cầu Phi Chức Năng (Non-Functional Requirements)

### 6.1. Security

| Yêu cầu              | Chi tiết                                       |
| -------------------- | ---------------------------------------------- |
| **Mã hóa Password**  | BCrypt với strength 10                         |
| **Authentication**   | JWT với access token (1h) + refresh token (7d) |
| **Authorization**    | Role-based access control (RBAC)               |
| **HTTPS**            | Bắt buộc cho production                        |
| **Input Validation** | Server-side validation cho tất cả input        |
| **SQL Injection**    | Sử dụng Prepared Statements (JPA)              |
| **XSS Protection**   | Escape output, Content Security Policy         |

### 6.2. Performance

| Metric                | Target                     |
| --------------------- | -------------------------- |
| **API Response Time** | < 500ms (trừ AI endpoints) |
| **AI Response Time**  | < 5 seconds                |
| **Page Load Time**    | < 3 seconds (LCP)          |
| **Concurrent Users**  | 100 users (MVP)            |
| **Database Queries**  | Indexed queries < 100ms    |

### 6.3. Availability

| Metric       | Target                     |
| ------------ | -------------------------- |
| **Uptime**   | 99% (Free tier limitation) |
| **Backup**   | Daily database backup      |
| **Recovery** | RTO < 4 hours              |

### 6.4. Usability

| Yêu cầu             | Chi tiết                                          |
| ------------------- | ------------------------------------------------- |
| **Responsive**      | Desktop, Tablet, Mobile                           |
| **Browser Support** | Chrome, Firefox, Safari, Edge (latest 2 versions) |
| **Accessibility**   | WCAG 2.1 Level A (Phase 2)                        |
| **Language**        | Tiếng Việt (default), English (Phase 2)           |

### 6.5. Scalability

| Aspect           | Strategy                      |
| ---------------- | ----------------------------- |
| **Frontend**     | Vercel Edge caching           |
| **Backend**      | Horizontal scaling ready      |
| **Database**     | Read replicas (Phase 2)       |
| **File Storage** | Cloud storage (Cloudinary/S3) |

---

## 7. Constraints & Assumptions

### 7.1. Constraints

| Constraint             | Impact                               |
| ---------------------- | ------------------------------------ |
| **Budget: $0**         | Use free tiers only (Vercel, Render) |
| **Gemini API Quota**   | Rate limit AI features               |
| **Team Size: 6**       | Focus on MVP features                |
| **Timeline: 3 months** | Phân chia sprint 2 tuần              |

### 7.2. Assumptions

- Users có kết nối internet ổn định
- Gemini API available 99% thời gian
- Video content không quá 1GB/course
- Max 1000 users trong Phase 1

---

## 8. Appendix

### 8.1. Glossary

| Term              | Definition                                 |
| ----------------- | ------------------------------------------ |
| **AI Tutor**      | Gia sư ảo sử dụng Gemini API               |
| **Smart Exam**    | Đề thi được tạo tự động bởi AI             |
| **Learning Room** | Giao diện học bài với video/PDF và AI chat |
| **Citation**      | Nguồn tham khảo trong câu trả lời AI       |

### 8.2. References

- [Google Gemini API Documentation](https://ai.google.dev/docs)
- [Next.js Documentation](https://nextjs.org/docs)
- [Spring Boot Reference](https://spring.io/projects/spring-boot)

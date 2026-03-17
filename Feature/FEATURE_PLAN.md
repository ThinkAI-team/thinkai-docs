# 📋 ThinkAI - Kế Hoạch Phân Chia Tính Năng

**Version:** 1.1.0  
**Cập nhật:** 2026-02-07  
**Team:** 7 thành viên × 5 tính năng = **35 tính năng**

> [!IMPORTANT]
> **Scope:** Nền tảng học **TIẾNG ANH** - Hỗ trợ luyện thi TOEIC/IELTS

---

## 🎯 Nguyên Tắc Phân Chia

| Nguyên tắc | Mô tả |
|------------|-------|
| **Theo Module** | Mỗi người phụ trách 1-2 module liên quan để dễ debug & test |
| **Full-stack** | Mỗi tính năng bao gồm: UI/UX → Frontend → Backend → Test |
| **Dependencies** | Tính năng cơ sở (Auth, Course base) làm trước |

---

## 👥 Bảng Phân Công Chi Tiết

### 1️⃣ Bình Minh — Module: **Authentication & User Profile**

| # | Tính năng | Độ khó | API liên quan | Màn hình |
|---|-----------|--------|---------------|----------|
| 1 | Đăng ký tài khoản (Email/Password) | ⭐⭐ | `POST /auth/register` | Register Page |
| 2 | Đăng nhập (Email/Password) | ⭐⭐ | `POST /auth/login` | Login Page |
| 3 | Đăng nhập Google OAuth | ⭐⭐⭐ | `POST /auth/google` | Login Page (Google btn) |
| 4 | Quản lý Profile (Xem/Sửa) | ⭐⭐ | `GET/PUT /users/me` | Profile Page |
| 5 | Đổi mật khẩu | ⭐ | `PUT /users/me/password` | Profile Page |

**Dependencies:** Không có (làm đầu tiên)  
**Output:** Auth Context, JWT handling, Protected routes

---

### 2️⃣ Hoàng Minh — Module: **Course Catalog & Enrollment**

| # | Tính năng | Độ khó | API liên quan | Màn hình |
|---|-----------|--------|---------------|----------|
| 1 | Trang chủ (Landing Page) | ⭐⭐ | - | Home Page |
| 2 | Danh sách khóa học (Filter, Search, Sort) | ⭐⭐⭐ | `GET /courses` | Courses List Page |
| 3 | Chi tiết khóa học | ⭐⭐ | `GET /courses/{id}` | Course Detail Page |
| 4 | Đăng ký khóa học (Enroll) | ⭐⭐ | `POST /courses/{id}/enroll` | Course Detail Page |
| 5 | Khóa học của tôi (My Courses) | ⭐⭐ | `GET /users/me/courses` | My Courses Page |

**Dependencies:** Auth module (Bình Minh)  
**Output:** Course listing, Course cards, Enrollment system

---

### 3️⃣ Anh Khoa — Module: **Learning Room & Progress**

| # | Tính năng | Độ khó | API liên quan | Màn hình |
|---|-----------|--------|---------------|----------|
| 1 | Learning Room Layout (Video + Sidebar) | ⭐⭐⭐ | - | Learning Room |
| 2 | Video Player (Play, Pause, Speed, Seek) | ⭐⭐⭐ | - | Learning Room |
| 3 | PDF Viewer | ⭐⭐ | - | Learning Room |
| 4 | Đánh dấu hoàn thành bài học | ⭐⭐ | `POST /courses/lessons/{id}/complete` | Learning Room |
| 5 | Dashboard Sinh viên (Overview + Progress) | ⭐⭐⭐ | `GET /users/me/dashboard` | Student Dashboard |

**Dependencies:** Course module (Hoàng Minh)  
**Output:** Video/PDF players, Progress tracking, Student dashboard

---

### 4️⃣ Bò Trang — Module: **AI Tutor Backend (Gia sư ảo)**

| # | Tính năng | Độ khó | API liên quan | Loại |
|---|-----------|--------|---------------|------|
| 1 | Chat với AI Tutor (Context-aware) | ⭐⭐⭐ | `POST /ai/chat` | Backend + Frontend |
| 2 | Tóm tắt bài học bằng AI | ⭐⭐⭐ | `POST /ai/summarize` | Backend + Frontend |
| 3 | Lịch sử chat AI (Xem lại, xóa cuộc hội thoại) | ⭐⭐ | `GET /ai/chat/history`, `GET /ai/chat/{id}`, `DELETE /ai/chat/{id}` | Backend |
| 4 | AI Settings per User (Ngôn ngữ, độ dài response) | ⭐ | `GET /ai/settings`, `PUT /ai/settings` | Backend |
| 5 | Đánh giá phản hồi AI (Thumbs up/down) | ⭐ | `POST /ai/chat/{messageId}/feedback` | Backend |

**Dependencies:** Auth (Bình Minh), Gemini API integration
**Output:** AI Chat API, AI Summary API, Chat history, AI Settings, Feedback system

> [!NOTE]
> 3 tính năng frontend gốc (AI Chat Widget, Hiển thị Citations, Gợi ý câu hỏi) đã chuyển sang Bình Minh.
> Thay bằng 3 tính năng backend phụ trợ AI Chat: Lịch sử chat, AI Settings, Đánh giá phản hồi.

---

### 5️⃣ Mai Pháp — Module: **Smart Exam (Làm bài thi)**

| # | Tính năng | Độ khó | API liên quan | Màn hình |
|---|-----------|--------|---------------|----------|
| 1 | Danh sách bài thi của khóa học | ⭐⭐ | `GET /courses/{id}/exams` | Course Detail |
| 2 | Giao diện làm bài TOEIC/IELTS (Listening + Reading) | ⭐⭐⭐ | `POST /exams/{id}/start` | Exam Taking Page |
| 3 | Nộp bài thi | ⭐⭐ | `POST /exams/{id}/submit` | Exam Taking Page |
| 4 | Xem kết quả + AI Feedback | ⭐⭐⭐ | - | Exam Result Page |
| 5 | Lịch sử làm bài | ⭐⭐ | `GET /exams/history` | Exam History Page |

**Dependencies:** Course module (Hoàng Minh)  
**Output:** Exam UI, Timer logic, Result display with AI feedback

---

### 6️⃣ Trọng Nghĩa — Module: **Teacher Portal (Quản lý khóa học)**

| # | Tính năng | Độ khó | API liên quan | Màn hình |
|---|-----------|--------|---------------|----------|
| 1 | Dashboard Giảng viên (Thống kê) | ⭐⭐⭐ | `GET /teacher/dashboard` | Teacher Dashboard |
| 2 | Tạo khóa học mới | ⭐⭐⭐ | `POST /teacher/courses` | Create Course Page |
| 3 | Upload nội dung bài học (Video/PDF) | ⭐⭐⭐ | `POST /teacher/lessons/upload` | Lesson Upload Page |
| 4 | Sắp xếp thứ tự bài học (Drag & Drop) | ⭐⭐ | `PUT /teacher/courses/{id}/lessons/order` | Course Editor |
| 5 | Quản lý ngân hàng câu hỏi TOEIC/IELTS | ⭐⭐⭐ | `POST /questions/import` | Question Bank Page |

**Dependencies:** Auth (Bình Minh), File upload service  
**Output:** Teacher dashboard, Course CRUD, AI exam generation

---

### 7️⃣ Thái Nguyên — Module: **Admin Panel**

| # | Tính năng | Độ khó | API liên quan | Màn hình |
|---|-----------|--------|---------------|----------|
| 1 | Admin Dashboard (Thống kê tổng hệ thống) | ⭐⭐⭐ | `GET /admin/dashboard` | Admin Dashboard |
| 2 | Quản lý Users (CRUD + Lock/Unlock) | ⭐⭐⭐ | `GET/PUT /admin/users` | User Management |
| 3 | Quản lý Khóa học (Duyệt/Xóa) | ⭐⭐ | `GET/PUT/DELETE /admin/courses` | Course Management |
| 4 | Cấu hình AI Prompts | ⭐⭐ | `PUT /admin/settings/ai-prompts` | AI Settings Page |
| 5 | Đánh giá & Nhận xét khóa học (Rating System) | ⭐⭐⭐ | `POST/GET /courses/{id}/reviews` | Course Detail |

**Dependencies:** Auth (Bình Minh), All modules for testing  
**Output:** Admin panel, User/Course management, Review system

---

## 📊 Ma Trận Dependencies

```
Bình Minh (Auth) ──┬──► Hoàng Minh (Course) ──► Anh Khoa (Learning)
                   │                                    │
                   │                                    ▼
                   │                    Bò Trang (AI) ◄─┘
                   │                                    
                   ├──► Trọng Nghĩa (Teacher) ──► Mai Pháp (Exam)
                   │
                   └──► Thái Nguyên (Admin)
```

---

## 📅 Timeline Đề Xuất (12 tuần)

| Tuần | Milestone | Người thực hiện |
|------|-----------|-----------------|
| 1-2 | Auth & User Profile | Bình Minh |
| 2-4 | Course Catalog & Enrollment | Hoàng Minh |
| 3-5 | Learning Room & Progress | Anh Khoa |
| 4-6 | AI Tutor | Bò Trang |
| 5-7 | Smart Exam | Mai Pháp |
| 6-8 | Teacher Portal | Trọng Nghĩa |
| 7-9 | Admin Panel | Thái Nguyên |
| 10-12 | Integration, Testing, Fix bugs | ALL |

---

## ✅ Checklist Cho Mỗi Tính Năng

Khi thực hiện mỗi tính năng, đảm bảo hoàn thành:

- [ ] **UI/UX Design** - Figma/Sketch theo Design System
- [ ] **Frontend** - React components + API integration
- [ ] **Backend** - REST API + Business logic
- [ ] **Database** - Schema nếu cần
- [ ] **Unit Tests** - Frontend + Backend
- [ ] **Integration Test** - E2E flow
- [ ] **Documentation** - API docs + README

---

## 📝 Ghi Chú Quan Trọng

> [!IMPORTANT]
> - Mỗi người tự tạo branch theo format: `feature/[tên-module]/[tên-tính-năng]`
> - PR review bởi ít nhất 1 người khác trước khi merge
> - Tuân thủ Design System trong `DESIGN_SYSTEM.md`

> [!TIP]
> - Communicate sớm nếu có blockers
> - Reuse components từ người khác khi có thể
> - Viết test trước khi code (TDD) sẽ giúp debug dễ hơn

# 🏗 ThinkAI - System Architecture

**Version:** 1.0.0  
**Last Updated:** 2026-01-25

---

## 1. Tổng Quan Kiến Trúc

ThinkAI sử dụng kiến trúc **3-tier (Client-Server-Database)** kết hợp với **AI Service Layer** để xử lý các tính năng thông minh.

### 1.1. High-Level Architecture

```mermaid
flowchart TB
    subgraph Client["🖥️ Client Layer"]
        Browser["Web Browser"]
        Mobile["Mobile App (Future)"]
    end

    subgraph Frontend["⚛️ Frontend (Next.js 14)"]
        NextApp["Next.js App Router"]
        Components["React Components"]
        State["State Management"]
    end

    subgraph Backend["☕ Backend (Spring Boot 3)"]
        Gateway["API Gateway"]
        Auth["Auth Service"]
        Course["Course Service"]
        AI["AI Service"]
        Exam["Exam Service"]
    end

    subgraph Database["🗄️ Data Layer"]
        MySQL["MySQL 8.0"]
        Redis["Redis Cache (Future)"]
    end

    subgraph External["🌐 External Services"]
        Gemini["Google Gemini API"]
        Storage["Cloud Storage"]
    end

    Browser --> NextApp
    Mobile --> NextApp
    NextApp --> Gateway
    Gateway --> Auth
    Gateway --> Course
    Gateway --> AI
    Gateway --> Exam

    Auth --> MySQL
    Course --> MySQL
    Exam --> MySQL
    AI --> Gemini
    AI --> MySQL
    Course --> Storage
```

---

## 2. Component Architecture

### 2.1. Frontend Architecture (Next.js)

```mermaid
flowchart TB
    subgraph Pages["📄 Pages (App Router)"]
        Home["/"]
        Login["/login"]
        Dashboard["/dashboard"]
        Course["/courses/[id]"]
        Learn["/learn/[lessonId]"]
        Exam["/exam/[examId]"]
        Admin["/admin/*"]
    end

    subgraph Components["🧩 Components"]
        Layout["Layout Components"]
        UI["UI Components (Shadcn)"]
        Features["Feature Components"]
    end

    subgraph Hooks["🪝 Custom Hooks"]
        useAuth["useAuth"]
        useCourse["useCourse"]
        useAI["useAI"]
    end

    subgraph State["📦 State"]
        AuthContext["Auth Context"]
        QueryClient["TanStack Query"]
    end

    Pages --> Components
    Components --> Hooks
    Hooks --> State
    Hooks --> API["API Client (Axios)"]
```

### 2.2. Backend Architecture (Spring Boot)

```mermaid
flowchart TB
    subgraph Controllers["🎮 Controllers"]
        AuthCtrl["AuthController"]
        UserCtrl["UserController"]
        CourseCtrl["CourseController"]
        AICtrl["AIController"]
        ExamCtrl["ExamController"]
        AdminCtrl["AdminController"]
    end

    subgraph Services["⚙️ Services"]
        AuthSvc["AuthService"]
        UserSvc["UserService"]
        CourseSvc["CourseService"]
        AISvc["AIService"]
        ExamSvc["ExamService"]
    end

    subgraph Repositories["💾 Repositories (JPA)"]
        UserRepo["UserRepository"]
        CourseRepo["CourseRepository"]
        LessonRepo["LessonRepository"]
        ExamRepo["ExamRepository"]
    end

    subgraph Security["🔒 Security"]
        JWTFilter["JWT Filter"]
        SecurityConfig["Security Config"]
    end

    Controllers --> Services
    Services --> Repositories
    Repositories --> DB[(MySQL)]
    JWTFilter --> Controllers
    Services --> External["External APIs"]
```

---

## 3. Luồng Xử Lý Chi Tiết

### 3.1. Luồng AI Tutor (Hỏi Đáp)

```mermaid
sequenceDiagram
    autonumber
    participant U as User
    participant FE as Frontend
    participant BE as Backend
    participant DB as MySQL
    participant AI as Gemini API

    U->>FE: Gửi câu hỏi
    FE->>BE: POST /api/v1/ai/chat
    BE->>DB: Lấy content bài học
    DB-->>BE: Lesson content

    Note over BE: Xây dựng Prompt:<br/>"Context: [Lesson]<br/>Question: [User]"

    BE->>AI: Generate Content
    AI-->>BE: AI Response

    BE->>DB: Lưu chat log
    BE-->>FE: Response với citations
    FE-->>U: Hiển thị câu trả lời
```

### 3.2. Luồng Smart Exam (Tạo Đề Tự Động)

```mermaid
sequenceDiagram
    autonumber
    participant T as Teacher/Admin
    participant FE as Frontend
    participant BE as Backend
    participant DB as MySQL
    participant AI as Gemini API

    T->>FE: Yêu cầu tạo đề thi
    FE->>BE: POST /api/v1/exams/generate
    BE->>DB: Lấy nội dung khóa học
    DB-->>BE: Course content

    Note over BE: Xây dựng Prompt:<br/>"Tạo [N] câu hỏi<br/>Độ khó: [Level]<br/>Format: JSON"

    BE->>AI: Generate Questions
    AI-->>BE: JSON Questions Array

    Note over BE: Parse & Validate JSON

    BE->>DB: Lưu Exam + Questions
    BE-->>FE: Exam created
    FE-->>T: Thông báo thành công
```

### 3.3. Luồng Làm Bài Thi

```mermaid
sequenceDiagram
    autonumber
    participant S as Student
    participant FE as Frontend
    participant BE as Backend
    participant DB as MySQL
    participant AI as Gemini API

    S->>FE: Bắt đầu làm bài
    FE->>BE: POST /exams/{id}/start
    BE->>DB: Tạo exam_attempt
    BE-->>FE: Questions (không có đáp án)

    Note over FE: Countdown Timer<br/>Hiển thị câu hỏi

    S->>FE: Nộp bài
    FE->>BE: POST /exams/{id}/submit
    BE->>DB: Lấy đáp án đúng

    Note over BE: Chấm điểm

    BE->>AI: Phân tích kết quả
    AI-->>BE: AI Feedback

    BE->>DB: Lưu kết quả + feedback
    BE-->>FE: Score + Details
    FE-->>S: Hiển thị kết quả
```

---

## 4. Technology Stack Details

### 4.1. Frontend Stack

| Layer           | Technology              | Purpose                    |
| --------------- | ----------------------- | -------------------------- |
| **Framework**   | Next.js 14 (App Router) | SSR, Routing, API Routes   |
| **UI Library**  | React 18                | Component-based UI         |
| **Styling**     | Tailwind CSS            | Utility-first CSS          |
| **Components**  | Shadcn/UI               | Pre-built components       |
| **Icons**       | Lucide React            | Icon library               |
| **State**       | TanStack Query          | Server state management    |
| **HTTP Client** | Axios                   | API requests               |
| **Forms**       | React Hook Form + Zod   | Form handling & validation |

### 4.2. Backend Stack

| Layer          | Technology         | Purpose                        |
| -------------- | ------------------ | ------------------------------ |
| **Framework**  | Spring Boot 3.2    | Application framework          |
| **Security**   | Spring Security 6  | Authentication & Authorization |
| **ORM**        | Spring Data JPA    | Database access                |
| **Validation** | Jakarta Validation | Input validation               |
| **JWT**        | jjwt               | Token management               |
| **Lombok**     | Lombok             | Boilerplate reduction          |
| **API Docs**   | SpringDoc OpenAPI  | Swagger documentation          |

### 4.3. Database Stack

| Component      | Technology     | Purpose                 |
| -------------- | -------------- | ----------------------- |
| **Primary DB** | MySQL 8.0      | Relational data storage |
| **Caching**    | Redis (Future) | Session & query cache   |
| **Search**     | MySQL FULLTEXT | Course search           |

---

## 5. Deployment Architecture

```mermaid
flowchart TB
    subgraph Production["🌐 Production Environment"]
        subgraph Vercel["Vercel (Free Tier)"]
            FE["Next.js Frontend"]
        end

        subgraph Render["Render (Free Tier)"]
            BE["Spring Boot Backend"]
            MySQL["MySQL Database"]
        end
    end

    subgraph External["External Services"]
        Gemini["Google Gemini API"]
        CloudStorage["Cloudinary/S3"]
    end

    Users["👥 Users"] --> FE
    FE --> BE
    BE --> MySQL
    BE --> Gemini
    BE --> CloudStorage
```

### 5.1. CI/CD Pipeline

```mermaid
flowchart LR
    Dev["👨‍💻 Developer"] --> Push["Git Push"]
    Push --> GitLab["GitLab CI"]

    subgraph Pipeline["CI/CD Pipeline"]
        Build["🔨 Build"]
        Test["🧪 Test"]
        Deploy["🚀 Deploy"]
    end

    GitLab --> Build
    Build --> Test
    Test --> Deploy

    Deploy --> Vercel["Vercel (FE)"]
    Deploy --> Render["Render (BE)"]
```

---

## 6. Security Architecture

### 6.1. Authentication Flow

```mermaid
flowchart TB
    User["User"] --> Login["POST /auth/login"]
    Login --> Validate["Validate Credentials"]
    Validate --> Generate["Generate JWT Tokens"]
    Generate --> Response["Return Access + Refresh Token"]

    subgraph Tokens["JWT Tokens"]
        Access["Access Token (1h)"]
        Refresh["Refresh Token (7d)"]
    end

    Response --> Tokens
```

### 6.2. Authorization Matrix

| Role        | Courses      | AI Chat | Exams    | Admin   |
| ----------- | ------------ | ------- | -------- | ------- |
| **STUDENT** | View, Enroll | ✅ Use  | Take     | ❌      |
| **TEACHER** | CRUD Own     | ✅ Use  | Create   | ❌      |
| **ADMIN**   | CRUD All     | ✅ Use  | CRUD All | ✅ Full |

---

## 7. Folder Structure

### 7.1. Frontend (`applications/frontend`)

```
src/
├── app/                    # Next.js App Router
│   ├── (auth)/            # Auth route group
│   ├── (main)/            # Main app routes
│   ├── admin/             # Admin routes
│   └── api/               # API routes
├── components/
│   ├── ui/                # Shadcn components
│   ├── layout/            # Layout components
│   └── features/          # Feature components
├── hooks/                 # Custom hooks
├── lib/                   # Utilities
├── services/              # API services
└── types/                 # TypeScript types
```

### 7.2. Backend (`applications/backend`)

```
src/main/java/com/thinkai/
├── config/                # Configuration classes
├── controller/            # REST Controllers
├── service/               # Business logic
├── repository/            # JPA Repositories
├── entity/                # JPA Entities
├── dto/                   # Data Transfer Objects
│   ├── request/
│   └── response/
├── exception/             # Custom exceptions
├── security/              # JWT, Security config
└── util/                  # Utility classes
```

---

## 8. Performance Considerations

| Aspect           | Strategy                            |
| ---------------- | ----------------------------------- |
| **API Response** | Target < 500ms (except AI)          |
| **AI Response**  | Target < 5s with streaming          |
| **Database**     | Indexed queries, Connection pooling |
| **Frontend**     | Code splitting, Image optimization  |
| **Caching**      | Redis for sessions (Future)         |

---

## 9. Future Enhancements

| Phase       | Feature       | Description               |
| ----------- | ------------- | ------------------------- |
| **Phase 2** | Redis Cache   | Session & query caching   |
| **Phase 2** | WebSocket     | Real-time notifications   |
| **Phase 3** | Mobile App    | React Native app          |
| **Phase 3** | Microservices | Split into micro services |

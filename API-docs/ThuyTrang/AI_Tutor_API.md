# 📋 ThinkAI — API Documentation: AI Tutor Backend (Gia sư ảo)
**Thành viên:** Bò Trang (Thùy Trang)  
**Module:** AI Tutor Backend  
**Base URL:** `http://localhost:8081`  
**Auth:** `Authorization: Bearer <access_token>` (Yêu cầu cho tất cả API)  
**Last Updated:** 2026-03-20

---

## 📌 Tổng quan 5 tính năng

| # | Tính năng | Mô tả | Số API |
|---|-----------|-------|--------|
| 1 | Chat với AI Tutor | Chat với gia sư ảo AI (Context-aware) | 1 |
| 2 | Tóm tắt bài học bằng AI | Tạo bản tóm tắt bài học dựa trên nội dung | 1 |
| 3 | Lịch sử chat AI | Xem danh sách, chi tiết và xóa lịch sử chat | 3 |
| 4 | AI Settings per User | Cấu hình ngôn ngữ, độ dài phản hồi AI | 2 |
| 5 | Đánh giá phản hồi AI | Đánh giá (Thumbs up/down) cho phản hồi của AI | 1 |

---

## ① Chat với AI Tutor

### 1.1 Gửi tin nhắn chat

| Field | Value |
|-------|-------|
| **Method** | `POST` |
| **Endpoint** | `/ai/chat` |
| **Auth** | Bearer Token (Authenticated) |

**Request Body:**
```json
{
  "message": "Can you explain present perfect tense?",
  "contextId": "123" 
}
```

| Field | Type | Validation | Mô tả |
|-------|------|------------|-------|
| `message` | String | @NotBlank | Nội dung tin nhắn của người dùng |
| `contextId` | String | Optional | ID ngữ cảnh (ví dụ: ID bài học đang học) để AI nắm context |

**Response `200 OK`:**
```json
{
  "chatId": "c_987654",
  "messageId": "m_123456",
  "reply": "The present perfect tense refers to an action or state that either occurred at an indefinite time in the past or began in the past and continued to the present time...",
  "timestamp": "2026-03-20T10:00:00"
}
```

**Business Logic:**
1. Lấy thông tin người dùng từ JWT Token
2. Load AI Settings của người dùng (ngôn ngữ, độ chi tiết)
3. Gọi Gemini API để xử lý câu trả lời dựa trên context và settings
4. Lưu tin nhắn của người dùng và phản hồi của AI vào database
5. Trả về phản hồi cho frontend

**Error Responses:**
| Status | Message |
|--------|---------|
| `400` | Tin nhắn không hợp lệ |
| `401` | Token không hợp lệ hoặc đã hết hạn |
| `500` | Lỗi kết nối AI Service |

---

## ② Tóm tắt bài học bằng AI

### 2.1 Yêu cầu tóm tắt

| Field | Value |
|-------|-------|
| **Method** | `POST` |
| **Endpoint** | `/ai/summarize` |
| **Auth** | Bearer Token (Authenticated) |

**Request Body:**
```json
{
  "lessonId": 456,
  "content": "Nội dung bài học hoặc transcript video cần tóm tắt..."
}
```

| Field | Type | Validation | Mô tả |
|-------|------|------------|-------|
| `lessonId` | Long | @NotNull | ID bài học (tùy chọn lưu liên kết) |
| `content` | String | @NotBlank | Nội dung hoặc transcript cần tóm tắt |

**Response `200 OK`:**
```json
{
  "summary": "Tóm tắt: Bài học nói về cách sử dụng thì hiện tại hoàn thành. Cấu trúc là S + have/has + V3/ed. Dấu hiệu nhận biết: since, for, already, yet...",
  "keyPoints": [
    "Cấu trúc thì hiện tại hoàn thành",
    "Cách sử dụng",
    "Dấu hiệu nhận biết"
  ]
}
```

**Business Logic:**
1. Nhận nội dung bài học hoặc transcript
2. Gửi prompt yêu cầu Gemini tóm tắt kiến thức cốt lõi
3. Format dữ liệu thành đoạn tóm tắt và key points

**Error Responses:**
| Status | Message |
|--------|---------|
| `400` | Nội dung không hợp lệ hoặc quá dài |
| `401` | Token không hợp lệ hoặc hết hạn |

---

## ③ Lịch sử chat AI

### 3.1 Lấy danh sách lịch sử (Phiên chat)

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Endpoint** | `/ai/chat/history` |
| **Auth** | Bearer Token (Authenticated) |

**Query Parameters:**
| Parameter | Type | Default | Mô tả |
|-----------|------|---------|-------|
| `page` | Integer | 0 | Trang hiện tại |
| `size` | Integer | 10 | Số lượng mỗi trang |

**Response `200 OK`:**
```json
{
  "content": [
    {
      "chatId": "c_987654",
      "title": "Hỏi về thì hiện tại hoàn thành",
      "createdAt": "2026-03-20T10:00:00",
      "updatedAt": "2026-03-20T10:05:00"
    }
  ],
  "totalPages": 1,
  "totalElements": 1
}
```

### 3.2 Xem chi tiết phiên chat

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Endpoint** | `/ai/chat/{id}` |
| **Auth** | Bearer Token (Authenticated) |

**Response `200 OK`:**
```json
{
  "chatId": "c_987654",
  "title": "Hỏi về thì hiện tại hoàn thành",
  "messages": [
    {
      "messageId": "m_111",
      "sender": "USER",
      "content": "Can you explain present perfect tense?",
      "timestamp": "2026-03-20T10:00:00"
    },
    {
      "messageId": "m_112",
      "sender": "AI",
      "content": "The present perfect tense refers to...",
      "timestamp": "2026-03-20T10:00:05",
      "feedback": "UP"
    }
  ]
}
```

### 3.3 Xóa lịch sử chat

| Field | Value |
|-------|-------|
| **Method** | `DELETE` |
| **Endpoint** | `/ai/chat/{id}` |
| **Auth** | Bearer Token (Authenticated) |

**Response `200 OK`:**
```json
{
  "message": "Xóa cuộc hội thoại thành công"
}
```

---

## ④ AI Settings per User

### 4.1 Lấy cấu hình AI hiện tại

| Field | Value |
|-------|-------|
| **Method** | `GET` |
| **Endpoint** | `/ai/settings` |
| **Auth** | Bearer Token (Authenticated) |

**Response `200 OK`:**
```json
{
  "language": "VI",
  "responseLength": "MEDIUM",
  "communicationStyle": "FRIENDLY"
}
```

### 4.2 Cập nhật cấu hình AI

| Field | Value |
|-------|-------|
| **Method** | `PUT` |
| **Endpoint** | `/ai/settings` |
| **Auth** | Bearer Token (Authenticated) |

**Request Body:**
```json
{
  "language": "EN",
  "responseLength": "SHORT",
  "communicationStyle": "PROFESSIONAL"
}
```

| Field | Type | Validation | Mô tả |
|-------|------|------------|-------|
| `language` | String | ENUM(VI, EN) | Ngôn ngữ trả lời của AI |
| `responseLength` | String | ENUM(SHORT, MEDIUM, LONG) | Chiều dài câu trả lời |
| `communicationStyle` | String| ENUM(FRIENDLY, PROFESSIONAL) | Phong cách giao tiếp |

**Response `200 OK`:**
```json
{
  "message": "Cập nhật cấu hình thành công",
  "settings": {
    "language": "EN",
    "responseLength": "SHORT",
    "communicationStyle": "PROFESSIONAL"
  }
}
```

**Business Logic:**
1. Upsert cài đặt của người dùng vào DB (dựa trên JWT)
2. Áp dụng các cài đặt này vào prompt cho các API chat/summarize tiếp theo

---

## ⑤ Đánh giá phản hồi AI

### 5.1 Gửi đánh giá

| Field | Value |
|-------|-------|
| **Method** | `POST` |
| **Endpoint** | `/ai/chat/{messageId}/feedback` |
| **Auth** | Bearer Token (Authenticated) |

**Request Body:**
```json
{
  "feedbackType": "UP",
  "comment": "Rất dễ hiểu!"
}
```

| Field | Type | Validation | Mô tả |
|-------|------|------------|-------|
| `feedbackType` | String | ENUM(UP, DOWN) | Thumbs up hoặc Thumbs down |
| `comment` | String | Optional | Nhận xét thêm nếu có |

**Response `200 OK`:**
```json
{
  "message": "Cảm ơn bạn đã phản hồi",
  "feedbackId": "fb_123"
}
```

**Business Logic:**
1. Kiểm tra messageId có tồn tại và thuộc về user không
2. Lưu đánh giá vào database để huấn luyện/phân tích sau này
3. Nếu tin nhắn bị đánh giá DOWN, có thể kích hoạt luồng log để improve prompt

---

## 🗄️ Database Schema (Gợi ý)

### `ai_chats`
| Column | Type | Mô tả |
|--------|------|-------|
| `id` | VARCHAR(50) PK | ID cuộc trò chuyện |
| `user_id` | BIGINT FK | Người sở hữu |
| `title` | VARCHAR(255) | Tiêu đề tóm tắt |
| `created_at` | DATETIME | |
| `updated_at` | DATETIME | |

### `ai_messages`
| Column | Type | Mô tả |
|--------|------|-------|
| `id` | VARCHAR(50) PK | ID tin nhắn |
| `chat_id` | VARCHAR(50) FK | Thuộc cuộc hội thoại nào |
| `sender` | ENUM | `USER` hoặc `AI` |
| `content` | TEXT | Nội dung |
| `timestamp` | DATETIME | |
| `feedback` | ENUM | `UP`, `DOWN`, `NONE` |

### `ai_user_settings`
| Column | Type | Mô tả |
|--------|------|-------|
| `user_id` | BIGINT PK / FK | ID user |
| `language` | VARCHAR(10) | VD: `VI`, `EN` |
| `response_length` | VARCHAR(20) | VD: `SHORT`, `MEDIUM` |
| `style` | VARCHAR(20) | VD: `FRIENDLY` |

---

> **Thực hiện bởi:** Thùy Trang (Bò Trang)  
> **Ngày hoàn thành:** 20/03/2026

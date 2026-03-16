# 🎨 ThinkAI - Hệ thống Thiết kế (Design System)
 
 **Phiên bản:** 1.1.0 (Zen Harmony Edition)  
 **Cập nhật cuối:** 2026-01-30  
 **Dự án:** ThinkAI - Nền tảng Giáo dục Thông minh
 
 ---
 
 ## 1. Triết lý Thiết kế (Design Philosophy)
 
 Phong cách **Zen Harmony** hướng tới sự cân bằng giữa tính thẩm mỹ hiện đại và sự tĩnh lặng tối giản. Mục tiêu là tạo ra một môi trường học tập không gây xao nhãng, sang trọng và dễ tiếp cận.
 
 | Nguyên tắc | Ý nghĩa đối với người dùng |
 |-----------|-----------------------|
 | **Sự Tĩnh Lặng (Zen)** | Sử dụng màu sắc hữu cơ và khoảng trắng lớn để giảm mỏi mắt và căng thẳng. |
 | **Sự Cân Bằng (Symmetry)** | Bố cục căn giữa tuyệt đối tạo cảm giác vững chãi và tin cậy. |
 | **Tính Hiện Đại (Modern)** | Kết hợp các hiệu ứng đổ bóng mờ, bo góc lớn và hiệu ứng kính (glassmorphism). |
 | **Dễ Tiếp Cận (Accessible)** | Đảm bảo độ tương phản đủ tốt để đọc nội dung trong thời gian dài. |
 
 ---
 
 ## 2. Các Thành phần Cơ bản (Design Tokens)
 
 ### 2.1. Bảng màu "Zen Harmony" (Color Palette)
 
 Bảng màu này tập trung vào sự tương phản nhẹ nhàng, tạo cảm giác cao cấp và organic (tự nhiên).
 
 #### Màu sắc Chủ đạo
 
 | Loại | Mã Màu | Tên gọi | Cách sử dụng |
 |------|--------|---------|-------------|
 | **Background** | `#F9F8F3` | Kem Giấy (Organic White) | Nền chính của toàn bộ trang web. |
 | **Primary Text**| `#1F2937` | Xám Than (Charcoal) | Màu chữ chính (Heading, Body). Nhẹ hơn đen thuần để tránh gắt mắt. |
 | **Accent** | `#3B82F6` | Xanh Dương Zen | Dùng cho các nút quan trọng (CTA), trạng thái và liên kết. |
 | **Warm Highlight**| `#EE8B60` | Cam San Hô (Coral) | Điểm nhấn cho các từ khóa quan trọng (thường dùng font Italic). |
 | **Surface** | `#FFFFFF` | Trắng Tinh Khiết | Nền của các thẻ (Cards), bảng biểu để nổi bật trên nền kem. |
 | **Footer Bg** | `#18181B` | Đen Huyền Bí | Nền chân trang, tạo sự vững chãi cho bố cục. |
 
 #### Màu sắc Trạng thái (Semantic Colors)
 
 | Trạng thái | Mã Màu | Ý nghĩa |
 |-----------|--------|---------|
 | **Thành công** | `#10B981` | Khi hoàn thành bài học hoặc nộp bài đúng. |
 | **Lỗi** | `#EF4444` | Thông báo sai sót hoặc lỗi hệ thống. |
 | **Cảnh báo** | `#F59E0B` | Lưu ý người dùng trước các hành động quan trọng. |
 
 > [!TIP]
 > **Quy tắc phối màu:** Luôn ưu tiên dùng màu `#F9F8F3` cho các vùng không gian lớn. Chỉ dùng màu `#FFFFFF` cho các thành phần cần sự tập trung cao như vùng soạn thảo hoặc các thẻ nội dung quan trọng.
 
 ### 2.2. Hệ thống Kiểu chữ (Typography)
 
 Chìa khóa của phong cách Zen là sự kết hợp giữa chữ có chân (Serif) truyền thống và không chân (Sans-serif) hiện đại.
 
 #### Lựa chọn Font chữ
 
 | Loại | Font đề xuất | Đặc điểm | Cách dùng |
 |------|--------------|----------|-----------|
 | **Tiêu đề (Headings)** | `Playfair Display` hoặc `Newsreader` | Serif (có chân), sang trọng, nghệ thuật. | Dùng cho H1, H2, H3. Sử dụng *Italic* cho các từ khóa nhấn mạnh. |
 | **Nội dung (Body)** | `Inter` hoặc `Satoshi` | Sans-serif (không chân), sạch sẽ, dễ đọc. | Dùng cho văn bản, nhãn (labels), nút bấm. |
 
 #### Thông số chi tiết
 
 | Cấp độ | Kích thước | Độ dày (Weight) | Khoảng cách dòng | Ghi chú |
 |--------|------------|----------------|-----------------|---------|
 | **Display 1**| 48px | 500 | 1.1 | Dùng cho tiêu đề Hero lớn nhất. |
 | **Heading 1**| 36px | 500 | 1.2 | Tiêu đề chính của trang. |
 | **Heading 2**| 24px | 500 | 1.3 | Tiêu đề các mục lớn. |
 | **Body Large**| 18px | 400 | 1.6 | Văn bản nội dung quan trọng. |
 | **Body Base** | 16px | 400 | 1.6 | Nội dung mặc định. |
 | **Labels** | 14px | 600 | 1.5 | Nhãn cho Inputs, Tabs (thường viết hoa). |
 
 > [!NOTE]
 > **Lưu ý về nhịp điệu:** Sử dụng font *Italic* cho các danh từ riêng hoặc cụm từ cảm xúc để tạo sự "mềm mại" trong thiết kế vốn dĩ rất quy củ.
 
 ### 2.3. Hệ thống Khoảng cách (Spacing) & Lưới (Grid)
 
 Một thiết kế "Zen" cần rất nhiều "khoảng thở". Đừng sợ những vùng trống lớn.
 
 | Token | Kích thước | Cách sử dụng |
 |-------|------------|-------------|
 | `--space-hero` | 120px - 160px | Padding trên/dưới của khu vực giới thiệu (Hero). |
 | `--space-section` | 80px | Khoảng cách giữa các phần lớn trên trang. |
 | `--space-card` | 24px - 32px | Padding bên trong các thẻ nội dung. |
 | `--container-max`| 1280px | Chiều rộng tối đa của nội dung chính. |
 
 ### 2.4. Độ bo góc (Border Radius)
 
 Sử dụng các góc bo lớn để tạo cảm giác thân thiện, mềm mại như những viên đá cuội.
 
 | Token | Giá trị | Cách sử dụng |
 |-------|---------|-------------|
 | `--radius-sm` | 8px | Nút bấm nhỏ, nhãn (tags). |
 | `--radius-md` | 16px | Các thẻ (Cards) nhỏ, ô nhập liệu (Inputs). |
 | `--radius-lg` | 40px - 48px | Khung trình duyệt (Mockup), các panel lớn. |
 | `--radius-full`| 9999px | Nút bấm dạng viên thuốc (Pill-shaped buttons). |
 
 ### 2.5. Đổ bóng (Shadows)
 
 Phong cách Zen sử dụng đổ bóng rất mờ và rộng để tạo cảm giác vật thể đang nổi nhẹ nhàng trên nền giấy, thay vì các đường viền (borders) cứng nhắc.
 
 | Loại | Giá trị (CSS) | Ý nghĩa |
 |------|--------------|---------|
 | **Soft Shadow** | `0 25px 50px -12px rgba(0,0,0,0.1)` | Dùng cho Browser Mockup hoặc các thẻ Card lớn. |
 | **Subtle Shadow**| `0 4px 6px -1px rgba(0,0,0,0.05)` | Dùng cho các thành phần nhỏ để tạo độ nổi nhẹ. |
 
 ---
 
 ## 3. Các thành phần Giao diện (UI Components)
 
 ### 3.1. Nút bấm (Buttons)
 
 Nút bấm trong Zen Harmony mang hình dáng viên thuốc (pill-shaped) để tối đa hóa sự mềm mại.
 
 | Loại nút | Màu sắc | Cách dùng |
 |----------|---------|-----------|
 | **Chính (Primary)** | Nền `#3B82F6`, chữ Trắng. | Hành động quan trọng nhất (Đăng ký, Bắt đầu). |
 | **Phụ (Secondary)** | Nền `#FFFFFF`, viền mỏng, chữ Xám. | Các hành động bổ trợ (Xem thêm, Hủy). |
 | **Nhấn mạnh (Highlight)**| Nền `#EE8B60`, chữ Trắng. | Các nút cần sự chú ý đặc biệt hoặc khuyến mại. |
 
 ### 3.2. Thành phần Nhập liệu (Form Elements)
 
 Ô nhập liệu cần tối giản hóa, không dùng viền quá đậm. Bo góc `16px` cho sự đồng bộ.
 
 ### 3.3. Thẻ nội dung (Cards)
 
 - **Thẻ khóa học:** Kích thước cố định (Aspect ratio 16:9 cho ảnh), tiêu đề 2 dòng, có tên giáo viên và đánh giá sao. Bo góc `24px`.
 - **Thẻ Dashboard:** Dùng cho thống kê (số lượng khóa học, tiến độ %). Bo góc `16px`, sử dụng icon pastel để phân loại.
 - **Thẻ bài học (Sidebar):** Nền trong suốt hoặc nhẹ, có chỉ báo trạng thái (Hoàn thành - Xanh, Đang học - Cam).
 
 ### 3.4. Công cụ Chat AI (AI Chat Widget)
 
 - **Giao diện hội thoại:** Các bong bóng chat có bo góc lớn (trái dưới/phải dưới giữ vuông nhẹ để định hướng).
 - **Thanh nhập liệu:** Dạng viên thuốc (Pill) kéo dài hết chiều rộng khung chat, icon gửi đặt gọn bên phải.
 - **Trạng thái:** Sử dụng hiệu ứng kính mờ (Glassmorphism) cực mạnh trên nền nội dung.
 
 ---
 
 ## 4. Bố cục trang thực tế (Practical Page Patterns)
 
 Dựa trên phân tích 20+ trang giao diện thực tế của ThinkAI:
 
 ### 4.1. Trang chủ (Landing Page)
 - **Ngôn ngữ visual:** Tiêu đề cực lớn ("chào mừng đến với một kỷ nguyên *học tập* mới"). Chữ *học tập* được in nghiêng bằng font Serif để tạo cảm giác nghệ thuật.
 - **Mockup:** Hình ảnh Dashboard được bọc trong khung trình duyệt bo góc `48px`, đổ bóng mờ ảo tạo độ sâu.
 
 ### 4.2. Dashboard Sinh viên (Student Dashboard)
 - **Sidebar bên trái:** Sử dụng hiệu ứng Glassmorphism giúp giao diện trông hiện đại và không bị bí. Các icon được thiết kế dạng nét mảnh (Outline).
 - **Khu vực trung tâm:** Lời chào cá nhân hóa ("Chào buổi sáng, Minh! 👋") sử dụng font Serif cỡ lớn.
 - **Lịch học tập:** Tích hợp nhỏ gọn ở góc phải dưới với các điểm đánh dấu tiến độ màu cam.
 
 ### 4.3. Gia sư ảo 24/7 (AI Tutor)
 - **Căn giữa (Centered Focus):** Toàn bộ giao diện chat được tập trung vào giữa màn hình để người dùng không bị xao nhãng.
 - **Gợi ý nhanh:** Các nút nhỏ bên dưới câu trả lời của AI ("Giải thích đơn giản hơn", "Cho ví dụ thực tế") giúp người dùng tương tác nhanh.
 
 ---
 
 ## 5. Thông số Kỹ thuật (Technical Specs)
 
 | Yếu tố | Giá trị Tailwind / CSS | Ghi chú |
 |--------|------------------------|---------|
 | **Góc bo lớn** | `rounded-[40px]` - `rounded-[48px]` | Cho mockup và các panel lớn. |
 | **Góc bo vừa** | `rounded-2xl` (16px) | Cho các thẻ Card và ô nhập liệu. |
 | **Nền mờ** | `backdrop-filter: blur(16px)` | Cho Sidebar và Navbar. |
 | **Đổ bóng Zen**| `shadow-[0_25px_50px_-12px_rgba(0,0,0,0.1)]` | Hiệu ứng nổi nhẹ nhàng. |
 
 ---
 
 ## 6. Hướng dẫn Trải nghiệm (UX Guidelines)
 
 - **Typing Effect:** Thêm hiệu ứng gõ chữ khi AI trả lời để tăng cảm giác "con người".
 - **Soft Transitions:** Toàn bộ hiệu ứng hover và chuyển trang sử dụng `duration-500 ease-in-out`.
 - **Whitespace:** Giữ khoảng cách tối thiểu `24px` giữa các thành phần để giao diện không bị ngột ngạt.
 
 ---
 
 <p align="center">
   <strong>ThinkAI Design System - Phiên bản Zen Harmony</strong><br>
   Thiết kế lấy cảm hứng từ sự tĩnh lặng và hiệu quả.
 </p>

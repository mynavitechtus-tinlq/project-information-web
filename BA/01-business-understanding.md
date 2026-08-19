# Business Understanding (BU) — Hệ thống Quản lý Dự án, Tech Stack & Bảo mật

> **Phase**: Design — Foundation | **Ngôn ngữ**: Tiếng Việt | **Trạng thái**: Draft v0.1 — chờ BU verify
> **Nguồn**: Context dự án do khách hàng/PO cung cấp `[FROM-TEAM]`. Các nội dung mở rộng chưa được xác nhận đều gắn nhãn `[ASSUMED]`.

---

## 1. Business overview

Hệ thống là một công cụ quản trị nội bộ giúp tổ chức theo dõi **toàn bộ danh mục dự án phần mềm** đang vận hành: mỗi dự án dùng công nghệ gì, phiên bản nào, và đang tồn tại những rủi ro bảo mật nào. Người hưởng lợi chính là **quản lý kỹ thuật và đội ngũ phát triển**: thay vì phải hỏi từng team hoặc lục tài liệu rời rạc, họ tra cứu một nơi duy nhất để biết tình trạng công nghệ và bảo mật của từng dự án.

Hệ thống gồm năm khối chức năng chính: đăng nhập và phân quyền (hai vai trò Admin và User); quản lý Project (thông tin dự án, repository, thành viên và trạng thái); quản lý Tech Stack theo Project (ngôn ngữ lập trình, framework, database, cache, cloud và phiên bản đang sử dụng); quản lý Security (theo dõi lỗ hổng CVE, phiên bản thư viện, trạng thái xử lý và khuyến nghị nâng cấp); và Dashboard hiển thị thống kê tổng quan.

Hệ thống là công cụ **theo dõi và ghi nhận** (registry): dữ liệu tech stack và lỗ hổng được con người nhập/cập nhật; hệ thống không tự quét mã nguồn hay tự đồng bộ từ scanner bên ngoài trong phạm vi lần triển khai này `[ASSUMED — xem Q-02]`.

## 2. Business goals & success criteria

| # | Mục tiêu | Tiêu chí thành công |
|---|----------|---------------------|
| G-01 | Có một nguồn duy nhất về danh mục dự án và công nghệ đang sử dụng | 100% dự án đang vận hành có hồ sơ trên hệ thống với tech stack đầy đủ |
| G-02 | Nhìn thấy sớm rủi ro bảo mật theo từng dự án | Mỗi lỗ hổng CVE liên quan được ghi nhận kèm trạng thái xử lý; không có lỗ hổng nghiêm trọng nào "không ai theo dõi" |
| G-03 | Giảm thời gian tổng hợp báo cáo tình trạng công nghệ/bảo mật | Quản lý xem được Dashboard tổng quan thay vì tổng hợp thủ công |
| G-04 | Kiểm soát ai được sửa dữ liệu | Phân quyền Admin/User rõ ràng; thao tác quản trị chỉ dành cho Admin |

## 3. Stakeholders & roles (business)

| Vai trò | Mô tả | Quan tâm chính |
|---------|-------|----------------|
| Admin | Quản trị hệ thống: quản lý tài khoản, phân quyền, toàn quyền trên dữ liệu | Dữ liệu chuẩn, kiểm soát truy cập |
| User | Thành viên dự án / kỹ sư: xem và cập nhật dữ liệu trong phạm vi được phép | Tra cứu nhanh, cập nhật thuận tiện |
| Quản lý kỹ thuật (đọc Dashboard) | Có thể là Admin hoặc User tùy tổ chức `[ASSUMED]` | Bức tranh tổng quan, rủi ro bảo mật |

## 4. As-Is process (high-level)

Hiện tại thông tin dự án, công nghệ và lỗ hổng được quản lý phân tán (file Excel, tài liệu wiki, trao đổi trực tiếp) `[ASSUMED — cần xác nhận hiện trạng]`. Hệ quả: khó biết dự án nào đang dùng thư viện có lỗ hổng, khó tổng hợp báo cáo, thông tin nhanh lỗi thời.

## 5. To-Be process (high-level)

1. Admin tạo tài khoản và phân quyền cho thành viên.
2. Admin/User tạo hồ sơ Project: thông tin chung, repository, thành viên, trạng thái.
3. Với mỗi Project, người phụ trách khai báo Tech Stack: ngôn ngữ, framework, database, cache, cloud và phiên bản đang sử dụng.
4. Khi phát hiện lỗ hổng (CVE) liên quan tới thư viện/phiên bản đang dùng, người phụ trách ghi nhận vào hệ thống: mã CVE, thư viện và phiên bản ảnh hưởng, mức nghiêm trọng, trạng thái xử lý, khuyến nghị nâng cấp.
5. Trạng thái xử lý được cập nhật theo tiến độ (ví dụ: Mới ghi nhận → Đang xử lý → Đã xử lý / Chấp nhận rủi ro).
6. Dashboard tổng hợp: số dự án theo trạng thái, phân bố công nghệ, số lỗ hổng theo mức nghiêm trọng và trạng thái.

## 6. Business rules

**Nhóm phân quyền**

- BR-01: Chỉ Admin được tạo/khóa tài khoản và thay đổi vai trò người dùng.
- BR-02: User chỉ được cập nhật dữ liệu của các Project mà mình là thành viên `[ASSUMED — xem Q-03]`; Admin cập nhật được mọi Project.
- BR-03: Mọi người dùng đã đăng nhập đều xem được Dashboard và danh sách Project `[ASSUMED — xem Q-03]`.

**Nhóm dữ liệu Project & Tech Stack**

- BR-04: Tên Project không được trùng trong toàn hệ thống.
- BR-05: Một Project có thể có nhiều repository và nhiều thành viên; mỗi thành viên có vai trò trong dự án (ví dụ PM, Dev) `[ASSUMED]`.
- BR-06: Mỗi hạng mục tech stack phải ghi rõ loại (ngôn ngữ / framework / database / cache / cloud), tên và phiên bản đang sử dụng.

**Nhóm bảo mật**

- BR-07: Mỗi lỗ hổng phải gắn với ít nhất một Project và ghi rõ thư viện/phiên bản bị ảnh hưởng.
- BR-08: Lỗ hổng phải có mức nghiêm trọng (Critical/High/Medium/Low) và trạng thái xử lý; không được xóa lỗ hổng đã ghi nhận, chỉ chuyển trạng thái `[ASSUMED]`.
- BR-09: Khi lỗ hổng được xử lý bằng nâng cấp phiên bản, tech stack của Project cần được cập nhật tương ứng (quy trình thủ công, hệ thống không tự đổi).

## 7. Business scenarios

### 7.1 Happy paths

- HP-01: Admin tạo tài khoản mới cho một kỹ sư, gán vai trò User; kỹ sư đăng nhập và thấy các Project của mình.
- HP-02: PM tạo Project mới, khai báo repository, thêm thành viên, khai báo tech stack.
- HP-03: Kỹ sư ghi nhận CVE mới cho thư viện đang dùng, đặt mức High, trạng thái "Đang xử lý", kèm khuyến nghị nâng cấp version; sau khi nâng cấp xong chuyển trạng thái "Đã xử lý" và cập nhật version trong tech stack.
- HP-04: Quản lý mở Dashboard, thấy tổng số dự án, phân bố công nghệ và số lỗ hổng Critical còn mở.

### 7.2 Edge cases / exceptions

- EC-01: Một thư viện có lỗ hổng được dùng ở nhiều Project → mỗi Project cần một bản ghi theo dõi riêng (trạng thái xử lý có thể khác nhau) `[ASSUMED — xem Q-04]`.
- EC-02: Project chuyển trạng thái ngừng vận hành → lỗ hổng còn mở của project đó xử lý thế nào (đóng tự động hay giữ nguyên)? `[NEEDS-CONFIRMATION — Q-05]`
- EC-03: Xóa thành viên khỏi Project khi người đó là người phụ trách lỗ hổng đang mở.
- EC-04: Tài khoản bị khóa khi đang là thành viên nhiều Project — dữ liệu lịch sử vẫn giữ tên người đó.

## 8. Dữ liệu và báo cáo

### 8.1 Nhóm dữ liệu nghiệp vụ

| Nhóm dữ liệu | Ý nghĩa nghiệp vụ | Ai tạo / ai dùng | Mức nhạy cảm | Ràng buộc lưu trữ | Nguồn |
|---|---|---|---|---|---|
| Tài khoản & vai trò | Danh tính và quyền của người dùng | Admin tạo; mọi người dùng | Thông tin cá nhân nội bộ (email, tên) | Giữ khi còn hoạt động; khóa thay vì xóa `[ASSUMED]` | `[FROM-TEAM]` |
| Hồ sơ Project | Thông tin dự án, repository, thành viên, trạng thái | PM/Admin tạo; mọi người dùng đọc | Nội bộ | Giữ cả dự án đã kết thúc để tra cứu | `[FROM-TEAM]` |
| Tech Stack | Công nghệ và phiên bản từng dự án | Thành viên dự án | Nội bộ | Theo vòng đời Project | `[FROM-TEAM]` |
| Lỗ hổng bảo mật | CVE, thư viện ảnh hưởng, trạng thái xử lý, khuyến nghị | Thành viên dự án / Admin | **Nhạy cảm** — lộ ra ngoài là lộ điểm yếu hệ thống | Không xóa; giữ làm dấu vết kiểm toán `[ASSUMED]` | `[FROM-TEAM]` |

### 8.2 Báo cáo và kết xuất

| Báo cáo | Ai đọc | Tần suất | Nội dung chính | Định dạng | Nguồn |
|---|---|---|---|---|---|
| Dashboard tổng quan | Quản lý, mọi người dùng | Realtime khi mở | Thống kê dự án, công nghệ, tình trạng bảo mật | Màn hình | `[FROM-TEAM]` |
| Kết xuất danh sách lỗ hổng | Quản lý | Theo nhu cầu | CVE theo mức nghiêm trọng/trạng thái | `[NEEDS-CONFIRMATION — Q-06]` | — |

## 9. Yêu cầu phi chức năng (mức nghiệp vụ)

| Nhóm | Kỳ vọng | Vì sao quan trọng | Mã NFR | Mức tin cậy |
|---|---|---|---|---|
| Bảo mật & phân quyền | Bắt buộc đăng nhập; dữ liệu lỗ hổng chỉ người trong tổ chức xem được; hành động quản trị chỉ Admin | Dữ liệu CVE là điểm yếu hệ thống | NFR-SEC | `[FROM-TEAM]` |
| Hiệu năng | Danh sách và Dashboard mở trong vài giây với quy mô hàng trăm dự án | Công cụ tra cứu hằng ngày | NFR-PERF | `[ASSUMED]` |
| Nền tảng sử dụng | Trình duyệt desktop tại văn phòng | Người dùng là kỹ sư/quản lý | NFR-PLAT | `[ASSUMED]` |
| Tính sẵn sàng | Giờ hành chính; gián đoạn ngắn chấp nhận được (công cụ nội bộ) | Không phải hệ thống mission-critical | NFR-AVAIL | `[ASSUMED]` |
| Tuân thủ | `[N/A — chưa ghi nhận yêu cầu pháp lý riêng; cần xác nhận chính sách bảo mật nội bộ]` | — | — | `[NEEDS-CONFIRMATION]` |

## 10. Tích hợp và phụ thuộc bên ngoài

Chưa ghi nhận tích hợp bắt buộc nào trong context đã cung cấp. Các tích hợp **tiềm năng** (GitHub/GitLab để lấy repository, NVD/OSV để tra cứu CVE tự động, SSO nội bộ) hiện coi là **ngoài phạm vi** cho tới khi được xác nhận `[NEEDS-CONFIRMATION — Q-02, Q-07]`.

## 11. Ngoài phạm vi (Out of scope)

| Hạng mục | Lý do | Xác nhận | Giai đoạn sau? |
|---|---|---|---|
| Tự động quét mã nguồn / dependency để phát hiện CVE | Không có trong context; ảnh hưởng lớn tới chi phí | `[NEEDS-CONFIRMATION]` | Có thể |
| Tích hợp SSO (Google/AD) | Context chỉ nêu login thường | `[NEEDS-CONFIRMATION]` | Có thể |
| Ứng dụng mobile | Công cụ nội bộ trên desktop | `[ASSUMED]` | — |
| Chuyển dữ liệu từ file/hệ thống cũ | Chưa xác định hiện trạng | `[NEEDS-CONFIRMATION]` | — |
| Gửi email/notification cảnh báo lỗ hổng | Chưa nêu trong context | `[NEEDS-CONFIRMATION — Q-08]` | Có thể |

## 12. Key concepts & terminology

| Thuật ngữ | Giải thích |
|---|---|
| Tech Stack | Tập hợp công nghệ một dự án đang dùng: ngôn ngữ, framework, database, cache, cloud, kèm phiên bản |
| CVE | Mã định danh công khai của một lỗ hổng bảo mật (Common Vulnerabilities and Exposures) |
| Trạng thái xử lý | Tiến độ khắc phục một lỗ hổng: Mới → Đang xử lý → Đã xử lý / Chấp nhận rủi ro `[ASSUMED]` |
| Khuyến nghị nâng cấp | Phiên bản thư viện nên nâng lên để vá lỗ hổng |

## 13. Assumptions / constraints

| Mã | Nội dung | Ảnh hưởng |
|---|---|---|
| ASM-01 | Dữ liệu nhập thủ công, không có scanner tự động | Phạm vi & chi phí |
| ASM-02 | Hai vai trò cố định Admin/User, không có phân quyền tùy biến | Thiết kế role matrix |
| ASM-03 | Đơn tổ chức (single-tenant), không chia theo phòng ban | Data scope |
| ASM-04 | Ngôn ngữ giao diện: tiếng Việt `[NEEDS-CONFIRMATION]` | UI/UX |

## 14. Open questions

| Mã | Câu hỏi | Ảnh hưởng | Ưu tiên |
|---|---|---|---|
| Q-01 | Quy mô dự kiến: bao nhiêu dự án, bao nhiêu người dùng? | Hiệu năng, hạ tầng | Cao |
| Q-02 | Có cần tự động lấy CVE từ nguồn ngoài (NVD/OSV) hay nhập tay hoàn toàn? | Phạm vi lớn | Cao |
| Q-03 | User có được xem mọi Project hay chỉ Project mình tham gia? Quyền sửa giới hạn thế nào? | Role matrix, screen spec | Cao |
| Q-04 | Một CVE ảnh hưởng nhiều Project: theo dõi riêng từng Project hay một bản ghi chung? | Mô hình dữ liệu | Cao |
| Q-05 | Project ngừng vận hành: xử lý lỗ hổng còn mở thế nào? | Business rule | Trung bình |
| Q-06 | Có cần export báo cáo (CSV/Excel) không? | Phạm vi | Trung bình |
| Q-07 | Có cần liên kết repository với GitHub/GitLab (link hay tích hợp API)? | Phạm vi | Trung bình |
| Q-08 | Có cần cảnh báo (email/notification) khi có lỗ hổng Critical không? | Phạm vi | Trung bình |

## 15. Q&A log — *(chưa có; sẽ mở khi bắt đầu vòng hỏi đáp với BU)*

## 16. Decision log — *(chưa có)*

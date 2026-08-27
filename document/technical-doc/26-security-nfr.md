# Security & NFR Design

> **Phase**: Design — Technical | **Trạng thái**: Draft v0.1 — chờ Tech Lead review
> **Upstream**: `01-business-understanding.md` §8–§9, `04-role-matrix.md`, `21-architecture.md`
> **Bối cảnh đặc thù**: hệ thống này **lưu danh sách điểm yếu bảo mật của chính tổ chức**. Một vụ rò rỉ ở đây không chỉ lộ dữ liệu — nó đưa cho kẻ tấn công đúng bản đồ chỗ nào cần đánh. Toàn bộ tài liệu này xoay quanh thực tế đó.

---

## 1. Phân loại dữ liệu

| Nhóm dữ liệu                                       | Mức nhạy cảm | Hệ quả nếu rò rỉ                                                                                 | Biện pháp                                                                |
| -------------------------------------------------- | ------------ | ------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------ |
| `vulnerabilities` + `vulnerability_status_history` | **Cao nhất** | Kẻ tấn công biết chính xác dự án nào đang dùng thư viện có lỗ hổng gì, phiên bản nào, đã vá chưa | Bắt buộc đăng nhập; không log nội dung; hạn chế kết xuất; ranh giới mạng |
| `tech_stack_items`                                 | **Cao**      | Bản đồ công nghệ toàn tổ chức — đủ để thu hẹp hướng tấn công dù không biết CVE cụ thể            | Bắt buộc đăng nhập                                                       |
| `users` (email, họ tên)                            | Trung bình   | Danh sách nhân sự phục vụ tấn công phi kỹ thuật                                                  | Chỉ Admin xem danh sách đầy đủ                                           |
| `password_hash`                                    | **Cao nhất** | —                                                                                                | Argon2id; **không bao giờ** trả về API, kể cả cho Admin                  |
| `projects`, `repositories`                         | Trung bình   | Danh mục dự án và vị trí mã nguồn                                                                | Bắt buộc đăng nhập                                                       |

> **Một hệ quả cần nói thẳng**: đặc tả cho phép **mọi người dùng đã đăng nhập đọc toàn bộ lỗ hổng** (BR-03, DEC-03). Điều đó có nghĩa **một tài khoản bị chiếm là lộ toàn bộ**. Đây là quyết định nghiệp vụ có ý thức — đánh đổi lấy sự minh bạch nội bộ — nhưng nó dồn gần như toàn bộ gánh nặng bảo mật lên **xác thực** và **quản lý phiên**. Câu hỏi mở Q-09 (BU) chính là chỗ để xem lại đánh đổi này.

## 2. Mô hình mối đe dọa

Áp dụng STRIDE, chỉ giữ những mối đe dọa **thực sự áp dụng** cho hệ thống này.

| #     | Mối đe dọa                            | Loại            | Kịch bản                                                               | Biện pháp                                                                                                                               | Rủi ro còn lại                                                                      |
| ----- | ------------------------------------- | --------------- | ---------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| TH-01 | Đoán mật khẩu hàng loạt               | Spoofing        | Thử mật khẩu phổ biến trên danh sách email nhân sự                     | BR-21 khóa tạm 5 lần/15 phút; Argon2id làm mỗi lần thử tốn ~100ms; Nginx `limit_req`                                                    | Tấn công rải chậm trên nhiều tài khoản vẫn khả thi — xem TH-02                      |
| TH-02 | Password spraying                     | Spoofing        | Một mật khẩu phổ biến thử trên toàn bộ 150 tài khoản, dưới ngưỡng khóa | BR-21 đếm theo **email**, không chặn được kiểu này                                                                                      | **Còn lại — xem §8 Q-SEC-02**: đề xuất thêm ngưỡng theo IP                          |
| TH-03 | Liệt kê tài khoản                     | Info disclosure | Dò email nào tồn tại qua khác biệt thông báo hoặc thời gian phản hồi   | `MSG-AUTH-001` giống hệt cho cả hai trường hợp; **luôn chạy Argon2id** kể cả khi email không tồn tại, để thời gian phản hồi không chênh | Thấp                                                                                |
| TH-04 | Đánh cắp token qua XSS                | Spoofing        | Chèn script đọc token                                                  | Token trong httpOnly cookie (ADR-02); React tự escape; CSP chặt                                                                         | Thấp                                                                                |
| TH-05 | Dùng lại refresh token đã đánh cắp    | Spoofing        | Kẻ tấn công lấy được refresh token và dùng song song                   | Xoay vòng + phát hiện tái sử dụng → thu hồi cả chuỗi (§5)                                                                               | Thấp                                                                                |
| TH-06 | CSRF                                  | Tampering       | Trang độc dụ trình duyệt gửi request có cookie                         | `SameSite=Lax`; Server Actions của Next.js có bảo vệ CSRF sẵn; thao tác ghi không dùng `GET`                                            | Thấp                                                                                |
| TH-07 | **Leo thang quyền qua API trực tiếp** | Elevation       | User gọi thẳng endpoint chấp nhận rủi ro cho lỗ hổng Critical          | Kiểm tra ở **máy chủ** (BR-15); giao diện chỉ vô hiệu hóa nút                                                                           | Thấp **nếu** test bắt buộc ở `10-error-message-catalog.md` §11 điểm 2 được thực thi |
| TH-08 | Ghi dữ liệu dự án không tham gia      | Elevation       | User gọi `PATCH /projects/{id}` của dự án khác                         | `require_project_write` trên mọi endpoint ghi                                                                                           | Thấp                                                                                |
| TH-09 | Truy cập trực tiếp API hoặc DB        | Elevation       | Bỏ qua tầng web                                                        | `api` và `db` không publish cổng ra host (§3)                                                                                           | Thấp                                                                                |
| TH-10 | **Kết xuất CSV rồi mang ra ngoài**    | Info disclosure | Người dùng hợp lệ tải toàn bộ danh sách lỗ hổng rồi gửi ra ngoài       | Giới hạn 10.000 dòng; **hiện chưa có** ghi nhật ký ai kết xuất gì                                                                       | **Còn lại — xem §8 Q-SEC-01**                                                       |
| TH-11 | SQL injection                         | Tampering       | —                                                                      | SQLAlchemy tham số hóa; không ghép chuỗi SQL                                                                                            | Rất thấp                                                                            |
| TH-12 | Phá dấu vết kiểm toán                 | Repudiation     | Sửa lịch sử để giấu việc đã chấp nhận rủi ro                           | Bất biến ở **tầng DB grant + trigger** (ADR-04, đã kiểm chứng T14/T15)                                                                  | Rất thấp                                                                            |
| TH-13 | Dependency có lỗ hổng                 | —               | Chính hệ thống chạy trên thư viện có CVE                               | Quét dependency trong CI (§9); **ADR-12 đang là điểm yếu**                                                                              | **Còn lại — phụ thuộc quyết định ADR-12**                                           |

## 3. Bảo mật theo lớp mạng

```
Internet / mạng nội bộ
        │  HTTPS :443
        ▼
   ┌─────────┐   cổng duy nhất publish ra host
   │  nginx  │   TLS, limit_req, security header
   └────┬────┘
        │  HTTP :3000  (mạng docker nội bộ)
        ▼
   ┌─────────┐
   │   web   │   giữ token; không có biến NEXT_PUBLIC_* nào trỏ tới api
   └────┬────┘
        │  HTTP :8000  (mạng docker nội bộ)
        ▼
   ┌─────────┐
   │   api   │   xác thực + phân quyền; docs tắt ở production
   └────┬────┘
        │  TCP :5432   (mạng docker nội bộ)
        ▼
   ┌─────────┐
   │   db    │   role app_runtime không có DDL, không DELETE lịch sử
   └─────────┘
```

Chỉ `nginx` publish cổng. Ba container còn lại **không** có `ports:` trong `docker-compose.yml` — chỉ `expose:`. Đây là biện pháp bảo mật, không phải chi tiết cấu hình: kể cả khi có lỗ hổng RCE ở tầng web, kẻ tấn công vẫn phải đi qua các lớp còn lại.

### 3.1 Header bảo mật (Nginx)

| Header                      | Giá trị                                                                                                                                                      | Chống             |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------- |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains`                                                                                                                        | Hạ cấp giao thức  |
| `Content-Security-Policy`   | `default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; frame-ancestors 'none'; base-uri 'self'; form-action 'self'` | XSS, clickjacking |
| `X-Content-Type-Options`    | `nosniff`                                                                                                                                                    | Đoán kiểu MIME    |
| `Referrer-Policy`           | `strict-origin-when-cross-origin`                                                                                                                            | Rò rỉ URL chứa ID |
| `Permissions-Policy`        | `camera=(), microphone=(), geolocation=()`                                                                                                                   | —                 |

> `frame-ancestors 'none'` thay cho `X-Frame-Options` — mạnh hơn và là chuẩn hiện hành. `Referrer-Policy` đáng chú ý ở đây: URL của hệ thống chứa ID dự án và ID lỗ hổng, không nên rò sang trang ngoài khi người dùng bấm liên kết repository.

## 4. Phân quyền — hai tầng

Phân quyền được kiểm tra ở **hai nơi**, với vai trò khác nhau:

| Tầng      | Nơi                             | Vai trò                                                            | Bỏ qua được không?          |
| --------- | ------------------------------- | ------------------------------------------------------------------ | --------------------------- |
| Giao diện | Next.js Server/Client Component | Ẩn nút, vô hiệu hóa lựa chọn — để giao diện gọn và người dùng hiểu | **Có** — chỉ là trải nghiệm |
| Máy chủ   | FastAPI dependency              | Quyết định thật sự                                                 | **Không**                   |

**Nguyên tắc bất di bất dịch**: kiểm tra ở giao diện là để **thân thiện**, không phải để **an toàn**. `writable_project_ids` mà `/auth/me` trả về giúp giao diện ẩn nút, nhưng mọi endpoint ghi vẫn tự kiểm tra lại từ database.

### 4.1 Ma trận enforce

| Quy tắc                                              | Kiểm tra ở giao diện                   | Kiểm tra ở máy chủ            | Mã lỗi         |
| ---------------------------------------------------- | -------------------------------------- | ----------------------------- | -------------- |
| BR-01 — chỉ Admin quản lý tài khoản                  | Ẩn menu Quản trị                       | `require_admin` + route guard | `MSG-AUTH-005` |
| BR-02 — ghi theo tư cách thành viên                  | Ẩn nút ghi                             | `require_project_write`       | `MSG-AUTH-005` |
| **BR-15 — Critical/High chỉ Admin chấp nhận rủi ro** | **Vô hiệu hóa kèm tooltip** (không ẩn) | `check_transition_permission` | `MSG-AUTH-006` |
| BR-05 — luôn còn ≥1 Admin                            | Vô hiệu hóa nút khóa                   | Service + **DB trigger**      | `MSG-BIZ-060`  |
| BR-08 — luôn còn ≥1 PM                               | Vô hiệu hóa nút xóa                    | Service + **DB trigger**      | `MSG-BIZ-051`  |
| BR-13/14 — bất biến                                  | Không có nút xóa/sửa                   | **DB grant + trigger**        | —              |

BR-15 là quy tắc quan trọng nhất về mặt an ninh nghiệp vụ (mục tiêu G-05) và cũng là quy tắc duy nhất phụ thuộc vào **mức nghiêm trọng** chứ không phải tư cách thành viên. Cần một ca kiểm thử riêng gọi thẳng API bằng token của User.

## 5. Xác thực và quản lý phiên

### 5.1 Mật khẩu

| Hạng mục                      | Quy định                                                  | Nguồn        |
| ----------------------------- | --------------------------------------------------------- | ------------ |
| Chính sách                    | ≥ 8 ký tự, có chữ hoa + chữ thường + số                   | BR-20        |
| Băm                           | Argon2id — `time_cost=3, memory_cost=64MB, parallelism=4` | ADR-07       |
| Lần đầu                       | Bắt buộc đổi (`must_change_password`)                     | DEC-12       |
| Đặt lại                       | Admin đặt mật khẩu tạm, hiển thị **một lần duy nhất**     | `SCR-ADM-11` |
| Không lưu lịch sử mật khẩu cũ | Chỉ chặn trùng mật khẩu **hiện tại** (R-ENT-011)          | —            |

> **Nhận xét thẳng về chính sách mật khẩu.** BR-20 là mức tối thiểu và cho phép những mật khẩu như `Password1` — rất yếu trước tấn công từ điển. Với hệ thống lưu dữ liệu loại này, đáng cân nhắc thêm **kiểm tra danh sách mật khẩu đã rò rỉ phổ biến** (danh sách offline vài nghìn mật khẩu, không cần gọi dịch vụ ngoài). Chi phí thấp, hiệu quả cao hơn nhiều so với việc tăng độ dài tối thiểu. Đề xuất ở §8 Q-SEC-03.

### 5.2 Vòng đời phiên

| Sự kiện                     | Hành vi                                                         |
| --------------------------- | --------------------------------------------------------------- |
| Đăng nhập                   | Cấp access (15 phút) + refresh (8 giờ trượt, tối đa 24 giờ)     |
| Không thao tác 30 phút      | Refresh không được làm mới → phiên chết (BR-22)                 |
| Đổi mật khẩu                | **Thu hồi toàn bộ** refresh token khác của người đó `[ASSUMED]` |
| Admin khóa tài khoản        | Thu hồi toàn bộ refresh token **trong cùng giao dịch**          |
| Admin đặt lại mật khẩu      | Thu hồi toàn bộ refresh token                                   |
| Đăng xuất                   | Thu hồi refresh token hiện tại                                  |
| Phát hiện tái sử dụng token | Thu hồi **cả chuỗi**, buộc đăng nhập lại                        |

### 5.3 Phát hiện tái sử dụng refresh token

```
Người dùng bình thường:  R1 → (refresh) → R2 → (refresh) → R3
                          R1 bị đánh dấu replaced_by=R2, R2 replaced_by=R3

Có kẻ đánh cắp R2:       Kẻ tấn công dùng R2 → nhận R3'
                          Người dùng thật dùng R2 → PHÁT HIỆN (R2 đã bị thay)
                          → thu hồi toàn bộ chuỗi, cả hai bị buộc đăng nhập lại
```

Cơ chế này không ngăn được việc đánh cắp, nhưng **giới hạn cửa sổ khai thác** và tạo tín hiệu rõ ràng để điều tra. Đây là lý do `refresh_tokens` giữ lại bản ghi đã thu hồi 30 ngày (`22-database-design.md` §10).

### 5.4 JWT

| Hạng mục                | Quy định                                                                                |
| ----------------------- | --------------------------------------------------------------------------------------- |
| Thuật toán              | `HS256` với khóa bí mật ≥ 32 byte                                                       |
| Claim                   | `sub` (user id), `role`, `exp`, `iat`, `jti`                                            |
| **Không** đưa vào token | Email, họ tên, `writable_project_ids` — dữ liệu thay đổi được thì không cache vào token |
| Xoay khóa               | Hỗ trợ hai khóa (`current` + `previous`) để xoay không làm rớt phiên                    |

> `writable_project_ids` **không** nằm trong token có chủ ý: nếu Admin thêm người vào dự án, quyền phải có hiệu lực ngay chứ không phải chờ 15 phút. Danh sách này tải cùng `/auth/me` ở mỗi lần render trang.

## 6. Quản lý bí mật

| Bí mật                       | Lưu ở đâu                                                     | Xoay vòng              |
| ---------------------------- | ------------------------------------------------------------- | ---------------------- |
| `JWT_SECRET`                 | Biến môi trường từ tệp `.env` chỉ root đọc được (`chmod 600`) | Khi nghi ngờ lộ        |
| `DATABASE_URL` (có mật khẩu) | Như trên                                                      | Theo chính sách nội bộ |
| `SESSION_COOKIE_SECRET`      | Như trên                                                      | Như trên               |
| Chứng chỉ TLS                | Thư mục Nginx, `chmod 600`                                    | Theo hạn chứng chỉ     |

**Không bao giờ**: đưa bí mật vào ảnh Docker, commit tệp `.env` vào Git, hay ghi bí mật ra log. `.gitignore` phải có `.env*` ngay từ commit đầu tiên — thêm sau khi đã lỡ commit thì bí mật vẫn nằm trong lịch sử Git.

## 7. Yêu cầu phi chức năng

### 7.1 Hiệu năng

| Chỉ tiêu                 | Mục tiêu                              | Cách đạt                                                     | Cách đo                 |
| ------------------------ | ------------------------------------- | ------------------------------------------------------------ | ----------------------- |
| Danh sách dự án          | ≤ 3 giây tại 200 dự án                | View `v_project_summary` + partial index; phân trang máy chủ | `duration_ms` trong log |
| Danh sách lỗ hổng        | ≤ 3 giây tại 5.000 bản ghi            | `vuln_open_detected_idx`                                     | Như trên                |
| Dashboard                | ≤ 3 giây, **từng khối hiện khi xong** | 4 truy vấn song song + `Suspense`                            | Như trên                |
| Chi tiết bất kỳ          | ≤ 1 giây                              | Truy vấn theo khóa chính                                     | Như trên                |
| Đăng nhập                | ≤ 2 giây                              | Argon2id ~100ms là phần lớn                                  | Như trên                |
| Kết xuất CSV 10.000 dòng | ≤ 30 giây                             | `StreamingResponse` + `yield_per`                            | Như trên                |

**Ngưỡng cần theo dõi** (khi chạm thì xem lại kiến trúc, không phải trước đó):

- Bản ghi lỗ hổng vượt **50.000** → cân nhắc materialized view cho Dashboard.
- Dự án vượt **1.000** → xem lại view `v_project_summary`.
- Người dùng đồng thời vượt **50** → xem lại số worker và pool kết nối.

Ba ngưỡng này đều gấp khoảng 10 lần dự kiến ở DEC-01. Tối ưu trước khi chạm ngưỡng là lãng phí.

### 7.2 Các NFR khác

| Nhóm             | Mục tiêu                                        | Cách đạt                                                        |
| ---------------- | ----------------------------------------------- | --------------------------------------------------------------- |
| Tính sẵn sàng    | Giờ hành chính; gián đoạn ngắn chấp nhận được   | `restart: unless-stopped`; healthcheck; **không** HA (ADR-10)   |
| Quy mô           | 200 dự án, 150 tài khoản, 5.000 lỗ hổng         | Một VM đủ; dữ liệu < 100 MB                                     |
| Nền tảng         | Chrome/Edge bản mới nhất và bản trước; ≥ 1280px | Không hỗ trợ responsive điện thoại (ngoài phạm vi BA)           |
| Ngôn ngữ         | Tiếng Việt, một ngôn ngữ                        | Catalog message tập trung; cấu trúc tệp dịch dựng sẵn (Q-FE-04) |
| Khả năng bảo trì | Sửa một quy tắc chỉ đụng một chỗ                | Bảng đối chiếu `24-backend-design.md` §5                        |

## 8. Rủi ro còn lại và đề xuất

| Mã           | Vấn đề                                                                                                                                            | Mức        | Đề xuất                                                                                                                                                            |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Q-SEC-01** | **Không có nhật ký ai kết xuất CSV** (TH-10). Một người dùng hợp lệ có thể tải toàn bộ danh sách điểm yếu của tổ chức mà không để lại dấu vết nào | **Cao**    | Ghi log mỗi lần kết xuất: ai, khi nào, bộ lọc gì, bao nhiêu dòng. Chi phí rất thấp, và đây là loại hành vi mà khi cần điều tra thì không có cách nào dựng lại được |
| **Q-SEC-02** | BR-21 đếm theo email nên **không chặn được password spraying** (TH-02)                                                                            | Trung bình | Thêm ngưỡng thứ hai theo IP: ví dụ 20 lần sai / 15 phút / IP, độc lập với ngưỡng theo email                                                                        |
| **Q-SEC-03** | Chính sách mật khẩu BR-20 cho phép mật khẩu yếu như `Password1`                                                                                   | Trung bình | Thêm kiểm tra danh sách mật khẩu phổ biến (offline, vài nghìn mục). Không cần đổi BR-20                                                                            |
| **Q-SEC-04** | ADR-12 — FastAPI 0.115.9 lỗi thời (TH-13)                                                                                                         | **Cao**    | Xác nhận lý do hoặc nâng cấp. Một hệ thống quản lý lỗ hổng chạy trên dependency cũ hơn một năm là điều rất khó giải thích khi audit                                |
| Q-SEC-05     | Q-09 (BU) chưa chốt — mọi người dùng đọc được mọi lỗ hổng                                                                                         | Trung bình | Nếu chốt là hạn chế, thiết kế truy vấn phải sửa ở 10 endpoint. Nên chốt sớm                                                                                        |
| Q-SEC-06     | Q-10 (BU) — không có audit log truy cập                                                                                                           | Thấp–TB    | Liên quan Q-SEC-01; có thể gộp thành một bảng `audit_log` chung                                                                                                    |

> Bốn mục đầu là những chỗ tôi cho rằng **đáng xử lý ngay trong phạm vi giai đoạn 1**, không nên đẩy sang giai đoạn sau. Q-SEC-01 và Q-SEC-02 mỗi cái tốn dưới một ngày công; Q-SEC-04 gần như không tốn gì nếu quyết định sớm.

## 9. Bảo mật trong quy trình phát triển

| Việc                           | Khi nào             | Công cụ                             |
| ------------------------------ | ------------------- | ----------------------------------- |
| Quét lỗ hổng dependency Python | Mỗi lần CI chạy     | `pip-audit`                         |
| Quét lỗ hổng dependency Node   | Mỗi lần CI chạy     | `npm audit --audit-level=high`      |
| Quét bí mật lỡ commit          | Pre-commit + CI     | `gitleaks`                          |
| Phân tích tĩnh Python          | Mỗi lần CI          | `bandit`, `ruff`                    |
| Quét ảnh Docker                | Trước khi phát hành | `trivy`                             |
| Kiểm thử phân quyền            | Mỗi lần CI          | Bộ test ở `24-backend-design.md` §9 |

> Có một sự trớ trêu đáng lưu ý: đây là hệ thống **theo dõi lỗ hổng của các dự án khác**, nên chính nó phải là dự án gương mẫu nhất về việc giữ dependency sạch. Đề xuất: tạo hồ sơ cho chính hệ thống này trong hệ thống, và cập nhật tech stack của nó như mọi dự án khác.

**Last Updated**: 2026-08-26

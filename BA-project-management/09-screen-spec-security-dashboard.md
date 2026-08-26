# Screen Spec — Security & Dashboard

> **Phase**: Design — Detailing | **Trạng thái**: Draft v0.1 — chờ BU verify
> **Phạm vi**: SCR-SEC-10, SCR-SEC-11, SCR-PRJ-24, SCR-DASH-10
> **Upstream**: `05-screen-flow.md` (v0.2), `04-role-matrix.md` (v0.2), `03-business-entities.md` (v0.2)
> **Downstream**: `10-error-message-catalog.md`
> **Quy ước chung**: cột "Kiểu" dùng tên chuẩn Item Type Catalog. Ngày `dd/MM/yyyy`, thời điểm `dd/MM/yyyy HH:mm`, GMT+7 (ASM-05). Danh sách mặc định 20 dòng/trang (ASM-06).
> **"Còn mở"** = lỗ hổng ở trạng thái `Mới` hoặc `Đang xử lý` (BU §12). **"Có quyền ghi trên Project"** = Admin hoặc thành viên của Project đó.

---

## §1. SCR-SEC-10 — Danh sách lỗ hổng (toàn hệ thống)

- **Screen ID**: `SCR-SEC-10`
- **Business name**: Danh sách lỗ hổng bảo mật
- **Route / entry**: `/security` — menu "Bảo mật", hoặc từ ô cảnh báo/khối thống kê trên Dashboard (kèm bộ lọc áp sẵn)
- **Related screens**: → `SCR-SEC-11` (chi tiết / tạo), ← `SCR-DASH-10`
- **Nguồn chính**: `[FROM-TEAM]` + `[DECIDED — DEC-04, DEC-06]`

### 1.1 Mục đích

Đây là góc nhìn cắt ngang quan trọng nhất của hệ thống: mọi lỗ hổng của mọi dự án ở một chỗ. Quản lý kỹ thuật dùng màn này để trả lời *"tổ chức đang có bao nhiêu rủi ro nghiêm trọng chưa xử lý, nằm ở đâu, ai chịu trách nhiệm, và cái nào tồn đọng lâu nhất"* (G-02). Chế độ **gom nhóm theo CVE** phục vụ một câu hỏi khác: *"một lỗ hổng ảnh hưởng bao nhiêu dự án"* — điều mà mô hình một bản ghi cho mỗi dự án (DEC-04) làm mờ đi nếu chỉ nhìn danh sách phẳng.

### 1.2 Điều kiện trước và phân quyền

Cần **đã đăng nhập**; mọi người dùng đọc được toàn bộ danh sách (BR-03).

- **Loại permission gate**: route guard cho phần đăng nhập.
- **Khác biệt theo quyền**: nút "Ghi nhận lỗ hổng" **ẩn** khi người dùng không có quyền ghi trên bất kỳ Project nào chưa `Kết thúc` `[PERMISSION-CLIENT]`.
- **Lưu ý về dữ liệu nhạy cảm**: nếu Q-09 (BU) xác định lỗ hổng Critical là dữ liệu hạn chế, phạm vi đọc của màn này phải thu hẹp `[NEEDS-CONFIRMATION]`.

### 1.3 Thành phần giao diện

| Thành phần | Kiểu | Bắt buộc? | Nguồn giá trị / option | Điều kiện enable/disable/hiển thị | Quy tắc nghiệp vụ | Ánh xạ entity / trường | Validation và cách phản hồi (UX) | Ghi chú |
|---|---|---|---|---|---|---|---|---|
| Tìm kiếm | `Text input (1 dòng)` | Không | Người dùng nhập | Luôn enable | Khớp một phần trên **mã CVE** hoặc **tên thư viện** | `Vulnerability.cve_id`, `Vulnerability.library` | Chạy sau khi ngừng gõ 400ms, đưa về trang 1. Chuỗi chỉ khoảng trắng bị bỏ qua. Không tìm thấy không phải lỗi — hiển thị trạng thái rỗng `MSG-INF-036`. | Tối đa 100 ký tự |
| Lọc dự án | `Autocomplete` | Không | `API` — danh sách Project, gợi ý theo tên hoặc mã sau khi gõ ≥ 2 ký tự | Luôn enable | — | `Vulnerability.project` | Debounce 300ms. Không cho nhập tự do ngoài danh sách. Nếu API gợi ý lỗi → ô vô hiệu hóa kèm tooltip `MSG-SYS-004`, các bộ lọc khác vẫn dùng được. | Chọn được nhiều dự án `[ASSUMED]` |
| Lọc mức nghiêm trọng | `Checkbox group` | Không | `static` — Critical (critical), High (high), Medium (medium), Low (low) | Luôn enable | 4 mức theo CVSS | `Vulnerability.severity` | Bỏ chọn hết = không lọc theo mức. Mỗi ô hiển thị số lượng kết quả tương ứng để người dùng biết trước sẽ ra bao nhiêu. Không có lỗi validation. | Dùng checkbox group vì thường chọn "Critical + High" |
| Lọc trạng thái xử lý | `Checkbox group` | Không | `static` — Mới (new), Đang xử lý (in_progress), Đã xử lý (resolved), Chấp nhận rủi ro (accepted) | Luôn enable | Mặc định chọn **Mới + Đang xử lý** (tức "còn mở") | `Vulnerability.status` | Như trên. Mặc định này có chủ ý: người mở màn này thường quan tâm việc chưa xong. Có một nút nhanh "Chỉ còn mở" để quay về mặc định. | — |
| Lọc người phụ trách | `Autocomplete` | Không | `API` — tài khoản đang là `assignee` của ít nhất một lỗ hổng | Luôn enable | — | `Vulnerability.assignee` | Debounce 300ms; có lựa chọn đặc biệt "Chưa gán người phụ trách". | Lựa chọn "chưa gán" rất hay dùng |
| Ngày ghi nhận từ | `Date range (From)` | Không | Người dùng chọn | Luôn enable | Không được sau ô "đến" | `Vulnerability.detected_date` | Nhập sai định dạng → `MSG-VAL-015` inline. Lớn hơn ô "đến" → `MSG-VAL-052` inline dưới ô này và chặn áp bộ lọc. | **Tách dòng riêng** với ô "đến" theo quy tắc From/To |
| Ngày ghi nhận đến | `Date range (To)` | Không | Người dùng chọn | Luôn enable | Không được trước ô "từ" | `Vulnerability.detected_date` | Nhập sai định dạng → `MSG-VAL-015` inline. Nhỏ hơn ô "từ" → `MSG-VAL-052` inline dưới ô này. Để trống một đầu = không giới hạn đầu đó. | **Tách dòng riêng** |
| Lọc quá hạn | `Checkbox (đơn)` | Không | — | Luôn enable | "Quá hạn" = còn mở và đã hơn 30 ngày kể từ ngày ghi nhận (DEC-08b) | Trường dẫn xuất | Bật sẽ chỉ hiển thị lỗ hổng quá hạn. Nhãn kèm tooltip giải thích ngưỡng 30 ngày để người dùng không phải đoán. | — |
| Chế độ gom nhóm theo CVE | `Toggle / Switch` | Không | — | Luôn enable; vô hiệu hóa khi đang tải | DEC-04 — một CVE có nhiều bản ghi theo dự án | — | Gạt sẽ tải lại danh sách ở chế độ gom nhóm; **không** gọi API ngay khi gạt mà chờ 200ms để tránh gạt qua lại liên tục gây nhiều yêu cầu. Trạng thái được ghi vào query string. | Xem cột bảng đổi ở dòng dưới |
| Xóa bộ lọc | `Button (phụ / hủy)` | — | — | Chỉ hiển thị khi có bộ lọc khác mặc định | — | — | Đưa mọi bộ lọc về mặc định (bao gồm trạng thái về "Mới + Đang xử lý") và tải lại trang 1. | — |
| Ghi nhận lỗ hổng | `Button (hành động chính)` | — | — | **Ẩn** khi không có quyền ghi trên bất kỳ Project nào chưa `Kết thúc` | BR-02, BR-11 | — | Điều hướng tới `/security/new`. Không có validation ở nút. | `[PERMISSION-CLIENT]` |
| Kết xuất CSV | `Button (phụ / hủy)` | — | — | Hiển thị với mọi người dùng; vô hiệu hóa khi đang tải hoặc 0 kết quả | Xuất theo **bộ lọc hiện tại** (DEC-06) | — | Nút chuyển sang trạng thái đang tạo tệp. Vượt 10.000 dòng → toast `MSG-BIZ-070`, không tạo tệp. Ở chế độ gom nhóm, tệp vẫn xuất **dòng chi tiết** (không gom) để dữ liệu dùng được cho phân tích. | Xem §1.9 |
| Bảng — chế độ phẳng | `Data table (hàng biến thiên)` | — | `API` — lỗ hổng theo bộ lọc, phân trang phía máy chủ | Hiển thị khi tắt gom nhóm | Cột: Mức, Mã CVE, Thư viện, Phiên bản bị ảnh hưởng, Dự án, Trạng thái, Người phụ trách, Ngày ghi nhận, Số ngày còn mở | `Vulnerability` | Rỗng → `MSG-INF-036`. API lỗi → thông báo inline trong vùng bảng kèm nút "Thử lại". Tương tác: sắp xếp được theo Mức, Ngày ghi nhận và Số ngày còn mở; không có tooltip hay legend — bảng HTML thuần, không dùng thư viện chart. | Mặc định sắp theo Số ngày còn mở giảm dần |
| Bảng — chế độ gom nhóm | `Data table (hàng biến thiên)` | — | `API` — lỗ hổng gom theo `cve_id` | Hiển thị khi bật gom nhóm | Cột: Mức, Mã CVE, Thư viện, Số dự án bị ảnh hưởng, Phân bố trạng thái, Ngày ghi nhận sớm nhất | `Vulnerability` gom nhóm | Mỗi dòng mở rộng được để xem các dòng con (từng dự án). Rỗng → `MSG-INF-036`. Tương tác: mở/đóng từng nhóm; sắp xếp theo Số dự án bị ảnh hưởng; không có tooltip/legend — bảng HTML thuần. | Cột "Phân bố trạng thái" hiển thị dạng chữ, ví dụ "2 mới · 3 đang xử lý · 2 đã xử lý" |
| Cột Mức | `Badge / Nhãn trạng thái` | — | `dynamic` — `Vulnerability.severity` | Luôn hiển thị | 4 mức cố định | `Vulnerability.severity` | Màu theo mức, kèm **chữ** ghi rõ tên mức — không chỉ dùng màu, vì người mù màu phải đọc được. Giá trị ngoài tập định nghĩa hiển thị nguyên văn để lộ lỗi dữ liệu. | Yêu cầu trợ năng |
| Cột Số ngày còn mở | `Label / Văn bản tĩnh` | — | `dynamic` — trường dẫn xuất | Luôn hiển thị | Chỉ tính khi trạng thái là `Mới`/`Đang xử lý` | Tính từ `detected_date` | Với lỗ hổng đã đóng, hiển thị dấu "—" thay vì số. Số > 30 hiển thị màu cam kèm biểu tượng để nổi bật lỗ hổng tồn đọng. | Là "tín hiệu" chính giúp ưu tiên |
| Cột Người phụ trách | `Label / Văn bản tĩnh` | — | `dynamic` — `Vulnerability.assignee` | Luôn hiển thị | Có thể rỗng khi trạng thái là `Mới` | `Vulnerability.assignee` | Rỗng hiển thị "Chưa gán" màu cam — không để trống, vì lỗ hổng không ai phụ trách là một tín hiệu cần thấy. Nếu tài khoản đó đã bị khóa, hiển thị thêm nhãn "(đã khóa)". | Chi tiết quan trọng cho G-02 |
| Phân trang | `Pagination` | — | `dynamic` — tổng số bản ghi | Ẩn khi chỉ một trang | — | — | Hiển thị tổng số kết quả. Đổi số dòng/trang khi ở trang cuối thì về trang 1. | ASM-06 |

### 1.4 Tương tác và luồng nhỏ trên màn

| Mã luồng | Tên luồng | Trigger | Tiền điều kiện | Xử lý hệ thống | Kết quả UI | Điều hướng / side effect | Ghi chú |
|---|---|---|---|---|---|---|---|
| F-S10-01 | Tải danh sách | Vào màn | Đã đăng nhập | Đọc bộ lọc từ query string hoặc dùng mặc định "còn mở"; gọi API | Bảng hiển thị | — | Vào từ Dashboard có bộ lọc áp sẵn |
| F-S10-02 | Lọc và tìm | Đổi bất kỳ bộ lọc nào | Bộ lọc ngày hợp lệ | Gọi API sau debounce; về trang 1; ghi query string | Bảng cập nhật; số đếm trên các ô lọc mức cập nhật theo | Link chia sẻ được | — |
| F-S10-03 | Bật gom nhóm theo CVE | Gạt công tắc | — | Gọi API chế độ gom nhóm | Bảng đổi cấu trúc cột; phân trang tính theo số nhóm | Query string ghi `group=cve` | US-032 |
| F-S10-04 | Mở rộng một nhóm | Bấm mũi tên trên dòng nhóm | Chế độ gom nhóm | Tải các bản ghi con của CVE đó | Dòng con hiện ra dưới dòng nhóm | Không rời màn | Tải lười để tránh nặng |
| F-S10-05 | Mở chi tiết | Bấm một dòng (hoặc dòng con) | — | — | — | `/security/:id` | Bộ lọc, trang và trạng thái gom nhóm được nhớ để quay lại |
| F-S10-06 | Ghi nhận lỗ hổng | Bấm "Ghi nhận lỗ hổng" | Có quyền ghi trên ≥1 Project | — | — | `/security/new` | DP-01 bước 2 |
| F-S10-07 | Kết xuất CSV | Bấm "Kết xuất CSV" | Có ≥1 kết quả | Tạo tệp theo bộ lọc | Nút ở trạng thái đang tạo, sau đó tải tệp | Không rời màn | DP-05 |
| F-S10-08 | Nút nhanh "Chỉ còn mở" | Bấm nút | — | Đặt bộ lọc trạng thái về Mới + Đang xử lý | Bảng cập nhật | — | Lối tắt cho thao tác dùng nhiều nhất |

### 1.5 Trạng thái màn hình

| State | Điều kiện vào | Người dùng thấy gì | Còn thao tác gì được | Cách thoát state | Ghi chú |
|---|---|---|---|---|---|
| Initial | Vào màn | Skeleton bảng, bộ lọc trạng thái ở mặc định "còn mở" | Đổi bộ lọc | API trả về | — |
| Loading | Đang gọi API | Skeleton dòng; bộ lọc vẫn thao tác được | Đổi bộ lọc (hủy yêu cầu cũ) | API trả về | Hủy yêu cầu cũ để tránh kết quả về sai thứ tự |
| Empty | 0 kết quả **do bộ lọc** | `MSG-INF-036` kèm nút "Xóa bộ lọc" | Đổi/xóa bộ lọc | Có kết quả | — |
| Empty | 0 kết quả **và không có bộ lọc nào** | `MSG-INF-037` "Chưa ghi nhận lỗ hổng nào trong hệ thống." | Ghi nhận lỗ hổng | Có dữ liệu | Đây là tin **tốt**, nên dùng văn phong trung tính chứ không cảnh báo |
| Empty | Bộ lọc mặc định "còn mở" cho 0 kết quả nhưng hệ thống có lỗ hổng đã đóng | `MSG-INF-038` "Không còn lỗ hổng nào đang mở. Bỏ bộ lọc trạng thái để xem các lỗ hổng đã xử lý." | Đổi bộ lọc | — | Ba trạng thái rỗng khác nhau — không gộp làm một |
| Error | API danh sách lỗi | Thông báo inline trong vùng bảng `MSG-SYS-003` kèm nút "Thử lại"; bộ lọc giữ nguyên | Thử lại | Gọi lại thành công | — |
| Timeout | Không phản hồi trong 20 giây | Như Error với `MSG-SYS-002` | Thử lại | — | `[ASSUMED]` |
| Concurrent / Race | Một lỗ hổng bị người khác đổi trạng thái trong lúc đang xem | Không cảnh báo — màn chỉ đọc; dữ liệu mới xuất hiện ở lần tải kế | Tiếp tục | — | Xung đột xử lý ở `SCR-SEC-11` |
| Success | Quay lại sau khi tạo/cập nhật lỗ hổng | Toast từ màn trước; dòng liên quan làm nổi 2 giây | Tiếp tục | Tự hết sau 4 giây | — |
| Session expired | Phiên hết hạn | Toast `MSG-AUTH-004`, chuyển `/login` | Không | — | — |

### 1.6 Validation, lỗi và trường hợp ngoại lệ

| Nhóm lỗi | Điều kiện phát sinh | Phản hồi UI mong đợi | Mã message | Vị trí hiển thị | Có nút Retry | Có chặn action | Ghi chú QA |
|---|---|---|---|---|---|---|---|
| Dữ liệu rỗng | Ba trường hợp rỗng khác nhau (xem §1.5) | Ba câu thông báo riêng biệt kèm hành động phù hợp | `MSG-INF-036`, `MSG-INF-037`, `MSG-INF-038` | inline vùng dữ liệu | Không | Không | Phải kiểm tra đủ cả ba — đây là điểm hay bị gộp làm một |
| Lỗi nhập liệu | Ngày từ > ngày đến; ngày sai định dạng | Thông báo đỏ dưới ô tương ứng, chặn áp bộ lọc | `MSG-VAL-052`, `MSG-VAL-015` | inline | Không | Có | Thử đảo ngược khoảng ngày, thử ngày 31/02 |
| Lỗi nghiệp vụ | Kết xuất vượt 10.000 dòng | Toast đỏ, không tạo tệp | `MSG-BIZ-070` | toast | Không | Có | Cần dữ liệu thử đủ lớn |
| Lỗi quyền (401/403) | Phiên hết hạn | Toast rồi chuyển `/login` | `MSG-AUTH-004` | toast | Không | Có | — |
| Không tìm thấy (404) | N/A — màn không tải bản ghi theo ID | — | — | — | — | — | Ghi N/A có chủ ý |
| Lỗi mạng / timeout | Mất kết nối hoặc quá 20 giây | Lỗi inline kèm nút Thử lại | `MSG-SYS-002` | inline vùng dữ liệu | **Có** | Không | Bộ lọc phải giữ nguyên |
| Thao tác đồng thời | N/A cho màn chỉ đọc | — | — | — | — | — | Ghi N/A có chủ ý |
| Lỗi hệ thống | API lỗi ngoài dự kiến | Lỗi inline kèm nút Thử lại | `MSG-SYS-003` | inline vùng dữ liệu | **Có** | Không | — |
| Lỗi bộ phận | API gợi ý dự án/người phụ trách lỗi | Ô lọc tương ứng vô hiệu hóa kèm tooltip; bảng vẫn hiển thị | `MSG-SYS-004` | tooltip | Không | Không | Lỗi một phần không làm hỏng cả màn |

#### 1.6.1 Đặc tả message

| Mã | Nội dung (VI) | Vị trí | Thời điểm | Hành vi sau message | Phân loại | Đối tượng đọc |
|---|---|---|---|---|---|---|
| `MSG-INF-036` | "Không tìm thấy lỗ hổng nào phù hợp với bộ lọc hiện tại." | inline vùng dữ liệu | Sau khi API trả 0 bản ghi và có bộ lọc | Không chặn; kèm nút "Xóa bộ lọc" | info | Cả hai |
| `MSG-INF-037` | "Chưa ghi nhận lỗ hổng nào trong hệ thống." | inline vùng dữ liệu | Khi hệ thống chưa có bản ghi nào | Không chặn | info | Cả hai |
| `MSG-INF-038` | "Không còn lỗ hổng nào đang mở. Bỏ bộ lọc trạng thái để xem các lỗ hổng đã xử lý." | inline vùng dữ liệu | Khi lọc mặc định "còn mở" trả 0 nhưng hệ thống có bản ghi đã đóng | Không chặn | info | Cả hai |
| `MSG-VAL-052` | "Khoảng ngày không hợp lệ: ngày bắt đầu phải trước hoặc bằng ngày kết thúc." | inline | Khi rời ô | Chặn áp bộ lọc | validation | Cả hai |

### 1.7 Mapping dữ liệu vào / ra

| Nhóm dữ liệu | Thành phần UI | Đọc từ đâu | Ghi ra đâu | Mục đích nghiệp vụ | Ghi chú |
|---|---|---|---|---|---|
| Danh sách lỗ hổng | Bảng phẳng | API lỗ hổng (lọc, sắp xếp, phân trang phía máy chủ) | — | Theo dõi rủi ro toàn tổ chức | "Số ngày còn mở" do máy chủ tính để đồng nhất múi giờ |
| Lỗ hổng gom nhóm | Bảng gom nhóm | API gom nhóm theo `cve_id` | — | Đánh giá diện ảnh hưởng của một CVE | Dòng con tải lười |
| Số đếm theo mức | Nhãn trên các ô lọc mức | API tổng hợp cùng bộ lọc (trừ chính bộ lọc mức) | — | Cho biết trước sẽ ra bao nhiêu kết quả | — |
| Gợi ý dự án / người phụ trách | Hai ô Autocomplete | API tương ứng | — | Hỗ trợ lọc | Lỗi độc lập với API danh sách |
| Bộ lọc | Toàn bộ vùng lọc | Người dùng nhập / query string | Query string | Chia sẻ link kết quả lọc | Dashboard drill-down dùng chính query string này |
| Tệp CSV | Nút kết xuất | API kết xuất theo bộ lọc | Tệp tải về | Báo cáo ngoài hệ thống | Xem §1.9 |

### 1.8 Email / Thông báo phát sinh từ màn

**Không phát sinh email/notification** `[DECIDED — DEC-08b]`. Đây là hệ quả đáng lưu ý nhất của quyết định đó: **không ai được cảnh báo chủ động khi có lỗ hổng Critical mới** — người dùng phải tự mở Dashboard hoặc màn này để biết. Rủi ro nghiệp vụ này đã được ghi nhận và cần khách hàng xác nhận có chấp nhận trong giai đoạn 1 hay không `[NEEDS-CONFIRMATION — Q-08]`.

### 1.9 Xuất dữ liệu

| Mã xuất | Định dạng | Phạm vi dữ liệu | Cột / trường + thứ tự | Quy tắc format từng cột | Tên file | Encoding / Newline | Hành vi khi rỗng / lỗi |
|---|---|---|---|---|---|---|---|
| `EXP-SEC-01` | CSV | **Toàn bộ kết quả của bộ lọc hiện tại**, không giới hạn ở trang đang xem; ở chế độ gom nhóm vẫn xuất **dòng chi tiết**; tối đa 10.000 dòng | 1. Mã CVE · 2. Mức nghiêm trọng · 3. Mã dự án · 4. Tên dự án · 5. Thư viện · 6. Phiên bản bị ảnh hưởng · 7. Trạng thái xử lý · 8. Người phụ trách (họ tên) · 9. Email người phụ trách · 10. Ngày ghi nhận · 11. Ngày xử lý xong · 12. Số ngày còn mở · 13. Khuyến nghị nâng cấp · 14. Ghi chú cách xử lý · 15. Lý do chấp nhận rủi ro · 16. Cập nhật cuối | Ngày: `dd/MM/yyyy`; Cập nhật cuối: `dd/MM/yyyy HH:mm` (GMT+7); Mức và Trạng thái: nhãn tiếng Việt như trên giao diện; Số ngày còn mở: số nguyên, để **trống** với lỗ hổng đã đóng (không ghi `0` gây hiểu nhầm); giá trị rỗng ghi chuỗi rỗng, không ghi `null`; giá trị chứa dấu phẩy, dấu nháy kép hoặc xuống dòng được bọc trong dấu nháy kép và nhân đôi dấu nháy bên trong | `vulnerabilities_YYYYMMDD_HHMMSS.csv` | UTF-8 **có BOM**, xuống dòng **CRLF**, phân tách bằng dấu phẩy | 0 dòng: nút đã vô hiệu hóa nên không xảy ra; nếu vẫn gọi được thì `MSG-BIZ-071`, không tạo tệp. Vượt 10.000 dòng: `MSG-BIZ-070`, không tạo tệp. Lỗi khi tạo tệp: toast `MSG-SYS-005`, không tải gì về |

Hàng tiêu đề dùng **tên cột tiếng Việt** giống nhãn giao diện. Ghi chú bảo mật: tệp này chứa danh sách điểm yếu của hệ thống — người kết xuất chịu trách nhiệm bảo quản `[NEEDS-CONFIRMATION — có cần cảnh báo trước khi tải không?]`.

### 1.10 Liên kết use case và chức năng

UC-SEC-01, UC-SEC-05. Feature FE-11, FE-13. Stories US-031, US-032, US-034.

### 1.11 Câu hỏi mở

- Q-09 (BU): nếu lỗ hổng Critical là dữ liệu hạn chế, màn này phải lọc theo quyền đọc.
- `[NEEDS-CONFIRMATION]` Ô lọc dự án có cho chọn nhiều dự án cùng lúc không? Đã giả định là **có**.
- `[NEEDS-CONFIRMATION]` Có cần hộp thoại cảnh báo trước khi kết xuất tệp chứa dữ liệu lỗ hổng không?

---

## §2. SCR-SEC-11 — Chi tiết / Tạo lỗ hổng

- **Screen ID**: `SCR-SEC-11`
- **Business name**: Chi tiết lỗ hổng
- **Route / entry**: `/security/new` (tạo), `/security/:id` (xem và cập nhật)
- **Related screens**: ← `SCR-SEC-10`, ← `SCR-PRJ-24`, → `SCR-PRJ-22` (từ lời nhắc cập nhật phiên bản)
- **RBAC note**: đọc — mọi người dùng. Ghi — có quyền ghi trên Project của lỗ hổng. **Chấp nhận rủi ro với mức Critical/High — chỉ Admin** (BR-15, DEC-09).
- **Nguồn chính**: `[FROM-TEAM]` + `[DECIDED — DEC-04, DEC-09, DEC-10]`

### 2.1 Mục đích

Đây là màn mang giá trị nghiệp vụ cao nhất của hệ thống. Nó phục vụ ba việc trong một chỗ: **ghi nhận** một lỗ hổng mới, **theo dõi và cập nhật** tiến độ xử lý theo một luồng trạng thái có ràng buộc, và **giữ dấu vết kiểm toán** về việc ai đã quyết định gì (G-02, G-05). Ràng buộc chặt ở đây là có chủ ý: một lỗ hổng nghiêm trọng không được phép biến mất khỏi tầm nhìn mà không có người chịu trách nhiệm và một lý do được ghi lại.

### 2.2 Điều kiện trước và phân quyền

- **Chế độ tạo**: cần có quyền ghi trên ít nhất một Project chưa `Kết thúc`.
- **Chế độ xem**: mọi người dùng đã đăng nhập.
- **Chế độ cập nhật**: cần quyền ghi trên Project của lỗ hổng đó.
- **Chấp nhận rủi ro Critical/High**: **chỉ Admin** — đây là ngoại lệ theo mức nghiêm trọng, không phải theo tư cách thành viên.
- **Loại permission gate**: route guard (đăng nhập) + **client-side computed** (quyền ghi theo Project, quyền chấp nhận rủi ro theo vai trò và mức).
- **Hệ quả UX**: các nút ghi **ẩn** khi không có quyền ghi. Riêng "Chấp nhận rủi ro" với Critical/High thì **hiển thị nhưng vô hiệu hóa kèm tooltip** — vì người dùng *có thể* thực hiện được trong hoàn cảnh khác (mức thấp hơn) và cần biết phải nhờ ai (`04-role-matrix.md` §5, quy ước ẩn vs vô hiệu hóa).

### 2.3 Thành phần giao diện

#### 2.3.1 Khối thông tin lỗ hổng

| Thành phần | Kiểu | Bắt buộc? | Nguồn giá trị / option | Điều kiện enable/disable/hiển thị | Quy tắc nghiệp vụ | Ánh xạ entity / trường | Validation và cách phản hồi (UX) | Ghi chú |
|---|---|---|---|---|---|---|---|---|
| Dự án | `Autocomplete` | Có | `API` — Project mà người dùng **có quyền ghi** và **không** ở trạng thái `Kết thúc` | Enable ở chế độ tạo khi vào từ `/security/new`; **chỉ đọc** khi vào từ tab Bảo mật của một dự án; **chỉ đọc** ở chế độ sửa (R-ENT-012) | BR-11 — mỗi lỗ hổng thuộc đúng một dự án; Project `Kết thúc` không cho ghi nhận mới | `Vulnerability.project` | Danh sách chỉ chứa dự án người dùng ghi được — không hiển thị rồi báo lỗi sau. Khi chưa chọn mà bấm Lưu → `MSG-VAL-053` inline. Nếu danh sách rỗng (người dùng không thuộc dự án nào đang mở) → hiển thị `MSG-BIZ-034` thay cho cả form và nút Lưu bị vô hiệu hóa. | Ở chế độ sửa kèm ghi chú "Dự án không thay đổi được sau khi ghi nhận" |
| Mã CVE | `Text input (1 dòng)` | Có | Người dùng nhập | Enable ở chế độ tạo và sửa | Định dạng `CVE-YYYY-NNNN` trở lên; lưu chữ hoa; duy nhất theo (dự án + CVE + thư viện) — R-ENT-009 | `Vulnerability.cve_id` | Chữ thường tự chuyển sang hoa khi gõ. Khi rời ô mà sai định dạng → `MSG-VAL-020` inline kèm ví dụ hợp lệ. Khi bấm Lưu mà trùng → `MSG-BIZ-030` inline kèm **liên kết tới bản ghi đã có** để người dùng kiểm tra thay vì tạo trùng. | Hệ thống **không** tra cứu CVE từ nguồn ngoài (DEC-02) — không tự điền mô tả hay điểm CVSS |
| Thư viện ảnh hưởng | `Text input (1 dòng)` | Có | Người dùng nhập, kèm gợi ý từ `API` — tên hạng mục tech stack của dự án đã chọn | Enable ở chế độ tạo và sửa | 1–100 ký tự; nhập tay dạng văn bản, không phải khóa ngoại (Q-ENT-05) | `Vulnerability.library` | Khi đã chọn dự án, ô gợi ý các công nghệ dự án đó đang khai báo — giúp tên khớp với tech stack để đối chiếu ở `SCR-PRJ-22` chạy đúng. **Vẫn cho nhập tự do** vì lỗ hổng có thể nằm ở thư viện phụ thuộc gián tiếp chưa khai báo. Rỗng khi bấm Lưu → `MSG-VAL-054` inline. | Gợi ý là cầu nối quan trọng giữa hai khối dữ liệu |
| Phiên bản bị ảnh hưởng | `Text input (1 dòng)` | Có | Người dùng nhập | Enable ở chế độ tạo và sửa | 1–30 ký tự; là phiên bản dự án **đang dùng** và bị ảnh hưởng | `Vulnerability.affected_version` | Rỗng khi bấm Lưu → `MSG-VAL-055` inline. Không ép định dạng. Nếu dự án có hạng mục tech stack cùng tên thư viện, giao diện hiển thị phiên bản đang khai báo bên cạnh ô như một gợi ý đối chiếu — nếu lệch, hiện cảnh báo nhẹ `MSG-BIZ-035` (không chặn), vì có thể tech stack chưa được cập nhật. | Cảnh báo lệch phiên bản giúp phát hiện dữ liệu lỗi thời |
| Mức nghiêm trọng | `Radio group` | Có | `static` — Critical (critical), High (high), Medium (medium), Low (low) | Enable ở chế độ tạo và sửa | Quyết định **ai** được chấp nhận rủi ro (BR-15) | `Vulnerability.severity` | Mỗi lựa chọn có mô tả một dòng. Khi chọn Critical hoặc High, giao diện hiện ngay một dòng ghi chú: "Chỉ quản trị viên được chấp nhận rủi ro cho mức này" — để người dùng biết trước ràng buộc thay vì gặp nút mờ sau đó. Đổi mức của lỗ hổng đang ở trạng thái `Chấp nhận rủi ro` từ Medium lên Critical → cảnh báo `MSG-BIZ-036`, yêu cầu Admin xác nhận lại `[NEEDS-CONFIRMATION]`. | Dùng radio để thấy hết 4 mức cùng lúc |
| Ngày ghi nhận | `Date picker` | Có | Người dùng chọn | Enable ở chế độ tạo và sửa | Không được là ngày tương lai | `Vulnerability.detected_date` | Mặc định hôm nay. Chọn ngày tương lai → `MSG-VAL-056` inline. Đây là mốc tính "số ngày còn mở" nên đổi giá trị này làm mọi số dẫn xuất tính lại. | — |
| Khuyến nghị nâng cấp | `Textarea (nhiều dòng)` | Không | Người dùng nhập | Enable ở chế độ tạo và sửa | Tối đa 500 ký tự | `Vulnerability.recommendation` | Bộ đếm ký tự hiển thị khi vượt 400. Placeholder gợi ý mẫu câu: "Nâng lên phiên bản 2.17.1 trở lên". Không bắt buộc vì có lúc chưa có bản vá. | — |
| Người phụ trách | `Autocomplete` | Không (Có khi chuyển sang `Đang xử lý`) | `API` — tài khoản `Hoạt động`; ưu tiên thành viên của dự án ở đầu danh sách | Enable ở chế độ tạo và sửa | Nên là thành viên dự án; tài khoản `Khóa` không xuất hiện (R-ENT-006) | `Vulnerability.assignee` | Chọn người **không phải** thành viên dự án → cảnh báo `MSG-BIZ-031` màu vàng dưới ô, **không chặn** lưu (có thể là chuyên gia bảo mật từ team khác). Để trống được ở trạng thái `Mới`, nhưng bắt buộc khi chuyển `Đang xử lý` (R-ENT-007). | Danh sách chia hai nhóm: "Thành viên dự án" và "Người dùng khác" |

#### 2.3.2 Khối trạng thái và hành động (chỉ ở chế độ xem)

| Thành phần | Kiểu | Bắt buộc? | Nguồn giá trị / option | Điều kiện enable/disable/hiển thị | Quy tắc nghiệp vụ | Ánh xạ entity / trường | Validation và cách phản hồi (UX) | Ghi chú |
|---|---|---|---|---|---|---|---|---|
| Badge trạng thái hiện tại | `Badge / Nhãn trạng thái` | — | `dynamic` — `Vulnerability.status` | Luôn hiển thị ở chế độ xem | 4 trạng thái theo sơ đồ BU §5.1 | `Vulnerability.status` | Kèm chữ, không chỉ màu. Với trạng thái `Đã xử lý` hiển thị thêm ngày xử lý; với `Chấp nhận rủi ro` hiển thị thêm người quyết định. | — |
| Số ngày còn mở | `Label / Văn bản tĩnh` | — | `dynamic` — trường dẫn xuất | Chỉ hiển thị khi trạng thái là `Mới`/`Đang xử lý` | Quá 30 ngày = quá hạn (DEC-08b) | Tính từ `detected_date` | Quá 30 ngày hiển thị màu cam kèm nhãn "Quá hạn". Với lỗ hổng đã đóng, khối này ẩn hoàn toàn thay vì hiển thị 0. | — |
| Chuyển trạng thái | `Button (hành động chính)` | — | — | **Ẩn** khi không có quyền ghi trên Project | — | — | Mở popup chuyển trạng thái. Không có validation ở nút. | `[PERMISSION-CLIENT]` |
| Danh sách trạng thái đích (trong popup) | `Radio group` | Có | `dynamic` — chỉ các trạng thái hợp lệ từ trạng thái hiện tại theo sơ đồ BU §5.1 | Lựa chọn "Chấp nhận rủi ro" **hiển thị nhưng vô hiệu hóa** khi mức là Critical/High và người dùng không phải Admin | R-ENT-001; BR-15 | `Vulnerability.status` | Trạng thái `Mới` **không bao giờ** xuất hiện là đích. Lựa chọn bị vô hiệu hóa kèm tooltip "Chỉ quản trị viên được chấp nhận rủi ro cho lỗ hổng Critical/High" — cố ý hiển thị chứ không ẩn, để người dùng biết cần nhờ ai. Nếu gọi API trực tiếp → `MSG-AUTH-006`. | Điểm kiểm soát cốt lõi của G-05 |
| Ngày xử lý xong (trong popup) | `Date picker` | Có khi đích = `Đã xử lý` | Người dùng chọn | Chỉ hiển thị khi chọn đích `Đã xử lý` | ≥ `detected_date` và ≤ hôm nay (R-ENT-003) | `Vulnerability.resolved_date` | Mặc định hôm nay. Trước ngày ghi nhận → `MSG-VAL-030` inline. Sau hôm nay → `MSG-VAL-056` inline. Bỏ trống → `MSG-VAL-031` inline. | — |
| Ghi chú / lý do (trong popup) | `Textarea (nhiều dòng)` | Tùy đích | Người dùng nhập | Luôn hiển thị; nhãn đổi theo đích: "Ghi chú cách xử lý" / "Lý do chấp nhận rủi ro" / "Lý do mở lại" / "Ghi chú" | Bắt buộc với `Đã xử lý` (BR-16), `Chấp nhận rủi ro` (BR-15) và mở lại; tùy chọn với `Đang xử lý` | `Vulnerability.resolution_note`, `risk_accept_reason`, `VulnerabilityStatusHistory.note` | Bỏ trống khi bắt buộc → `MSG-VAL-031` / `MSG-VAL-032` / `MSG-VAL-057` inline tùy đích. Tối đa 500 ký tự, bộ đếm hiển thị khi vượt 400. Nhãn và message đổi theo ngữ cảnh chứ không dùng một câu chung — người dùng cần biết đang được hỏi điều gì. | Chi tiết quan trọng: message phải đúng ngữ cảnh |
| Người phụ trách (trong popup) | `Autocomplete` | Có khi đích = `Đang xử lý` | `API` — như trên | Chỉ hiển thị khi chọn đích `Đang xử lý` và lỗ hổng chưa có người phụ trách | R-ENT-007 | `Vulnerability.assignee` | Bỏ trống → `MSG-VAL-033` inline và chặn xác nhận. Nếu đã có người phụ trách thì ô này không hiện, nhưng có liên kết "Đổi người phụ trách". | — |
| Xác nhận chuyển trạng thái | `Button (hành động chính)` | — | — | Vô hiệu hóa khi chưa chọn đích, còn lỗi validation, hoặc đang gửi | — | — | Thành công → popup đóng, trang tải lại, toast `MSG-INF-021`, và nếu đích là `Đã xử lý` thì hiện thêm lời nhắc `MSG-INF-020` kèm liên kết tới tab Tech Stack. Thất bại → popup giữ nguyên với lỗi inline. | BR-17 |
| Sửa thông tin | `Button (phụ / hủy)` | — | — | **Ẩn** khi không có quyền ghi | — | — | Chuyển các trường ở §2.3.1 sang chế độ nhập (trừ Dự án). Không có validation ở nút. | — |
| Xóa | — | — | — | **Không tồn tại** ở bất kỳ vai trò nào | BR-13 — không ai được xóa lỗ hổng | — | Không có nút xóa trên giao diện. Nếu API xóa tồn tại thì đó là lỗi thiết kế. | Ghi rõ để QA kiểm tra sự **vắng mặt** |

#### 2.3.3 Khối lịch sử xử lý

| Thành phần | Kiểu | Bắt buộc? | Nguồn giá trị / option | Điều kiện enable/disable/hiển thị | Quy tắc nghiệp vụ | Ánh xạ entity / trường | Validation và cách phản hồi (UX) | Ghi chú |
|---|---|---|---|---|---|---|---|---|
| Bảng lịch sử trạng thái | `Data table (hàng biến thiên)` | — | `API` — `VulnerabilityStatusHistory` của lỗ hổng | Chỉ hiển thị ở chế độ xem | Bất biến — không sửa, không xóa (BR-14) | `VulnerabilityStatusHistory` | Cột: Thời điểm, Từ trạng thái, Sang trạng thái, Người thực hiện, Ghi chú. Sắp xếp mới nhất trước, **không đổi được** — thứ tự thời gian là bản chất của lịch sử. Dòng đầu tiên (lúc ghi nhận) có cột "Từ trạng thái" rỗng, hiển thị "— (ghi nhận mới)". Rỗng về lý thuyết không xảy ra; nếu gặp, hiển thị `MSG-INF-039` và ghi nhận là lỗi dữ liệu. Khi API lỗi: thông báo inline trong khối này kèm nút "Thử lại"; **phần còn lại của màn vẫn hiển thị bình thường**. Tương tác: không có tooltip hay legend — bảng HTML thuần, không dùng thư viện chart. | Không có nút sửa/xóa trên bất kỳ dòng nào — QA phải kiểm tra sự vắng mặt này |
| Ghi chú tính bất biến | `Label / Văn bản tĩnh` | — | `hardcoded` | Luôn hiển thị dưới bảng lịch sử | BR-14 | — | Một dòng nhỏ: "Lịch sử xử lý không thể sửa hoặc xóa." Không có validation. | Đặt kỳ vọng đúng, tránh người dùng đi tìm nút sửa |

### 2.4 Tương tác và luồng nhỏ trên màn

| Mã luồng | Tên luồng | Trigger | Tiền điều kiện | Xử lý hệ thống | Kết quả UI | Điều hướng / side effect | Ghi chú |
|---|---|---|---|---|---|---|---|
| F-S11-01 | Vào chế độ tạo | `/security/new` | Có quyền ghi trên ≥1 Project chưa Kết thúc | Tải danh sách dự án ghi được | Form rỗng, ngày ghi nhận = hôm nay | — | UC-SEC-02 |
| F-S11-02 | Vào chế độ tạo từ tab Bảo mật | Bấm "Ghi nhận lỗ hổng" ở `SCR-PRJ-24` | Dự án chưa `Kết thúc` | — | Ô Dự án điền sẵn và chỉ đọc; ô Thư viện có gợi ý từ tech stack dự án đó | — | US-026 |
| F-S11-03 | Không thuộc dự án nào ghi được | `/security/new` | Người dùng không là thành viên dự án nào chưa Kết thúc và không phải Admin | — | Thay cho form là `MSG-BIZ-034` kèm nút "Về danh sách lỗ hổng" | — | Tránh để người dùng điền hết form rồi mới biết không lưu được |
| F-S11-04 | Lưu tạo mới | Bấm "Lưu" | Validation qua | Tạo bản ghi trạng thái `Mới`; tạo dòng lịch sử đầu tiên | Toast `MSG-INF-022` | → `/security/:id` chế độ xem | UC-SEC-02, US-025 |
| F-S11-05 | Trùng bản ghi | Bấm "Lưu" | Đã có (dự án + CVE + thư viện) | Máy chủ từ chối | `MSG-BIZ-030` inline dưới ô CVE kèm liên kết tới bản ghi đã có | Ở lại màn | R-ENT-009, US-025 |
| F-S11-06 | Chuyển trạng thái → Đang xử lý | Popup chuyển trạng thái | Có quyền ghi | Cập nhật trạng thái + `assignee`; ghi dòng lịch sử | Toast `MSG-INF-021`; badge và bảng lịch sử cập nhật | — | R-ENT-007, US-027 |
| F-S11-07 | Chuyển trạng thái → Đã xử lý | Popup chuyển trạng thái | Có quyền ghi; đã nhập ngày và ghi chú | Cập nhật trạng thái, `resolved_date`, `resolution_note`; ghi dòng lịch sử | Toast `MSG-INF-021` **và** lời nhắc `MSG-INF-020` kèm liên kết tới tab Tech Stack của dự án | Không tự đổi tech stack (BR-17) | US-028 |
| F-S11-08 | Chuyển trạng thái → Chấp nhận rủi ro (Medium/Low) | Popup chuyển trạng thái | Có quyền ghi; đã nhập lý do | Cập nhật trạng thái + `risk_accept_reason`; ghi dòng lịch sử | Toast `MSG-INF-021` | — | BR-15, US-029 |
| F-S11-09 | Chặn chấp nhận rủi ro Critical/High | Mở popup với lỗ hổng Critical/High, không phải Admin | — | — | Lựa chọn hiển thị nhưng **vô hiệu hóa** kèm tooltip giải thích | Không đổi trạng thái | DEC-09, US-029 |
| F-S11-10 | Mở lại lỗ hổng đã đóng | Popup chuyển trạng thái từ `Đã xử lý` sang `Đang xử lý` | Có quyền ghi; đã nhập lý do mở lại | Cập nhật trạng thái; xóa `resolved_date`; ghi dòng lịch sử | Toast `MSG-INF-021` | — | BU §5.1 |
| F-S11-11 | Chuyển trạng thái không hợp lệ | Gọi API trực tiếp với đích không hợp lệ | — | Máy chủ từ chối | Toast `MSG-BIZ-040` và tải lại | Không đổi | R-ENT-001, US-027 |
| F-S11-12 | Xung đột đồng thời | Bấm xác nhận | Người khác vừa đổi trạng thái | Máy chủ so `updated_at` và từ chối | Popup hiển thị `MSG-BIZ-021` nêu rõ **trạng thái hiện tại mới** và nút "Tải lại" | Không đổi | EC-05, quan trọng vì đây là dữ liệu nhiều người cùng động tới |
| F-S11-13 | Sửa thông tin lỗ hổng | Bấm "Sửa thông tin" → Lưu | Có quyền ghi | Cập nhật các trường §2.3.1 (trừ Dự án) | Toast `MSG-INF-023` | Không sinh dòng lịch sử (lịch sử chỉ ghi chuyển **trạng thái**) | Điểm dễ hiểu nhầm — cần ghi rõ cho Dev |
| F-S11-14 | Đi tới tab Tech Stack từ lời nhắc | Bấm liên kết trong `MSG-INF-020` | — | — | — | `/projects/:id/tech-stack` | DP-01 bước 6 |

### 2.5 Trạng thái màn hình

| State | Điều kiện vào | Người dùng thấy gì | Còn thao tác gì được | Cách thoát state | Ghi chú |
|---|---|---|---|---|---|
| Initial | Vào chế độ tạo | Form rỗng, nút Lưu vô hiệu hóa | Nhập liệu | Điền đủ trường bắt buộc | — |
| Loading | Đang tải chi tiết hoặc đang lưu | Skeleton / vòng quay trên nút | Không | Máy chủ phản hồi | Khối lịch sử tải độc lập |
| Empty | Không có dự án nào ghi được (chế độ tạo) | `MSG-BIZ-034` thay cho form | Về danh sách | Rời màn | Trạng thái rỗng đặc thù của màn này |
| Empty | Bảng lịch sử rỗng | `MSG-INF-039` — dữ liệu bất thường | Tiếp tục | — | Không được xảy ra theo BR-14 |
| Error | API chi tiết lỗi | Thông báo `MSG-SYS-003` chiếm chỗ nội dung kèm nút "Thử lại" và "Về danh sách" | Thử lại | Tải thành công | — |
| Error (bộ phận) | API lịch sử lỗi nhưng chi tiết tốt | Khối lịch sử hiện lỗi kèm nút "Thử lại"; phần còn lại bình thường | Mọi thao tác khác | Tải lại khối | Lỗi một phần không làm hỏng cả màn |
| Error | Lưu hoặc chuyển trạng thái lỗi | Lỗi inline theo ô hoặc banner; **giữ nguyên** dữ liệu đã nhập | Sửa và thử lại | Thành công | Không bao giờ rời màn khi lưu thất bại |
| Timeout | Không phản hồi trong 20 giây | Banner `MSG-SYS-002`; dữ liệu giữ nguyên | Thử lại | — | `[ASSUMED]` |
| Concurrent / Race | Người khác vừa đổi trạng thái lỗ hổng này | `MSG-BIZ-021` nêu rõ trạng thái mới + nút "Tải lại" | Tải lại rồi thao tác | Tải lại | Trạng thái quan trọng nhất của màn này |
| Success | Lưu / chuyển trạng thái thành công | Toast xanh; badge và bảng lịch sử cập nhật; có thể kèm lời nhắc `MSG-INF-020` | Tiếp tục | Tự hết sau 4 giây (lời nhắc giữ đến khi đóng) | — |
| No permission | Không có quyền ghi (chế độ xem) | Nội dung đầy đủ, mọi nút ghi **ẩn**; riêng "Chấp nhận rủi ro" trong popup thì mờ kèm tooltip | Đọc, xem lịch sử | — | Phân biệt ẩn và vô hiệu hóa có chủ ý |
| Not found (404) | ID không tồn tại | **Trang 404** `MSG-NF-005` + nút về danh sách | Rời màn | — | — |
| Session expired | Phiên hết hạn | Toast `MSG-AUTH-004`, chuyển `/login` | Không | — | Dữ liệu chưa lưu bị mất |

### 2.6 Validation, lỗi và trường hợp ngoại lệ

| Nhóm lỗi | Điều kiện phát sinh | Phản hồi UI mong đợi | Mã message | Vị trí hiển thị | Có nút Retry | Có chặn action | Ghi chú QA |
|---|---|---|---|---|---|---|---|
| Dữ liệu rỗng | Không có dự án ghi được; bảng lịch sử rỗng | Hai thông báo riêng biệt | `MSG-BIZ-034`, `MSG-INF-039` | inline vùng nội dung | Không | Có / Không | Thử với tài khoản User không thuộc dự án nào |
| Lỗi nhập liệu | CVE sai định dạng; thư viện/phiên bản rỗng; ngày tương lai; ngày xử lý trước ngày ghi nhận; ghi chú bắt buộc để trống | Thông báo đỏ tại đúng ô, chặn gọi API | `MSG-VAL-020`, `MSG-VAL-030`, `MSG-VAL-031`, `MSG-VAL-032`, `MSG-VAL-033`, `MSG-VAL-053..057` | inline | Không | Có | Thử `CVE-24-123`, `cve-2024-12345`, `CVE-2024-123`, `CVE-2024-1234567`, thư viện 101 ký tự |
| Lỗi nghiệp vụ | Trùng (dự án + CVE + thư viện) | Inline dưới ô CVE kèm liên kết tới bản ghi đã có | `MSG-BIZ-030` | inline | Không | Có | Thử `cve-2024-12345` vs `CVE-2024-12345` — vẫn phải bị chặn |
| Lỗi nghiệp vụ | Ghi nhận cho dự án đã `Kết thúc` | Dự án đó không có trong danh sách; nếu gọi API trực tiếp thì toast | `MSG-BIZ-032` | toast | Không | Có | US-026 |
| Lỗi nghiệp vụ | Chuyển trạng thái không hợp lệ theo sơ đồ | Toast và tải lại | `MSG-BIZ-040` | toast | Không | Có | Thử gọi API chuyển về `Mới` |
| Lỗi nghiệp vụ | Người phụ trách không phải thành viên dự án | **Cảnh báo** vàng dưới ô, không chặn | `MSG-BIZ-031` | inline (cảnh báo) | Không | **Không** | Điểm dễ implement nhầm thành chặn |
| Lỗi nghiệp vụ | Gán tài khoản đã khóa làm người phụ trách (chỉ qua API trực tiếp) | Toast; tài khoản khóa không xuất hiện trong danh sách chọn trên giao diện | `MSG-BIZ-033` | toast | Không | Có | R-ENT-006. Thử gọi API với id của tài khoản vừa bị khóa |
| Lỗi nghiệp vụ | Phiên bản bị ảnh hưởng lệch với tech stack đang khai báo | **Cảnh báo** vàng, không chặn | `MSG-BIZ-035` | inline (cảnh báo) | Không | **Không** | Thử khi dự án chưa khai báo thư viện đó — không được hiện cảnh báo |
| Lỗi quyền (403) | Không phải Admin mà chấp nhận rủi ro Critical/High | Lựa chọn vô hiệu hóa kèm tooltip; gọi API trực tiếp → toast | `MSG-AUTH-006` | toast | Không | Có | **Kiểm tra máy chủ chặn thật**, không chỉ vô hiệu hóa trên giao diện — đây là kiểm soát cốt lõi của G-05 |
| Lỗi quyền (403) | Không có quyền ghi mà gọi API cập nhật | Toast | `MSG-AUTH-005` | toast | Không | Có | Thử với lỗ hổng của dự án mình không tham gia |
| Lỗi quyền (401) | Phiên hết hạn | Toast rồi chuyển `/login` | `MSG-AUTH-004` | toast | Không | Có | — |
| Không tìm thấy (404) | ID lỗ hổng không tồn tại | Trang 404 kèm nút về danh sách | `MSG-NF-005` | page | Không | Có | Phân biệt rõ với lỗi hệ thống |
| Lỗi mạng / timeout | Mất kết nối khi lưu | Banner, **giữ nguyên** dữ liệu đã nhập | `MSG-SYS-002` | banner | Không (bấm lại) | Có | Kiểm tra ghi chú dài không bị mất |
| Thao tác đồng thời | Người khác vừa đổi trạng thái | `MSG-BIZ-021` nêu rõ trạng thái mới + nút Tải lại | `MSG-BIZ-021` | banner trong popup | Không | Có | **Trường hợp quan trọng nhất** — nhiều người cùng xử lý một lỗ hổng là chuyện thường |
| Lỗi hệ thống | Lỗi ngoài dự kiến | Banner chung, giữ nguyên dữ liệu | `MSG-SYS-001` | banner | Không | Có | — |

#### 2.6.1 Đặc tả message

| Mã | Nội dung (VI) | Vị trí | Thời điểm | Hành vi sau message | Phân loại | Đối tượng đọc |
|---|---|---|---|---|---|---|
| `MSG-VAL-020` | "Mã CVE không đúng định dạng. Ví dụ hợp lệ: CVE-2024-12345." | inline | Khi rời ô | Chặn gọi API | validation | Cả hai |
| `MSG-VAL-030` | "Ngày xử lý xong không được trước ngày ghi nhận." | inline | Khi rời ô | Chặn xác nhận | validation | Cả hai |
| `MSG-VAL-031` | "Vui lòng nhập ghi chú cách xử lý." | inline | Khi bấm xác nhận | Chặn xác nhận | validation | Cả hai |
| `MSG-VAL-032` | "Vui lòng nhập lý do chấp nhận rủi ro." | inline | Khi bấm xác nhận | Chặn xác nhận | validation | Cả hai |
| `MSG-VAL-033` | "Vui lòng chọn người phụ trách trước khi chuyển sang Đang xử lý." | inline | Khi bấm xác nhận | Chặn xác nhận | validation | Cả hai |
| `MSG-VAL-053` | "Vui lòng chọn dự án." | inline | Khi bấm Lưu | Chặn gọi API | validation | Cả hai |
| `MSG-VAL-054` | "Vui lòng nhập tên thư viện bị ảnh hưởng." | inline | Khi rời ô | Chặn gọi API | validation | Cả hai |
| `MSG-VAL-055` | "Vui lòng nhập phiên bản đang sử dụng bị ảnh hưởng." | inline | Khi rời ô | Chặn gọi API | validation | Cả hai |
| `MSG-VAL-056` | "Ngày không được là ngày trong tương lai." | inline | Khi rời ô | Chặn gọi API | validation | Cả hai |
| `MSG-VAL-057` | "Vui lòng nhập lý do mở lại lỗ hổng này." | inline | Khi bấm xác nhận | Chặn xác nhận | validation | Cả hai |
| `MSG-BIZ-021` | "Lỗ hổng này vừa được người khác chuyển sang trạng thái {trạng thái mới}. Vui lòng tải lại trước khi thao tác tiếp." | banner trong popup | Sau khi máy chủ từ chối | Chặn; kèm nút "Tải lại" | business | Cả hai |
| `MSG-BIZ-030` | "Dự án này đã ghi nhận {mã CVE} cho thư viện {tên thư viện}." | inline | Sau khi máy chủ từ chối | Chặn lưu; kèm liên kết tới bản ghi đã có | business | Cả hai |
| `MSG-BIZ-031` | "{Họ tên} không phải thành viên của dự án này. Bạn vẫn có thể gán, nhưng người đó sẽ không sửa được dữ liệu dự án." | inline (cảnh báo vàng) | Khi chọn người | **Không** chặn | business | Cả hai |
| `MSG-BIZ-032` | "Không thể ghi nhận lỗ hổng cho dự án đã kết thúc." | toast | Sau khi máy chủ từ chối | Chặn | business | Cả hai |
| `MSG-BIZ-034` | "Bạn chưa tham gia dự án nào đang hoạt động nên chưa thể ghi nhận lỗ hổng. Vui lòng liên hệ PM của dự án để được thêm vào." | inline vùng nội dung | Khi vào chế độ tạo | Chặn; kèm nút về danh sách | business | Người dùng cuối |
| `MSG-BIZ-035` | "Tech stack của dự án đang ghi phiên bản {phiên bản}. Hãy kiểm tra lại xem thông tin nào chính xác." | inline (cảnh báo vàng) | Khi rời ô phiên bản | **Không** chặn | business | Cả hai |
| `MSG-BIZ-036` | "Lỗ hổng này đang ở trạng thái Chấp nhận rủi ro. Nâng mức lên {mức} khiến quyết định đó cần được quản trị viên xem xét lại." | inline (cảnh báo vàng) | Khi đổi mức | **Không** chặn `[NEEDS-CONFIRMATION]` | business | Cả hai |
| `MSG-BIZ-040` | "Không thể chuyển sang trạng thái này từ trạng thái hiện tại." | toast | Sau khi máy chủ từ chối | Chặn; tải lại | business | Cả hai |
| `MSG-AUTH-006` | "Chỉ quản trị viên được chấp nhận rủi ro cho lỗ hổng mức Critical hoặc High." | toast / tooltip | Khi mở popup (tooltip) hoặc sau khi máy chủ từ chối (toast) | Chặn | auth | Cả hai |
| `MSG-INF-020` | "Đã đóng lỗ hổng. Nếu bạn xử lý bằng cách nâng phiên bản, đừng quên cập nhật phiên bản trong tab Tech Stack của dự án." | banner (thông tin) | Sau khi chuyển sang Đã xử lý | Không chặn; kèm liên kết tới tab Tech Stack; giữ đến khi người dùng đóng | info | Cả hai |
| `MSG-INF-021` | "Đã chuyển trạng thái sang {trạng thái}." | toast | Sau khi chuyển thành công | Tải lại chi tiết và lịch sử | info | Cả hai |
| `MSG-INF-022` | "Đã ghi nhận lỗ hổng {mã CVE} cho dự án {tên dự án}." | toast | Sau khi tạo thành công | Chuyển sang chế độ xem | info | Cả hai |
| `MSG-INF-023` | "Đã cập nhật thông tin lỗ hổng." | toast | Sau khi sửa thành công | Không chặn | info | Cả hai |
| `MSG-INF-039` | "Không có dữ liệu lịch sử. Đây là dữ liệu bất thường — vui lòng liên hệ quản trị viên." | inline vùng dữ liệu | Khi API lịch sử trả 0 bản ghi | Không chặn | info | Cả hai |
| `MSG-NF-005` | "Không tìm thấy lỗ hổng bạn đang tìm." | page | Sau khi API trả 404 | Chặn; kèm nút về danh sách | not-found | Cả hai |

### 2.7 Mapping dữ liệu vào / ra

| Nhóm dữ liệu | Thành phần UI | Đọc từ đâu | Ghi ra đâu | Mục đích nghiệp vụ | Ghi chú |
|---|---|---|---|---|---|
| Chi tiết lỗ hổng | Khối thông tin, khối trạng thái | API chi tiết `Vulnerability` | — | Hiển thị hiện trạng | Kèm `updated_at` chống ghi đè |
| Lịch sử trạng thái | Bảng lịch sử | API `VulnerabilityStatusHistory` | — | Dấu vết kiểm toán (BR-14) | Gọi độc lập, lỗi không làm hỏng cả màn |
| Danh sách dự án ghi được | Ô Dự án | API Project mà người dùng ghi được và chưa `Kết thúc` | — | Ngăn chọn dự án không hợp lệ ngay từ đầu | Không hiển thị rồi báo lỗi sau |
| Gợi ý thư viện | Ô Thư viện | API `TechStackItem` của dự án đã chọn | — | Giúp tên khớp tech stack để đối chiếu chạy đúng | Vẫn cho nhập tự do |
| Gợi ý người phụ trách | Ô Người phụ trách | API User `Hoạt động`, đánh dấu ai là thành viên dự án | — | Chọn người chịu trách nhiệm | Loại trừ tài khoản `Khóa` (R-ENT-006) |
| Đối chiếu phiên bản | Gợi ý cạnh ô Phiên bản | API `TechStackItem` cùng tên thư viện | — | Phát hiện dữ liệu tech stack lỗi thời | Chỉ cảnh báo, không chặn |
| Tạo / cập nhật / chuyển trạng thái | Form và popup | Người dùng nhập | API `Vulnerability` (+ tự sinh `VulnerabilityStatusHistory`) | Theo dõi và đóng rủi ro | Máy chủ kiểm tra R-ENT-001..004, 007, 009 và BR-15 |

### 2.8 Email / Thông báo phát sinh từ màn

**Không phát sinh email/notification** `[DECIDED — DEC-08b]`. Hệ quả nghiệp vụ rõ rệt tại màn này: khi một người được **gán làm người phụ trách** một lỗ hổng, họ **không nhận được thông báo nào** — người gán phải báo qua kênh ngoài hệ thống. Với lỗ hổng Critical, đây là rủi ro quy trình đáng kể `[NEEDS-CONFIRMATION — Q-08: cân nhắc ít nhất một thông báo trong ứng dụng ở giai đoạn sau]`.

### 2.9 Xuất dữ liệu

**Không có chức năng xuất dữ liệu** ở màn này. Kết xuất danh sách lỗ hổng nằm ở `SCR-SEC-10` (`EXP-SEC-01`).

### 2.10 Liên kết use case và chức năng

UC-SEC-02, UC-SEC-03, UC-SEC-04. Feature FE-09, FE-10. Stories US-025, US-026, US-027, US-028, US-029, US-030.

### 2.11 Câu hỏi mở

- `[NEEDS-CONFIRMATION]` Khi nâng mức nghiêm trọng của một lỗ hổng đang ở trạng thái `Chấp nhận rủi ro` từ Medium lên Critical, có nên **chặn** và yêu cầu Admin xác nhận lại thay vì chỉ cảnh báo không? (hiện chỉ cảnh báo — `MSG-BIZ-036`)
- `[NEEDS-CONFIRMATION]` Có cần thông báo trong ứng dụng khi được gán làm người phụ trách không?
- Q-ENT-05 (BE): thư viện nhập tự do làm việc đối chiếu với tech stack không chắc chắn.

---

## §3. SCR-PRJ-24 — Tab Security theo Project

- **Screen ID**: `SCR-PRJ-24`
- **Business name**: Bảo mật của dự án
- **Route / entry**: `/projects/:id/security`
- **Related screens**: cùng khung với `SCR-PRJ-20`; → `SCR-SEC-11`
- **RBAC note**: đọc — mọi người dùng. Ghi nhận lỗ hổng mới — có quyền ghi trên Project và Project chưa `Kết thúc`.
- **Nguồn chính**: `[FROM-TEAM]`

### 3.1 Mục đích

Tab này là bản thu hẹp của `SCR-SEC-10` vào phạm vi một dự án. Nó phục vụ người trong dự án — những người cần biết *"dự án của tôi đang nợ những gì"* — chứ không phải góc nhìn toàn tổ chức. Nó cũng là điểm vào tự nhiên nhất để ghi nhận lỗ hổng, vì bối cảnh dự án đã có sẵn.

### 3.2 Điều kiện trước và phân quyền

Cần đã đăng nhập và dự án tồn tại. Ghi nhận lỗ hổng mới cần quyền ghi và dự án chưa `Kết thúc`.

- **Loại permission gate**: client-side computed.
- **Hệ quả UX**: nút "Ghi nhận lỗ hổng" **ẩn** khi không đủ quyền hoặc dự án đã `Kết thúc`.

### 3.3 Thành phần giao diện

| Thành phần | Kiểu | Bắt buộc? | Nguồn giá trị / option | Điều kiện enable/disable/hiển thị | Quy tắc nghiệp vụ | Ánh xạ entity / trường | Validation và cách phản hồi (UX) | Ghi chú |
|---|---|---|---|---|---|---|---|---|
| Khối tóm tắt theo mức | `Bảng dữ liệu tĩnh` | — | `API` — số lỗ hổng còn mở của dự án theo 4 mức | Luôn hiển thị | "Còn mở" = Mới + Đang xử lý | `Vulnerability` | Lỗi / trạng thái rỗng: khi API lỗi, khối hiển thị dấu "—" kèm tooltip `MSG-SYS-004`; khi dự án không còn lỗ hổng mở, hiển thị "Không còn lỗ hổng nào đang mở" thay vì bốn số 0. Tương tác: không có — khối render bằng HTML thuần, không dùng thư viện chart; mỗi con số bấm được để áp bộ lọc mức tương ứng vào bảng bên dưới. | Bốn ô: Critical, High, Medium, Low |
| Ghi nhận lỗ hổng | `Button (hành động chính)` | — | — | **Ẩn** khi không có quyền ghi hoặc dự án `Kết thúc` | BR-11, EC-02 | — | Điều hướng tới `/security/new` với dự án điền sẵn. Không có validation ở nút. | `[PERMISSION-CLIENT]` |
| Lọc mức nghiêm trọng | `Checkbox group` | Không | `static` — Critical, High, Medium, Low | Luôn enable | — | `Vulnerability.severity` | Như `SCR-SEC-10`. Bỏ chọn hết = không lọc theo mức. | — |
| Lọc trạng thái xử lý | `Checkbox group` | Không | `static` — Mới, Đang xử lý, Đã xử lý, Chấp nhận rủi ro | Luôn enable | Mặc định chọn Mới + Đang xử lý | `Vulnerability.status` | Như `SCR-SEC-10`. | — |
| Bảng lỗ hổng của dự án | `Data table (hàng biến thiên)` | — | `API` — lỗ hổng của dự án theo bộ lọc | Luôn hiển thị | Cột: Mức, Mã CVE, Thư viện, Phiên bản, Trạng thái, Người phụ trách, Ngày ghi nhận, Số ngày còn mở | `Vulnerability` | Rỗng → `MSG-INF-040` hoặc `MSG-INF-041` tùy có bộ lọc hay không. API lỗi → thông báo inline kèm nút "Thử lại". Tương tác: sắp xếp theo Mức, Ngày ghi nhận, Số ngày còn mở; không có tooltip/legend — bảng HTML thuần. | **Không** có cột Dự án — thừa trong ngữ cảnh này |
| Cảnh báo dự án đã kết thúc | `Label / Văn bản tĩnh` | — | `dynamic` | Chỉ hiển thị khi `Project.status = Kết thúc` | BR-19 | `Project.status` | Banner xám: "Dự án đã kết thúc. Các lỗ hổng dưới đây không được tính vào Dashboard và không thể ghi nhận lỗ hổng mới." Không có validation. | Giải thích vì sao nút ghi nhận biến mất |
| Phân trang | `Pagination` | — | `dynamic` | Ẩn khi chỉ một trang | — | — | Như các màn danh sách khác. | ASM-06 |

### 3.4 Tương tác và luồng nhỏ trên màn

| Mã luồng | Tên luồng | Trigger | Tiền điều kiện | Xử lý hệ thống | Kết quả UI | Điều hướng / side effect | Ghi chú |
|---|---|---|---|---|---|---|---|
| F-P24-01 | Tải danh sách | Vào tab | Dự án tồn tại | Gọi API tóm tắt + API danh sách | Khối tóm tắt và bảng hiển thị | — | Hai API độc lập |
| F-P24-02 | Vào từ drill-down | Bấm số lỗ hổng ở `SCR-PRJ-10` hoặc `SCR-PRJ-20` | — | Áp bộ lọc từ query string | Bảng đã lọc sẵn | — | F-P10-06, F-P20-05 |
| F-P24-03 | Lọc | Đổi checkbox | — | Gọi API; về trang 1 | Bảng cập nhật | Ghi query string | — |
| F-P24-04 | Drill-down từ khối tóm tắt | Bấm một con số | — | Áp bộ lọc mức tương ứng + trạng thái còn mở | Bảng cập nhật | Không rời tab | — |
| F-P24-05 | Ghi nhận lỗ hổng | Bấm "Ghi nhận lỗ hổng" | Có quyền ghi, dự án chưa Kết thúc | — | — | `/security/new` với dự án điền sẵn và khóa | US-026 |
| F-P24-06 | Mở chi tiết | Bấm một dòng | — | — | — | `/security/:id` | Quay lại giữ nguyên tab và bộ lọc |
| F-P24-07 | Vào từ thông báo chặn kết thúc dự án | Bấm liên kết trong `MSG-BIZ-003` | — | Áp bộ lọc trạng thái còn mở | Bảng chỉ hiển thị lỗ hổng còn mở | — | DP-04 bước 3 |

### 3.5 Trạng thái màn hình

| State | Điều kiện vào | Người dùng thấy gì | Còn thao tác gì được | Cách thoát state | Ghi chú |
|---|---|---|---|---|---|
| Initial | Vào tab | Skeleton khối tóm tắt và bảng | Không | API trả về | — |
| Loading | Đang tải | Skeleton | Đổi bộ lọc sau khi tải xong | API trả về | — |
| Empty | Dự án chưa có lỗ hổng nào | `MSG-INF-041` "Dự án chưa ghi nhận lỗ hổng nào." kèm nút ghi nhận nếu có quyền | Ghi nhận lỗ hổng | Có dữ liệu | Tin tốt — văn phong trung tính |
| Empty (theo bộ lọc) | Bộ lọc không ra kết quả | `MSG-INF-040` kèm nút xóa bộ lọc | Đổi bộ lọc | Có kết quả | Hai câu khác nhau |
| Error | API danh sách lỗi | Thông báo inline trong vùng bảng kèm nút "Thử lại" | Thử lại | Tải thành công | — |
| Error (bộ phận) | API tóm tắt lỗi nhưng danh sách tốt | Khối tóm tắt hiện "—" kèm tooltip; bảng bình thường | Mọi thao tác | Tải lại | — |
| Timeout | Không phản hồi trong 20 giây | Như Error với `MSG-SYS-002` | Thử lại | — | `[ASSUMED]` |
| Concurrent / Race | Lỗ hổng bị người khác đổi trạng thái | Không cảnh báo — tab chỉ đọc | Tiếp tục | — | Xung đột xử lý ở `SCR-SEC-11` |
| Success | Quay lại sau khi ghi nhận/cập nhật | Toast từ màn trước; dòng làm nổi 2 giây | Tiếp tục | Tự hết sau 4 giây | — |
| No permission | Không có quyền ghi | Bảng đầy đủ, nút ghi nhận ẩn | Đọc, lọc | — | — |
| Session expired | Phiên hết hạn | Toast `MSG-AUTH-004`, chuyển `/login` | Không | — | — |

### 3.6 Validation, lỗi và trường hợp ngoại lệ

| Nhóm lỗi | Điều kiện phát sinh | Phản hồi UI mong đợi | Mã message | Vị trí hiển thị | Có nút Retry | Có chặn action | Ghi chú QA |
|---|---|---|---|---|---|---|---|
| Dữ liệu rỗng | Chưa có lỗ hổng / lọc không ra | Hai câu riêng biệt | `MSG-INF-040`, `MSG-INF-041` | inline vùng dữ liệu | Không | Không | Kiểm tra cả hai mức quyền |
| Lỗi nhập liệu | N/A — tab chỉ có bộ lọc dạng checkbox | — | — | — | — | — | Ghi N/A có chủ ý |
| Lỗi nghiệp vụ | Ghi nhận cho dự án đã Kết thúc | Nút đã ẩn; gọi URL trực tiếp → toast ở màn đích | `MSG-BIZ-032` | toast | Không | Có | Thử mở `/security/new?project=` của dự án đã kết thúc |
| Lỗi quyền (401/403) | Phiên hết hạn | Toast rồi chuyển `/login` | `MSG-AUTH-004` | toast | Không | Có | — |
| Không tìm thấy (404) | ID dự án không tồn tại | Trang 404 ở cấp màn cha | `MSG-NF-001` | page | Không | Có | — |
| Lỗi mạng / timeout | Mất kết nối | Lỗi inline kèm nút Thử lại | `MSG-SYS-002` | inline vùng dữ liệu | **Có** | Không | — |
| Thao tác đồng thời | N/A cho tab chỉ đọc | — | — | — | — | — | Ghi N/A có chủ ý |
| Lỗi hệ thống | API lỗi ngoài dự kiến | Lỗi inline kèm nút Thử lại | `MSG-SYS-003` | inline vùng dữ liệu | **Có** | Không | Thử riêng trường hợp chỉ API tóm tắt lỗi |

#### 3.6.1 Đặc tả message

| Mã | Nội dung (VI) | Vị trí | Thời điểm | Hành vi sau message | Phân loại | Đối tượng đọc |
|---|---|---|---|---|---|---|
| `MSG-INF-040` | "Không có lỗ hổng nào phù hợp với bộ lọc hiện tại." | inline vùng dữ liệu | Khi API trả 0 và có bộ lọc | Không chặn; kèm nút xóa bộ lọc | info | Cả hai |
| `MSG-INF-041` | "Dự án chưa ghi nhận lỗ hổng nào." | inline vùng dữ liệu | Khi dự án chưa có bản ghi nào | Không chặn; kèm nút ghi nhận nếu có quyền | info | Cả hai |

### 3.7 Mapping dữ liệu vào / ra

| Nhóm dữ liệu | Thành phần UI | Đọc từ đâu | Ghi ra đâu | Mục đích nghiệp vụ | Ghi chú |
|---|---|---|---|---|---|
| Tóm tắt theo mức | Khối 4 ô | API tổng hợp lỗ hổng còn mở theo Project | — | Nắm nhanh nợ bảo mật của dự án | Gọi độc lập với danh sách |
| Danh sách lỗ hổng | Bảng | API lỗ hổng lọc theo Project | — | Xem chi tiết từng lỗ hổng | Không có cột Dự án |
| Trạng thái dự án | Banner cảnh báo, nút ghi nhận | API chi tiết Project (đã có ở màn cha) | — | Giải thích vì sao không ghi nhận được | BR-19, EC-02 |

### 3.8 Email / Thông báo phát sinh từ màn

**Không phát sinh email/notification** `[DECIDED — DEC-08b]`.

### 3.9 Xuất dữ liệu

**Không có chức năng xuất dữ liệu** ở tab này. Người dùng cần kết xuất theo dự án có thể dùng `SCR-SEC-10` với bộ lọc dự án tương ứng `[NEEDS-CONFIRMATION — có nên bổ sung nút kết xuất ngay tại tab này cho tiện không?]`.

### 3.10 Liên kết use case và chức năng

UC-SEC-01. Feature FE-11. Stories US-026, US-031.

### 3.11 Câu hỏi mở

- `[NEEDS-CONFIRMATION]` Có bổ sung nút kết xuất CSV ngay tại tab này không?

---

## §4. SCR-DASH-10 — Dashboard

- **Screen ID**: `SCR-DASH-10`
- **Business name**: Dashboard tổng quan
- **Route / entry**: `/` (alias `/dashboard`) — trang chủ sau khi đăng nhập
- **Related screens**: → `SCR-PRJ-10`, → `SCR-SEC-10`
- **Nguồn chính**: `[FROM-TEAM]` + `[DECIDED — DEC-05, DEC-08b]`

### 4.1 Mục đích

Dashboard tồn tại để thay thế công việc tổng hợp thủ công (G-03) và — vì hệ thống **không gửi cảnh báo chủ động** (DEC-08b) — nó còn gánh thêm vai trò **kênh cảnh báo duy nhất**: nơi một lỗ hổng Critical mới hoặc một lỗ hổng tồn đọng quá lâu được đẩy lên trước mắt người dùng ngay khi họ đăng nhập. Vì vậy khối cảnh báo được đặt trên cùng, trước mọi thống kê.

### 4.2 Điều kiện trước và phân quyền

Cần **đã đăng nhập**. Mọi người dùng thấy cùng một nội dung — Dashboard không lọc theo dự án người dùng tham gia, vì mục tiêu là bức tranh toàn tổ chức (BR-03).

- **Loại permission gate**: route guard.
- **Khác biệt theo quyền**: không có phần tử nào bị ẩn theo vai trò `[NEEDS-CONFIRMATION — nếu Q-09 thu hẹp phạm vi đọc lỗ hổng Critical, khối cảnh báo phải đổi]`.

### 4.3 Thành phần giao diện

| Thành phần | Kiểu | Bắt buộc? | Nguồn giá trị / option | Điều kiện enable/disable/hiển thị | Quy tắc nghiệp vụ | Ánh xạ entity / trường | Validation và cách phản hồi (UX) | Ghi chú |
|---|---|---|---|---|---|---|---|---|
| Tùy chọn bao gồm dự án đã kết thúc | `Toggle / Switch` | Không | — | Luôn hiển thị ở đầu trang | BR-19 — mặc định **không** bao gồm | `Project.status` | Gạt sẽ tải lại **toàn bộ** các khối; trong lúc tải, các khối hiện skeleton chứ không hiện số cũ. Trạng thái được ghi vào query string và ghi nhớ cho lần mở sau `[ASSUMED]`. Dưới công tắc có ghi chú "Đang tính {n} dự án" để người dùng biết phạm vi số liệu. | Ghi chú phạm vi là chi tiết chống hiểu nhầm |
| **Khối 1 — Cảnh báo bảo mật** | `Bảng dữ liệu tĩnh` | — | `API` — số lỗ hổng Critical còn mở, số lỗ hổng quá hạn > 30 ngày, số lỗ hổng chưa gán người phụ trách | Luôn hiển thị, đặt trên cùng | DEC-08b — thay cho email cảnh báo | `Vulnerability` | Lỗi / trạng thái rỗng: khi API lỗi, khối hiện thông báo `MSG-SYS-006` kèm nút "Thử lại" và **không** hiển thị số nào (thà không có số còn hơn số sai ở khối cảnh báo); khi cả ba chỉ số bằng 0, khối đổi sang thông điệp tích cực `MSG-INF-042` với nền trung tính thay vì ba số 0 màu đỏ. Tương tác: không có tooltip hay legend — khối render bằng HTML thuần, không dùng thư viện chart; mỗi con số bấm được để mở danh sách lỗ hổng đã lọc. | Ba ô, ô Critical nổi bật nhất |
| **Khối 2 — Dự án theo trạng thái** | `Bảng dữ liệu tĩnh` | — | `API` — số dự án theo 5 trạng thái | Luôn hiển thị | 5 trạng thái theo DEC-08 | `Project.status` | Lỗi / trạng thái rỗng: API lỗi → thông báo trong khối kèm nút "Thử lại", các khối khác không bị ảnh hưởng; hệ thống chưa có dự án nào → `MSG-INF-043` kèm nút "Tạo dự án". Tương tác: không có — bảng HTML thuần, không dùng thư viện chart; mỗi dòng bấm được để mở danh sách dự án đã lọc theo trạng thái đó. | Không dùng biểu đồ tròn — 5 con số đọc nhanh hơn |
| **Khối 3 — Phân bố công nghệ** | `Bảng dữ liệu tĩnh` | — | `API` — top 10 công nghệ theo số dự án sử dụng, nhóm theo loại | Luôn hiển thị | Đếm theo tên công nghệ dạng văn bản (Q-ENT-04) | `TechStackItem` | Lỗi / trạng thái rỗng: API lỗi → thông báo trong khối kèm nút "Thử lại"; chưa có dự án nào khai báo tech stack → `MSG-INF-044`. Tương tác: không có — bảng HTML thuần, không dùng thư viện chart; mỗi dòng bấm được để mở danh sách dự án lọc theo công nghệ đó. Dưới bảng có ghi chú "Đếm theo tên công nghệ do các dự án tự khai báo; tên viết khác nhau sẽ được đếm riêng" — nêu rõ giới hạn thay vì để người đọc tin tuyệt đối. | Ghi chú giới hạn là bắt buộc vì Q-ENT-04 chưa giải quyết |
| **Khối 4 — Lỗ hổng theo mức × trạng thái** | `Bảng dữ liệu tĩnh` | — | `API` — ma trận 4 mức × 4 trạng thái | Luôn hiển thị | — | `Vulnerability` | Lỗi / trạng thái rỗng: API lỗi → thông báo trong khối kèm nút "Thử lại"; chưa có lỗ hổng nào → `MSG-INF-045` với văn phong trung tính (đây là tin tốt). Tương tác: không có — bảng HTML thuần, không dùng thư viện chart; mỗi ô trong ma trận bấm được để mở danh sách lỗ hổng lọc theo đúng cặp mức + trạng thái đó. Ô có giá trị 0 hiển thị "—" và không bấm được. | Ma trận 4×4 kèm dòng và cột tổng |
| Thời điểm cập nhật số liệu | `Label / Văn bản tĩnh` | — | `dynamic` — thời điểm gọi API | Luôn hiển thị cuối trang | Số liệu tính tại thời điểm mở màn, không tự làm mới | — | Hiển thị "Số liệu tính lúc {dd/MM/yyyy HH:mm}" kèm nút "Làm mới". Không tự động làm mới định kỳ — tránh số liệu nhảy khi người dùng đang đọc. | Đặt kỳ vọng đúng |
| Làm mới | `Button (phụ / hủy)` | — | — | Luôn hiển thị | — | — | Bấm sẽ tải lại toàn bộ 4 khối; trong lúc tải hiện skeleton. Vô hiệu hóa khi đang tải. | — |

### 4.4 Tương tác và luồng nhỏ trên màn

| Mã luồng | Tên luồng | Trigger | Tiền điều kiện | Xử lý hệ thống | Kết quả UI | Điều hướng / side effect | Ghi chú |
|---|---|---|---|---|---|---|---|
| F-D10-01 | Tải Dashboard | Đăng nhập thành công hoặc bấm menu Dashboard | Đã đăng nhập | Gọi **4 API độc lập**, một cho mỗi khối | Bốn khối hiển thị, khối nào xong trước hiện trước | — | Độc lập để lỗi một khối không làm hỏng cả màn |
| F-D10-02 | Drill-down cảnh báo Critical | Bấm số ở khối 1 | Số > 0 | — | — | `/security?severity=critical&status=new,in_progress` | DP-01 bước 1 |
| F-D10-03 | Drill-down quá hạn | Bấm số "quá hạn" | Số > 0 | — | — | `/security?overdue=true&status=new,in_progress` | — |
| F-D10-04 | Drill-down chưa gán | Bấm số "chưa gán người phụ trách" | Số > 0 | — | — | `/security?assignee=none&status=new,in_progress` | — |
| F-D10-05 | Drill-down trạng thái dự án | Bấm một dòng ở khối 2 | Số > 0 | — | — | `/projects?status=<trạng thái>` | — |
| F-D10-06 | Drill-down công nghệ | Bấm một dòng ở khối 3 | — | — | — | `/projects?tech=<tên công nghệ>` | — |
| F-D10-07 | Drill-down ma trận lỗ hổng | Bấm một ô ở khối 4 | Giá trị > 0 | — | — | `/security?severity=<mức>&status=<trạng thái>` | US-033 |
| F-D10-08 | Bật bao gồm dự án đã kết thúc | Gạt công tắc | — | Gọi lại cả 4 API với tham số mới | Bốn khối hiện skeleton rồi cập nhật; ghi chú phạm vi đổi | Ghi query string | BR-19, US-033 |
| F-D10-09 | Làm mới | Bấm "Làm mới" | Không đang tải | Gọi lại cả 4 API | Skeleton rồi cập nhật; thời điểm cập nhật đổi | — | — |
| F-D10-10 | Thử lại một khối | Bấm "Thử lại" trong khối lỗi | Khối đó đang lỗi | Gọi lại **chỉ API của khối đó** | Khối đó cập nhật, các khối khác không đổi | — | Chi tiết quan trọng: không tải lại cả trang |

### 4.5 Trạng thái màn hình

| State | Điều kiện vào | Người dùng thấy gì | Còn thao tác gì được | Cách thoát state | Ghi chú |
|---|---|---|---|---|---|
| Initial | Vào màn | Bốn khối ở dạng skeleton | Gạt công tắc | API trả về | — |
| Loading | Đang gọi API | Skeleton từng khối, khối nào xong hiện trước | Gạt công tắc (hủy yêu cầu cũ) | API trả về | Không chặn cả màn chờ khối chậm nhất |
| Empty | Hệ thống chưa có dự án nào | Khối 2 hiện `MSG-INF-043` kèm nút "Tạo dự án"; khối 3 và 4 hiện trạng thái rỗng riêng; khối 1 hiện `MSG-INF-042` | Tạo dự án | Có dữ liệu | Bốn thông điệp rỗng riêng biệt, **không** hiển thị số 0 khắp nơi |
| Empty | Có dự án nhưng chưa có lỗ hổng nào | Khối 1 hiện `MSG-INF-042` (tích cực); khối 4 hiện `MSG-INF-045` | Tiếp tục | — | Đây là tin tốt — văn phong phải phản ánh điều đó |
| Error | Một khối lỗi | **Chỉ khối đó** hiện thông báo kèm nút "Thử lại"; ba khối còn lại hiển thị bình thường | Thử lại khối đó | Gọi lại thành công | Yêu cầu cốt lõi của US-033 |
| Error | Cả bốn khối lỗi | Bốn khối đều hiện lỗi riêng | Thử lại từng khối hoặc bấm "Làm mới" | — | Không có trang lỗi toàn màn |
| Timeout | Một API không phản hồi trong 20 giây | Khối đó hiện `MSG-SYS-002` kèm nút "Thử lại" | Thử lại | — | `[ASSUMED]` |
| Concurrent / Race | Dữ liệu đổi trong lúc đang xem | Không cảnh báo; số liệu là ảnh chụp tại thời điểm ghi ở cuối trang | Bấm "Làm mới" | — | Đã nêu rõ bằng nhãn thời điểm |
| Success | Tải xong | Bốn khối hiển thị số liệu; thời điểm cập nhật hiện ở cuối | Drill-down | — | Không có toast — không phải thao tác ghi |
| Session expired | Phiên hết hạn | Toast `MSG-AUTH-004`, chuyển `/login` | Không | — | — |

### 4.6 Validation, lỗi và trường hợp ngoại lệ

| Nhóm lỗi | Điều kiện phát sinh | Phản hồi UI mong đợi | Mã message | Vị trí hiển thị | Có nút Retry | Có chặn action | Ghi chú QA |
|---|---|---|---|---|---|---|---|
| Dữ liệu rỗng | Bốn trường hợp rỗng riêng theo từng khối | Bốn thông điệp riêng, không hiển thị số 0 | `MSG-INF-042`, `MSG-INF-043`, `MSG-INF-044`, `MSG-INF-045` | inline từng khối | Không | Không | Thử hệ thống hoàn toàn trống, và hệ thống có dự án nhưng không có lỗ hổng |
| Lỗi nhập liệu | N/A — màn chỉ có một công tắc | — | — | — | — | — | Ghi N/A có chủ ý |
| Lỗi nghiệp vụ | N/A — màn không có thao tác ghi | — | — | — | — | — | Ghi N/A có chủ ý |
| Lỗi quyền (401/403) | Phiên hết hạn | Toast rồi chuyển `/login` | `MSG-AUTH-004` | toast | Không | Có | — |
| Không tìm thấy (404) | N/A — màn không tải bản ghi theo ID | — | — | — | — | — | Ghi N/A có chủ ý |
| Lỗi mạng / timeout | Một hoặc nhiều API không phản hồi | Lỗi **cục bộ trong từng khối** kèm nút Thử lại | `MSG-SYS-002` | inline từng khối | **Có** | Không | Thử ngắt mạng rồi bật lại, kiểm tra chỉ khối lỗi được tải lại |
| Thao tác đồng thời | N/A cho màn chỉ đọc | — | — | — | — | — | Ghi N/A có chủ ý |
| Lỗi hệ thống | Một API lỗi ngoài dự kiến | Lỗi cục bộ trong khối kèm nút Thử lại; **không** hiển thị số nào ở khối cảnh báo khi lỗi | `MSG-SYS-006` | inline từng khối | **Có** | Không | Đặc biệt kiểm tra khối 1: thà không có số còn hơn số sai |

#### 4.6.1 Đặc tả message

| Mã | Nội dung (VI) | Vị trí | Thời điểm | Hành vi sau message | Phân loại | Đối tượng đọc |
|---|---|---|---|---|---|---|
| `MSG-INF-042` | "Không có lỗ hổng nghiêm trọng nào đang mở." | inline khối 1 | Khi ba chỉ số cảnh báo đều bằng 0 | Không chặn; nền trung tính, không phải màu đỏ | info | Cả hai |
| `MSG-INF-043` | "Chưa có dự án nào trong hệ thống." | inline khối 2 | Khi chưa có dự án | Không chặn; kèm nút "Tạo dự án" | info | Cả hai |
| `MSG-INF-044` | "Chưa có dự án nào khai báo tech stack." | inline khối 3 | Khi chưa có hạng mục nào | Không chặn | info | Cả hai |
| `MSG-INF-045` | "Chưa ghi nhận lỗ hổng nào." | inline khối 4 | Khi chưa có lỗ hổng nào | Không chặn | info | Cả hai |
| `MSG-SYS-006` | "Không tải được số liệu của khối này. Vui lòng thử lại." | inline từng khối | Khi API của khối đó lỗi | Có nút "Thử lại"; không ảnh hưởng khối khác | system | Cả hai |

### 4.7 Mapping dữ liệu vào / ra

| Nhóm dữ liệu | Thành phần UI | Đọc từ đâu | Ghi ra đâu | Mục đích nghiệp vụ | Ghi chú |
|---|---|---|---|---|---|
| Cảnh báo bảo mật | Khối 1 | API tổng hợp lỗ hổng Critical còn mở, quá hạn > 30 ngày, chưa gán người phụ trách | — | Kênh cảnh báo duy nhất thay cho email (DEC-08b) | Loại trừ dự án `Kết thúc` trừ khi bật công tắc |
| Dự án theo trạng thái | Khối 2 | API đếm Project theo `status` | — | Bức tranh danh mục dự án | — |
| Phân bố công nghệ | Khối 3 | API đếm `TechStackItem` theo tên, nhóm theo loại | — | Biết tổ chức đang phụ thuộc công nghệ nào | Đếm theo văn bản — có giới hạn, đã ghi chú trên giao diện |
| Ma trận lỗ hổng | Khối 4 | API đếm `Vulnerability` theo `severity` × `status` | — | Tình trạng xử lý rủi ro tổng thể | — |
| Tham số phạm vi | Công tắc | Người dùng gạt / query string | Query string + ghi nhớ cho lần sau | Quyết định có tính dự án đã kết thúc không | BR-19 |

### 4.8 Email / Thông báo phát sinh từ màn

**Không phát sinh email/notification** `[DECIDED — DEC-08b]`. Ngược lại, màn này **thay thế** cơ chế cảnh báo qua email: khối 1 là nơi duy nhất một lỗ hổng Critical mới được đẩy lên trước mắt người dùng. Điểm yếu đã biết: người dùng chỉ thấy khi họ chủ động mở hệ thống `[NEEDS-CONFIRMATION — Q-08]`.

### 4.9 Xuất dữ liệu

**Không có chức năng xuất dữ liệu** ở màn này. Người dùng drill-down sang `SCR-SEC-10` hoặc `SCR-PRJ-10` rồi kết xuất từ đó.

### 4.10 Liên kết use case và chức năng

UC-DASH-01. Feature FE-12. Story US-033.

### 4.11 Câu hỏi mở

- `[NEEDS-CONFIRMATION]` Ngưỡng "quá hạn" 30 ngày có phù hợp không, hay nên khác nhau theo mức nghiêm trọng (ví dụ Critical 7 ngày, High 14 ngày)?
- `[NEEDS-CONFIRMATION]` Trạng thái công tắc "bao gồm dự án đã kết thúc" có nên được ghi nhớ giữa các phiên không?
- Q-08 (BU): nếu bổ sung email cảnh báo ở giai đoạn sau, vai trò của khối 1 cần được xem lại.
- Q-ENT-04 (BE): tên công nghệ nhập tự do làm khối 3 kém chính xác.

---

## Checklist rà soát (áp dụng cho cả 4 màn)

- [x] Screen ID khớp `05-screen-flow.md`.
- [x] Route/entry, related screens, hướng điều hướng ghi đủ để trace; mọi drill-down ghi rõ query string đích.
- [x] Permission gate phân loại rõ; phân biệt **ẩn** (không bao giờ làm được) và **vô hiệu hóa kèm tooltip** (làm được trong hoàn cảnh khác) — đặc biệt ở `SCR-SEC-11`.
- [x] Cột "Kiểu" dùng tên chuẩn Item Type Catalog; cặp "Ngày ghi nhận từ / đến" **tách hai dòng riêng**.
- [x] Dropdown và checkbox group static liệt kê **đủ** option kèm giá trị.
- [x] Mọi khối chỉ số dùng nhãn chuẩn `Bảng dữ liệu tĩnh` — đã xác nhận **không dùng thư viện chart**; cột Validation/UX của từng khối có **đủ hai phần**: hành vi lỗi/rỗng và khai báo tường minh "không có tương tác tooltip/legend".
- [x] §5 rà đủ bộ trạng thái tối thiểu; state không áp dụng ghi "N/A" kèm lý do.
- [x] §6 rà đủ 8 nhóm ngoại lệ bắt buộc; mỗi lỗi nghiệp vụ có **message riêng**, không gom vào "lỗi hệ thống".
- [x] §6.1 đặc tả message đủ nội dung, vị trí, thời điểm, retry, phân loại, đối tượng đọc; message đổi theo **ngữ cảnh hành động** (ghi chú xử lý / lý do chấp nhận rủi ro / lý do mở lại).
- [x] §8 ghi rõ "không phát sinh email/notification" kèm **hệ quả nghiệp vụ** đã được nêu thẳng.
- [x] §9 ghi rõ có hay không; `EXP-SEC-01` đặc tả đủ cột, format, tên tệp, encoding, hành vi biên.
- [x] Mọi mã `MSG-*` có mặt trong `10-error-message-catalog.md`.

**Last Updated**: 2026-08-26

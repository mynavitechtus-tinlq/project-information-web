# Screen Spec — Xác thực & Quản trị người dùng

> **Phase**: Design — Detailing | **Trạng thái**: Draft v0.1 — chờ BU verify
> **Phạm vi**: SCR-AUTH-10, SCR-AUTH-11, SCR-ADM-10, SCR-ADM-11
> **Upstream**: `05-screen-flow.md` (v0.2), `04-role-matrix.md` (v0.2), `03-business-entities.md` (v0.2)
> **Downstream**: `10-error-message-catalog.md` (mọi mã `MSG-*` dùng ở đây phải tồn tại trong catalog)
> **Quy ước**: cột "Kiểu" dùng **tên chuẩn** từ Item Type Catalog của ai-framework. Ngày hiển thị `dd/MM/yyyy`, thời điểm `dd/MM/yyyy HH:mm`, múi giờ GMT+7 (ASM-05).

---

## §1. SCR-AUTH-10 — Đăng nhập

- **Screen ID**: `SCR-AUTH-10`
- **Business name**: Đăng nhập
- **Route / entry**: `/login` — cũng là đích chuyển hướng của mọi route protected khi chưa có phiên
- **Related screens**: → `SCR-AUTH-11` (khi có cờ đổi mật khẩu), → `SCR-DASH-10` (bình thường)
- **Nguồn chính**: `[FROM-TEAM]` + `[DECIDED — DEC-12]`

### 1.1 Mục đích

Màn này tồn tại để một thành viên đã được cấp tài khoản chứng minh danh tính và mở một phiên làm việc. Vì dữ liệu lỗ hổng bảo mật là điểm yếu hệ thống của tổ chức (BU §8.1), đây là **cổng vào duy nhất**: không có bất kỳ nội dung nghiệp vụ nào xem được trước khi qua màn này.

### 1.2 Điều kiện trước và phân quyền

Màn **public**, không cần đăng nhập. Người dùng đã có phiên hợp lệ mở `/login` sẽ được chuyển thẳng tới Dashboard. Không có dữ liệu nền nào cần chuẩn bị trước.

- **Loại permission gate**: không có gate — đây là màn duy nhất ngoài vùng route guard.
- **Hệ quả UX khi thiếu điều kiện**: N/A.

### 1.3 Thành phần giao diện

| Thành phần | Kiểu | Bắt buộc? | Nguồn giá trị / option | Điều kiện enable/disable/hiển thị | Quy tắc nghiệp vụ | Ánh xạ entity / trường | Validation và cách phản hồi (UX) | Ghi chú |
|---|---|---|---|---|---|---|---|---|
| Logo và tên hệ thống | `Label / Văn bản tĩnh` | — | `hardcoded` — "Quản lý Dự án, Tech Stack & Bảo mật" | Luôn hiển thị | — | — | Không có nhập liệu nên không có validation. | Đặt trên cùng khối form |
| Email | `Email input` | Có | Người dùng nhập | Luôn enable, trừ khi đang gửi yêu cầu đăng nhập | Không phân biệt hoa/thường; hệ thống chuyển về chữ thường trước khi so khớp | `User.email` | Khi rời ô mà để trống, hiển thị `MSG-VAL-004` màu đỏ ngay dưới ô và không gọi API. Khi rời ô mà sai định dạng email, hiển thị `MSG-VAL-005` dưới ô. Khoảng trắng đầu/cuối được cắt tự động trước khi kiểm tra. | Tự động focus khi vào màn |
| Mật khẩu | `Password input` | Có | Người dùng nhập | Luôn enable, trừ khi đang gửi yêu cầu | Không kiểm tra độ mạnh ở màn này — chỉ so khớp | `User.password_hash` | Khi bấm "Đăng nhập" mà để trống, hiển thị `MSG-VAL-006` dưới ô và không gọi API. Không hiển thị quy tắc độ mạnh ở đây để tránh gợi ý cấu trúc mật khẩu. | Hỗ trợ dán; chặn autocomplete gợi ý mật khẩu cũ |
| Hiện / ẩn mật khẩu | `Icon button` | — | `hardcoded` | Hiển thị khi ô mật khẩu có ít nhất một ký tự | Chỉ đổi cách hiển thị, không đổi giá trị | — | Không có validation. Khi bật, ký tự hiển thị rõ; tự động về trạng thái ẩn khi rời màn. | `aria-label` = "Hiện mật khẩu" / "Ẩn mật khẩu" |
| Đăng nhập | `Button (hành động chính)` | — | — | Vô hiệu hóa khi một trong hai ô rỗng, hoặc khi đang gửi yêu cầu | Gửi email + mật khẩu để xác thực | — | Khi bấm, nút chuyển sang trạng thái đang tải và bị khóa để chặn double-click. Nếu máy chủ từ chối, hiển thị thông báo ở **banner đầu form** (không phải inline), giữ nguyên email đã nhập và **xóa** ô mật khẩu. | Enter trong hai ô cũng kích hoạt nút này |
| Thông báo lỗi đăng nhập | `Label / Văn bản tĩnh` | — | `dynamic` — nội dung theo mã message trả về | Chỉ hiển thị sau một lần đăng nhập thất bại | Không tiết lộ sai email hay sai mật khẩu (`MSG-AUTH-001`) | — | Vùng thông báo dùng `role="alert"` để trình đọc màn hình đọc ngay. Tự ẩn khi người dùng bắt đầu gõ lại. | Banner đỏ nhạt phía trên hai ô nhập |
| Ghi chú liên hệ quản trị | `Label / Văn bản tĩnh` | — | `hardcoded` — "Quên mật khẩu? Liên hệ quản trị viên hệ thống." | Luôn hiển thị dưới nút | Không có luồng quên mật khẩu tự phục vụ (DEC-08b) | — | Không có validation. | Có thể kèm email nhóm quản trị `[NEEDS-CONFIRMATION]` |

### 1.4 Tương tác và luồng nhỏ trên màn

| Mã luồng | Tên luồng | Trigger | Tiền điều kiện | Xử lý hệ thống | Kết quả UI | Điều hướng / side effect | Ghi chú |
|---|---|---|---|---|---|---|---|
| F-A10-01 | Vào màn | Mở `/login` | — | Kiểm tra có phiên hợp lệ không | Form rỗng, focus ô Email | Có phiên hợp lệ → chuyển tới `/` ngay, không hiển thị form | Tránh nhấp nháy form |
| F-A10-02 | Đăng nhập thành công | Bấm "Đăng nhập" hoặc Enter | Hai ô đã điền | Xác thực; đặt lại `failed_login_count` = 0; ghi `last_login_at`; tạo phiên | Nút ở trạng thái đang tải rồi chuyển màn | Có cờ `must_change_password` → `/change-password`; ngược lại → route đích đã ghi nhớ hoặc `/` | UC-AUTH-01 |
| F-A10-03 | Đăng nhập thất bại | Bấm "Đăng nhập" | — | Tăng `failed_login_count`; kiểm tra ngưỡng 5 lần / 15 phút | Banner `MSG-AUTH-001`; ô mật khẩu bị xóa; focus về ô mật khẩu | Không tạo phiên | BR-21 |
| F-A10-04 | Bị khóa tạm | Lần sai thứ 5 | — | Đặt `locked_until` = hiện tại + 15 phút | Banner `MSG-AUTH-002` kèm thời điểm thử lại; nút "Đăng nhập" bị vô hiệu hóa cho tới thời điểm đó | Không tạo phiên | BR-21 |
| F-A10-05 | Tài khoản bị khóa | Bấm "Đăng nhập" | Tài khoản `status = Khóa` | Từ chối, không tăng bộ đếm sai | Banner `MSG-AUTH-003` | Không tạo phiên | BR-23 |
| F-A10-06 | Quay lại sau khi hết phiên | Bị chuyển về từ route protected | — | Ghi nhớ route đích | Banner `MSG-AUTH-004` (thông tin, màu vàng) | Sau khi đăng nhập → về đúng route đích | BR-22 |

### 1.5 Trạng thái màn hình

| State | Điều kiện vào | Người dùng thấy gì | Còn thao tác gì được | Cách thoát state | Ghi chú |
|---|---|---|---|---|---|
| Initial | Mở `/login` không có phiên | Form rỗng, nút vô hiệu hóa | Nhập liệu | Nhập đủ hai ô | — |
| Loading | Đã bấm "Đăng nhập" | Nút hiện vòng quay, hai ô bị khóa | Không | Máy chủ phản hồi | Chặn double-click |
| Empty | N/A — màn không có danh sách dữ liệu | — | — | — | Ghi "N/A" theo yêu cầu rà đủ bộ trạng thái |
| Error | Máy chủ từ chối hoặc lỗi hệ thống | Banner đỏ ở đầu form với mã message tương ứng; **không** có nút Retry riêng (người dùng bấm lại nút Đăng nhập) | Nhập lại và thử lại | Bắt đầu gõ lại → banner tự ẩn | `MSG-AUTH-001/002/003`, `MSG-SYS-001` |
| Timeout | Máy chủ không phản hồi trong 15 giây | Banner `MSG-SYS-002` kèm gợi ý thử lại; email được giữ, mật khẩu bị xóa | Thử lại | Bấm lại "Đăng nhập" | `[ASSUMED]` ngưỡng 15 giây |
| Concurrent / Race | Người dùng bấm Enter nhiều lần liên tiếp | Chỉ một yêu cầu được gửi | Không | Yêu cầu đầu tiên trả về | Nút bị khóa trong lúc gửi |
| Success | Xác thực thành công | Chuyển màn ngay, không hiện toast | — | — | Toast chào mừng bị coi là thừa |
| Session expired | Bị chuyển về từ route protected sau 401 | Banner vàng `MSG-AUTH-004` | Đăng nhập lại | Đăng nhập thành công | Route đích được giữ |

### 1.6 Validation, lỗi và trường hợp ngoại lệ

| Nhóm lỗi | Điều kiện phát sinh | Phản hồi UI mong đợi | Mã message | Vị trí hiển thị | Có nút Retry | Có chặn action | Ghi chú QA |
|---|---|---|---|---|---|---|---|
| Dữ liệu rỗng | N/A — màn không hiển thị danh sách | — | — | — | — | — | Ghi N/A có chủ ý |
| Lỗi nhập liệu | Email rỗng / sai định dạng; mật khẩu rỗng | Thông báo đỏ dưới ô tương ứng, không gọi API | `MSG-VAL-004`, `MSG-VAL-005`, `MSG-VAL-006` | inline | Không | Có | Thử email chỉ có khoảng trắng, email có chữ hoa, email dài 256 ký tự |
| Lỗi nghiệp vụ | Sai thông tin đăng nhập | Banner đỏ, xóa ô mật khẩu | `MSG-AUTH-001` | banner | Không | Có | Message phải **giống hệt nhau** cho email không tồn tại và mật khẩu sai — kiểm tra không lộ thông tin |
| Lỗi nghiệp vụ | Sai quá 5 lần trong 15 phút | Banner đỏ kèm thời điểm mở khóa; nút bị vô hiệu hóa | `MSG-AUTH-002` | banner | Không | Có | Thử đúng mật khẩu trong lúc đang khóa tạm — vẫn phải bị chặn |
| Lỗi nghiệp vụ | Tài khoản `status = Khóa` | Banner đỏ, gợi ý liên hệ quản trị | `MSG-AUTH-003` | banner | Không | Có | Không được tăng bộ đếm sai cho trường hợp này |
| Lỗi quyền (401/403) | Phiên hết hạn ở màn khác nên bị đưa về đây | Banner vàng thông tin | `MSG-AUTH-004` | banner | Không | Không | Kiểm tra route đích được nhớ đúng |
| Không tìm thấy (404) | N/A — màn không tải bản ghi theo ID | — | — | — | — | — | Ghi N/A có chủ ý |
| Lỗi mạng / timeout | Không phản hồi trong 15 giây hoặc mất kết nối | Banner đỏ kèm gợi ý kiểm tra kết nối; email giữ nguyên, mật khẩu bị xóa | `MSG-SYS-002` | banner | Không (bấm lại nút chính) | Có | Thử ngắt mạng giữa chừng |
| Thao tác đồng thời | Nhấn Enter/click liên tiếp | Chỉ một yêu cầu gửi đi | — | — | — | Có | Kiểm tra log máy chủ chỉ nhận một request |
| Lỗi hệ thống | Máy chủ trả lỗi ngoài dự kiến | Banner đỏ với message chung, giữ nguyên màn | `MSG-SYS-001` | banner | Không | Có | Không được lộ chi tiết kỹ thuật ra giao diện |

#### 1.6.1 Đặc tả message

| Mã | Nội dung (VI) | Vị trí | Thời điểm | Hành vi sau message | Phân loại | Đối tượng đọc |
|---|---|---|---|---|---|---|
| `MSG-AUTH-001` | "Email hoặc mật khẩu không đúng." | banner | Sau khi máy chủ trả lời | Không chặn thử lại; xóa ô mật khẩu | auth | Cả hai |
| `MSG-AUTH-002` | "Bạn đã nhập sai quá 5 lần. Vui lòng thử lại sau {phút} phút." | banner | Sau khi máy chủ trả lời | Vô hiệu hóa nút cho tới hết thời gian | auth | Cả hai |
| `MSG-AUTH-003` | "Tài khoản đã bị khóa. Vui lòng liên hệ quản trị viên hệ thống." | banner | Sau khi máy chủ trả lời | Chặn đăng nhập | auth | Người dùng cuối |
| `MSG-AUTH-004` | "Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại." | banner (vàng) | Khi vào màn từ route protected | Không chặn | auth | Cả hai |
| `MSG-VAL-004` | "Vui lòng nhập email." | inline | Khi rời ô hoặc khi bấm Đăng nhập | Chặn gọi API | validation | Cả hai |
| `MSG-VAL-005` | "Email không đúng định dạng." | inline | Khi rời ô | Chặn gọi API | validation | Cả hai |
| `MSG-VAL-006` | "Vui lòng nhập mật khẩu." | inline | Khi bấm Đăng nhập | Chặn gọi API | validation | Cả hai |
| `MSG-SYS-001` | "Hệ thống đang gặp sự cố. Vui lòng thử lại sau ít phút." | banner | Sau khi máy chủ trả lời | Không chặn thử lại | system | Người dùng cuối |
| `MSG-SYS-002` | "Không kết nối được máy chủ. Vui lòng kiểm tra kết nối mạng và thử lại." | banner | Sau 15 giây không phản hồi | Không chặn thử lại | system | Cả hai |

### 1.7 Mapping dữ liệu vào / ra

| Nhóm dữ liệu | Thành phần UI | Đọc từ đâu | Ghi ra đâu | Mục đích nghiệp vụ | Ghi chú |
|---|---|---|---|---|---|
| Thông tin đăng nhập | Email, Mật khẩu | Người dùng nhập | Gửi tới dịch vụ xác thực khi bấm Đăng nhập | Chứng minh danh tính | Mật khẩu không bao giờ được ghi log |
| Kết quả xác thực | — | Phản hồi máy chủ | Lưu phiên phía trình duyệt | Duy trì phiên 30 phút | BR-22 |
| Thông tin người dùng hiện tại | Thanh điều hướng (màn sau) | Phản hồi máy chủ (họ tên, vai trò, danh sách Project là thành viên) | Bộ nhớ ứng dụng | Quyết định hiển thị menu Quản trị và các nút ghi | Danh sách Project là thành viên dùng cho `[PERMISSION-CLIENT]` ở các màn khác |

### 1.8 Email / Thông báo phát sinh từ màn

**Không phát sinh email/notification.** Hệ thống không có hạ tầng gửi mail ở giai đoạn 1 `[DECIDED — DEC-08b]`.

### 1.9 Xuất dữ liệu

**Không có chức năng xuất dữ liệu.**

### 1.10 Liên kết use case và chức năng

UC-AUTH-01 (Đăng nhập), UC-AUTH-02 (Đăng xuất — nút nằm ở menu tài khoản của các màn sau). Feature FE-01. Stories US-001, US-002, US-003, US-004.

### 1.11 Câu hỏi mở

- `[NEEDS-CONFIRMATION]` Có hiển thị email/kênh liên hệ cụ thể của nhóm quản trị ở ghi chú cuối màn không, hay chỉ ghi chung chung?
- `[NEEDS-CONFIRMATION]` Ngưỡng timeout 15 giây và thời gian khóa tạm 15 phút cần đội vận hành xác nhận.

---

## §2. SCR-AUTH-11 — Đổi mật khẩu

- **Screen ID**: `SCR-AUTH-11`
- **Business name**: Đổi mật khẩu
- **Route / entry**: `/change-password` — vào từ menu tài khoản, hoặc bị **ép** vào sau khi đăng nhập nếu có cờ `must_change_password`
- **Related screens**: ← `SCR-AUTH-10`, → `SCR-DASH-10`
- **Nguồn chính**: `[DECIDED — DEC-12]`

### 2.1 Mục đích

Màn này để người dùng tự đặt mật khẩu mới. Nó phục vụ hai tình huống khác nhau: **bắt buộc** — người dùng vừa được Admin cấp tài khoản hoặc vừa được đặt lại mật khẩu, phải đổi trước khi làm bất cứ việc gì khác, để không ai dùng lâu dài mật khẩu do người khác biết; và **chủ động** — người dùng muốn thay mật khẩu định kỳ.

### 2.2 Điều kiện trước và phân quyền

Cần **đã đăng nhập**. Không phân biệt vai trò — Admin và User dùng chung màn này và chỉ đổi được mật khẩu **của chính mình** (đổi mật khẩu người khác là chức năng riêng ở SCR-ADM-11).

- **Loại permission gate**: route guard — chưa đăng nhập thì chuyển về `/login`.
- **Chế độ bắt buộc**: khi `User.must_change_password = Đúng`, mọi route khác (trừ `/logout`) đều chuyển về màn này `[PERMISSION-CLIENT]`; thanh điều hướng chính bị ẩn để không gợi ý lối thoát không tồn tại.

### 2.3 Thành phần giao diện

| Thành phần | Kiểu | Bắt buộc? | Nguồn giá trị / option | Điều kiện enable/disable/hiển thị | Quy tắc nghiệp vụ | Ánh xạ entity / trường | Validation và cách phản hồi (UX) | Ghi chú |
|---|---|---|---|---|---|---|---|---|
| Thông báo chế độ bắt buộc | `Label / Văn bản tĩnh` | — | `dynamic` — nội dung `MSG-INF-003` | Chỉ hiển thị khi `must_change_password = Đúng` | Giải thích vì sao người dùng bị giữ ở đây | `User.must_change_password` | Không có validation. Banner màu vàng, `role="status"`. | Ở chế độ chủ động thì khối này ẩn hoàn toàn |
| Mật khẩu hiện tại | `Password input` | Có | Người dùng nhập | Luôn hiển thị và enable | So khớp với mật khẩu đang lưu | `User.password_hash` | Khi bấm Lưu mà để trống, hiển thị `MSG-VAL-007` dưới ô. Khi máy chủ báo sai, hiển thị `MSG-VAL-008` dưới ô này (không dùng banner, để người dùng biết chính xác ô nào sai). | Cả chế độ bắt buộc cũng yêu cầu ô này — mật khẩu tạm do Admin cấp |
| Mật khẩu mới | `Password input` | Có | Người dùng nhập | Luôn enable | ≥ 8 ký tự, có chữ hoa + chữ thường + số (BR-20); phải khác mật khẩu hiện tại (R-ENT-011) | `User.password_hash` | Kiểm tra **ngay khi gõ**: khối quy tắc bên dưới đổi màu từng dòng đạt/chưa đạt. Khi bấm Lưu mà chưa đạt, hiển thị `MSG-VAL-001` dưới ô và chặn gọi API. Nếu trùng mật khẩu hiện tại, máy chủ trả `MSG-VAL-002` hiển thị dưới ô này. | Không giới hạn ký tự đặc biệt |
| Khối quy tắc mật khẩu | `Label / Văn bản tĩnh` | — | `static` — 3 dòng: "Ít nhất 8 ký tự", "Có chữ hoa và chữ thường", "Có ít nhất một chữ số" | Hiển thị khi ô Mật khẩu mới được focus hoặc có giá trị | Phản ánh đúng BR-20 | — | Mỗi dòng có biểu tượng đạt/chưa đạt cập nhật theo từng ký tự gõ vào. Đây là hướng dẫn, không phải thông báo lỗi. | Giúp giảm số lần submit hỏng |
| Xác nhận mật khẩu mới | `Password input` | Có | Người dùng nhập | Luôn enable | Phải khớp chính xác ô Mật khẩu mới | — | Kiểm tra khi rời ô: nếu khác, hiển thị `MSG-VAL-003` dưới ô và chặn Lưu. Khi người dùng sửa ô Mật khẩu mới, lỗi này được tính lại. | Không cho dán để tránh sai âm thầm `[NEEDS-CONFIRMATION]` |
| Hiện / ẩn mật khẩu | `Icon button` | — | `hardcoded` | Mỗi ô mật khẩu có một nút riêng | Chỉ đổi cách hiển thị | — | Không có validation. | 3 nút độc lập |
| Lưu mật khẩu | `Button (hành động chính)` | — | — | Vô hiệu hóa khi có ô rỗng, quy tắc chưa đạt, hoặc hai ô mới không khớp; vô hiệu hóa khi đang gửi | Gửi mật khẩu hiện tại + mật khẩu mới | — | Khi bấm, nút vào trạng thái đang tải. Thành công → toast `MSG-INF-001` và chuyển màn. Thất bại → lỗi hiển thị inline ở đúng ô liên quan. | Chặn double-click |
| Hủy | `Button (phụ / hủy)` | — | — | **Ẩn** khi ở chế độ bắt buộc; hiển thị ở chế độ chủ động | Không có lối thoát ở chế độ bắt buộc | — | Khi có dữ liệu đã nhập, bấm Hủy hiện hộp thoại xác nhận `MSG-INF-011`. | `[PERMISSION-CLIENT]` — ẩn theo cờ, không theo vai trò |
| Đăng xuất | `Link / Liên kết` | — | `hardcoded` | Chỉ hiển thị ở chế độ bắt buộc | Lối thoát duy nhất khi chưa muốn đổi | — | Bấm sẽ hủy phiên và về `/login` ngay, không hỏi lại. | Tránh tình trạng người dùng bị "kẹt" không đăng xuất được |

### 2.4 Tương tác và luồng nhỏ trên màn

| Mã luồng | Tên luồng | Trigger | Tiền điều kiện | Xử lý hệ thống | Kết quả UI | Điều hướng / side effect | Ghi chú |
|---|---|---|---|---|---|---|---|
| F-A11-01 | Vào màn chế độ bắt buộc | Đăng nhập thành công với cờ bật | `must_change_password = Đúng` | — | Banner vàng, nút Hủy ẩn, thanh điều hướng ẩn | Mọi route khác chuyển về đây | DEC-12 |
| F-A11-02 | Vào màn chế độ chủ động | Menu tài khoản → "Đổi mật khẩu" | Đã đăng nhập | — | Không có banner, có nút Hủy | — | — |
| F-A11-03 | Kiểm tra quy tắc theo thời gian thực | Gõ vào ô Mật khẩu mới | — | Đánh giá 3 quy tắc phía trình duyệt | Từng dòng quy tắc đổi trạng thái đạt/chưa đạt | Không gọi API | Giảm submit hỏng |
| F-A11-04 | Lưu thành công | Bấm "Lưu mật khẩu" | Mọi validation đã qua | Cập nhật mật khẩu, gỡ cờ `must_change_password`, **hủy các phiên khác** của người dùng `[ASSUMED]` | Toast `MSG-INF-001` | Chế độ bắt buộc → `/`; chế độ chủ động → về màn trước đó | R-ENT-011 |
| F-A11-05 | Sai mật khẩu hiện tại | Bấm "Lưu mật khẩu" | — | Từ chối | `MSG-VAL-008` inline dưới ô Mật khẩu hiện tại; ô đó bị xóa và được focus | Không đổi mật khẩu | Không tính vào bộ đếm khóa đăng nhập `[ASSUMED]` |
| F-A11-06 | Thoát ở chế độ bắt buộc | Bấm "Đăng xuất" | — | Hủy phiên | Về `/login` | Cờ vẫn còn cho lần đăng nhập sau | Lối thoát duy nhất |

### 2.5 Trạng thái màn hình

| State | Điều kiện vào | Người dùng thấy gì | Còn thao tác gì được | Cách thoát state | Ghi chú |
|---|---|---|---|---|---|
| Initial | Vào màn | Form rỗng; banner vàng nếu bắt buộc; nút Lưu vô hiệu hóa | Nhập liệu | Điền đủ và hợp lệ | — |
| Loading | Đã bấm Lưu | Nút hiện vòng quay, các ô bị khóa | Không | Máy chủ phản hồi | — |
| Empty | N/A — không có danh sách | — | — | — | Ghi N/A có chủ ý |
| Error | Sai mật khẩu hiện tại, trùng mật khẩu cũ, hoặc lỗi hệ thống | Lỗi nghiệp vụ hiển thị **inline** ở ô liên quan; lỗi hệ thống hiển thị banner | Sửa và thử lại | Sửa dữ liệu | Không mất mật khẩu mới đã gõ trừ khi là lỗi mật khẩu hiện tại |
| Timeout | Không phản hồi trong 15 giây | Banner `MSG-SYS-002`; **giữ nguyên** toàn bộ dữ liệu đã nhập | Bấm Lưu lại | Máy chủ phản hồi | Không được xóa form |
| Concurrent / Race | Mật khẩu vừa bị Admin đặt lại ở phiên khác | Máy chủ báo sai mật khẩu hiện tại → `MSG-VAL-008` | Nhập mật khẩu tạm mới | — | Trường hợp hiếm, QA cần thử |
| Success | Đổi thành công | Toast xanh `MSG-INF-001` rồi chuyển màn | — | — | — |
| Session expired | Phiên hết hạn khi đang mở form | Banner `MSG-AUTH-004`, chuyển về `/login` sau 3 giây | Không | — | Dữ liệu đã nhập bị mất — chấp nhận vì là mật khẩu |

### 2.6 Validation, lỗi và trường hợp ngoại lệ

| Nhóm lỗi | Điều kiện phát sinh | Phản hồi UI mong đợi | Mã message | Vị trí hiển thị | Có nút Retry | Có chặn action | Ghi chú QA |
|---|---|---|---|---|---|---|---|
| Dữ liệu rỗng | N/A | — | — | — | — | — | Ghi N/A có chủ ý |
| Lỗi nhập liệu | Ô rỗng; mật khẩu mới chưa đạt quy tắc; xác nhận không khớp | Thông báo đỏ dưới ô tương ứng | `MSG-VAL-007`, `MSG-VAL-001`, `MSG-VAL-003` | inline | Không | Có | Thử mật khẩu 7 ký tự, chỉ chữ thường, chỉ số, có khoảng trắng, 200 ký tự, ký tự Unicode |
| Lỗi nghiệp vụ | Mật khẩu hiện tại sai | Thông báo đỏ dưới ô Mật khẩu hiện tại, xóa ô đó | `MSG-VAL-008` | inline | Không | Có | Không được dùng banner chung chung — người dùng phải biết ô nào sai |
| Lỗi nghiệp vụ | Mật khẩu mới trùng mật khẩu hiện tại | Thông báo đỏ dưới ô Mật khẩu mới | `MSG-VAL-002` | inline | Không | Có | R-ENT-011 |
| Lỗi quyền (401/403) | Phiên hết hạn khi đang mở form | Banner rồi chuyển về `/login` | `MSG-AUTH-004` | banner | Không | Có | — |
| Không tìm thấy (404) | N/A | — | — | — | — | — | Ghi N/A có chủ ý |
| Lỗi mạng / timeout | Không phản hồi trong 15 giây | Banner, **giữ nguyên** dữ liệu đã nhập | `MSG-SYS-002` | banner | Không (bấm lại Lưu) | Có | Kiểm tra dữ liệu không bị xóa |
| Thao tác đồng thời | Bấm Lưu nhiều lần | Chỉ một yêu cầu gửi đi | — | — | — | Có | — |
| Lỗi hệ thống | Máy chủ lỗi ngoài dự kiến | Banner đỏ, giữ nguyên form | `MSG-SYS-001` | banner | Không | Có | — |

#### 2.6.1 Đặc tả message

| Mã | Nội dung (VI) | Vị trí | Thời điểm | Hành vi sau message | Phân loại | Đối tượng đọc |
|---|---|---|---|---|---|---|
| `MSG-INF-003` | "Đây là lần đăng nhập đầu tiên của bạn. Vui lòng đặt mật khẩu mới trước khi tiếp tục." | banner (vàng) | Khi vào màn ở chế độ bắt buộc | Không chặn | info | Người dùng cuối |
| `MSG-VAL-001` | "Mật khẩu phải có ít nhất 8 ký tự, gồm chữ hoa, chữ thường và chữ số." | inline | Khi bấm Lưu | Chặn gọi API | validation | Cả hai |
| `MSG-VAL-002` | "Mật khẩu mới phải khác mật khẩu hiện tại." | inline | Sau khi máy chủ trả lời | Chặn lưu | validation | Cả hai |
| `MSG-VAL-003` | "Mật khẩu xác nhận không khớp." | inline | Khi rời ô xác nhận | Chặn gọi API | validation | Cả hai |
| `MSG-VAL-007` | "Vui lòng nhập mật khẩu hiện tại." | inline | Khi bấm Lưu | Chặn gọi API | validation | Cả hai |
| `MSG-VAL-008` | "Mật khẩu hiện tại không đúng." | inline | Sau khi máy chủ trả lời | Chặn lưu, xóa ô | validation | Cả hai |
| `MSG-INF-001` | "Đổi mật khẩu thành công." | toast | Sau khi lưu thành công | Chuyển màn sau 1 giây | info | Cả hai |

### 2.7 Mapping dữ liệu vào / ra

| Nhóm dữ liệu | Thành phần UI | Đọc từ đâu | Ghi ra đâu | Mục đích nghiệp vụ | Ghi chú |
|---|---|---|---|---|---|
| Cờ bắt buộc đổi | Banner, nút Hủy, thanh điều hướng | Thông tin người dùng trong phiên | — | Quyết định chế độ màn | `User.must_change_password` |
| Mật khẩu | 3 ô nhập | Người dùng nhập | Gửi tới dịch vụ đổi mật khẩu | Cập nhật `User.password_hash`, gỡ cờ | Không ghi log, không lưu tạm |

### 2.8 Email / Thông báo phát sinh từ màn

**Không phát sinh email/notification** `[DECIDED — DEC-08b]`. Ghi chú: ở nhiều hệ thống, đổi mật khẩu thành công thường kèm email xác nhận như một biện pháp phát hiện chiếm tài khoản — điểm này nên đưa vào giai đoạn sau khi có hạ tầng mail `[NEEDS-CONFIRMATION]`.

### 2.9 Xuất dữ liệu

**Không có chức năng xuất dữ liệu.**

### 2.10 Liên kết use case và chức năng

UC-AUTH-03. Feature FE-02. Stories US-005, US-006.

### 2.11 Câu hỏi mở

- `[NEEDS-CONFIRMATION]` Đổi mật khẩu thành công có nên hủy toàn bộ phiên khác của người dùng không? (đã giả định là **có**)
- `[NEEDS-CONFIRMATION]` Có chặn dán vào ô Xác nhận mật khẩu không?
- `[NEEDS-CONFIRMATION]` Nhập sai mật khẩu hiện tại nhiều lần có tính vào ngưỡng khóa tạm của BR-21 không? (đã giả định là **không**)

---

## §3. SCR-ADM-10 — Quản lý người dùng

- **Screen ID**: `SCR-ADM-10`
- **Business name**: Quản lý người dùng
- **Route / entry**: `/admin/users` — vào từ menu "Quản trị" trên thanh điều hướng
- **Related screens**: → `SCR-ADM-11` (popup tạo/sửa)
- **RBAC note**: **Admin only** — route guard. User mở URL trực tiếp nhận trang 403 (EC-07), xem `04-role-matrix.md` §5.
- **Nguồn chính**: `[FROM-TEAM]`

### 3.1 Mục đích

Màn này để quản trị viên nắm và điều chỉnh danh sách người có quyền vào hệ thống: ai đang hoạt động, ai giữ vai trò gì, ai lâu rồi không đăng nhập. Vì hệ thống chứa dữ liệu lỗ hổng bảo mật, việc gỡ quyền của người đã rời tổ chức là một thao tác an ninh, không chỉ là dọn dẹp dữ liệu.

### 3.2 Điều kiện trước và phân quyền

Cần đăng nhập với **vai trò Admin**. Không có điều kiện dữ liệu nền nào khác.

- **Loại permission gate**: **route guard** — kiểm tra vai trò ở tầng định tuyến.
- **Hệ quả UX khi không đủ quyền**: hiển thị **trang 403** với `MSG-AUTH-005` và nút "Về Dashboard". Mục "Quản trị" trên thanh điều hướng cũng **ẩn** với User `[PERMISSION-CLIENT]` — nhưng việc ẩn menu không thay thế route guard.

### 3.3 Thành phần giao diện

| Thành phần | Kiểu | Bắt buộc? | Nguồn giá trị / option | Điều kiện enable/disable/hiển thị | Quy tắc nghiệp vụ | Ánh xạ entity / trường | Validation và cách phản hồi (UX) | Ghi chú |
|---|---|---|---|---|---|---|---|---|
| Tìm kiếm | `Text input (1 dòng)` | Không | Người dùng nhập | Luôn enable | Tìm theo email hoặc họ tên, khớp một phần, không phân biệt hoa/thường và dấu tiếng Việt | `User.email`, `User.full_name` | Tìm kiếm chạy sau khi ngừng gõ 400ms. Chuỗi chỉ có khoảng trắng bị bỏ qua. Không có lỗi validation — không tìm thấy thì hiển thị trạng thái rỗng chứ không phải lỗi. | Tối đa 100 ký tự |
| Lọc vai trò | `Dropdown (chọn 1)` | Không | `static` — Tất cả (all), Admin (admin), User (user) | Luôn enable | — | `User.role` | Đổi giá trị làm tải lại danh sách ngay và đưa về trang 1. Không có trạng thái lỗi riêng. | Mặc định "Tất cả" |
| Lọc trạng thái | `Dropdown (chọn 1)` | Không | `static` — Tất cả (all), Hoạt động (active), Khóa (locked) | Luôn enable | — | `User.status` | Như trên. | Mặc định "Tất cả" |
| Xóa bộ lọc | `Button (phụ / hủy)` | — | — | Chỉ hiển thị khi có ít nhất một bộ lọc khác mặc định | — | — | Bấm sẽ đưa mọi bộ lọc về mặc định và tải lại danh sách trang 1. | — |
| Tạo tài khoản | `Button (hành động chính)` | — | — | Luôn hiển thị với Admin | Mở popup ở chế độ tạo | — | Không có validation ở nút. Mở `SCR-ADM-11`. | — |
| Bảng danh sách người dùng | `Data table (hàng biến thiên)` | — | `API` — danh sách người dùng theo bộ lọc, phân trang phía máy chủ | Luôn hiển thị | Cột: Email, Họ tên, Vai trò, Trạng thái, Đăng nhập gần nhất, Thao tác | `User` | Khi API lỗi: hiển thị thông báo lỗi **inline trong vùng bảng** kèm nút "Thử lại", giữ nguyên bộ lọc. Khi API trả rỗng: hiển thị `MSG-INF-033`. Tương tác: sắp xếp được theo Họ tên và Đăng nhập gần nhất; không có tooltip hay legend vì đây là bảng HTML thuần, không dùng thư viện chart. | 20 dòng/trang mặc định |
| Cột Vai trò | `Badge / Nhãn trạng thái` | — | `dynamic` — từ `User.role` | Luôn hiển thị | Admin: nhãn nhấn mạnh; User: nhãn trung tính | `User.role` | Giá trị ngoài tập {Admin, User} không tồn tại theo thiết kế; nếu gặp thì hiển thị nguyên văn giá trị để lộ lỗi dữ liệu thay vì im lặng. | — |
| Cột Trạng thái | `Badge / Nhãn trạng thái` | — | `dynamic` — từ `User.status` | Luôn hiển thị | Hoạt động: xanh; Khóa: xám | `User.status` | Như trên. | — |
| Cột Đăng nhập gần nhất | `Label / Văn bản tĩnh` | — | `dynamic` — `User.last_login_at` | Luôn hiển thị | Định dạng `dd/MM/yyyy HH:mm` (GMT+7) | `User.last_login_at` | Khi rỗng (chưa đăng nhập lần nào) hiển thị "Chưa đăng nhập" thay vì để trống. | ASM-05 |
| Sửa | `Icon button` | — | — | Hiển thị trên mọi dòng | Mở popup ở chế độ sửa | — | `aria-label` = "Sửa tài khoản {email}". Không có validation. | — |
| Khóa / Mở khóa | `Icon button` | — | — | Hiển thị trên mọi dòng; **vô hiệu hóa** khi dòng đó là Admin hoạt động cuối cùng, kèm tooltip giải thích | BR-05 | `User.status` | Bấm mở hộp thoại xác nhận `MSG-INF-012` / `MSG-INF-013`. Nếu máy chủ vẫn từ chối (do người khác vừa hạ vai trò một Admin), hiển thị `MSG-BIZ-060` dạng toast và tải lại danh sách. | `[PERMISSION-CLIENT]` — điều kiện tính từ dữ liệu danh sách |
| Đặt lại mật khẩu | `Icon button` | — | — | Hiển thị trên mọi dòng trạng thái Hoạt động | Đặt cờ `must_change_password` | — | Bấm mở popup nhập mật khẩu tạm (một phần của `SCR-ADM-11`). | — |
| Phân trang | `Pagination` | — | `dynamic` — tổng số bản ghi từ API | Ẩn khi chỉ có một trang | — | — | Hiển thị tổng số kết quả. Khi ở trang cuối mà đổi số dòng/trang, hệ thống đưa về trang 1 thay vì trang trống. | 20 / 50 / 100 dòng (ASM-06) |

### 3.4 Tương tác và luồng nhỏ trên màn

| Mã luồng | Tên luồng | Trigger | Tiền điều kiện | Xử lý hệ thống | Kết quả UI | Điều hướng / side effect | Ghi chú |
|---|---|---|---|---|---|---|---|
| F-AD10-01 | Tải danh sách | Vào màn | Là Admin | Gọi API với bộ lọc mặc định, trang 1 | Bảng hiển thị 20 dòng đầu | — | UC-ADM-01 |
| F-AD10-02 | Tìm kiếm và lọc | Gõ hoặc đổi dropdown | — | Gọi API sau 400ms ngừng gõ; đưa về trang 1 | Bảng cập nhật; nút "Xóa bộ lọc" xuất hiện | Bộ lọc ghi vào query string để chia sẻ được link | — |
| F-AD10-03 | Mở popup tạo | Bấm "Tạo tài khoản" | — | — | `SCR-ADM-11` mở ở chế độ tạo, form rỗng | — | UC-ADM-01 |
| F-AD10-04 | Mở popup sửa | Bấm biểu tượng sửa | — | Tải chi tiết tài khoản | `SCR-ADM-11` mở ở chế độ sửa với dữ liệu hiện tại | — | UC-ADM-01, UC-ADM-02 |
| F-AD10-05 | Khóa tài khoản | Bấm biểu tượng khóa → xác nhận | Tài khoản đang Hoạt động và không phải Admin cuối cùng | Đổi `status` = Khóa | Toast `MSG-INF-004`; dòng cập nhật badge | Người đó không đăng nhập được ở phiên sau; các phiên đang mở của họ bị hủy `[ASSUMED]` | BR-05, BR-23 |
| F-AD10-06 | Mở khóa tài khoản | Bấm biểu tượng mở khóa → xác nhận | Tài khoản đang Khóa | Đổi `status` = Hoạt động; đặt lại `failed_login_count` | Toast `MSG-INF-005` | — | — |
| F-AD10-07 | Đặt lại mật khẩu | Bấm biểu tượng đặt lại → nhập mật khẩu tạm | Tài khoản Hoạt động | Cập nhật mật khẩu, bật cờ `must_change_password` | Hộp thoại hiển thị mật khẩu tạm **một lần duy nhất** kèm nút sao chép | Người đó bị ép đổi mật khẩu ở lần đăng nhập sau | US-010 |
| F-AD10-08 | Sau khi popup lưu | Popup đóng với kết quả thành công | — | Tải lại danh sách giữ nguyên bộ lọc và trang | Toast tương ứng; dòng mới/đã sửa được làm nổi 2 giây | — | Không đưa về trang 1 khi sửa |

### 3.5 Trạng thái màn hình

| State | Điều kiện vào | Người dùng thấy gì | Còn thao tác gì được | Cách thoát state | Ghi chú |
|---|---|---|---|---|---|
| Initial | Vào màn | Khung xương bảng (skeleton), bộ lọc ở mặc định | Đổi bộ lọc | API trả về | — |
| Loading | Đang gọi API danh sách | Skeleton 20 dòng; bộ lọc vẫn thao tác được | Đổi bộ lọc (hủy yêu cầu cũ) | API trả về | Yêu cầu cũ bị hủy để tránh kết quả về sai thứ tự |
| Empty | API trả về 0 bản ghi | Vùng bảng hiển thị `MSG-INF-033` "Không tìm thấy tài khoản nào phù hợp." kèm nút "Xóa bộ lọc" | Đổi/xóa bộ lọc | Có kết quả | Phân biệt với lỗi — không dùng màu đỏ |
| Error | API danh sách lỗi | Thông báo lỗi **inline trong vùng bảng** với `MSG-SYS-003` và nút **"Thử lại"**; bộ lọc giữ nguyên | Bấm Thử lại, đổi bộ lọc | Gọi lại thành công | Không dùng toast — lỗi tải danh sách phải nằm ở chỗ đáng lẽ có dữ liệu |
| Timeout | Không phản hồi trong 20 giây | Như Error, message `MSG-SYS-002` | Thử lại | — | `[ASSUMED]` |
| Concurrent / Race | Một Admin khác vừa đổi vai trò/trạng thái của cùng tài khoản | Thao tác bị máy chủ từ chối → toast `MSG-BIZ-020` và tải lại danh sách | Thao tác lại trên dữ liệu mới | Tải lại xong | Kiểm tra bằng `updated_at` |
| Success | Thao tác khóa/mở khóa/lưu thành công | Toast xanh + dòng được làm nổi 2 giây | Tiếp tục | Tự hết sau 4 giây | — |
| No permission | User mở URL trực tiếp | **Trang 403** với `MSG-AUTH-005` và nút "Về Dashboard" | Về Dashboard | Rời màn | EC-07 — không chuyển hướng âm thầm |
| Session expired | Phiên hết hạn khi đang thao tác | Toast `MSG-AUTH-004` rồi chuyển `/login` | Không | — | — |

### 3.6 Validation, lỗi và trường hợp ngoại lệ

| Nhóm lỗi | Điều kiện phát sinh | Phản hồi UI mong đợi | Mã message | Vị trí hiển thị | Có nút Retry | Có chặn action | Ghi chú QA |
|---|---|---|---|---|---|---|---|
| Dữ liệu rỗng | Bộ lọc không khớp tài khoản nào | Trạng thái rỗng trong vùng bảng kèm nút xóa bộ lọc | `MSG-INF-033` | inline vùng dữ liệu | Không | Không | Phân biệt rõ "chưa có dữ liệu" và "lọc không ra" — hệ thống luôn có ≥1 Admin nên chỉ có trường hợp thứ hai |
| Lỗi nhập liệu | Chuỗi tìm kiếm > 100 ký tự | Cắt tại 100 ký tự, không báo lỗi | — | — | — | Không | Thử dán chuỗi 1.000 ký tự |
| Lỗi nghiệp vụ | Khóa hoặc hạ vai trò Admin hoạt động cuối cùng | Nút vô hiệu hóa kèm tooltip; nếu vẫn gọi được API thì toast đỏ | `MSG-BIZ-060` | toast | Không | Có | Thử với đúng 2 Admin: khóa một người phải được, khóa người còn lại phải bị chặn |
| Lỗi quyền (401/403) | User mở URL trực tiếp | Trang 403 | `MSG-AUTH-005` | page | Không | Có | Thử cả khi menu Quản trị đã bị ẩn |
| Lỗi quyền (401) | Phiên hết hạn giữa chừng | Toast rồi chuyển `/login` | `MSG-AUTH-004` | toast | Không | Có | — |
| Không tìm thấy (404) | Bấm sửa một tài khoản vừa bị Admin khác thao tác khiến ID không còn hợp lệ | Toast `MSG-NF-002` và tải lại danh sách | `MSG-NF-002` | toast | Không | Có | Trường hợp hiếm vì không có chức năng xóa tài khoản |
| Lỗi mạng / timeout | Mất kết nối hoặc quá 20 giây | Lỗi inline trong vùng bảng kèm nút Thử lại | `MSG-SYS-002` | inline vùng dữ liệu | **Có** | Không | Bộ lọc phải được giữ nguyên |
| Thao tác đồng thời | Hai Admin cùng sửa một tài khoản | Người lưu sau nhận `MSG-BIZ-020`, danh sách tải lại | `MSG-BIZ-020` | toast | Không | Có | Kiểm tra không ghi đè âm thầm |
| Lỗi hệ thống | API trả lỗi ngoài dự kiến | Lỗi inline trong vùng bảng kèm nút Thử lại | `MSG-SYS-003` | inline vùng dữ liệu | **Có** | Không | Không lộ chi tiết kỹ thuật |

#### 3.6.1 Đặc tả message

| Mã | Nội dung (VI) | Vị trí | Thời điểm | Hành vi sau message | Phân loại | Đối tượng đọc |
|---|---|---|---|---|---|---|
| `MSG-INF-033` | "Không tìm thấy tài khoản nào phù hợp với bộ lọc hiện tại." | inline vùng dữ liệu | Sau khi API trả 0 bản ghi | Không chặn | info | Quản trị viên |
| `MSG-INF-004` | "Đã khóa tài khoản {email}." | toast | Sau khi lưu thành công | Tải lại danh sách | info | Quản trị viên |
| `MSG-INF-005` | "Đã mở khóa tài khoản {email}." | toast | Sau khi lưu thành công | Tải lại danh sách | info | Quản trị viên |
| `MSG-INF-012` | "Khóa tài khoản {email}? Người này sẽ không đăng nhập được nhưng mọi dữ liệu và lịch sử của họ vẫn được giữ." | dialog | Trước khi khóa | Chờ xác nhận | info | Quản trị viên |
| `MSG-INF-013` | "Mở khóa tài khoản {email}? Người này sẽ đăng nhập lại được ngay." | dialog | Trước khi mở khóa | Chờ xác nhận | info | Quản trị viên |
| `MSG-BIZ-060` | "Không thể thực hiện: hệ thống phải luôn có ít nhất một quản trị viên đang hoạt động." | toast | Sau khi máy chủ từ chối | Chặn thao tác | business | Quản trị viên |
| `MSG-BIZ-020` | "Dữ liệu đã được người khác cập nhật. Danh sách đã được tải lại, vui lòng thao tác lại." | toast | Sau khi máy chủ từ chối | Chặn, tải lại | business | Quản trị viên |
| `MSG-AUTH-005` | "Bạn không có quyền truy cập trang này." | page | Khi route guard từ chối | Chặn, hiện nút về Dashboard | auth | Người dùng cuối |
| `MSG-SYS-003` | "Không tải được danh sách. Vui lòng thử lại." | inline vùng dữ liệu | Sau khi API lỗi | Có nút Thử lại | system | Quản trị viên |
| `MSG-NF-002` | "Tài khoản không còn tồn tại." | toast | Sau khi API trả 404 | Tải lại danh sách | not-found | Quản trị viên |

### 3.7 Mapping dữ liệu vào / ra

| Nhóm dữ liệu | Thành phần UI | Đọc từ đâu | Ghi ra đâu | Mục đích nghiệp vụ | Ghi chú |
|---|---|---|---|---|---|
| Danh sách người dùng | Bảng | API danh sách User (lọc + phân trang phía máy chủ) | — | Tra cứu ai có quyền vào hệ thống | Không trả `password_hash` về giao diện trong bất kỳ trường hợp nào |
| Bộ lọc | Ô tìm, 2 dropdown, phân trang | Người dùng nhập | Query string của URL | Chia sẻ được đường dẫn kết quả lọc | — |
| Thay đổi trạng thái | Nút Khóa/Mở khóa | — | API cập nhật `User.status` | Kiểm soát truy cập | Kèm `updated_at` để chống ghi đè |
| Đặt lại mật khẩu | Nút đặt lại | Admin nhập mật khẩu tạm | API cập nhật `password_hash` + `must_change_password` | Khôi phục truy cập khi người dùng quên | Mật khẩu tạm chỉ hiển thị một lần, không lưu lại để xem lại |

### 3.8 Email / Thông báo phát sinh từ màn

**Không phát sinh email/notification** `[DECIDED — DEC-08b]`. Hệ quả nghiệp vụ cần lưu ý: khi Admin tạo tài khoản hoặc đặt lại mật khẩu, **Admin phải tự chuyển mật khẩu tạm cho người dùng qua kênh ngoài hệ thống**. Đây là điểm yếu đã biết của giai đoạn 1 `[NEEDS-CONFIRMATION — cần khách hàng xác nhận quy trình bàn giao mật khẩu tạm]`.

### 3.9 Xuất dữ liệu

**Không có chức năng xuất dữ liệu** ở màn này. Kết xuất CSV chỉ áp dụng cho danh sách Project và danh sách lỗ hổng (DEC-06).

### 3.10 Liên kết use case và chức năng

UC-ADM-01, UC-ADM-02. Feature FE-03, FE-04. Stories US-007, US-009, US-010, US-011, US-012.

### 3.11 Câu hỏi mở

- `[NEEDS-CONFIRMATION]` Khóa một tài khoản có hủy ngay các phiên đang mở của người đó không? (đã giả định là **có**)
- `[NEEDS-CONFIRMATION]` Quy trình bàn giao mật khẩu tạm khi không có email — dùng kênh nào?
- Q-10 (BU): nếu cần audit log, màn này là nơi hợp lý để đặt liên kết tới nhật ký.

---

## §4. SCR-ADM-11 — Popup tạo / sửa tài khoản

- **Screen ID**: `SCR-ADM-11`
- **Business name**: Popup tạo / sửa tài khoản
- **Entry trigger**: nút "Tạo tài khoản" hoặc biểu tượng sửa trên `SCR-ADM-10`
- **Loại**: **Modal / Dialog** — có backdrop, chặn tương tác với bảng phía sau, có focus trap
- **RBAC note**: **Admin only** — kế thừa route guard của `SCR-ADM-10`
- **Nguồn chính**: `[FROM-TEAM]`

### 4.1 Mục đích

Popup này để quản trị viên nhập hoặc chỉnh thông tin định danh và quyền của một tài khoản. Nó cố ý là popup chứ không phải trang riêng, vì thao tác ngắn và quản trị viên thường xử lý nhiều tài khoản liên tiếp — giữ nguyên bối cảnh danh sách phía sau giúp họ không mất vị trí đang xem.

### 4.2 Điều kiện trước và phân quyền

Cần đăng nhập với vai trò Admin và đang ở `SCR-ADM-10`. Ở chế độ sửa, cần tải được chi tiết tài khoản theo ID.

- **Loại permission gate**: kế thừa route guard của màn cha; không có gate riêng.
- **Hệ quả UX khi không đủ quyền**: popup không mở được vì nút gọi nó nằm sau route guard.

### 4.3 Thành phần giao diện

| Thành phần | Kiểu | Bắt buộc? | Nguồn giá trị / option | Điều kiện enable/disable/hiển thị | Quy tắc nghiệp vụ | Ánh xạ entity / trường | Validation và cách phản hồi (UX) | Ghi chú |
|---|---|---|---|---|---|---|---|---|
| Tiêu đề popup | `Label / Văn bản tĩnh` | — | `dynamic` — "Tạo tài khoản" hoặc "Sửa tài khoản" | Luôn hiển thị | — | — | Không có validation. | Phân biệt hai chế độ ngay từ tiêu đề |
| Email đăng nhập | `Email input` | Có | Người dùng nhập | Enable ở chế độ tạo; **chỉ đọc** ở chế độ sửa | Duy nhất toàn hệ thống, không phân biệt hoa/thường; lưu chữ thường; tối đa 255 ký tự | `User.email` | Khi rời ô mà sai định dạng, hiển thị `MSG-VAL-005` dưới ô. Khi bấm Lưu mà trùng email đã có, máy chủ trả về và hiển thị `MSG-BIZ-061` dưới ô, không gọi lưu lần hai. Ở chế độ sửa, ô hiển thị giá trị nhưng không sửa được — email là định danh đăng nhập. | Ở chế độ sửa nên kèm ghi chú "Email đăng nhập không thay đổi được" |
| Họ tên | `Text input (1 dòng)` | Có | Người dùng nhập | Luôn enable | 2–100 ký tự, cắt khoảng trắng đầu/cuối | `User.full_name` | Khi rời ô mà rỗng, hiển thị `MSG-VAL-009` dưới ô. Khi vượt 100 ký tự, ô ngừng nhận thêm ký tự và hiện bộ đếm màu đỏ. Chuỗi chỉ có khoảng trắng bị coi là rỗng. | Bộ đếm ký tự hiển thị khi vượt 80 |
| Vai trò hệ thống | `Radio group` | Có | `static` — Admin (admin), User (user) | Enable; **vô hiệu hóa lựa chọn "User"** khi tài khoản đang sửa là Admin hoạt động cuối cùng, kèm tooltip | BR-05 | `User.role` | Mỗi lựa chọn có mô tả một dòng bên dưới ("Toàn quyền hệ thống, quản lý tài khoản" / "Xem toàn hệ thống, sửa dữ liệu dự án mình tham gia") để Admin không chọn nhầm. Nếu máy chủ từ chối do BR-05, hiển thị `MSG-BIZ-060` ở đầu popup. | Dùng radio thay dropdown vì chỉ 2 lựa chọn và cần hiển thị mô tả |
| Mật khẩu tạm | `Password input` | Có (chế độ tạo) | Người dùng nhập hoặc bấm "Sinh tự động" | **Chỉ hiển thị ở chế độ tạo** và ở luồng đặt lại mật khẩu | ≥ 8 ký tự, có chữ hoa + chữ thường + số (BR-20); người dùng sẽ bị buộc đổi ở lần đăng nhập đầu | `User.password_hash` | Kiểm tra quy tắc ngay khi gõ, hiển thị 3 dòng đạt/chưa đạt như `SCR-AUTH-11`. Khi bấm Lưu mà chưa đạt, hiển thị `MSG-VAL-001` dưới ô và chặn gọi API. | Ở chế độ sửa, ô này ẩn hoàn toàn — đổi mật khẩu là luồng riêng |
| Sinh mật khẩu tự động | `Button (phụ / hủy)` | — | — | Chỉ hiển thị cùng ô Mật khẩu tạm | Sinh chuỗi 12 ký tự thỏa BR-20 | — | Bấm sẽ điền vào ô và tự bật chế độ hiện ký tự để Admin sao chép được. Không có validation. | Giảm rủi ro Admin đặt mật khẩu yếu |
| Trạng thái tài khoản | `Toggle / Switch` | Có | `dynamic` — từ `User.status` | **Chỉ hiển thị ở chế độ sửa**; vô hiệu hóa khi là Admin hoạt động cuối cùng | BR-05, BR-23 | `User.status` | Gạt sang Khóa sẽ hiện hộp thoại xác nhận `MSG-INF-012` trước khi ghi nhận thay đổi vào form (chưa lưu). Nếu máy chủ từ chối, gạt trở về giá trị cũ và hiển thị `MSG-BIZ-060`. | Không gọi API ngay khi gạt — chỉ đổi trạng thái form |
| Thông báo lỗi chung | `Label / Văn bản tĩnh` | — | `dynamic` | Chỉ hiển thị khi có lỗi mức popup | — | — | Vùng `role="alert"` ở đầu popup, dùng cho lỗi nghiệp vụ và lỗi hệ thống không gắn với một ô cụ thể. | — |
| Lưu | `Button (hành động chính)` | — | — | Vô hiệu hóa khi còn lỗi validation hoặc **không có thay đổi nào** (chế độ sửa); vô hiệu hóa khi đang gửi | — | — | Bấm sẽ khóa popup và hiện vòng quay trên nút. Thành công → popup đóng, danh sách tải lại, toast tương ứng. Thất bại → popup **giữ nguyên** với dữ liệu đã nhập và lỗi hiển thị đúng chỗ. | Chặn double-click |
| Hủy | `Button (phụ / hủy)` | — | — | Luôn hiển thị | — | — | Khi form chưa đổi gì, đóng ngay. Khi đã đổi, hiện hộp thoại xác nhận `MSG-INF-011` "Thay đổi chưa lưu sẽ mất". | — |
| Đóng (dấu ×) | `Icon button` | — | — | Góc trên phải | — | — | Hành vi giống nút Hủy, kể cả phần xác nhận khi form dirty. | `aria-label` = "Đóng" |

### 4.4 Tương tác và luồng nhỏ trên màn

| Mã luồng | Tên luồng | Trigger | Tiền điều kiện | Xử lý hệ thống | Kết quả UI | Điều hướng / side effect | Ghi chú |
|---|---|---|---|---|---|---|---|
| F-AD11-01 | Mở chế độ tạo | Bấm "Tạo tài khoản" | Là Admin | — | Popup mở, form rỗng, vai trò mặc định "User", focus ô Email | Backdrop chặn bảng phía sau | — |
| F-AD11-02 | Mở chế độ sửa | Bấm biểu tượng sửa | — | Tải chi tiết tài khoản theo ID | Popup mở với dữ liệu hiện tại; ô Email chỉ đọc; ô Mật khẩu tạm ẩn | — | — |
| F-AD11-03 | Tải chi tiết thất bại | — | — | API lỗi hoặc 404 | Popup mở với thông báo lỗi và **chỉ có nút Đóng** — không hiển thị form rỗng gây hiểu nhầm | — | Điểm QA hay bỏ sót |
| F-AD11-04 | Lưu thành công | Bấm "Lưu" | Validation đã qua | Tạo hoặc cập nhật bản ghi | Popup đóng; toast `MSG-INF-002` (tạo) hoặc `MSG-INF-006` (sửa); danh sách tải lại giữ nguyên bộ lọc và trang; dòng liên quan được làm nổi 2 giây | — | US-008, US-011 |
| F-AD11-05 | Lưu thất bại do trùng email | Bấm "Lưu" | — | Máy chủ từ chối | `MSG-BIZ-061` inline dưới ô Email; popup **không đóng**; dữ liệu giữ nguyên | — | US-008 |
| F-AD11-06 | Lưu thất bại do BR-05 | Bấm "Lưu" | Hạ vai trò Admin cuối cùng | Máy chủ từ chối | `MSG-BIZ-060` ở đầu popup; popup không đóng | — | US-011 |
| F-AD11-07 | Đóng bằng Escape hoặc click backdrop | Nhấn Escape / click ra ngoài | — | — | Form sạch → đóng ngay. Form dirty → hộp thoại `MSG-INF-011` | — | Phải hành xử giống nút Hủy |
| F-AD11-08 | Đặt lại mật khẩu | Vào từ nút đặt lại ở danh sách | Tài khoản Hoạt động | Cập nhật mật khẩu + bật cờ | Popup rút gọn chỉ có ô Mật khẩu tạm; sau khi lưu hiển thị mật khẩu **một lần** kèm nút sao chép, kèm cảnh báo `MSG-INF-014` | Người dùng bị ép đổi ở lần đăng nhập sau | US-010 |

### 4.5 Trạng thái màn hình

| State | Điều kiện vào | Người dùng thấy gì | Còn thao tác gì được | Cách thoát state | Ghi chú |
|---|---|---|---|---|---|
| Initial | Popup vừa mở ở chế độ tạo | Form rỗng, nút Lưu vô hiệu hóa | Nhập liệu | Nhập đủ trường bắt buộc | Focus vào ô đầu tiên |
| Loading | Đang tải chi tiết (chế độ sửa) hoặc đang lưu | Skeleton trong thân popup / vòng quay trên nút Lưu | Không (form bị khóa) | Máy chủ phản hồi | Không đóng popup khi đang lưu |
| Empty | N/A — popup là form, không có danh sách | — | — | — | Ghi N/A có chủ ý |
| Error | Tải chi tiết lỗi, hoặc lưu lỗi | Tải lỗi → thông báo + chỉ nút Đóng. Lưu lỗi → message ở đầu popup hoặc inline theo ô, **giữ nguyên dữ liệu đã nhập** | Sửa và thử lại (với lỗi lưu) | Sửa dữ liệu hoặc đóng | Không bao giờ đóng popup khi lưu thất bại |
| Timeout | Không phản hồi trong 20 giây | Message ở đầu popup `MSG-SYS-002`; dữ liệu giữ nguyên | Bấm Lưu lại | — | `[ASSUMED]` |
| Concurrent / Race | Admin khác vừa sửa cùng tài khoản | Máy chủ từ chối → `MSG-BIZ-020` ở đầu popup, kèm nút "Tải lại dữ liệu mới" | Tải lại rồi sửa tiếp | Tải lại | Kiểm tra bằng `updated_at` |
| Success | Lưu thành công | Popup đóng, toast xanh ở màn cha | — | — | — |
| Not found (404) | Tài khoản không còn tồn tại khi mở chế độ sửa | Thông báo `MSG-NF-002`, chỉ nút Đóng; đóng xong tải lại danh sách | Đóng | — | — |
| Session expired | Phiên hết hạn khi popup đang mở | Popup đóng, toast `MSG-AUTH-004`, chuyển `/login` | Không | — | Dữ liệu đã nhập bị mất — chấp nhận |

### 4.6 Validation, lỗi và trường hợp ngoại lệ

| Nhóm lỗi | Điều kiện phát sinh | Phản hồi UI mong đợi | Mã message | Vị trí hiển thị | Có nút Retry | Có chặn action | Ghi chú QA |
|---|---|---|---|---|---|---|---|
| Dữ liệu rỗng | N/A | — | — | — | — | — | Ghi N/A có chủ ý |
| Lỗi nhập liệu | Email rỗng/sai định dạng; Họ tên rỗng hoặc > 100 ký tự; Mật khẩu tạm chưa đạt quy tắc | Thông báo đỏ dưới ô tương ứng, chặn gọi API | `MSG-VAL-004`, `MSG-VAL-005`, `MSG-VAL-009`, `MSG-VAL-001` | inline | Không | Có | Thử họ tên 1 ký tự, 101 ký tự, chỉ khoảng trắng, ký tự tiếng Việt có dấu, emoji |
| Lỗi nghiệp vụ | Email đã tồn tại | Thông báo đỏ dưới ô Email, popup không đóng | `MSG-BIZ-061` | inline | Không | Có | Thử email khác hoa/thường của một email đã có — vẫn phải bị chặn |
| Lỗi nghiệp vụ | Hạ vai trò hoặc khóa Admin hoạt động cuối cùng | Thông báo ở đầu popup; lựa chọn bị đặt về giá trị cũ | `MSG-BIZ-060` | banner trong popup | Không | Có | Thử với đúng 1 và đúng 2 Admin |
| Lỗi quyền (401/403) | Phiên hết hạn khi popup đang mở | Popup đóng, chuyển `/login` | `MSG-AUTH-004` | toast | Không | Có | — |
| Không tìm thấy (404) | Mở chế độ sửa với ID không còn tồn tại | Thông báo trong popup, chỉ nút Đóng; danh sách tải lại sau khi đóng | `MSG-NF-002` | banner trong popup | Không | Có | **Không** hiển thị form rỗng như thể đang tạo mới |
| Lỗi mạng / timeout | Mất kết nối khi lưu | Thông báo ở đầu popup, **giữ nguyên** dữ liệu đã nhập | `MSG-SYS-002` | banner trong popup | Không (bấm lại Lưu) | Có | Kiểm tra dữ liệu không bị mất |
| Thao tác đồng thời | Hai Admin cùng sửa một tài khoản | `MSG-BIZ-020` kèm nút tải lại dữ liệu mới | `MSG-BIZ-020` | banner trong popup | Không | Có | Không được ghi đè âm thầm |
| Lỗi hệ thống | Lỗi ngoài dự kiến khi lưu | Thông báo chung ở đầu popup, giữ nguyên dữ liệu | `MSG-SYS-001` | banner trong popup | Không | Có | Không lộ chi tiết kỹ thuật |

#### 4.6.1 Đặc tả message

| Mã | Nội dung (VI) | Vị trí | Thời điểm | Hành vi sau message | Phân loại | Đối tượng đọc |
|---|---|---|---|---|---|---|
| `MSG-VAL-009` | "Vui lòng nhập họ tên." | inline | Khi rời ô hoặc bấm Lưu | Chặn gọi API | validation | Quản trị viên |
| `MSG-BIZ-061` | "Email này đã được sử dụng cho một tài khoản khác." | inline | Sau khi máy chủ trả lời | Chặn lưu, popup không đóng | business | Quản trị viên |
| `MSG-INF-002` | "Đã tạo tài khoản {email}. Người dùng sẽ được yêu cầu đổi mật khẩu ở lần đăng nhập đầu tiên." | toast | Sau khi tạo thành công | Đóng popup, tải lại danh sách | info | Quản trị viên |
| `MSG-INF-006` | "Đã cập nhật tài khoản {email}." | toast | Sau khi sửa thành công | Đóng popup, tải lại danh sách | info | Quản trị viên |
| `MSG-INF-011` | "Thay đổi chưa được lưu sẽ bị mất. Bạn có chắc muốn đóng?" | dialog | Khi đóng popup đang dirty | Chờ xác nhận | info | Cả hai |
| `MSG-INF-014` | "Hãy sao chép mật khẩu tạm ngay — mật khẩu này chỉ hiển thị một lần và không xem lại được." | banner trong popup | Sau khi đặt lại mật khẩu thành công | Không chặn | info | Quản trị viên |

### 4.7 Mapping dữ liệu vào / ra

| Nhóm dữ liệu | Thành phần UI | Đọc từ đâu | Ghi ra đâu | Mục đích nghiệp vụ | Ghi chú |
|---|---|---|---|---|---|
| Chi tiết tài khoản (chế độ sửa) | Toàn bộ form | API chi tiết User theo ID | — | Hiển thị giá trị hiện tại để chỉnh | Không bao giờ trả về mật khẩu, kể cả dạng băm |
| Dữ liệu tạo mới | Email, Họ tên, Vai trò, Mật khẩu tạm | Người dùng nhập | API tạo User | Cấp quyền truy cập cho thành viên mới | Cờ `must_change_password` do máy chủ tự đặt = Đúng |
| Dữ liệu cập nhật | Họ tên, Vai trò, Trạng thái | Người dùng nhập | API cập nhật User | Điều chỉnh quyền và trạng thái | Gửi kèm `updated_at` đã tải để chống ghi đè |
| Ràng buộc Admin cuối cùng | Vai trò, Trạng thái | Số lượng Admin hoạt động (từ API danh sách hoặc chi tiết) | — | Vô hiệu hóa lựa chọn vi phạm BR-05 ngay trên giao diện | Máy chủ vẫn phải kiểm tra lại — giao diện chỉ là lớp thân thiện |

### 4.8 Email / Thông báo phát sinh từ màn

**Không phát sinh email/notification** `[DECIDED — DEC-08b]`. Xem ghi chú ở §3.8 về việc bàn giao mật khẩu tạm qua kênh ngoài hệ thống.

### 4.9 Xuất dữ liệu

**Không có chức năng xuất dữ liệu.**

### 4.10 Liên kết use case và chức năng

UC-ADM-01, UC-ADM-02. Feature FE-03, FE-04. Stories US-008, US-010, US-011.

### 4.11 Câu hỏi mở

- `[NEEDS-CONFIRMATION]` Có cho phép Admin sửa email đăng nhập của người dùng không? (đã giả định là **không** — email là định danh)
- `[NEEDS-CONFIRMATION]` Mật khẩu tạm nên do Admin đặt hay luôn sinh tự động?

---

## Checklist rà soát (áp dụng cho cả 4 màn)

- [x] Screen ID khớp `05-screen-flow.md`, không trùng ý nghĩa.
- [x] Route/entry, related screens, hướng điều hướng đã ghi đủ để trace.
- [x] Màn protected có permission note và phân loại gate (route guard / client-side computed).
- [x] Mọi trường bắt buộc có quy tắc và cách phản hồi khi sai, viết bằng câu đầy đủ.
- [x] Cột "Kiểu" dùng tên chuẩn Item Type Catalog; không dùng bí danh.
- [x] Popup đã phân loại **Modal / Dialog** (có backdrop, focus trap) — `SCR-ADM-11`.
- [x] §5 rà đủ bộ trạng thái tối thiểu; state không áp dụng ghi "N/A" kèm lý do.
- [x] §6 rà đủ 8 nhóm ngoại lệ bắt buộc.
- [x] §6.1 đặc tả message đủ nội dung, vị trí, thời điểm, retry, phân loại, đối tượng đọc.
- [x] §8 ghi rõ "không phát sinh email/notification" kèm hệ quả nghiệp vụ.
- [x] §9 ghi rõ "không có xuất dữ liệu".
- [x] Mọi mã `MSG-*` dùng ở đây đều có mặt trong `10-error-message-catalog.md`.

**Last Updated**: 2026-08-26

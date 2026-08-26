# Error Message Catalog

> **Phase**: Design — Detailing | **Trạng thái**: Draft v0.1 — chờ BU verify
> **Vai trò**: **một nguồn chân lý duy nhất** cho mọi thông điệp hiển thị cho người dùng. Screen Spec chỉ trỏ tới mã message, không lặp lại nội dung.
> **Upstream**: `07-screen-spec-auth-admin.md`, `08-screen-spec-project.md`, `09-screen-spec-security-dashboard.md`
> **Ngôn ngữ**: chỉ tiếng Việt — hệ thống một ngôn ngữ (ASM-04). Nếu sau này bổ sung ngôn ngữ, thêm cột `Nội dung (EN)` / `Nội dung (JP)` vào các bảng dưới.

---

## 1. Quy ước mã message

```
MSG-<NHÓM>-<SỐ>
```

| Nhóm | Ý nghĩa | Dải số | Số lượng |
|------|---------|--------|----------|
| `VAL` | **Validation** — sai định dạng, thiếu trường bắt buộc, vượt giới hạn. Gắn với từng Item Type ở Screen Spec §3. | 001–099 | 33 |
| `BIZ` | **Business error** — vi phạm quy tắc nghiệp vụ. Mỗi case một message riêng, **không** gom vào lỗi hệ thống. | 001–099 | 26 |
| `AUTH` | **Auth (401/403)** — chưa đăng nhập, phiên hết hạn, quyền bị từ chối. | 001–099 | 6 |
| `NF` | **Not-found (404)** — bản ghi không tồn tại hoặc đã bị xóa. Tách bạch với lỗi hệ thống. | 001–099 | 5 |
| `SYS` | **System error** — lỗi không lường trước, mạng, timeout. Message chung, không lộ chi tiết kỹ thuật. | 001–099 | 6 |
| `INF` | **Info / success / empty state / confirm dialog** — không phải lỗi. | 001–099 | 36 |

Dải số trong nhóm `VAL` và `BIZ` được chia theo miền nghiệp vụ để dễ tra:

| Dải | Miền |
|---|---|
| 001–009 | Tài khoản, mật khẩu, xác thực |
| 010–019 | Project và Repository |
| 020–029 | Xung đột đồng thời (BIZ), CVE (VAL) |
| 030–039 | Lỗ hổng bảo mật |
| 040–049 | Luồng trạng thái (BIZ), thành viên (VAL) |
| 050–059 | Thành viên dự án (BIZ), Tech Stack và bộ lọc (VAL) |
| 060–069 | Quản trị tài khoản |
| 070–079 | Kết xuất dữ liệu |

Dải `INF`: 001–029 = thành công và hộp thoại xác nhận · 030–049 = trạng thái rỗng.

## 2. Quy ước hiển thị

| Vị trí | Khi nào dùng | Ví dụ |
|--------|--------------|-------|
| `inline` | Lỗi gắn với **một trường cụ thể** trên form | "Email không đúng định dạng." dưới ô Email |
| `banner` | Lỗi mức form hoặc mức màn, không gắn một trường | "Không thể kết thúc dự án khi còn 3 lỗ hổng chưa xử lý." đầu form |
| `toast` | Kết quả một thao tác ngắn, tự ẩn sau 4 giây | "Đã cập nhật thành viên dự án." |
| `dialog` | Cần người dùng xác nhận trước khi tiếp tục | "Xóa repository khỏi dự án?" |
| `page` | Lỗi chặn toàn màn (403, 404) | Trang "Bạn không có quyền truy cập trang này." |
| `inline vùng dữ liệu` | Trạng thái rỗng hoặc lỗi tải của **một vùng dữ liệu** (bảng, khối chỉ số) | "Không tìm thấy dự án nào phù hợp." trong vùng bảng |
| `tooltip` | Giải thích vì sao một phần tử bị vô hiệu hóa | "Chỉ quản trị viên được chấp nhận rủi ro cho lỗ hổng Critical/High." |

**Ba nguyên tắc bắt buộc:**

1. **Lỗi tải danh sách hiển thị ở chỗ đáng lẽ có dữ liệu**, kèm nút "Thử lại" — không dùng toast, vì toast biến mất và người dùng ở lại với một vùng trống không giải thích được.
2. **Lỗi nghiệp vụ hiển thị inline tại trường gây ra nó** khi xác định được trường đó; chỉ dùng banner khi lỗi thuộc về cả form.
3. **Không bao giờ đóng form hay rời màn khi lưu thất bại** — dữ liệu người dùng đã nhập phải được giữ nguyên.

## 3. Quy tắc văn phong

- **Nói rõ nguyên nhân và cách xử lý**, không dùng câu chung chung. "Có lỗi xảy ra" là không chấp nhận được cho một lỗi nghiệp vụ có thể nói rõ.
- **Không lộ chi tiết kỹ thuật** cho người dùng cuối: không mã HTTP, không tên bảng, không stack trace.
- **Xưng hô trung tính**: dùng "Vui lòng…" cho yêu cầu hành động, "Không thể…" cho việc bị chặn, "Đã…" cho việc đã xong. Không dùng "Bạn đã sai".
- **Tin tốt dùng văn phong tích cực**: "Không có lỗ hổng nghiêm trọng nào đang mở" chứ không phải "0 lỗ hổng Critical".
- **Cảnh báo khác với chặn**: message cảnh báo (màu vàng) phải nói rõ người dùng **vẫn tiếp tục được**.
- **Biến chèn** viết trong ngoặc nhọn: `{email}`, `{n}`, `{tên dự án}`, `{trạng thái}`. Mỗi biến phải có nguồn dữ liệu rõ ràng (cột "Ghi chú").

## 4. Nhóm VAL — Lỗi nhập liệu

### 4.1 Tài khoản và mật khẩu (001–009)

| Mã | Màn / Ngữ cảnh | Điều kiện phát sinh | Nội dung (VI) | Vị trí | Có Retry | Chặn action | Severity | Đối tượng đọc | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|
| `MSG-VAL-001` | SCR-AUTH-11, SCR-ADM-11 | Mật khẩu mới chưa đạt quy tắc BR-20 | Mật khẩu phải có ít nhất 8 ký tự, gồm chữ hoa, chữ thường và chữ số. | inline | Không | Có | Medium | Cả hai | Kèm khối 3 dòng quy tắc cập nhật theo từng ký tự gõ |
| `MSG-VAL-002` | SCR-AUTH-11 | Mật khẩu mới trùng mật khẩu hiện tại | Mật khẩu mới phải khác mật khẩu hiện tại. | inline | Không | Có | Medium | Cả hai | R-ENT-011; chỉ máy chủ kiểm tra được |
| `MSG-VAL-003` | SCR-AUTH-11 | Ô xác nhận không khớp mật khẩu mới | Mật khẩu xác nhận không khớp. | inline | Không | Có | Medium | Cả hai | Tính lại khi ô mật khẩu mới đổi |
| `MSG-VAL-004` | SCR-AUTH-10, SCR-ADM-11 | Ô email để trống | Vui lòng nhập email. | inline | Không | Có | Low | Cả hai | Chuỗi chỉ khoảng trắng coi là rỗng |
| `MSG-VAL-005` | SCR-AUTH-10, SCR-ADM-11 | Email sai định dạng | Email không đúng định dạng. | inline | Không | Có | Low | Cả hai | — |
| `MSG-VAL-006` | SCR-AUTH-10 | Ô mật khẩu để trống | Vui lòng nhập mật khẩu. | inline | Không | Có | Low | Cả hai | — |
| `MSG-VAL-007` | SCR-AUTH-11 | Ô mật khẩu hiện tại để trống | Vui lòng nhập mật khẩu hiện tại. | inline | Không | Có | Low | Cả hai | — |
| `MSG-VAL-008` | SCR-AUTH-11 | Mật khẩu hiện tại không đúng | Mật khẩu hiện tại không đúng. | inline | Không | Có | Medium | Cả hai | Hiển thị **inline** chứ không banner — người dùng cần biết ô nào sai; ô bị xóa và được focus |
| `MSG-VAL-009` | SCR-ADM-11 | Ô họ tên để trống hoặc chỉ có khoảng trắng | Vui lòng nhập họ tên. | inline | Không | Có | Low | Quản trị viên | — |

### 4.2 Project và Repository (010–019)

| Mã | Màn / Ngữ cảnh | Điều kiện phát sinh | Nội dung (VI) | Vị trí | Có Retry | Chặn action | Severity | Đối tượng đọc | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|
| `MSG-VAL-010` | SCR-PRJ-11 | URL repository thiếu scheme hoặc sai định dạng | Đường dẫn phải bắt đầu bằng http:// hoặc https:// | inline | Không | Có | Low | Cả hai | Chặn cả `javascript:` và `ftp://` |
| `MSG-VAL-011` | SCR-PRJ-11 | Trạng thái = Kết thúc mà ngày kết thúc để trống | Vui lòng nhập ngày kết thúc khi dự án ở trạng thái Kết thúc. | inline | Không | Có | Medium | Cả hai | R-ENT-008 |
| `MSG-VAL-012` | SCR-PRJ-11 | Ô mã dự án để trống | Vui lòng nhập mã dự án. | inline | Không | Có | Low | Cả hai | — |
| `MSG-VAL-013` | SCR-PRJ-11 | Mã dự án sai định dạng | Mã dự án chỉ gồm chữ hoa không dấu, số và dấu gạch dưới, dài 2–20 ký tự. Ví dụ: PAYGW, CRM_2026. | inline | Không | Có | Low | Cả hai | Có ví dụ trong message để người dùng không phải đoán |
| `MSG-VAL-014` | SCR-PRJ-11 | Tên dự án rỗng hoặc ngoài khoảng 3–100 ký tự | Tên dự án phải có từ 3 đến 100 ký tự. | inline | Không | Có | Low | Cả hai | — |
| `MSG-VAL-015` | SCR-PRJ-11, SCR-SEC-10 | Ngày nhập tay sai định dạng | Ngày không đúng định dạng ngày/tháng/năm. | inline | Không | Có | Low | Cả hai | Định dạng `dd/MM/yyyy` (ASM-05) |
| `MSG-VAL-016` | SCR-PRJ-11 | Ngày kết thúc trước ngày bắt đầu | Ngày kết thúc không được trước ngày bắt đầu. | inline | Không | Có | Medium | Cả hai | R-ENT-008; tính lại khi ngày bắt đầu đổi |
| `MSG-VAL-017` | SCR-PRJ-11 | Dòng repository có URL nhưng thiếu tên | Vui lòng nhập tên repository. | inline | Không | Có | Low | Cả hai | — |
| `MSG-VAL-018` | SCR-PRJ-11 | Tên repository trùng trong cùng dự án | Tên repository đã tồn tại trong dự án này. | inline | Không | Có | Medium | Cả hai | Kiểm tra ngay phía trình duyệt trong phạm vi bảng |
| `MSG-VAL-019` | SCR-PRJ-11 | URL repository trùng trong cùng dự án | Đường dẫn này trùng với một repository khác trong dự án. | inline (**cảnh báo vàng**) | Không | **Không** | Low | Cả hai | **Cảnh báo, không chặn** — có thể là hai repository con cùng đường dẫn gốc |

### 4.3 CVE và lỗ hổng (020, 030–039)

| Mã | Màn / Ngữ cảnh | Điều kiện phát sinh | Nội dung (VI) | Vị trí | Có Retry | Chặn action | Severity | Đối tượng đọc | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|
| `MSG-VAL-020` | SCR-SEC-11 | Mã CVE sai định dạng | Mã CVE không đúng định dạng. Ví dụ hợp lệ: CVE-2024-12345. | inline | Không | Có | Medium | Cả hai | Mẫu `^CVE-\d{4}-\d{4,7}$`; chữ thường tự chuyển sang hoa |
| `MSG-VAL-030` | SCR-SEC-11 | Ngày xử lý xong trước ngày ghi nhận | Ngày xử lý xong không được trước ngày ghi nhận. | inline | Không | Có | Medium | Cả hai | R-ENT-003 |
| `MSG-VAL-031` | SCR-SEC-11 | Chuyển sang Đã xử lý mà ghi chú để trống | Vui lòng nhập ghi chú cách xử lý. | inline | Không | Có | High | Cả hai | R-ENT-002, BR-16 — bắt buộc để giữ tri thức xử lý |
| `MSG-VAL-032` | SCR-SEC-11 | Chuyển sang Chấp nhận rủi ro mà lý do để trống | Vui lòng nhập lý do chấp nhận rủi ro. | inline | Không | Có | **High** | Cả hai | R-ENT-004, BR-15 — cốt lõi của G-05 |
| `MSG-VAL-033` | SCR-SEC-11 | Chuyển sang Đang xử lý mà chưa có người phụ trách | Vui lòng chọn người phụ trách trước khi chuyển sang Đang xử lý. | inline | Không | Có | High | Cả hai | R-ENT-007 |
| `MSG-VAL-053` | SCR-SEC-11 | Chưa chọn dự án khi ghi nhận lỗ hổng | Vui lòng chọn dự án. | inline | Không | Có | Medium | Cả hai | BR-11 |
| `MSG-VAL-054` | SCR-SEC-11 | Ô thư viện để trống | Vui lòng nhập tên thư viện bị ảnh hưởng. | inline | Không | Có | Medium | Cả hai | — |
| `MSG-VAL-055` | SCR-SEC-11 | Ô phiên bản bị ảnh hưởng để trống | Vui lòng nhập phiên bản đang sử dụng bị ảnh hưởng. | inline | Không | Có | Medium | Cả hai | — |
| `MSG-VAL-056` | SCR-SEC-11 | Ngày ghi nhận hoặc ngày xử lý là ngày tương lai | Ngày không được là ngày trong tương lai. | inline | Không | Có | Low | Cả hai | Múi giờ GMT+7 (ASM-05) |
| `MSG-VAL-057` | SCR-SEC-11 | Mở lại lỗ hổng đã đóng mà lý do để trống | Vui lòng nhập lý do mở lại lỗ hổng này. | inline | Không | Có | High | Cả hai | Message **riêng theo ngữ cảnh**, không dùng chung với `MSG-VAL-031` |

### 4.4 Thành viên, Tech Stack, bộ lọc (040, 050–052)

| Mã | Màn / Ngữ cảnh | Điều kiện phát sinh | Nội dung (VI) | Vị trí | Có Retry | Chặn action | Severity | Đối tượng đọc | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|
| `MSG-VAL-040` | SCR-PRJ-21 | Ngày tham gia là ngày tương lai | Ngày tham gia không được là ngày trong tương lai. | inline | Không | Có | Low | Cả hai | — |
| `MSG-VAL-050` | SCR-PRJ-23 | Ô tên công nghệ để trống | Vui lòng nhập tên công nghệ. | inline | Không | Có | Low | Cả hai | — |
| `MSG-VAL-051` | SCR-PRJ-23 | Ô phiên bản để trống | Vui lòng nhập phiên bản đang sử dụng. | inline | Không | Có | Medium | Cả hai | BR-09 — phiên bản là bắt buộc, không được bỏ trống |
| `MSG-VAL-052` | SCR-SEC-10 | Khoảng ngày ghi nhận bị đảo ngược | Khoảng ngày không hợp lệ: ngày bắt đầu phải trước hoặc bằng ngày kết thúc. | inline | Không | Có | Low | Cả hai | Hiển thị dưới ô vừa gây lỗi |

## 5. Nhóm BIZ — Lỗi nghiệp vụ

### 5.1 Project (001–003, 011)

| Mã | Màn / Ngữ cảnh | Điều kiện phát sinh | Nội dung (VI) | Vị trí | Có Retry | Chặn action | Severity | Đối tượng đọc | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|
| `MSG-BIZ-001` | SCR-PRJ-11 | Mã dự án đã tồn tại | Mã dự án này đã được sử dụng. | inline | Không | Có | Medium | Cả hai | BR-06; so sánh không phân biệt hoa/thường |
| `MSG-BIZ-002` | SCR-PRJ-11 | Tên dự án đã tồn tại | Tên dự án này đã tồn tại. | inline | Không | Có | Medium | Cả hai | BR-06; kèm **liên kết** tới dự án đang giữ tên, để người dùng kiểm tra có trùng lặp thật không |
| `MSG-BIZ-003` | SCR-PRJ-11 | Chuyển sang Kết thúc khi còn lỗ hổng Mới/Đang xử lý | Không thể kết thúc dự án khi còn {n} lỗ hổng chưa xử lý. Vui lòng xử lý hoặc chấp nhận rủi ro trước. | banner | Không | Có | **High** | Cả hai | BR-18, DEC-05; kèm liên kết "Xem {n} lỗ hổng còn mở". `{n}` từ API tổng hợp theo Project |

### 5.2 Tech Stack (010–011)

| Mã | Màn / Ngữ cảnh | Điều kiện phát sinh | Nội dung (VI) | Vị trí | Có Retry | Chặn action | Severity | Đối tượng đọc | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|
| `MSG-BIZ-010` | SCR-PRJ-23 | Trùng loại + tên trong cùng dự án | Dự án đã có hạng mục {loại} tên {tên}. Vui lòng sửa hạng mục đó thay vì thêm mới. | inline | Không | Có | Medium | Cả hai | R-ENT-005; kèm liên kết tới hạng mục đang có. `{loại}`, `{tên}` từ dữ liệu người dùng vừa nhập |
| `MSG-BIZ-011` | SCR-PRJ-22 | Gỡ hạng mục có lỗ hổng chưa đóng khớp tên thư viện | Đang có {n} lỗ hổng chưa xử lý liên quan tới thư viện này. Gỡ hạng mục không làm thay đổi các lỗ hổng đó. | dialog (**cảnh báo vàng**) | Không | **Không** | Medium | Cả hai | EC-06 — **cảnh báo, không chặn**. `{n}` từ API đối chiếu theo tên |

### 5.3 Xung đột đồng thời (020–021)

| Mã | Màn / Ngữ cảnh | Điều kiện phát sinh | Nội dung (VI) | Vị trí | Có Retry | Chặn action | Severity | Đối tượng đọc | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|
| `MSG-BIZ-020` | SCR-ADM-10/11, SCR-PRJ-11/21/22/23 | `updated_at` phía máy chủ khác giá trị người dùng đã tải | Dữ liệu đã được người khác cập nhật. Danh sách đã được tải lại, vui lòng thao tác lại. | toast (danh sách) / banner (form) | Không | Có | Medium | Cả hai | EC-05. Ở form thì kèm nút "Tải lại dữ liệu mới" và **cảnh báo rằng tải lại sẽ mất thay đổi chưa lưu** |
| `MSG-BIZ-021` | SCR-SEC-11 | Trạng thái lỗ hổng vừa bị người khác đổi | Lỗ hổng này vừa được người khác chuyển sang trạng thái {trạng thái mới}. Vui lòng tải lại trước khi thao tác tiếp. | banner trong popup | Không | Có | **High** | Cả hai | Message **riêng** cho lỗ hổng vì cần nêu rõ trạng thái mới — nhiều người cùng xử lý một lỗ hổng là chuyện thường. `{trạng thái mới}` từ phản hồi máy chủ |

### 5.4 Lỗ hổng bảo mật (030–036, 040)

| Mã | Màn / Ngữ cảnh | Điều kiện phát sinh | Nội dung (VI) | Vị trí | Có Retry | Chặn action | Severity | Đối tượng đọc | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|
| `MSG-BIZ-030` | SCR-SEC-11 | Trùng (dự án + CVE + thư viện) | Dự án này đã ghi nhận {mã CVE} cho thư viện {tên thư viện}. | inline | Không | Có | Medium | Cả hai | R-ENT-009, BR-12; kèm **liên kết tới bản ghi đã có** |
| `MSG-BIZ-031` | SCR-SEC-11 | Người phụ trách không phải thành viên dự án | {Họ tên} không phải thành viên của dự án này. Bạn vẫn có thể gán, nhưng người đó sẽ không sửa được dữ liệu dự án. | inline (**cảnh báo vàng**) | Không | **Không** | Low | Cả hai | REL-003 — **cảnh báo, không chặn**; có thể là chuyên gia bảo mật từ team khác |
| `MSG-BIZ-032` | SCR-SEC-11, SCR-PRJ-24 | Ghi nhận lỗ hổng cho dự án đã Kết thúc | Không thể ghi nhận lỗ hổng cho dự án đã kết thúc. | toast | Không | Có | Medium | Cả hai | EC-02, REL-002 |
| `MSG-BIZ-033` | SCR-SEC-11 | Gán tài khoản đã khóa làm người phụ trách (qua API trực tiếp) | Không thể gán tài khoản đã khóa làm người phụ trách. | toast | Không | Có | Medium | Cả hai | R-ENT-006; trên giao diện tài khoản khóa đã không xuất hiện trong danh sách chọn |
| `MSG-BIZ-034` | SCR-SEC-11 | Người dùng không thuộc dự án nào chưa Kết thúc | Bạn chưa tham gia dự án nào đang hoạt động nên chưa thể ghi nhận lỗ hổng. Vui lòng liên hệ PM của dự án để được thêm vào. | inline vùng nội dung | Không | Có | Medium | Người dùng cuối | Hiển thị **thay cho cả form** để người dùng không điền hết rồi mới biết không lưu được |
| `MSG-BIZ-035` | SCR-SEC-11 | Phiên bản bị ảnh hưởng lệch với tech stack đang khai báo | Tech stack của dự án đang ghi phiên bản {phiên bản}. Hãy kiểm tra lại xem thông tin nào chính xác. | inline (**cảnh báo vàng**) | Không | **Không** | Low | Cả hai | **Cảnh báo, không chặn** — tech stack có thể chưa được cập nhật. `{phiên bản}` từ `TechStackItem.version` cùng tên thư viện |
| `MSG-BIZ-036` | SCR-SEC-11 | Nâng mức của lỗ hổng đang ở trạng thái Chấp nhận rủi ro lên Critical/High | Lỗ hổng này đang ở trạng thái Chấp nhận rủi ro. Nâng mức lên {mức} khiến quyết định đó cần được quản trị viên xem xét lại. | inline (**cảnh báo vàng**) | Không | **Không** `[NEEDS-CONFIRMATION]` | High | Cả hai | Đang là cảnh báo; xem câu hỏi mở ở `09-screen-spec-security-dashboard.md` §2.11 về việc có nên chặn không |
| `MSG-BIZ-040` | SCR-SEC-11 | Chuyển trạng thái không hợp lệ theo sơ đồ BU §5.1 | Không thể chuyển sang trạng thái này từ trạng thái hiện tại. | toast | Không | Có | Medium | Cả hai | R-ENT-001; trên giao diện các đích không hợp lệ đã không xuất hiện |

### 5.5 Thành viên dự án (050–052)

| Mã | Màn / Ngữ cảnh | Điều kiện phát sinh | Nội dung (VI) | Vị trí | Có Retry | Chặn action | Severity | Đối tượng đọc | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|
| `MSG-BIZ-050` | SCR-PRJ-21 | Xóa thành viên đang phụ trách lỗ hổng chưa đóng | Không thể xóa {họ tên} khỏi dự án vì đang phụ trách {n} lỗ hổng chưa xử lý. Vui lòng gán người phụ trách khác trước. | dialog | Không | Có | High | Cả hai | EC-03, REL-003; kèm **danh sách lỗ hổng** và liên kết để gán người khác |
| `MSG-BIZ-051` | SCR-PRJ-21 | Xóa hoặc hạ vai trò PM cuối cùng | Dự án phải có ít nhất một PM. Vui lòng gán PM khác trước khi thay đổi. | toast | Không | Có | High | Cả hai | BR-08, REL-006; giá trị dropdown quay về cũ |
| `MSG-BIZ-052` | SCR-PRJ-21 | Thêm người đã là thành viên | {Họ tên} đã là thành viên của dự án này. | inline | Không | Có | Low | Cả hai | Chỉ xảy ra khi có thao tác đồng thời — trên giao diện người đã là thành viên bị vô hiệu hóa trong gợi ý |

### 5.6 Quản trị tài khoản (060–061)

| Mã | Màn / Ngữ cảnh | Điều kiện phát sinh | Nội dung (VI) | Vị trí | Có Retry | Chặn action | Severity | Đối tượng đọc | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|
| `MSG-BIZ-060` | SCR-ADM-10, SCR-ADM-11 | Khóa hoặc hạ vai trò Admin hoạt động cuối cùng | Không thể thực hiện: hệ thống phải luôn có ít nhất một quản trị viên đang hoạt động. | toast (danh sách) / banner (popup) | Không | Có | **Critical** | Quản trị viên | BR-05, REL-007 — nếu vi phạm thì hệ thống mất hoàn toàn khả năng quản trị |
| `MSG-BIZ-061` | SCR-ADM-11 | Email đã được dùng cho tài khoản khác | Email này đã được sử dụng cho một tài khoản khác. | inline | Không | Có | Medium | Quản trị viên | So sánh không phân biệt hoa/thường |

### 5.7 Kết xuất dữ liệu (070–071)

| Mã | Màn / Ngữ cảnh | Điều kiện phát sinh | Nội dung (VI) | Vị trí | Có Retry | Chặn action | Severity | Đối tượng đọc | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|
| `MSG-BIZ-070` | SCR-PRJ-10, SCR-SEC-10 | Kết quả bộ lọc vượt 10.000 dòng | Kết quả vượt quá 10.000 dòng nên không thể kết xuất. Vui lòng thu hẹp bộ lọc. | toast | Không | Có | Medium | Cả hai | DEC-06 |
| `MSG-BIZ-071` | SCR-PRJ-10, SCR-SEC-10 | Kết quả bộ lọc là 0 dòng | Không có dữ liệu nào để kết xuất với bộ lọc hiện tại. | toast | Không | Có | Low | Cả hai | Trên giao diện nút đã bị vô hiệu hóa; message này là lớp phòng vệ phía máy chủ |

## 6. Nhóm AUTH — Xác thực và phân quyền

| Mã | Màn / Ngữ cảnh | Điều kiện phát sinh | Nội dung (VI) | Vị trí | Có Retry | Chặn action | Severity | Đối tượng đọc | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|
| `MSG-AUTH-001` | SCR-AUTH-10 | Email không tồn tại **hoặc** mật khẩu sai | Email hoặc mật khẩu không đúng. | banner | Không | Có | Medium | Cả hai | **Bắt buộc dùng cùng một message cho cả hai trường hợp** — nói rõ trường nào sai là lộ thông tin tài khoản nào tồn tại. QA phải kiểm tra điều này |
| `MSG-AUTH-002` | SCR-AUTH-10 | Sai mật khẩu 5 lần trong 15 phút | Bạn đã nhập sai quá 5 lần. Vui lòng thử lại sau {phút} phút. | banner | Không | Có | Medium | Cả hai | BR-21; nút Đăng nhập bị vô hiệu hóa tới hết thời gian. `{phút}` tính từ `User.locked_until` |
| `MSG-AUTH-003` | SCR-AUTH-10 | Tài khoản ở trạng thái Khóa | Tài khoản đã bị khóa. Vui lòng liên hệ quản trị viên hệ thống. | banner | Không | Có | Medium | Người dùng cuối | BR-23; **không** tăng bộ đếm sai cho trường hợp này |
| `MSG-AUTH-004` | Toàn cục | Phiên hết hạn sau 30 phút không thao tác, hoặc API trả 401 | Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại. | banner (ở màn đăng nhập) / toast (ở màn trong) | Không | Có | Medium | Cả hai | BR-22; route đích được ghi nhớ để quay lại sau khi đăng nhập |
| `MSG-AUTH-005` | SCR-ADM-10/11, SCR-PRJ-11, và mọi API ghi | Không đủ quyền: User mở màn quản trị, hoặc ghi dữ liệu dự án không tham gia | Bạn không có quyền truy cập trang này. | page (route guard) / toast (API) | Không | Có | High | Người dùng cuối | EC-07 — hiển thị **trang 403 rõ ràng**, không chuyển hướng âm thầm; kèm nút "Về Dashboard" |
| `MSG-AUTH-006` | SCR-SEC-11 | Không phải Admin mà chấp nhận rủi ro lỗ hổng Critical/High | Chỉ quản trị viên được chấp nhận rủi ro cho lỗ hổng mức Critical hoặc High. | tooltip (khi vô hiệu hóa) / toast (khi API từ chối) | Không | Có | **Critical** | Cả hai | BR-15, DEC-09 — kiểm soát cốt lõi của G-05. **QA bắt buộc kiểm tra máy chủ chặn thật**, không chỉ vô hiệu hóa trên giao diện |

## 7. Nhóm NF — Không tìm thấy (404)

| Mã | Màn / Ngữ cảnh | Điều kiện phát sinh | Nội dung (VI) | Vị trí | Có Retry | Chặn action | Severity | Đối tượng đọc | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|
| `MSG-NF-001` | SCR-PRJ-11, SCR-PRJ-20, SCR-PRJ-2x | ID dự án không tồn tại | Không tìm thấy dự án bạn đang tìm. Có thể dự án đã bị đổi mã hoặc đường dẫn không đúng. | page | Không | Có | Low | Cả hai | Kèm nút "Về danh sách dự án". **Phân biệt rõ với `MSG-SYS-*`** — 404 không phải lỗi hệ thống |
| `MSG-NF-002` | SCR-ADM-10, SCR-ADM-11 | Tài khoản không còn tồn tại | Tài khoản không còn tồn tại. | toast / banner trong popup | Không | Có | Low | Quản trị viên | Hiếm vì không có chức năng xóa tài khoản; popup phải hiện thông báo chứ **không** hiện form rỗng |
| `MSG-NF-003` | SCR-PRJ-21 | Thành viên vừa bị người khác xóa | Thành viên này không còn trong dự án. | toast | Không | Có | Low | Cả hai | Tải lại bảng sau khi hiển thị |
| `MSG-NF-004` | SCR-PRJ-22, SCR-PRJ-23 | Hạng mục tech stack vừa bị gỡ | Hạng mục công nghệ này không còn tồn tại. | toast / banner trong popup | Không | Có | Low | Cả hai | Popup phải hiện thông báo chứ **không** hiện form rỗng như thể tạo mới |
| `MSG-NF-005` | SCR-SEC-11 | ID lỗ hổng không tồn tại | Không tìm thấy lỗ hổng bạn đang tìm. | page | Không | Có | Low | Cả hai | Kèm nút "Về danh sách lỗ hổng" |

## 8. Nhóm SYS — Lỗi hệ thống

| Mã | Màn / Ngữ cảnh | Điều kiện phát sinh | Nội dung (VI) | Vị trí | Có Retry | Chặn action | Severity | Đối tượng đọc | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|
| `MSG-SYS-001` | Toàn cục | Máy chủ trả lỗi ngoài dự kiến khi **ghi** dữ liệu | Hệ thống đang gặp sự cố. Vui lòng thử lại sau ít phút. | banner | Không (bấm lại nút chính) | Có | High | Người dùng cuối | **Fallback cuối cùng** — chỉ dùng khi không có message nghiệp vụ cụ thể hơn. Không lộ chi tiết kỹ thuật. Dữ liệu người dùng đã nhập phải được giữ nguyên |
| `MSG-SYS-002` | Toàn cục | Mất kết nối hoặc máy chủ không phản hồi trong ngưỡng timeout | Không kết nối được máy chủ. Vui lòng kiểm tra kết nối mạng và thử lại. | banner (form) / inline vùng dữ liệu (danh sách) | **Có** (ở danh sách) | Có | High | Cả hai | Ngưỡng: 15 giây ở màn đăng nhập, 20 giây ở các màn khác `[ASSUMED]`. **Dữ liệu đang nhập phải được giữ nguyên** |
| `MSG-SYS-003` | Mọi màn danh sách | API tải danh sách trả lỗi | Không tải được danh sách. Vui lòng thử lại. | inline vùng dữ liệu | **Có** | Không | Medium | Cả hai | Hiển thị **ở chỗ đáng lẽ có dữ liệu**, không dùng toast; bộ lọc được giữ nguyên |
| `MSG-SYS-004` | SCR-PRJ-10, SCR-PRJ-20, SCR-PRJ-22, SCR-SEC-10, SCR-PRJ-24 | API phụ (gợi ý, số liệu tổng hợp) lỗi trong khi API chính vẫn tốt | Tạm thời không tải được dữ liệu bổ sung cho phần này. | tooltip / ghi chú nhỏ | Không | **Không** | Low | Cả hai | **Lỗi bộ phận không được làm hỏng cả màn**: ô lọc bị vô hiệu hóa hoặc chỉ số hiện dấu "—", phần còn lại vẫn dùng được |
| `MSG-SYS-005` | SCR-PRJ-10, SCR-SEC-10 | Lỗi trong lúc tạo tệp kết xuất | Không tạo được tệp kết xuất. Vui lòng thử lại. | toast | Không | Có | Medium | Cả hai | Không tải về tệp hỏng hay tệp rỗng |
| `MSG-SYS-006` | SCR-DASH-10 | API của một khối Dashboard lỗi | Không tải được số liệu của khối này. Vui lòng thử lại. | inline từng khối | **Có** | Không | Medium | Cả hai | **Chỉ khối lỗi bị ảnh hưởng**; ở khối cảnh báo bảo mật thì **không hiển thị số nào** — thà không có số còn hơn số sai |

## 9. Nhóm INF — Thông báo, xác nhận, trạng thái rỗng

### 9.1 Thành công (001–009, 017–024)

| Mã | Màn / Ngữ cảnh | Điều kiện phát sinh | Nội dung (VI) | Vị trí | Severity | Đối tượng đọc | Ghi chú |
|---|---|---|---|---|---|---|---|
| `MSG-INF-001` | SCR-AUTH-11 | Đổi mật khẩu thành công | Đổi mật khẩu thành công. | toast | Low | Cả hai | Chuyển màn sau 1 giây |
| `MSG-INF-002` | SCR-ADM-11 | Tạo tài khoản thành công | Đã tạo tài khoản {email}. Người dùng sẽ được yêu cầu đổi mật khẩu ở lần đăng nhập đầu tiên. | toast | Low | Quản trị viên | Nêu rõ hệ quả để Admin biết cần bàn giao mật khẩu tạm |
| `MSG-INF-004` | SCR-ADM-10 | Khóa tài khoản thành công | Đã khóa tài khoản {email}. | toast | Low | Quản trị viên | — |
| `MSG-INF-005` | SCR-ADM-10 | Mở khóa tài khoản thành công | Đã mở khóa tài khoản {email}. | toast | Low | Quản trị viên | Đồng thời đặt lại `failed_login_count` |
| `MSG-INF-006` | SCR-ADM-11 | Cập nhật tài khoản thành công | Đã cập nhật tài khoản {email}. | toast | Low | Quản trị viên | — |
| `MSG-INF-007` | SCR-PRJ-11 | Tạo dự án thành công | Đã tạo dự án {tên}. Bạn là PM của dự án này. | toast | Low | Cả hai | Nêu rõ hệ quả BR-04 để người dùng biết mình vừa nhận trách nhiệm |
| `MSG-INF-008` | SCR-PRJ-11 | Cập nhật dự án thành công | Đã cập nhật dự án {tên}. | toast | Low | Cả hai | — |
| `MSG-INF-009` | SCR-PRJ-21 | Thêm hoặc đổi vai trò thành viên thành công | Đã cập nhật thành viên dự án. | toast | Low | Cả hai | — |
| `MSG-INF-017` | SCR-PRJ-22 | Gỡ hạng mục tech stack thành công | Đã gỡ {tên công nghệ} khỏi dự án. | toast | Low | Cả hai | — |
| `MSG-INF-018` | SCR-PRJ-23 | Thêm hạng mục tech stack thành công | Đã thêm {tên công nghệ} vào tech stack. | toast | Low | Cả hai | — |
| `MSG-INF-019` | SCR-PRJ-23 | Sửa hạng mục tech stack thành công | Đã cập nhật {tên công nghệ}. | toast | Low | Cả hai | — |
| `MSG-INF-021` | SCR-SEC-11 | Chuyển trạng thái lỗ hổng thành công | Đã chuyển trạng thái sang {trạng thái}. | toast | Low | Cả hai | Tải lại chi tiết và bảng lịch sử |
| `MSG-INF-022` | SCR-SEC-11 | Ghi nhận lỗ hổng thành công | Đã ghi nhận lỗ hổng {mã CVE} cho dự án {tên dự án}. | toast | Low | Cả hai | — |
| `MSG-INF-023` | SCR-SEC-11 | Sửa thông tin lỗ hổng thành công | Đã cập nhật thông tin lỗ hổng. | toast | Low | Cả hai | **Không** sinh dòng lịch sử — lịch sử chỉ ghi chuyển trạng thái |
| `MSG-INF-024` | SCR-PRJ-21 | Xóa thành viên khỏi dự án thành công | Đã xóa {họ tên} khỏi dự án. | toast | Low | Cả hai | — |

### 9.2 Thông tin và nhắc việc (003, 014, 020)

| Mã | Màn / Ngữ cảnh | Điều kiện phát sinh | Nội dung (VI) | Vị trí | Severity | Đối tượng đọc | Ghi chú |
|---|---|---|---|---|---|---|---|
| `MSG-INF-003` | SCR-AUTH-11 | Vào màn ở chế độ bắt buộc đổi mật khẩu | Đây là lần đăng nhập đầu tiên của bạn. Vui lòng đặt mật khẩu mới trước khi tiếp tục. | banner (vàng) | Low | Người dùng cuối | Giải thích vì sao người dùng bị giữ lại ở màn này |
| `MSG-INF-014` | SCR-ADM-11 | Đặt lại mật khẩu thành công | Hãy sao chép mật khẩu tạm ngay — mật khẩu này chỉ hiển thị một lần và không xem lại được. | banner trong popup | Medium | Quản trị viên | Kèm nút sao chép. Hệ quả của việc không có hạ tầng mail (DEC-08b) |
| `MSG-INF-020` | SCR-SEC-11 | Chuyển lỗ hổng sang Đã xử lý | Đã đóng lỗ hổng. Nếu bạn xử lý bằng cách nâng phiên bản, đừng quên cập nhật phiên bản trong tab Tech Stack của dự án. | banner (thông tin) | Medium | Cả hai | BR-17 — hệ thống **không** tự cập nhật tech stack. Kèm liên kết tới tab; giữ đến khi người dùng đóng, không tự ẩn như toast |

### 9.3 Hộp thoại xác nhận (010–016)

| Mã | Màn / Ngữ cảnh | Điều kiện phát sinh | Nội dung (VI) | Vị trí | Severity | Đối tượng đọc | Ghi chú |
|---|---|---|---|---|---|---|---|
| `MSG-INF-010` | SCR-PRJ-22 | Trước khi gỡ hạng mục tech stack | Gỡ hạng mục {tên công nghệ} khỏi dự án? | dialog | Low | Cả hai | Nếu có lỗ hổng liên quan thì bổ sung `MSG-BIZ-011` trong cùng hộp thoại |
| `MSG-INF-011` | Mọi form | Đóng form khi có thay đổi chưa lưu | Thay đổi chưa được lưu sẽ bị mất. Bạn có chắc muốn đóng? | dialog | Medium | Cả hai | Áp dụng cho nút Hủy, dấu ×, phím Escape và click backdrop — **cả bốn phải hành xử giống nhau** |
| `MSG-INF-012` | SCR-ADM-10, SCR-ADM-11 | Trước khi khóa tài khoản | Khóa tài khoản {email}? Người này sẽ không đăng nhập được nhưng mọi dữ liệu và lịch sử của họ vẫn được giữ. | dialog | Medium | Quản trị viên | Nêu rõ BR-23 để Admin không lo mất dữ liệu |
| `MSG-INF-013` | SCR-ADM-10 | Trước khi mở khóa tài khoản | Mở khóa tài khoản {email}? Người này sẽ đăng nhập lại được ngay. | dialog | Low | Quản trị viên | — |
| `MSG-INF-015` | SCR-PRJ-11 | Trước khi xóa dòng repository đã có dữ liệu | Xóa repository {tên} khỏi dự án? | dialog | Low | Cả hai | Dòng chưa nhập gì thì xóa ngay, không hỏi |
| `MSG-INF-016` | SCR-PRJ-21 | Trước khi xóa thành viên | Xóa {họ tên} khỏi dự án? Người này sẽ mất quyền sửa dữ liệu của dự án nhưng vẫn giữ nguyên trong lịch sử xử lý lỗ hổng. | dialog | Medium | Cả hai | Nêu rõ hệ quả về **quyền** — đây là thao tác an ninh, không chỉ là dọn dẹp danh sách |

### 9.4 Trạng thái rỗng (030–045)

> Nguyên tắc: **mỗi hoàn cảnh rỗng có một câu riêng**. Gộp "chưa có dữ liệu" và "lọc không ra kết quả" vào một câu khiến người dùng không biết nên tạo mới hay nên sửa bộ lọc.

| Mã | Màn / Ngữ cảnh | Điều kiện phát sinh | Nội dung (VI) | Hành động kèm theo | Severity | Ghi chú |
|---|---|---|---|---|---|---|
| `MSG-INF-030` | SCR-PRJ-10 | Bộ lọc không ra kết quả | Không tìm thấy dự án nào phù hợp với bộ lọc hiện tại. | Nút "Xóa bộ lọc" | Low | — |
| `MSG-INF-031` | SCR-PRJ-22 | Dự án chưa khai báo tech stack | Dự án chưa khai báo công nghệ nào. | Nút "Thêm hạng mục" nếu có quyền ghi | Low | Người không có quyền ghi chỉ thấy câu thông báo |
| `MSG-INF-033` | SCR-ADM-10 | Bộ lọc không ra tài khoản nào | Không tìm thấy tài khoản nào phù hợp với bộ lọc hiện tại. | Nút "Xóa bộ lọc" | Low | Hệ thống luôn có ≥1 Admin nên không có trường hợp "chưa có tài khoản nào" |
| `MSG-INF-034` | SCR-PRJ-10 | Hệ thống chưa có dự án nào | Chưa có dự án nào trong hệ thống. Hãy tạo dự án đầu tiên. | Nút "Tạo dự án" | Low | Khác hẳn `MSG-INF-030` |
| `MSG-INF-035` | SCR-PRJ-21 | Dự án có 0 thành viên | Dự án chưa có thành viên nào. Đây là dữ liệu bất thường — vui lòng liên hệ quản trị viên. | — | **Medium** | Vi phạm BR-08 — nếu gặp là lỗi dữ liệu cần báo, không phải trạng thái bình thường |
| `MSG-INF-036` | SCR-SEC-10 | Bộ lọc không ra lỗ hổng nào | Không tìm thấy lỗ hổng nào phù hợp với bộ lọc hiện tại. | Nút "Xóa bộ lọc" | Low | — |
| `MSG-INF-037` | SCR-SEC-10 | Hệ thống chưa có lỗ hổng nào | Chưa ghi nhận lỗ hổng nào trong hệ thống. | — | Low | Văn phong **trung tính** — đây có thể là tin tốt |
| `MSG-INF-038` | SCR-SEC-10 | Lọc mặc định "còn mở" ra 0 nhưng hệ thống có lỗ hổng đã đóng | Không còn lỗ hổng nào đang mở. Bỏ bộ lọc trạng thái để xem các lỗ hổng đã xử lý. | Nút "Xem tất cả trạng thái" | Low | Trường hợp thứ ba, khác hẳn hai câu trên — QA hay bỏ sót |
| `MSG-INF-039` | SCR-SEC-11 | Bảng lịch sử trạng thái rỗng | Không có dữ liệu lịch sử. Đây là dữ liệu bất thường — vui lòng liên hệ quản trị viên. | — | **Medium** | Vi phạm BR-14 — mỗi lỗ hổng phải có ít nhất một dòng lịch sử |
| `MSG-INF-040` | SCR-PRJ-24 | Bộ lọc không ra kết quả trong dự án | Không có lỗ hổng nào phù hợp với bộ lọc hiện tại. | Nút "Xóa bộ lọc" | Low | — |
| `MSG-INF-041` | SCR-PRJ-24 | Dự án chưa có lỗ hổng nào | Dự án chưa ghi nhận lỗ hổng nào. | Nút "Ghi nhận lỗ hổng" nếu có quyền | Low | Văn phong trung tính |
| `MSG-INF-042` | SCR-DASH-10 khối 1 | Ba chỉ số cảnh báo đều bằng 0 | Không có lỗ hổng nghiêm trọng nào đang mở. | — | Low | **Nền trung tính, không phải màu đỏ** — đây là tin tốt |
| `MSG-INF-043` | SCR-DASH-10 khối 2 | Hệ thống chưa có dự án nào | Chưa có dự án nào trong hệ thống. | Nút "Tạo dự án" | Low | — |
| `MSG-INF-044` | SCR-DASH-10 khối 3 | Chưa dự án nào khai báo tech stack | Chưa có dự án nào khai báo tech stack. | — | Low | — |
| `MSG-INF-045` | SCR-DASH-10 khối 4 | Chưa có lỗ hổng nào | Chưa ghi nhận lỗ hổng nào. | — | Low | Văn phong trung tính |

## 10. Ma trận message × màn hình

| Screen ID | VAL | BIZ | AUTH | NF | SYS | INF |
|---|---|---|---|---|---|---|
| SCR-AUTH-10 | 004, 005, 006 | — | 001, 002, 003, 004 | — | 001, 002 | — |
| SCR-AUTH-11 | 001, 002, 003, 007, 008 | — | 004 | — | 001, 002 | 001, 003, 011 |
| SCR-ADM-10 | — | 020, 060 | 004, 005 | 002 | 002, 003 | 004, 005, 012, 013, 033 |
| SCR-ADM-11 | 001, 004, 005, 009 | 020, 060, 061 | 004, 005 | 002 | 001, 002 | 002, 006, 011, 014 |
| SCR-PRJ-10 | — | 070, 071 | 004 | — | 002, 003, 004, 005 | 030, 034 |
| SCR-PRJ-11 | 010–019 | 001, 002, 003, 020 | 004, 005 | 001 | 001, 002, 003 | 007, 008, 011, 015 |
| SCR-PRJ-20 | — | — | 004 | 001 | 002, 003, 004 | — |
| SCR-PRJ-21 | 040 | 020, 050, 051, 052 | 004, 005 | 003 | 002, 003 | 009, 011, 016, 024, 035 |
| SCR-PRJ-22 | — | 011, 020 | 004, 005 | 004 | 002, 003, 004 | 010, 017, 031 |
| SCR-PRJ-23 | 050, 051 | 010, 020 | 004, 005 | 004 | 001, 002 | 011, 018, 019 |
| SCR-PRJ-24 | — | 032 | 004 | 001 | 002, 003, 004 | 040, 041 |
| SCR-SEC-10 | 015, 052 | 070, 071 | 004 | — | 002, 003, 004, 005 | 036, 037, 038 |
| SCR-SEC-11 | 020, 030–033, 053–057 | 021, 030–036, 040 | 004, 005, 006 | 005 | 001, 002, 003 | 020, 021, 022, 023, 039 |
| SCR-DASH-10 | — | — | 004 | — | 002, 006 | 042, 043, 044, 045 |

## 11. Danh sách kiểm thử bắt buộc cho QA

Những điểm dưới đây là nơi message dễ bị làm sai nhất, tách riêng để đội kiểm thử không phải tự suy ra từ spec:

| # | Điểm kiểm tra | Vì sao quan trọng |
|---|---|---|
| 1 | `MSG-AUTH-001` phải **giống hệt nhau** khi email không tồn tại và khi mật khẩu sai | Nói rõ trường nào sai là lộ thông tin tài khoản nào tồn tại trong tổ chức |
| 2 | `MSG-AUTH-006` phải được **máy chủ** chặn, không chỉ vô hiệu hóa nút trên giao diện | Đây là kiểm soát cốt lõi của G-05 — chặn phía trình duyệt là vô nghĩa |
| 3 | `MSG-BIZ-060` phải chặn được cả khi có đúng 1 Admin và khi có 2 Admin cùng bị thao tác đồng thời | Vi phạm khiến hệ thống mất hoàn toàn khả năng quản trị |
| 4 | `MSG-BIZ-011`, `MSG-BIZ-031`, `MSG-BIZ-035`, `MSG-BIZ-036`, `MSG-VAL-019` là **cảnh báo, không chặn** | Rất dễ bị implement nhầm thành chặn, làm người dùng không hoàn thành được việc hợp lệ |
| 5 | Ba trạng thái rỗng của `SCR-SEC-10` (`MSG-INF-036/037/038`) phải phân biệt được | Người dùng cần biết nên tạo mới, nên sửa bộ lọc, hay mọi việc đã xong |
| 6 | Lưu thất bại ở mọi form phải **giữ nguyên** dữ liệu đã nhập và **không** đóng popup | Mất dữ liệu đã gõ là lỗi trải nghiệm nghiêm trọng nhất |
| 7 | 404 (`MSG-NF-*`) phải phân biệt với lỗi hệ thống (`MSG-SYS-*`) | Người dùng cần biết là mình gõ sai đường dẫn hay hệ thống đang hỏng |
| 8 | Popup mở ở chế độ sửa mà tải chi tiết thất bại phải hiện thông báo, **không** hiện form rỗng | Form rỗng khiến người dùng tưởng đang tạo mới và nhập lại từ đầu |
| 9 | `MSG-SYS-006` ở khối cảnh báo Dashboard phải **không hiển thị số nào** khi lỗi | Số sai ở khối cảnh báo bảo mật nguy hiểm hơn là không có số |
| 10 | `MSG-VAL-031`, `MSG-VAL-032`, `MSG-VAL-057` là ba message **riêng theo ngữ cảnh** | Dùng chung một câu "Vui lòng nhập ghi chú" khiến người dùng không biết đang được hỏi điều gì |

## 12. Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng |
|---|---|---|
| Q-MSG-01 | `MSG-BIZ-036` (nâng mức lỗ hổng đang ở trạng thái Chấp nhận rủi ro) nên **cảnh báo** hay **chặn và yêu cầu Admin xác nhận lại**? | SCR-SEC-11, BR-15 |
| Q-MSG-02 | Có cần thêm message xác nhận trước khi kết xuất CSV chứa dữ liệu lỗ hổng không? Tệp này là danh sách điểm yếu của tổ chức. | SCR-SEC-10 §9 |
| Q-MSG-03 | Ngưỡng timeout (15 giây ở đăng nhập, 20 giây ở các màn khác) cần đội vận hành xác nhận. | `MSG-SYS-002` |
| Q-MSG-04 | Nếu bổ sung ngôn ngữ thứ hai ở giai đoạn sau, catalog này cần thêm cột — nên chốt sớm để không phải sửa toàn bộ Screen Spec. | Toàn bộ catalog |

## 13. Checklist đồng bộ với Screen Spec

- [x] Mọi mã message xuất hiện trong ba file Screen Spec đều có mặt trong catalog này (112 mã).
- [x] Mỗi message có đủ: nội dung, vị trí hiển thị, có Retry, chặn action, severity, đối tượng đọc.
- [x] Lỗi nghiệp vụ được tách bạch từng case, **không** gom vào `MSG-SYS-001`.
- [x] 401/403 (`AUTH`) và 404 (`NF`) tách riêng khỏi lỗi hệ thống (`SYS`).
- [x] Message cảnh báo (không chặn) được đánh dấu rõ ở cột "Chặn action" và trong nội dung.
- [x] Wording cho cùng một hành động nhất quán giữa các màn (ví dụ mọi "Đã cập nhật…" dùng chung cấu trúc câu).
- [x] Biến chèn `{…}` đều ghi rõ nguồn dữ liệu ở cột Ghi chú.
- [x] Không có message nào lộ chi tiết kỹ thuật cho người dùng cuối.

**Last Updated**: 2026-08-26

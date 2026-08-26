# Backlog — Epic / Feature / User Story

> **Phase**: Design — Specification → Detailing | **Trạng thái**: Draft v0.2 — chờ BU verify
> **Upstream**: `01-business-understanding.md` (v0.2), `02-usecase-overview.md` (v0.2), `05-screen-flow.md` (v0.2)
> **Thay đổi v0.1 → v0.2**: bổ sung EP-06 (Kết xuất báo cáo); tách 11 Feature thành 13; viết đầy đủ **34 User Story** kèm tiêu chí chấp nhận GIVEN/WHEN/THEN; bổ sung ước lượng tương đối và thứ tự ưu tiên phát triển.

---

## 1. Epics

### EP-01

**Name**: Xác thực & Phân quyền

**1. Goal** — Người dùng truy cập hệ thống an toàn bằng tài khoản được cấp; quyền quản trị tách bạch khỏi người dùng thường; không có tài khoản nào dùng mật khẩu do người khác đặt lâu dài.

**2. Scope** — Đăng nhập/đăng xuất, đổi mật khẩu (bắt buộc lần đầu), quản lý tài khoản (tạo/sửa/khóa/đặt lại mật khẩu), gán vai trò Admin/User, guard route theo vai trò, xử lý phiên hết hạn.

**3. Out of scope** — SSO, 2FA, tự đăng ký tài khoản, quên mật khẩu qua email (không có hạ tầng mail — DEC-08b).

**4. Features** — FE-01, FE-02, FE-03, FE-04

**5. Related use cases** — UC-AUTH-01, UC-AUTH-02, UC-AUTH-03, UC-ADM-01, UC-ADM-02

**6. Related screens** — SCR-AUTH-10, SCR-AUTH-11, SCR-ADM-10, SCR-ADM-11

**7. Acceptance outline** — Đăng nhập đúng/sai xử lý chuẩn; tài khoản khóa không vào được; lần đầu bắt buộc đổi mật khẩu; User mở URL quản trị nhận trang 403; hệ thống luôn còn ≥1 Admin hoạt động.

---

### EP-02

**Name**: Quản lý Project

**1. Goal** — Mọi dự án có hồ sơ chuẩn: thông tin, repository, thành viên, trạng thái; là một nguồn duy nhất thay cho Excel và wiki rời rạc (G-01).

**2. Scope** — Tạo/sửa project, quản lý repository (chỉ lưu link), quản lý thành viên và vai trò trong dự án, tìm kiếm/lọc/phân trang danh sách, ràng buộc vòng đời trạng thái.

**3. Out of scope** — Tích hợp API GitHub/GitLab (DEC-07); xóa Project; chuyển dữ liệu từ hệ thống cũ (DEC-11).

**4. Features** — FE-05, FE-06, FE-07

**5. Related use cases** — UC-PRJ-01, UC-PRJ-02, UC-PRJ-03, UC-PRJ-04

**6. Related screens** — SCR-PRJ-10, SCR-PRJ-11, SCR-PRJ-20, SCR-PRJ-21

**7. Acceptance outline** — Mã và tên project không trùng; thành viên không trùng trong một project; luôn còn ≥1 PM; không kết thúc được project còn lỗ hổng mở; quyền sửa theo role matrix.

---

### EP-03

**Name**: Quản lý Tech Stack theo Project

**1. Goal** — Biết chính xác từng dự án đang dùng công nghệ gì, phiên bản nào, để khi một CVE xuất hiện có thể trả lời ngay "dự án nào bị ảnh hưởng".

**2. Scope** — Thêm/sửa/gỡ hạng mục theo 5 loại (ngôn ngữ, framework, database, cache, cloud) kèm phiên bản; xem theo project nhóm theo loại; ghi nhận người và thời điểm sửa cuối.

**3. Out of scope** — Tự động phát hiện tech stack từ mã nguồn; lịch sử thay đổi phiên bản (DEC-10); danh mục tên công nghệ chuẩn hóa (Q-ENT-04).

**4. Features** — FE-08

**5. Related use cases** — UC-TS-01, UC-TS-02

**6. Related screens** — SCR-PRJ-22, SCR-PRJ-23

**7. Acceptance outline** — Không trùng loại + tên trong một project (R-ENT-005); bắt buộc nhập phiên bản; người không phải thành viên không thấy nút sửa.

---

### EP-04

**Name**: Quản lý Security (CVE)

**1. Goal** — Mọi lỗ hổng liên quan tới các dự án được ghi nhận, theo dõi trạng thái xử lý, có khuyến nghị nâng cấp và người phụ trách; không có lỗ hổng nghiêm trọng nào bị đóng âm thầm (G-02, G-05).

**2. Scope** — Ghi nhận CVE theo từng project, luồng trạng thái có ràng buộc, lịch sử trạng thái bất biến, khuyến nghị nâng cấp, người phụ trách, danh sách toàn hệ thống và theo project, lọc và gom nhóm theo CVE, kiểm soát quyền chấp nhận rủi ro theo mức nghiêm trọng.

**3. Out of scope** — Tự động đồng bộ CVE từ NVD/OSV (DEC-02); cảnh báo email (DEC-08b); xóa lỗ hổng (BR-13).

**4. Features** — FE-09, FE-10, FE-11

**5. Related use cases** — UC-SEC-01, UC-SEC-02, UC-SEC-03, UC-SEC-04

**6. Related screens** — SCR-SEC-10, SCR-SEC-11, SCR-PRJ-24

**7. Acceptance outline** — Luồng trạng thái đúng sơ đồ BU §5.1; không xóa được lỗ hổng; mọi lần chuyển trạng thái sinh một dòng lịch sử; Critical/High chỉ Admin chấp nhận rủi ro được.

---

### EP-05

**Name**: Dashboard

**1. Goal** — Quản lý nhìn một màn hình là nắm được tình trạng danh mục dự án, công nghệ và bảo mật, thay cho việc tổng hợp thủ công (G-03).

**2. Scope** — Ô cảnh báo lỗ hổng Critical còn mở và lỗ hổng quá hạn 30 ngày; thống kê dự án theo trạng thái; phân bố công nghệ đang dùng; lỗ hổng theo mức nghiêm trọng và trạng thái; điều hướng nhanh tới danh sách đã lọc; tùy chọn bao gồm dự án đã kết thúc.

**3. Out of scope** — Báo cáo tùy biến, biểu đồ do người dùng cấu hình, so sánh theo thời gian (DEC-06).

**4. Features** — FE-12

**5. Related use cases** — UC-DASH-01

**6. Related screens** — SCR-DASH-10

**7. Acceptance outline** — Số liệu khớp dữ liệu nguồn; mọi phần tử thống kê bấm được để đi tới danh sách đã lọc; lỗi ở một khối không làm hỏng các khối còn lại.

---

### EP-06

**Name**: Kết xuất báo cáo `[DECIDED — DEC-06]`

**1. Goal** — Cho phép quản lý mang số liệu ra ngoài hệ thống để báo cáo định kỳ mà không cần chức năng báo cáo tùy biến.

**2. Scope** — Kết xuất CSV danh sách lỗ hổng và danh sách dự án theo bộ lọc hiện tại; quy ước UTF-8 có BOM, CRLF; giới hạn 10.000 dòng.

**3. Out of scope** — Export Excel/PDF; đặt lịch gửi báo cáo tự động.

**4. Features** — FE-13

**5. Related use cases** — UC-PRJ-05, UC-SEC-05

**6. Related screens** — SCR-PRJ-10, SCR-SEC-10

**7. Acceptance outline** — Xuất theo bộ lọc (không phải theo trang); mở đúng tiếng Việt trong Excel; chặn khi quá 10.000 dòng; báo rõ khi 0 dòng.

---

## 2. Features

| ID | Feature | Epic | Mô tả | UC / Screen | Stories | Ước lượng |
|----|---------|------|-------|-------------|---------|-----------|
| FE-01 | Đăng nhập / đăng xuất | EP-01 | Form đăng nhập, xử lý sai mật khẩu, khóa tạm, tài khoản khóa, session timeout | UC-AUTH-01/02 / SCR-AUTH-10 | US-001..004 | M |
| FE-02 | Đổi mật khẩu | EP-01 | Đổi mật khẩu chủ động và bắt buộc lần đầu | UC-AUTH-03 / SCR-AUTH-11 | US-005..006 | S |
| FE-03 | Quản lý tài khoản | EP-01 | Danh sách, tạo, sửa, khóa/mở khóa, đặt lại mật khẩu | UC-ADM-01 / SCR-ADM-10, 11 | US-007..010 | L |
| FE-04 | Phân quyền vai trò & guard | EP-01 | Gán Admin/User; guard route; trang 403/404 | UC-ADM-02 / SCR-ADM-10 | US-011..012 | M |
| FE-05 | Danh sách & tìm kiếm Project | EP-02 | Danh sách, tìm theo tên/mã, lọc theo trạng thái/công nghệ, phân trang | UC-PRJ-01 / SCR-PRJ-10 | US-013..014 | M |
| FE-06 | Hồ sơ Project & repository | EP-02 | Tạo/sửa thông tin, trạng thái, danh sách repository | UC-PRJ-02/03 / SCR-PRJ-11, 20 | US-015..018 | L |
| FE-07 | Thành viên Project | EP-02 | Thêm/xóa thành viên, vai trò trong dự án, ràng buộc PM | UC-PRJ-04 / SCR-PRJ-21 | US-019..021 | M |
| FE-08 | Khai báo Tech Stack | EP-03 | CRUD hạng mục công nghệ theo 5 loại kèm phiên bản | UC-TS-01/02 / SCR-PRJ-22, 23 | US-022..024 | M |
| FE-09 | Ghi nhận lỗ hổng | EP-04 | Form CVE: project, thư viện, phiên bản, mức, khuyến nghị, người phụ trách | UC-SEC-02 / SCR-SEC-11 | US-025..026 | M |
| FE-10 | Luồng xử lý lỗ hổng | EP-04 | Chuyển trạng thái có ràng buộc, lịch sử bất biến, kiểm soát chấp nhận rủi ro | UC-SEC-03/04 / SCR-SEC-11 | US-027..030 | L |
| FE-11 | Danh sách lỗ hổng | EP-04 | Toàn hệ thống + theo project, lọc mức/trạng thái, gom nhóm theo CVE | UC-SEC-01 / SCR-SEC-10, SCR-PRJ-24 | US-031..032 | M |
| FE-12 | Dashboard tổng quan | EP-05 | Cảnh báo, thống kê dự án/công nghệ/bảo mật, drill-down | UC-DASH-01 / SCR-DASH-10 | US-033 | L |
| FE-13 | Kết xuất CSV | EP-06 | Export danh sách lỗ hổng và dự án theo bộ lọc | UC-PRJ-05, UC-SEC-05 / SCR-PRJ-10, SCR-SEC-10 | US-034 | S |

> Ước lượng tương đối: **S** ≈ 1–2 ngày · **M** ≈ 3–5 ngày · **L** ≈ 6–10 ngày, cho một cặp FE+BE. `[ASSUMED]` — cần đội phát triển hiệu chỉnh.

## 3. User Stories

> Định dạng: *Là [vai trò], tôi muốn [hành động], để [giá trị]*. Mỗi story kèm tiêu chí chấp nhận GIVEN/WHEN/THEN, ưu tiên MoSCoW và mã message liên quan.

### FE-01 — Đăng nhập / đăng xuất

**US-001 — Đăng nhập thành công** · Must · SCR-AUTH-10
*Là người dùng đã được cấp tài khoản, tôi muốn đăng nhập bằng email và mật khẩu, để truy cập dữ liệu dự án và bảo mật.*
- GIVEN tài khoản `an@cty.vn` đang ở trạng thái Hoạt động và không có cờ đổi mật khẩu
- WHEN tôi nhập đúng email và mật khẩu rồi bấm "Đăng nhập"
- THEN hệ thống tạo phiên và chuyển tôi tới Dashboard, thanh điều hướng hiển thị tên và vai trò của tôi

**US-002 — Xử lý đăng nhập sai** · Must · SCR-AUTH-10 · `MSG-AUTH-001`, `MSG-AUTH-002`
*Là người dùng, tôi muốn được báo lỗi rõ ràng khi đăng nhập sai, để biết mình cần làm gì tiếp.*
- GIVEN tôi đang ở màn Đăng nhập
- WHEN tôi nhập sai mật khẩu
- THEN hệ thống hiển thị `MSG-AUTH-001` phía trên form, **không** cho biết sai email hay sai mật khẩu, và giữ nguyên email đã nhập
- GIVEN tôi đã nhập sai 4 lần trong 15 phút
- WHEN tôi nhập sai lần thứ 5
- THEN hệ thống khóa đăng nhập 15 phút và hiển thị `MSG-AUTH-002` kèm thời điểm có thể thử lại

**US-003 — Tài khoản bị khóa không đăng nhập được** · Must · SCR-AUTH-10 · `MSG-AUTH-003`
*Là quản trị viên, tôi muốn tài khoản đã khóa không thể đăng nhập, để kiểm soát người rời tổ chức.*
- GIVEN tài khoản `binh@cty.vn` ở trạng thái Khóa
- WHEN người đó nhập đúng email và mật khẩu
- THEN hệ thống từ chối và hiển thị `MSG-AUTH-003` gợi ý liên hệ quản trị viên, không tạo phiên

**US-004 — Đăng xuất và hết hạn phiên** · Must · Toàn cục · `MSG-AUTH-004`
*Là người dùng, tôi muốn kết thúc phiên khi rời máy, để dữ liệu bảo mật không bị người khác xem.*
- GIVEN tôi đang đăng nhập
- WHEN tôi bấm "Đăng xuất" trong menu tài khoản
- THEN phiên bị hủy và tôi về màn Đăng nhập; bấm nút Back của trình duyệt không vào lại được màn trong
- GIVEN tôi không thao tác 30 phút
- WHEN tôi bấm bất kỳ chức năng nào
- THEN hệ thống hiển thị `MSG-AUTH-004` và chuyển về màn Đăng nhập

### FE-02 — Đổi mật khẩu

**US-005 — Bắt buộc đổi mật khẩu ở lần đăng nhập đầu** · Must · SCR-AUTH-11
*Là quản trị viên, tôi muốn người dùng mới buộc phải đổi mật khẩu tạm, để không ai dùng lâu dài mật khẩu do người khác đặt.*
- GIVEN tài khoản của tôi vừa được Admin tạo và có cờ "phải đổi mật khẩu"
- WHEN tôi đăng nhập thành công
- THEN hệ thống đưa tôi tới màn Đổi mật khẩu và **chặn** mọi route khác cho tới khi tôi đổi xong
- WHEN tôi đặt mật khẩu mới hợp lệ và lưu
- THEN cờ được gỡ, tôi được chuyển tới Dashboard

**US-006 — Đổi mật khẩu chủ động** · Should · SCR-AUTH-11 · `MSG-VAL-001..003`
*Là người dùng, tôi muốn tự đổi mật khẩu bất cứ lúc nào, để giữ tài khoản an toàn.*
- GIVEN tôi đang đăng nhập
- WHEN tôi mở "Đổi mật khẩu" từ menu tài khoản, nhập đúng mật khẩu hiện tại và mật khẩu mới hợp lệ
- THEN mật khẩu được cập nhật và tôi thấy thông báo thành công `MSG-INF-001`
- WHEN mật khẩu mới không đủ 8 ký tự hoặc thiếu chữ hoa/thường/số
- THEN hiển thị `MSG-VAL-001` ngay dưới ô, nút Lưu bị vô hiệu hóa
- WHEN ô xác nhận không khớp
- THEN hiển thị `MSG-VAL-003` dưới ô xác nhận

### FE-03 — Quản lý tài khoản

**US-007 — Xem và tìm kiếm danh sách tài khoản** · Must · SCR-ADM-10
*Là quản trị viên, tôi muốn xem danh sách tài khoản kèm vai trò và trạng thái, để nắm ai đang có quyền gì.*
- GIVEN tôi là Admin đang ở màn Quản lý người dùng
- WHEN màn hình tải xong
- THEN tôi thấy bảng gồm email, họ tên, vai trò, trạng thái, đăng nhập gần nhất, phân trang 20 dòng
- WHEN tôi gõ một phần email vào ô tìm kiếm và lọc vai trò = Admin
- THEN danh sách chỉ còn các tài khoản khớp cả hai điều kiện

**US-008 — Tạo tài khoản mới** · Must · SCR-ADM-11 · `MSG-BIZ-061`
*Là quản trị viên, tôi muốn tạo tài khoản cho thành viên mới, để họ bắt đầu dùng hệ thống.*
- GIVEN tôi là Admin
- WHEN tôi bấm "Tạo tài khoản", nhập email, họ tên, vai trò, mật khẩu tạm và lưu
- THEN tài khoản được tạo với cờ "phải đổi mật khẩu", xuất hiện đầu danh sách, và tôi thấy `MSG-INF-002`
- WHEN email đã tồn tại
- THEN hiển thị `MSG-BIZ-061` inline dưới ô email và không gọi lưu lần nữa

**US-009 — Khóa và mở khóa tài khoản** · Must · SCR-ADM-10 · `MSG-BIZ-060`
*Là quản trị viên, tôi muốn khóa tài khoản người đã rời tổ chức, để chặn truy cập nhưng vẫn giữ lịch sử của họ.*
- GIVEN tài khoản `binh@cty.vn` đang Hoạt động và là thành viên của 3 dự án
- WHEN tôi bấm "Khóa" và xác nhận
- THEN trạng thái chuyển sang Khóa, người đó không đăng nhập được, nhưng tên vẫn còn trong danh sách thành viên và lịch sử lỗ hổng
- GIVEN tôi là Admin hoạt động **cuối cùng** của hệ thống
- WHEN tôi cố khóa chính mình
- THEN hệ thống chặn và hiển thị `MSG-BIZ-060`

**US-010 — Đặt lại mật khẩu cho người dùng** · Should · SCR-ADM-11
*Là quản trị viên, tôi muốn đặt lại mật khẩu khi người dùng quên, để họ vào lại được mà không cần hạ tầng email.*
- GIVEN tôi đang mở tài khoản của một người dùng
- WHEN tôi bấm "Đặt lại mật khẩu", nhập mật khẩu tạm và xác nhận
- THEN mật khẩu được đặt lại, cờ "phải đổi mật khẩu" được bật, và hệ thống hiển thị mật khẩu tạm **một lần duy nhất** để tôi chuyển cho người dùng

### FE-04 — Phân quyền vai trò & guard

**US-011 — Gán vai trò hệ thống** · Must · SCR-ADM-11 · `MSG-BIZ-060`
*Là quản trị viên, tôi muốn nâng hoặc hạ vai trò của một tài khoản, để quyền khớp với trách nhiệm thực tế.*
- GIVEN tài khoản `an@cty.vn` đang là User
- WHEN tôi đổi vai trò thành Admin và lưu
- THEN người đó truy cập được màn Quản trị ngay ở phiên đăng nhập tiếp theo
- GIVEN chỉ còn một Admin hoạt động
- WHEN tôi hạ vai trò của người đó xuống User
- THEN hệ thống chặn và hiển thị `MSG-BIZ-060`

**US-012 — Chặn truy cập không đủ quyền** · Must · Toàn cục · `MSG-AUTH-005`, `MSG-NF-001`
*Là chủ hệ thống, tôi muốn người dùng thường không vào được màn quản trị dù gõ URL trực tiếp, để bảo vệ dữ liệu tài khoản.*
- GIVEN tôi đăng nhập với vai trò User
- WHEN tôi gõ trực tiếp `/admin/users`
- THEN hệ thống hiển thị **trang 403** với `MSG-AUTH-005` và nút "Về Dashboard" — không chuyển hướng âm thầm
- WHEN tôi mở `/projects/99999` (không tồn tại)
- THEN hệ thống hiển thị **trang 404** với `MSG-NF-001` và nút quay lại danh sách

### FE-05 — Danh sách & tìm kiếm Project

**US-013 — Tra cứu dự án** · Must · SCR-PRJ-10
*Là kỹ sư, tôi muốn tìm nhanh một dự án theo tên hoặc mã, để mở hồ sơ của nó mà không phải cuộn cả danh sách.*
- GIVEN hệ thống có 200 dự án
- WHEN tôi gõ "thanh toán" vào ô tìm kiếm
- THEN danh sách chỉ hiển thị các dự án có tên hoặc mã chứa chuỗi đó, không phân biệt hoa/thường và dấu tiếng Việt `[ASSUMED]`
- WHEN không có dự án nào khớp
- THEN hiển thị trạng thái rỗng `MSG-INF-030` kèm nút xóa bộ lọc

**US-014 — Lọc theo trạng thái và công nghệ** · Must · SCR-PRJ-10
*Là quản lý kỹ thuật, tôi muốn lọc dự án đang vận hành dùng một công nghệ cụ thể, để đánh giá phạm vi ảnh hưởng khi công nghệ đó có vấn đề.*
- GIVEN tôi đang ở danh sách dự án
- WHEN tôi chọn trạng thái = "Đang vận hành" và công nghệ = "Spring Boot"
- THEN danh sách chỉ còn các dự án thỏa cả hai, và bộ lọc được giữ khi tôi mở một dự án rồi bấm quay lại

### FE-06 — Hồ sơ Project & repository

**US-015 — Tạo dự án mới** · Must · SCR-PRJ-11 · `MSG-BIZ-001`, `MSG-BIZ-002`
*Là PM, tôi muốn tạo hồ sơ dự án mới, để bắt đầu quản lý tech stack và bảo mật của nó.*
- GIVEN tôi đã đăng nhập
- WHEN tôi bấm "Tạo dự án", nhập mã `PAYGW`, tên "Cổng thanh toán", chọn trạng thái và lưu
- THEN dự án được tạo, tôi tự động là thành viên với vai trò PM, và hệ thống chuyển tôi tới màn chi tiết
- WHEN mã hoặc tên đã tồn tại
- THEN hiển thị `MSG-BIZ-001` / `MSG-BIZ-002` inline dưới trường tương ứng

**US-016 — Quản lý repository của dự án** · Must · SCR-PRJ-11
*Là Dev, tôi muốn ghi các đường dẫn repository của dự án, để người mới biết mã nguồn nằm ở đâu.*
- GIVEN tôi đang sửa một dự án mình là thành viên
- WHEN tôi bấm "Thêm repository", nhập tên và URL rồi lưu
- THEN repository xuất hiện trong bảng ở màn chi tiết dưới dạng liên kết mở tab mới
- WHEN URL không có scheme `http`/`https`
- THEN hiển thị `MSG-VAL-010` inline và chặn lưu

**US-017 — Xem chi tiết dự án** · Must · SCR-PRJ-20
*Là kỹ sư, tôi muốn xem toàn bộ hồ sơ một dự án ở một chỗ, để không phải hỏi từng người.*
- GIVEN dự án `PAYGW` tồn tại
- WHEN tôi mở màn chi tiết
- THEN tôi thấy thông tin chung, danh sách repository, và bốn tab với số đếm: Thành viên (n), Tech Stack (n), Bảo mật (n lỗ hổng còn mở)
- WHEN tôi không phải thành viên
- THEN nút "Sửa" không hiển thị nhưng mọi nội dung vẫn đọc được

**US-018 — Kết thúc dự án có kiểm soát** · Must · SCR-PRJ-11 · `MSG-BIZ-003`
*Là PM, tôi muốn không thể đóng dự án khi còn lỗ hổng chưa xử lý, để rủi ro không bị bỏ quên khi dự án khép lại.*
- GIVEN dự án `PAYGW` còn 3 lỗ hổng ở trạng thái Mới hoặc Đang xử lý
- WHEN tôi đổi trạng thái sang "Kết thúc" và lưu
- THEN hệ thống chặn, hiển thị `MSG-BIZ-003` kèm số 3 và liên kết "Xem 3 lỗ hổng còn mở"
- GIVEN tôi đã xử lý hoặc chấp nhận rủi ro cả 3
- WHEN tôi lưu lại với trạng thái "Kết thúc" và ngày kết thúc
- THEN dự án được đóng và biến mất khỏi số liệu Dashboard mặc định

### FE-07 — Thành viên Project

**US-019 — Thêm thành viên vào dự án** · Must · SCR-PRJ-21 · `MSG-BIZ-052`
*Là PM, tôi muốn thêm người vào dự án kèm vai trò, để họ có quyền cập nhật dữ liệu dự án.*
- GIVEN tôi là thành viên của dự án
- WHEN tôi bấm "Thêm thành viên", chọn một tài khoản Hoạt động, chọn vai trò Dev và lưu
- THEN người đó xuất hiện trong bảng và ngay lập tức có quyền ghi trên dự án
- WHEN tôi chọn người đã là thành viên
- THEN hiển thị `MSG-BIZ-052` và không cho lưu; tài khoản Khóa không xuất hiện trong danh sách chọn

**US-020 — Giữ ít nhất một PM** · Must · SCR-PRJ-21 · `MSG-BIZ-051`
*Là chủ hệ thống, tôi muốn mỗi dự án luôn có người chịu trách nhiệm, để không có dự án vô chủ.*
- GIVEN dự án chỉ có một thành viên vai trò PM
- WHEN tôi xóa người đó hoặc đổi vai trò của họ sang Dev
- THEN hệ thống chặn và hiển thị `MSG-BIZ-051`

**US-021 — Chặn xóa thành viên đang phụ trách lỗ hổng** · Must · SCR-PRJ-21 · `MSG-BIZ-050`
*Là PM, tôi muốn không xóa nhầm người đang phụ trách một lỗ hổng chưa đóng, để việc xử lý không bị mất người chịu trách nhiệm.*
- GIVEN `an@cty.vn` đang phụ trách 2 lỗ hổng ở trạng thái Đang xử lý của dự án này
- WHEN tôi xóa `an@cty.vn` khỏi dự án
- THEN hệ thống chặn, hiển thị `MSG-BIZ-050` kèm danh sách 2 lỗ hổng và liên kết để gán người khác

### FE-08 — Khai báo Tech Stack

**US-022 — Xem tech stack theo loại** · Must · SCR-PRJ-22
*Là kỹ sư, tôi muốn thấy công nghệ của dự án nhóm theo loại, để nắm nhanh bức tranh kỹ thuật.*
- GIVEN dự án có 12 hạng mục công nghệ
- WHEN tôi mở tab Tech Stack
- THEN các hạng mục hiển thị theo 5 nhóm (Ngôn ngữ, Framework, Database, Cache, Cloud) kèm tên, phiên bản, ghi chú, người và thời điểm sửa cuối
- WHEN dự án chưa khai báo gì
- THEN hiển thị trạng thái rỗng `MSG-INF-031` kèm nút "Thêm hạng mục" (nếu tôi có quyền ghi)

**US-023 — Thêm và sửa hạng mục công nghệ** · Must · SCR-PRJ-23 · `MSG-BIZ-010`
*Là Dev, tôi muốn khai báo công nghệ và phiên bản dự án đang dùng, để khi có CVE mọi người tra ra ngay.*
- GIVEN tôi là thành viên dự án và đang ở tab Tech Stack
- WHEN tôi bấm "Thêm hạng mục", chọn loại Framework, nhập "Spring Boot" phiên bản "3.2.1" và lưu
- THEN popup đóng, bảng làm mới, hạng mục xuất hiện trong nhóm Framework
- WHEN dự án đã có hạng mục Framework tên "spring boot"
- THEN hiển thị `MSG-BIZ-010` inline dưới ô Tên công nghệ (so sánh không phân biệt hoa/thường)

**US-024 — Gỡ hạng mục công nghệ** · Should · SCR-PRJ-22 · `MSG-BIZ-011`
*Là Dev, tôi muốn gỡ công nghệ không còn dùng, để dữ liệu phản ánh đúng hiện trạng.*
- GIVEN tôi là thành viên dự án
- WHEN tôi bấm biểu tượng xóa trên một dòng
- THEN hiện hộp thoại xác nhận `MSG-INF-010`; xác nhận thì hạng mục bị gỡ
- GIVEN hạng mục đó trùng tên với thư viện của một lỗ hổng chưa đóng
- WHEN tôi xác nhận gỡ
- THEN hệ thống hiển thị cảnh báo `MSG-BIZ-011` nhưng **vẫn cho** tiếp tục

### FE-09 — Ghi nhận lỗ hổng

**US-025 — Ghi nhận một CVE mới** · Must · SCR-SEC-11 · `MSG-VAL-020`, `MSG-BIZ-030`
*Là kỹ sư, tôi muốn ghi nhận lỗ hổng vừa phát hiện, để nó được theo dõi thay vì nằm trong email.*
- GIVEN tôi là thành viên dự án `PAYGW`
- WHEN tôi nhập `CVE-2024-12345`, thư viện "log4j-core", phiên bản "2.14.1", mức Critical, khuyến nghị "Nâng lên 2.17.1 trở lên" và lưu
- THEN bản ghi được tạo với trạng thái "Mới", một dòng lịch sử đầu tiên được ghi, và tôi thấy màn chi tiết
- WHEN mã CVE sai định dạng
- THEN hiển thị `MSG-VAL-020` inline
- WHEN dự án đã có bản ghi cùng CVE và cùng thư viện
- THEN hiển thị `MSG-BIZ-030` kèm liên kết tới bản ghi đã có

**US-026 — Ghi nhận từ ngữ cảnh dự án** · Should · SCR-PRJ-24 · `MSG-BIZ-032`
*Là kỹ sư, tôi muốn ghi nhận lỗ hổng ngay từ tab Bảo mật của dự án, để không phải chọn lại dự án.*
- GIVEN tôi đang ở tab Bảo mật của dự án `PAYGW`
- WHEN tôi bấm "Ghi nhận lỗ hổng"
- THEN màn tạo mở ra với trường Dự án đã điền sẵn `PAYGW` và ở chế độ chỉ đọc
- GIVEN dự án `PAYGW` ở trạng thái "Kết thúc"
- WHEN tôi mở tab Bảo mật
- THEN nút "Ghi nhận lỗ hổng" không hiển thị; gọi URL trực tiếp trả về `MSG-BIZ-032`

### FE-10 — Luồng xử lý lỗ hổng

**US-027 — Chuyển trạng thái theo luồng hợp lệ** · Must · SCR-SEC-11 · `MSG-BIZ-040`
*Là người phụ trách, tôi muốn cập nhật tiến độ xử lý lỗ hổng, để mọi người biết việc đang tới đâu.*
- GIVEN lỗ hổng đang ở trạng thái "Mới"
- WHEN tôi bấm "Chuyển trạng thái"
- THEN chỉ các trạng thái đích hợp lệ theo sơ đồ BU §5.1 xuất hiện — "Mới" không bao giờ là lựa chọn
- WHEN tôi chọn "Đang xử lý" mà chưa chọn người phụ trách
- THEN hiển thị `MSG-VAL-033` và chặn xác nhận

**US-028 — Đóng lỗ hổng bằng cách xử lý** · Must · SCR-SEC-11 · `MSG-VAL-030`, `MSG-VAL-031`, `MSG-INF-020`
*Là người phụ trách, tôi muốn ghi lại cách mình đã xử lý lỗ hổng, để lần sau gặp lại có căn cứ.*
- GIVEN lỗ hổng đang "Đang xử lý", ngày ghi nhận 01/08/2026
- WHEN tôi chọn "Đã xử lý", nhập ngày 20/08/2026 và ghi chú "Đã nâng log4j lên 2.17.1"
- THEN trạng thái được cập nhật, một dòng lịch sử được ghi, và hệ thống hiển thị `MSG-INF-020` nhắc cập nhật phiên bản trong tab Tech Stack kèm liên kết
- WHEN tôi nhập ngày xử lý 25/07/2026 (trước ngày ghi nhận)
- THEN hiển thị `MSG-VAL-030` inline và chặn
- WHEN tôi bỏ trống ghi chú
- THEN hiển thị `MSG-VAL-031` và chặn

**US-029 — Chấp nhận rủi ro có kiểm soát** · Must · SCR-SEC-11 · `MSG-VAL-032`, `MSG-AUTH-006`
*Là chủ hệ thống, tôi muốn rủi ro nghiêm trọng chỉ được chấp nhận bởi quản trị viên và luôn có lý do, để không ai âm thầm đóng sổ một lỗ hổng lớn.*
- GIVEN lỗ hổng mức Medium và tôi là thành viên dự án
- WHEN tôi chọn "Chấp nhận rủi ro" và nhập lý do
- THEN trạng thái được cập nhật cùng lý do và một dòng lịch sử
- WHEN tôi bỏ trống lý do
- THEN hiển thị `MSG-VAL-032` và chặn
- GIVEN lỗ hổng mức Critical và tôi **không phải** Admin
- WHEN tôi mở danh sách trạng thái đích
- THEN "Chấp nhận rủi ro" hiển thị nhưng **bị vô hiệu hóa** kèm tooltip giải thích; gọi API trực tiếp trả `MSG-AUTH-006`

**US-030 — Xem lịch sử xử lý** · Should · SCR-SEC-11
*Là quản lý, tôi muốn xem ai đã chuyển trạng thái gì và vì sao, để truy vết trách nhiệm khi cần.*
- GIVEN lỗ hổng đã qua 3 lần chuyển trạng thái
- WHEN tôi mở phần "Lịch sử xử lý" ở màn chi tiết
- THEN tôi thấy 4 dòng (gồm dòng ghi nhận ban đầu) theo thứ tự mới nhất trước, mỗi dòng có trạng thái cũ → mới, người thực hiện, thời điểm và ghi chú
- WHEN tôi tìm nút sửa hoặc xóa một dòng lịch sử
- THEN không có nút nào — lịch sử là bất biến với mọi vai trò

### FE-11 — Danh sách lỗ hổng

**US-031 — Lọc lỗ hổng toàn hệ thống** · Must · SCR-SEC-10
*Là quản lý kỹ thuật, tôi muốn lọc mọi lỗ hổng Critical còn mở của toàn tổ chức, để biết cần thúc dự án nào trước.*
- GIVEN hệ thống có 5.000 bản ghi lỗ hổng
- WHEN tôi chọn mức = Critical và trạng thái = Mới + Đang xử lý
- THEN danh sách hiển thị đúng tập kết quả, sắp xếp mặc định theo số ngày còn mở giảm dần, phân trang 20 dòng, tổng số kết quả hiển thị rõ
- WHEN tôi bấm một dòng
- THEN mở màn chi tiết; bấm quay lại giữ nguyên bộ lọc và số trang

**US-032 — Gom nhóm theo CVE** · Should · SCR-SEC-10
*Là quản lý kỹ thuật, tôi muốn thấy một CVE ảnh hưởng bao nhiêu dự án, để ưu tiên xử lý theo diện rộng.*
- GIVEN `CVE-2024-12345` được ghi nhận ở 7 dự án
- WHEN tôi bật chế độ "Gom nhóm theo CVE"
- THEN danh sách hiển thị một dòng cho CVE đó với số dự án bị ảnh hưởng và phân bố trạng thái xử lý
- WHEN tôi mở rộng dòng
- THEN thấy 7 dòng con, mỗi dòng là một dự án kèm trạng thái riêng

### FE-12 — Dashboard

**US-033 — Nắm tình hình trong một màn** · Must · SCR-DASH-10 · `MSG-INF-042`
*Là quản lý kỹ thuật, tôi muốn một màn tổng quan, để không phải tổng hợp thủ công từ nhiều nguồn.*
- GIVEN tôi vừa đăng nhập
- WHEN Dashboard tải xong
- THEN tôi thấy ô cảnh báo (số lỗ hổng Critical còn mở, số lỗ hổng quá hạn 30 ngày), thống kê dự án theo trạng thái, phân bố công nghệ, và lỗ hổng theo mức × trạng thái
- WHEN tôi bấm ô "Critical còn mở"
- THEN hệ thống mở danh sách lỗ hổng với bộ lọc mức = Critical và trạng thái = còn mở đã áp sẵn
- WHEN tôi bật "Bao gồm dự án đã kết thúc"
- THEN mọi số liệu tính lại và ghi chú dưới mỗi khối đổi tương ứng
- WHEN một khối lỗi khi tổng hợp
- THEN chỉ khối đó hiển thị lỗi kèm nút "Thử lại", các khối còn lại vẫn hiển thị bình thường
- WHEN hệ thống chưa có dự án nào
- THEN mỗi khối hiển thị trạng thái rỗng riêng (MSG-INF-042..045), không hiển thị số 0 gây hiểu nhầm

### FE-13 — Kết xuất CSV

**US-034 — Kết xuất danh sách ra CSV** · Should · SCR-SEC-10, SCR-PRJ-10 · `MSG-BIZ-070`, `MSG-BIZ-071`
*Là quản lý, tôi muốn tải danh sách đang lọc ra CSV, để đưa vào báo cáo tháng.*
- GIVEN tôi đã lọc danh sách lỗ hổng còn 320 kết quả và đang xem trang 1
- WHEN tôi bấm "Kết xuất CSV"
- THEN tệp tải về chứa đủ **320 dòng** (không phải 20 dòng của trang hiện tại), tên tệp dạng `vulnerabilities_YYYYMMDD_HHMMSS.csv`
- WHEN tôi mở tệp bằng Excel
- THEN tiếng Việt hiển thị đúng (UTF-8 có BOM) và mỗi bản ghi nằm trên một dòng (CRLF)
- WHEN bộ lọc cho hơn 10.000 kết quả
- THEN hệ thống hiển thị `MSG-BIZ-070` và không tạo tệp
- WHEN bộ lọc cho 0 kết quả
- THEN hệ thống hiển thị `MSG-BIZ-071` và không tạo tệp

## 4. Thứ tự phát triển đề xuất

| Đợt | Nội dung | Lý do |
|---|---|---|
| 1 | FE-01, FE-02, FE-03, FE-04 | Không có xác thực và phân quyền thì không kiểm thử được gì khác |
| 2 | FE-05, FE-06, FE-07 | Project là gốc của mọi dữ liệu còn lại |
| 3 | FE-08 | Tech Stack phụ thuộc Project |
| 4 | FE-09, FE-10, FE-11 | Khối giá trị chính; phụ thuộc Project và tài khoản |
| 5 | FE-12, FE-13 | Chỉ có ý nghĩa khi đã có dữ liệu thật |

## 5. Traceability tóm tắt

| Epic | Use cases | Screens | Entities chính | Stories |
|------|-----------|---------|-----------------|---------|
| EP-01 | UC-AUTH-01/02/03, UC-ADM-01/02 | SCR-AUTH-10/11, SCR-ADM-10/11 | User | US-001..012 |
| EP-02 | UC-PRJ-01..04 | SCR-PRJ-10/11/20/21 | Project, Repository, ProjectMember | US-013..021 |
| EP-03 | UC-TS-01/02 | SCR-PRJ-22/23 | TechStackItem | US-022..024 |
| EP-04 | UC-SEC-01..04 | SCR-SEC-10/11, SCR-PRJ-24 | Vulnerability, VulnerabilityStatusHistory | US-025..032 |
| EP-05 | UC-DASH-01 | SCR-DASH-10 | (tổng hợp từ tất cả) | US-033 |
| EP-06 | UC-PRJ-05, UC-SEC-05 | SCR-PRJ-10, SCR-SEC-10 | Project, Vulnerability | US-034 |

**Last Updated**: 2026-08-26

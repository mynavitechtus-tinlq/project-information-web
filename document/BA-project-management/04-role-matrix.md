# Business Role Matrix — Hệ thống Quản lý Dự án, Tech Stack & Bảo mật

> **Phase**: Design — Foundation | **Trạng thái**: Draft v0.2 — chờ BU verify
> **Upstream**: `01-business-understanding.md` (v0.2), `02-usecase-overview.md` (v0.2)
> **Thay đổi v0.1 → v0.2**: ASM-RM-001/002 và Q-RM-01 đã được chốt (DEC-03, DEC-09); bổ sung khái niệm **quyền theo tư cách thành viên** như một chiều phân quyền thứ hai; bổ sung ma trận quyền chi tiết theo hành động và ma trận truy cập màn hình.

---

## 1. Scope and Principles

Phân quyền của hệ thống được xác định bởi **hai chiều độc lập**, cả hai đều phải thỏa mãn thì hành động mới được phép:

1. **Vai trò hệ thống** — `Admin` hoặc `User`. Quyết định quyền quản trị (tài khoản, phân quyền) và quyền vượt rào (Admin ghi được mọi Project).
2. **Tư cách thành viên Project** — người dùng có phải thành viên (`ProjectMember`) của Project đang thao tác hay không. Quyết định quyền **ghi** dữ liệu của Project đó.

Nguyên tắc đã chốt:

- **Đọc là toàn cục**: mọi người dùng đã đăng nhập đọc được toàn bộ Project, Tech Stack, lỗ hổng và Dashboard `[DECIDED — DEC-03]`.
- **Ghi bị giới hạn theo tư cách thành viên**: User chỉ ghi được dữ liệu Project mình tham gia; Admin ghi được mọi Project `[DECIDED — DEC-03]`.
- **Tạo Project là quyền phổ thông**: User được tạo Project mới và tự động trở thành PM của Project đó `[DECIDED — DEC-03]`.
- **Vai trò trong dự án (PM / Tech Lead / Dev / QA / Khác) không tạo lớp quyền riêng** ở giai đoạn 1 — chỉ dùng để ghi nhận trách nhiệm và ràng buộc "luôn còn ≥1 PM" `[ASSUMED — ASM-RM-003]`.
- **Một ngoại lệ theo mức nghiêm trọng**: chấp nhận rủi ro cho lỗ hổng Critical/High chỉ Admin thực hiện được `[DECIDED — DEC-09]`.

## 2. Role Inventory

| Role ID | Business Role                           | Mapped Actor(s) | Description                                                                                   | Số lượng | Status                             |
| ------- | --------------------------------------- | --------------- | --------------------------------------------------------------------------------------------- | -------- | ---------------------------------- |
| RM-001  | Admin                                   | Admin           | Quản trị hệ thống, toàn quyền trên mọi dữ liệu, người duy nhất chấp nhận rủi ro Critical/High | ~5       | Active                             |
| RM-002  | User — thành viên Project               | User            | Đọc toàn hệ thống; ghi dữ liệu của các Project mình là thành viên                             | ~145     | Active                             |
| RM-002a | User — không phải thành viên (ngữ cảnh) | User            | Cùng tài khoản RM-002 nhưng đang xem Project mình **không** tham gia: chỉ đọc                 | —        | Ngữ cảnh, không phải vai trò riêng |

> RM-002 và RM-002a là **cùng một tài khoản**; khác nhau ở ngữ cảnh Project đang mở. Screen Spec dùng cách gọi "người dùng có quyền ghi trên Project" để chỉ RM-001 hoặc RM-002.

## 3. Role Permission Matrix

| Role ID      | Related Use Cases                                                       | Main Actions Allowed                                                                                                                                | Restricted Actions                                                                                                                             | Data Scope                              | Approval Authority                  | SoD Constraints                                                           | Related Screens                   |
| ------------ | ----------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------- | ----------------------------------- | ------------------------------------------------------------------------- | --------------------------------- |
| RM-001 Admin | Toàn bộ UC                                                              | Quản lý tài khoản/phân quyền; CRUD Project, thành viên, tech stack, lỗ hổng trên **mọi** Project; chấp nhận rủi ro mọi mức; sửa Project đã Kết thúc | Không xóa lỗ hổng (BR-13); không xóa/sửa lịch sử trạng thái (BR-14)                                                                            | Global (đọc + ghi)                      | Có — chấp nhận rủi ro Critical/High | Không tự khóa hoặc tự hạ vai trò khi là Admin hoạt động cuối cùng (BR-05) | Tất cả 14 màn                     |
| RM-002 User  | UC-AUTH-01/02/03, UC-PRJ-01..05, UC-TS-01/02, UC-SEC-01..05, UC-DASH-01 | Đọc toàn hệ thống; tạo Project mới; ghi dữ liệu Project mình tham gia; chấp nhận rủi ro Medium/Low                                                  | Không truy cập quản lý tài khoản/phân quyền; không ghi dữ liệu Project không tham gia; không chấp nhận rủi ro Critical/High; không xóa lỗ hổng | Đọc: Global. Ghi: Project là thành viên | Không                               | Không                                                                     | Tất cả trừ SCR-ADM-10, SCR-ADM-11 |

## 4. Ma trận quyền theo hành động

Ký hiệu: **✔** cho phép · **✖** không cho phép · **TV** chỉ khi là thành viên Project · **—** không áp dụng

| #   | Hành động                                                  | Admin | User (thành viên) | User (không thành viên) | Ràng buộc bổ sung                             |
| --- | ---------------------------------------------------------- | ----- | ----------------- | ----------------------- | --------------------------------------------- |
| 1   | Đăng nhập / đăng xuất / đổi mật khẩu của mình              | ✔     | ✔                 | ✔                       | BR-20..22                                     |
| 2   | Tạo tài khoản người dùng                                   | ✔     | ✖                 | ✖                       | BR-01                                         |
| 3   | Sửa thông tin tài khoản người khác                         | ✔     | ✖                 | ✖                       | BR-01                                         |
| 4   | Khóa / mở khóa tài khoản                                   | ✔     | ✖                 | ✖                       | BR-01, BR-05                                  |
| 5   | Đặt lại mật khẩu người khác                                | ✔     | ✖                 | ✖                       | Đặt cờ `must_change_password`                 |
| 6   | Gán / đổi vai trò hệ thống                                 | ✔     | ✖                 | ✖                       | BR-01, BR-05                                  |
| 7   | Xem danh sách & chi tiết Project                           | ✔     | ✔                 | ✔                       | BR-03                                         |
| 8   | Tạo Project mới                                            | ✔     | ✔                 | ✔                       | BR-04 — người tạo thành PM                    |
| 9   | Sửa thông tin Project                                      | ✔     | TV                | ✖                       | BR-02; Project `Kết thúc` chỉ Admin           |
| 10  | Thêm / sửa / xóa repository                                | ✔     | TV                | ✖                       | BR-02, BR-10                                  |
| 11  | Thêm / xóa thành viên, đổi vai trò trong dự án             | ✔     | TV                | ✖                       | BR-08 — luôn còn ≥1 PM                        |
| 12  | Xem Tech Stack                                             | ✔     | ✔                 | ✔                       | BR-03                                         |
| 13  | Thêm / sửa / gỡ hạng mục Tech Stack                        | ✔     | TV                | ✖                       | BR-02, BR-09                                  |
| 14  | Xem danh sách & chi tiết lỗ hổng                           | ✔     | ✔                 | ✔                       | BR-03                                         |
| 15  | Ghi nhận lỗ hổng mới                                       | ✔     | TV                | ✖                       | BR-02; Project `Kết thúc` → ✖ cả hai          |
| 16  | Sửa nội dung lỗ hổng (thư viện, mức, khuyến nghị)          | ✔     | TV                | ✖                       | BR-02                                         |
| 17  | Chuyển trạng thái → Đang xử lý / Đã xử lý                  | ✔     | TV                | ✖                       | R-ENT-002, R-ENT-007                          |
| 18  | Chuyển trạng thái → Chấp nhận rủi ro (**Medium / Low**)    | ✔     | TV                | ✖                       | Bắt buộc lý do (R-ENT-004)                    |
| 19  | Chuyển trạng thái → Chấp nhận rủi ro (**Critical / High**) | ✔     | **✖**             | ✖                       | **BR-15 / DEC-09** — điểm khác biệt then chốt |
| 20  | Mở lại lỗ hổng đã đóng                                     | ✔     | TV                | ✖                       | Bắt buộc lý do                                |
| 21  | Xóa lỗ hổng                                                | ✖     | ✖                 | ✖                       | BR-13 — không ai được xóa                     |
| 22  | Sửa / xóa lịch sử trạng thái                               | ✖     | ✖                 | ✖                       | BR-14 — bất biến                              |
| 23  | Xem lịch sử trạng thái lỗ hổng                             | ✔     | ✔                 | ✔                       | BR-03                                         |
| 24  | Xem Dashboard                                              | ✔     | ✔                 | ✔                       | BR-03                                         |
| 25  | Kết xuất CSV (Project / lỗ hổng)                           | ✔     | ✔                 | ✔                       | DEC-06                                        |
| 26  | Chuyển Project sang `Kết thúc`                             | ✔     | TV                | ✖                       | BR-18 — chặn nếu còn lỗ hổng mở               |
| 27  | Xóa Project                                                | ✖     | ✖                 | ✖                       | Không có chức năng ở giai đoạn 1              |

## 5. Ma trận truy cập màn hình

| Screen ID   | Tên màn                          | Admin  | User             | Loại guard                         | Hành vi khi không đủ quyền                                                                                                       |
| ----------- | -------------------------------- | ------ | ---------------- | ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| SCR-AUTH-10 | Đăng nhập                        | Public | Public           | Không                              | —                                                                                                                                |
| SCR-AUTH-11 | Đổi mật khẩu                     | ✔      | ✔                | Route guard — đã đăng nhập         | Chuyển về Đăng nhập                                                                                                              |
| SCR-DASH-10 | Dashboard                        | ✔      | ✔                | Route guard — đã đăng nhập         | Chuyển về Đăng nhập                                                                                                              |
| SCR-PRJ-10  | Danh sách Project                | ✔      | ✔                | Route guard — đã đăng nhập         | Chuyển về Đăng nhập                                                                                                              |
| SCR-PRJ-11  | Tạo / Sửa Project                | ✔      | Tạo: ✔ · Sửa: TV | Route guard + client-side computed | Sửa không đủ quyền → trang 403 `MSG-AUTH-005`                                                                                    |
| SCR-PRJ-20  | Chi tiết Project — tab Thông tin | ✔      | ✔                | Route guard                        | —                                                                                                                                |
| SCR-PRJ-21  | Tab Thành viên                   | ✔      | Đọc: ✔ · Ghi: TV | Client-side computed               | Nút Thêm/Xóa **ẩn** khi không đủ quyền `[PERMISSION-CLIENT]`                                                                     |
| SCR-PRJ-22  | Tab Tech Stack                   | ✔      | Đọc: ✔ · Ghi: TV | Client-side computed               | Nút Thêm/Sửa/Gỡ **ẩn**                                                                                                           |
| SCR-PRJ-23  | Popup hạng mục công nghệ         | ✔      | TV               | Client-side computed               | Không mở được vì nút gọi nó đã ẩn                                                                                                |
| SCR-PRJ-24  | Tab Security theo Project        | ✔      | Đọc: ✔ · Ghi: TV | Client-side computed               | Nút "Ghi nhận lỗ hổng" **ẩn**                                                                                                    |
| SCR-SEC-10  | Danh sách lỗ hổng toàn hệ thống  | ✔      | ✔                | Route guard                        | —                                                                                                                                |
| SCR-SEC-11  | Chi tiết / Tạo lỗ hổng           | ✔      | Đọc: ✔ · Ghi: TV | Route guard + client-side computed | Nút sửa/chuyển trạng thái **ẩn**; nút "Chấp nhận rủi ro" với Critical/High **hiển thị nhưng vô hiệu hóa** kèm tooltip giải thích |
| SCR-ADM-10  | Quản lý người dùng               | ✔      | **✖**            | **Route guard — Admin only**       | Trang 403 `MSG-AUTH-005`, không chuyển hướng âm thầm (EC-07)                                                                     |
| SCR-ADM-11  | Popup tạo/sửa tài khoản          | ✔      | **✖**            | Route guard — Admin only           | Không mở được                                                                                                                    |

> **Quy ước UX về ẩn vs vô hiệu hóa**: hành động người dùng **không bao giờ** có thể thực hiện ở màn đó thì **ẩn** (giảm nhiễu). Hành động người dùng **có thể** thực hiện trong hoàn cảnh khác thì **vô hiệu hóa kèm tooltip** — ví dụ nút "Chấp nhận rủi ro" với lỗ hổng Critical hiển thị mờ kèm tooltip "Chỉ quản trị viên được chấp nhận rủi ro cho lỗ hổng Critical/High", để người dùng hiểu phải nhờ ai.

## 6. Role Detail (By Role)

### RM-001: Admin

- **Business purpose**: Đảm bảo hệ thống có người kiểm soát tài khoản, dữ liệu chuẩn và xử lý ngoại lệ; là chốt chặn cuối cùng trước khi một rủi ro nghiêm trọng bị chấp nhận.
- **Allowed actions**: Toàn bộ hành động 1–20 và 23–26 ở §4.
- **Restricted actions**: Không xóa lỗ hổng (21), không sửa lịch sử (22), không xóa Project (27), không tự khóa/hạ quyền khi là Admin cuối cùng (BR-05).
- **Data access scope**: Toàn hệ thống, đọc và ghi.
- **Approval rights**: Quyết định cuối với "Chấp nhận rủi ro" của lỗ hổng Critical/High `[DECIDED — DEC-09]`.
- **Exception handling**: Gán lại người phụ trách khi thành viên rời dự án (EC-03); sửa dữ liệu Project đã Kết thúc khi cần đính chính.
- **Related Use Cases**: Tất cả. **Related Screens**: Tất cả 14 màn.

### RM-002: User

- **Business purpose**: Cho phép kỹ sư/PM tự quản lý dữ liệu dự án của mình mà không phải qua quản trị viên, đồng thời tra cứu được toàn hệ thống để biết công nghệ nào đang có rủi ro ở đâu.
- **Allowed actions**: 1, 7, 8, 12, 14, 23, 24, 25 ở mọi ngữ cảnh; 9, 10, 11, 13, 15, 16, 17, 18, 20, 26 khi là thành viên Project.
- **Restricted actions**: 2–6 (quản trị tài khoản), 19 (chấp nhận rủi ro Critical/High), 21, 22, 27; mọi hành động ghi trên Project không tham gia.
- **Data access scope**: Đọc toàn hệ thống. Ghi: các Project có bản ghi `ProjectMember` tương ứng.
- **Approval rights**: Không.
- **Exception handling**: Cần sửa dữ liệu Project khác → liên hệ PM của Project đó hoặc Admin. Cần chấp nhận rủi ro Critical/High → đề nghị Admin, ghi bối cảnh vào ghi chú lỗ hổng trước.
- **Related Use Cases**: Tất cả trừ UC-ADM-01/02. **Related Screens**: Tất cả trừ SCR-ADM-10/11.

## 7. Open Questions and Assumptions

| ID         | Type       | Statement                                                                                                     | Impact | Status                                     | Ghi chú                                                     |
| ---------- | ---------- | ------------------------------------------------------------------------------------------------------------- | ------ | ------------------------------------------ | ----------------------------------------------------------- |
| ASM-RM-001 | Assumption | User được **đọc** mọi Project trong hệ thống, chỉ giới hạn quyền **ghi**                                      | High   | **Chốt tại DEC-03**                        | Chờ khách hàng xác nhận                                     |
| ASM-RM-002 | Assumption | User được phép tạo Project mới và tự động trở thành PM                                                        | Medium | **Chốt tại DEC-03**                        | Chờ khách hàng xác nhận                                     |
| ASM-RM-003 | Assumption | Vai trò trong dự án (PM/Tech Lead/Dev/QA) không tạo lớp quyền riêng ở giai đoạn 1                             | Medium | Pending Confirmation                       | Nếu bị bác → phát sinh lớp quyền thứ ba, ảnh hưởng §4 và §5 |
| Q-RM-01    | Question   | "Chấp nhận rủi ro" với lỗ hổng Critical có cần Admin không?                                                   | High   | **Chốt tại DEC-09** — Có, Critical và High | Chờ khách hàng xác nhận                                     |
| Q-RM-02    | Question   | Nếu Q-09 (BU) xác định lỗ hổng Critical là dữ liệu hạn chế, phạm vi **đọc** của RM-002 có phải thu hẹp không? | High   | Open                                       | Chặn hoàn thiện §5 nếu câu trả lời là "có"                  |
| Q-RM-03    | Question   | PM của Project có nên được quyền thêm/xóa thành viên trong khi Dev/QA thì không?                              | Medium | Open                                       | Liên quan trực tiếp ASM-RM-003                              |

## 8. Decision Log

| Date       | Decision                                                                             | Impacted Roles | Nguồn        | Approved By    |
| ---------- | ------------------------------------------------------------------------------------ | -------------- | ------------ | -------------- |
| 2026-08-26 | User đọc toàn hệ thống, ghi theo tư cách thành viên; được tạo Project và tự thành PM | RM-002         | DEC-03       | ☐ Chờ xác nhận |
| 2026-08-26 | Chấp nhận rủi ro Critical/High chỉ Admin                                             | RM-001, RM-002 | DEC-09       | ☐ Chờ xác nhận |
| 2026-08-26 | Không ai được xóa lỗ hổng và lịch sử trạng thái                                      | RM-001, RM-002 | BR-13, BR-14 | ☐ Chờ xác nhận |

## 9. Completion Checklist

- [x] All business roles identified (Admin, User + ngữ cảnh thành viên)
- [x] Role-to-use-case mapping completed
- [x] Data scope and approval authority documented (DEC-03, DEC-09)
- [x] Ma trận quyền theo hành động (27 hành động) và theo màn hình (14 màn)
- [x] SoD constraints clarified (BR-05, BR-08, BR-15)
- [ ] No high-impact assumption pending confirmation — **còn ASM-RM-003, Q-RM-02**
- [ ] User confirmed completion

**Last Updated**: 2026-08-26

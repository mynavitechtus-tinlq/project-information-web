# Business Role Matrix — Hệ thống Quản lý Dự án, Tech Stack & Bảo mật

> **Phase**: Design — Specification | **Trạng thái**: Draft v0.1 — chờ BU verify
> **Upstream**: [01-business-understanding.md](./01-business-understanding.md), [02-usecase-overview.md](./02-usecase-overview.md)

---

## 1. Scope and Principles

- Hệ thống có **hai vai trò hệ thống**: Admin và User (theo context đã cung cấp).
- Nguyên tắc: quyền quản trị (tài khoản, phân quyền) chỉ thuộc Admin; quyền sửa dữ liệu dự án gắn với **tư cách thành viên** của dự án đó `[ASSUMED — Q-03]`.
- Vai trò **trong dự án** (PM/Dev/QA) là thuộc tính của ProjectMember, dùng để hiển thị và quy trách nhiệm, chưa tạo thành lớp quyền riêng trong lần triển khai này `[ASSUMED]`.

## 2. Role Inventory

| Role ID | Business Role | Mapped Actor(s) | Description | Status |
|---------|----------------|-----------------|-------------|--------|
| RM-001 | Admin | Admin | Quản trị hệ thống, toàn quyền trên mọi dữ liệu | Active |
| RM-002 | User | User | Thành viên dự án; xem toàn hệ thống `[ASSUMED]`, sửa dữ liệu dự án mình tham gia | Active |

## 3. Role Permission Matrix

| Role ID | Related Use Cases | Main Actions Allowed | Restricted Actions | Data Scope | Approval Authority | SoD Constraints | Related Screens |
|---------|-------------------|----------------------|--------------------|------------|--------------------|-----------------|-----------------|
| RM-001 Admin | Tất cả UC | Quản lý tài khoản/phân quyền; CRUD Project, thành viên, tech stack, lỗ hổng; xem Dashboard | — | Global | Yes | Không tự hạ vai trò Admin cuối cùng của hệ thống `[ASSUMED]` | Tất cả |
| RM-002 User | UC-AUTH-01/02, UC-PRJ-01..04, UC-TS-01/02, UC-SEC-01..03, UC-DASH-01 | Xem danh sách/chi tiết Project, tech stack, lỗ hổng, Dashboard; tạo Project `[NEEDS-CONFIRMATION]`; cập nhật dữ liệu dự án là thành viên | Không truy cập quản lý tài khoản/phân quyền; không sửa dữ liệu dự án không tham gia `[ASSUMED — Q-03]` | Own projects (ghi), Global (đọc) `[ASSUMED]` | No | — | Trừ SCR-ADM-* |

## 4. Role Detail (By Role)

### RM-001: Admin

- **Business purpose**: Đảm bảo hệ thống có người kiểm soát tài khoản, dữ liệu chuẩn và xử lý ngoại lệ.
- **Allowed actions**: Toàn bộ chức năng, gồm tạo/khóa tài khoản, gán vai trò, CRUD mọi Project/tech stack/lỗ hổng.
- **Restricted actions**: Không có (trừ ràng buộc không khóa/hạ quyền Admin cuối cùng `[ASSUMED]`).
- **Data access scope**: Toàn hệ thống.
- **Approval rights**: Quyết định cuối với "Chấp nhận rủi ro" của lỗ hổng Critical `[NEEDS-CONFIRMATION — Q-RM-01]`.
- **Exception handling**: Gán lại người phụ trách lỗ hổng khi thành viên rời dự án (EC-03).
- **Related Use Cases**: Tất cả. **Related Screens**: Tất cả.

### RM-002: User

- **Business purpose**: Cho phép kỹ sư/PM tự quản lý dữ liệu dự án của mình, tra cứu toàn hệ thống.
- **Allowed actions**: Đăng nhập; xem Project/tech stack/lỗ hổng/Dashboard; tạo và cập nhật dữ liệu của dự án mình là thành viên (thông tin, repository, thành viên, tech stack, lỗ hổng và trạng thái xử lý).
- **Restricted actions**: Quản lý tài khoản, phân quyền; sửa dữ liệu dự án không tham gia `[ASSUMED — Q-03]`; xóa lỗ hổng (không ai được xóa — BR-08).
- **Data access scope**: Đọc: toàn hệ thống `[ASSUMED]`. Ghi: dự án mình tham gia.
- **Approval rights**: Không.
- **Exception handling**: Khi cần sửa dữ liệu dự án khác → liên hệ Admin hoặc PM dự án đó.
- **Related Use Cases**: Tất cả trừ UC-ADM-01/02. **Related Screens**: Tất cả trừ SCR-ADM-10/11.

## 5. Open Questions and Assumptions

| ID | Type | Statement | Impact | Status | User Confirmation |
|----|------|-----------|--------|--------|-------------------|
| ASM-RM-001 | Assumption | User được **đọc** mọi Project trong hệ thống, chỉ giới hạn quyền **ghi** | High | Pending Confirmation | — |
| ASM-RM-002 | Assumption | User được phép tạo Project mới (và tự động trở thành thành viên) | Medium | Pending Confirmation | — |
| ASM-RM-003 | Assumption | Vai trò trong dự án (PM/Dev/QA) không tạo lớp quyền riêng ở phase này | Medium | Pending Confirmation | — |
| Q-RM-01 | Question | "Chấp nhận rủi ro" với lỗ hổng Critical có cần Admin phê duyệt không? | High | Open | — |

## 6. Decision Log

| Date | Decision | Impacted Roles | Approved By |
|------|----------|----------------|-------------|
| — | *(chưa có)* | — | — |

## 7. Completion Checklist

- [x] All business roles identified (theo context: Admin, User)
- [x] Role-to-use-case mapping completed (draft)
- [ ] Data scope and approval authority documented — **chờ xác nhận ASM-RM-001/002, Q-RM-01**
- [ ] SoD constraints clarified
- [ ] No high-impact assumption pending confirmation
- [ ] User confirmed completion

**Last Updated**: 2026-08-12

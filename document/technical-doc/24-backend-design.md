# Backend Design — Python 3.13 / FastAPI 0.115.9

> **Phase**: Design — Technical | **Trạng thái**: Draft v0.1 — chờ Tech Lead review
> **Upstream**: `21-architecture.md`, `22-database-design.md`, `23-api-specification.md`, `01-business-understanding.md` §6
> **Lưu ý phiên bản**: FastAPI pin ở **0.115.9** theo yêu cầu — xem **ADR-12**, đây là điểm cần Tech Lead xác nhận.

---

## 1. Cấu trúc thư mục

```
app-be/
├── alembic/
│   ├── versions/                    # 001..009 theo 22-database-design §7.2
│   └── env.py                       # chạy bằng DB role app_owner
├── src/
│   ├── main.py                      # tạo app, đăng ký router + exception handler
│   ├── config.py                    # Settings (pydantic-settings), đọc từ env
│   │
│   ├── core/
│   │   ├── database.py              # async engine, session factory, get_session()
│   │   ├── security.py              # Argon2id, mã hóa/giải mã JWT
│   │   ├── errors.py                # ★ BusinessError và cây exception nghiệp vụ
│   │   ├── exception_handlers.py    # ★ ánh xạ exception → JSON có mã MSG-*
│   │   ├── pagination.py            # tham số phân trang dùng chung + vỏ {items, meta}
│   │   └── logging.py               # log JSON, lọc dữ liệu nhạy cảm
│   │
│   ├── deps/
│   │   ├── auth.py                  # get_current_user, require_admin
│   │   └── project_access.py        # ★ require_project_write — chốt chặn BR-02
│   │
│   ├── models/                      # SQLAlchemy 2.0 declarative
│   │   ├── base.py                  # Base, mixin AuditMixin (created_*/updated_*)
│   │   ├── user.py, project.py, repository.py, project_member.py
│   │   ├── tech_stack.py, vulnerability.py, vulnerability_history.py
│   │
│   ├── schemas/                     # Pydantic v2 — biên giới dữ liệu, snake_case
│   │   ├── auth.py, user.py, project.py, member.py
│   │   ├── tech_stack.py, vulnerability.py, dashboard.py
│   │
│   ├── modules/                     # ★ nghiệp vụ, chia theo 5 khối của BA
│   │   ├── auth/       {router.py, service.py, queries.py}
│   │   ├── admin/      {router.py, service.py, queries.py}
│   │   ├── projects/   {router.py, service.py, queries.py}
│   │   ├── tech_stack/ {router.py, service.py, queries.py}
│   │   ├── security/   {router.py, service.py, queries.py, transitions.py}
│   │   ├── dashboard/  {router.py, queries.py}
│   │   └── export/     {router.py, csv_writer.py}
│   │
│   └── tests/
│       ├── conftest.py              # testcontainers PostgreSQL 17.9
│       ├── test_rules/              # ★ một tệp cho mỗi nhóm business rule
│       └── test_api/                # kiểm thử endpoint
├── pyproject.toml
├── requirements.txt                 # fastapi==0.115.9 (ADR-12)
└── Dockerfile
```

**Chia module theo khối nghiệp vụ, không theo loại kỹ thuật.** Tức là `modules/security/service.py` chứ không phải `services/vulnerability_service.py`. Lý do: khi sửa một nghiệp vụ, mọi thứ liên quan nằm cạnh nhau; và nếu sau này cần tách service (ADR-01 đã tính tới), ranh giới đã sẵn.

## 2. Phân tầng và trách nhiệm

| Tầng      | Được phép làm                                                     | **Không** được làm                                     |
| --------- | ----------------------------------------------------------------- | ------------------------------------------------------ |
| `router`  | Khai báo path, method, schema, dependency phân quyền; gọi service | Chứa `if` nghiệp vụ; truy vấn DB trực tiếp             |
| `deps`    | Quyết định "người này có được làm việc này không"; ném `403`      | Chứa quy tắc nghiệp vụ khác ngoài phân quyền           |
| `service` | Toàn bộ business rule; điều phối giao dịch; ném `BusinessError`   | Biết về HTTP (không import `Request`, `HTTPException`) |
| `queries` | Câu truy vấn SQLAlchemy/SQL                                       | Ra quyết định nghiệp vụ                                |
| `schemas` | Validate định dạng, tuần tự hóa                                   | Truy cập DB                                            |

> **Service không được biết HTTP.** Service ném `ProjectHasOpenVulnerabilitiesError`, không ném `HTTPException(400)`. Tầng `exception_handlers` mới dịch sang mã HTTP và mã `MSG-*`. Nhờ vậy service kiểm thử được mà không cần dựng HTTP client, và cùng một quy tắc dùng lại được cho tác vụ dòng lệnh nếu sau này cần.

## 3. Xử lý lỗi

### 3.1 Cây exception

```python
# core/errors.py
class AppError(Exception):
    """Gốc của mọi lỗi có mã message."""
    code: str            # ví dụ "MSG-BIZ-003"
    http_status: int
    field: str | None = None
    def __init__(self, **details): self.details = details

class BusinessError(AppError):    http_status = 400
class ConflictError(AppError):    http_status = 409   # xung đột / trùng dữ liệu
class ValidationError(AppError):  http_status = 422
class AuthError(AppError):        http_status = 401
class ForbiddenError(AppError):   http_status = 403
class NotFoundError(AppError):    http_status = 404

# Mỗi quy tắc nghiệp vụ có MỘT lớp exception riêng
class ProjectHasOpenVulnerabilitiesError(BusinessError):
    code = "MSG-BIZ-003"
class DuplicateProjectCodeError(ConflictError):
    code = "MSG-BIZ-001"; field = "code"
class LastAdminError(BusinessError):
    code = "MSG-BIZ-060"
class RiskAcceptanceRequiresAdminError(ForbiddenError):
    code = "MSG-AUTH-006"
class VulnerabilityStateChangedError(ConflictError):
    code = "MSG-BIZ-021"
```

**Vì sao mỗi quy tắc một lớp riêng thay vì `BusinessError("MSG-BIZ-003")`.** Lớp riêng làm cho mã lỗi trở thành thứ **kiểm tra được lúc biên dịch và tìm được bằng công cụ**: cần biết BR-18 được enforce ở đâu thì tìm tham chiếu tới `ProjectHasOpenVulnerabilitiesError`. Truyền chuỗi thì mã lỗi rải rác khắp nơi và gõ sai không ai phát hiện.

### 3.2 Handler tập trung

```python
# core/exception_handlers.py
@app.exception_handler(AppError)
async def handle_app_error(request, exc: AppError):
    return JSONResponse(
        status_code=exc.http_status,
        content={"error": {
            "code": exc.code,
            "message": render_message(exc.code, exc.details),  # điền biến {n}, {email}…
            "field": exc.field,
            "details": exc.details,
        }})
```

`render_message` đọc từ **một tệp catalog duy nhất** (`core/messages.py`) sinh ra từ `10-error-message-catalog.md`. Không rải câu chữ tiếng Việt trong service.

> **Việc cần làm ở sprint 1**: viết một test đọc `10-error-message-catalog.md` và khẳng định mọi mã dùng trong mã nguồn đều tồn tại trong catalog, và ngược lại mọi mã do BE sinh ra đều được khai báo. Chi phí thấp, chặn được cả một lớp lỗi lệch tài liệu.

## 4. Phân quyền

Ba dependency, không hơn:

```python
# deps/auth.py
async def get_current_user(...) -> User:
    """Giải mã JWT, tải người dùng, kiểm tra status='active'. Ném AuthError."""

async def require_admin(user: User = Depends(get_current_user)) -> User:
    """Ném ForbiddenError(MSG-AUTH-005) nếu user.role != 'admin'."""

# deps/project_access.py
def require_project_write(project_id_param: str = "project_id"):
    """
    Trả về dependency kiểm tra: user là admin, HOẶC là thành viên của project.
    Kiểm tra thêm: project.status != 'closed' (trừ khi là admin) — theo ma trận
    vòng đời ở 03-business-entities §4.3.
    Ném ForbiddenError(MSG-AUTH-005).
    """
```

Router khai báo quyền ngay ở chữ ký, nên đọc là thấy:

```python
@router.post("/projects/{project_id}/tech-stack", status_code=201)
async def create_tech_stack_item(
    project_id: UUID,
    payload: TechStackItemCreate,
    user: User = Depends(require_project_write()),
    session: AsyncSession = Depends(get_session),
): ...
```

**Quy tắc bắt buộc.** Mọi endpoint ghi **phải** khai báo một trong `require_admin` hoặc `require_project_write`. Endpoint đọc dùng `get_current_user`. Không có endpoint nào không khai báo dependency — CI kiểm tra điều này bằng một test duyệt qua toàn bộ route và khẳng định mỗi route có ít nhất một dependency xác thực (trừ danh sách trắng `/auth/login`, `/auth/refresh`, `/health`).

> Việc **kiểm tra ở tầng máy chủ là bắt buộc, không phải tùy chọn**. `writable_project_ids` mà `/auth/me` trả về chỉ để giao diện ẩn nút cho gọn. Screen Spec đã ghi rõ điều này ở mọi màn có `[PERMISSION-CLIENT]`, và `10-error-message-catalog.md` §11 điểm 2 đưa nó thành mục kiểm thử bắt buộc.

## 5. Bảng đối chiếu: business rule → nơi enforce

Đây là bảng quan trọng nhất của tài liệu này. Mỗi quy tắc trong BA có **một** nơi chịu trách nhiệm.

| Rule                  | Nội dung                                 | Tầng enforce             | Vị trí cụ thể                                                   |
| --------------------- | ---------------------------------------- | ------------------------ | --------------------------------------------------------------- |
| BR-01                 | Chỉ Admin quản lý tài khoản              | Dependency               | `require_admin` trên toàn bộ `/admin/*`                         |
| BR-02                 | User chỉ ghi dự án mình tham gia         | Dependency               | `require_project_write`                                         |
| BR-03                 | Mọi người đọc được toàn hệ thống         | Dependency               | `get_current_user`                                              |
| BR-04                 | Người tạo dự án thành PM                 | Service                  | `projects/service.py::create_project` — cùng giao dịch          |
| **BR-05**             | Luôn còn ≥1 Admin hoạt động              | **DB trigger** + Service | `users_require_active_admin` + kiểm tra trước để có message đẹp |
| BR-06                 | Mã và tên dự án duy nhất                 | **DB unique index**      | Service bắt `IntegrityError` → `MSG-BIZ-001/002`                |
| BR-07                 | Nhiều repository, nhiều thành viên       | Mô hình dữ liệu          | Khóa ngoại                                                      |
| **BR-08**             | Mỗi dự án ≥1 PM                          | **DB trigger** + Service | `project_members_require_pm` + kiểm tra trước                   |
| BR-09                 | Tech stack không trùng loại+tên          | **DB unique index**      | Service bắt `IntegrityError` → `MSG-BIZ-010`                    |
| BR-10                 | Repository chỉ lưu URL                   | DB `CHECK` + Pydantic    | `repositories_url_scheme` + `HttpUrl`                           |
| BR-11                 | Lỗ hổng gắn đúng một dự án               | Mô hình dữ liệu          | Khóa ngoại, không sửa được                                      |
| BR-12                 | (dự án+CVE+thư viện) duy nhất            | **DB unique index**      | Service bắt `IntegrityError` → `MSG-BIZ-030`                    |
| **BR-13**             | Không xóa lỗ hổng                        | **DB grant + trigger**   | Không có endpoint `DELETE` nào                                  |
| **BR-14**             | Lịch sử bất biến                         | **DB grant + trigger**   | `security/service.py` chỉ `INSERT`                              |
| **BR-15**             | Critical/High chỉ Admin chấp nhận rủi ro | **Service**              | `security/transitions.py::check_transition_permission`          |
| BR-16                 | `resolved` cần ngày + ghi chú            | DB `CHECK` + Service     | Service kiểm tra trước để có message theo ngữ cảnh              |
| BR-17                 | Nhắc cập nhật tech stack sau khi đóng    | Không enforce — chỉ nhắc | Trả cờ `should_remind_tech_stack: true` trong response          |
| **BR-18**             | Không kết thúc dự án khi còn lỗ hổng mở  | **Service**              | `projects/service.py::update_project` — cần đếm để dựng message |
| BR-19                 | Dự án kết thúc không tính vào Dashboard  | Query                    | `dashboard/queries.py` — mặc định `include_closed=False`        |
| BR-20                 | Chính sách mật khẩu                      | Pydantic validator       | `schemas/auth.py::PasswordStr`                                  |
| BR-21                 | Khóa tạm sau 5 lần sai                   | Service                  | `auth/service.py::check_rate_limit` + bảng `login_attempts`     |
| BR-22                 | Phiên hết hạn 30 phút                    | Cấu hình token           | Access 15 phút + refresh trượt                                  |
| BR-23                 | Chỉ khóa, không xóa tài khoản            | DB `ON DELETE RESTRICT`  | Không có endpoint `DELETE /admin/users/{id}`                    |
| R-ENT-001             | Luồng chuyển trạng thái                  | Service                  | `security/transitions.py::ALLOWED_TRANSITIONS`                  |
| R-ENT-002/003/004/007 | Trường bắt buộc theo trạng thái          | DB `CHECK` + Service     | Service kiểm tra trước để có message riêng theo đích            |
| R-ENT-005             | Tech stack không trùng                   | DB unique index          | Như BR-09                                                       |
| R-ENT-006             | Không gán tài khoản khóa                 | Service                  | `security/service.py` → `MSG-BIZ-033`                           |
| R-ENT-008             | `closed` cần `end_date`                  | DB `CHECK`               | `projects_closed_needs_end_date`                                |
| R-ENT-009             | (dự án+CVE+thư viện) duy nhất            | DB unique index          | Như BR-12                                                       |
| R-ENT-010/012         | `code` và `project_id` bất biến          | Pydantic schema          | Không có trong `ProjectUpdate` / `VulnerabilityUpdate`          |
| R-ENT-011             | Mật khẩu mới khác mật khẩu cũ            | Service                  | `auth/service.py::change_password`                              |

### 5.1 Vì sao nhiều quy tắc enforce ở CẢ hai tầng

BR-05, BR-08, BR-06, BR-09, BR-12 và nhóm R-ENT-002/003/004/007 xuất hiện ở cả DB lẫn service. Đây không phải trùng lặp thừa mà là phân vai rõ ràng:

- **DB là chốt chặn cuối** — đảm bảo dữ liệu không bao giờ sai, kể cả khi có bug ở tầng ứng dụng hoặc ai đó chạy script trực tiếp.
- **Service kiểm tra trước** — để trả về **thông báo đúng ngữ cảnh** mà người dùng hiểu được. Một `IntegrityError` từ Postgres chỉ nói "vi phạm ràng buộc `vuln_project_cve_library_uq`"; service biết đó là `MSG-BIZ-030` và biết cần kèm `existing_id` để FE dựng liên kết "Xem bản ghi đã có".

Service **vẫn phải bắt `IntegrityError`** như lớp phòng vệ cho tình huống chạy đua: hai request cùng lúc đều qua được bước kiểm tra trước rồi cùng ghi. Mẫu chuẩn:

```python
try:
    session.add(item); await session.flush()
except IntegrityError as e:
    if "tech_stack_project_cat_name_uq" in str(e.orig):
        existing = await queries.find_tech_stack_item(...)
        raise DuplicateTechStackItemError(existing_id=existing.id, category=..., name=...)
    raise
```

## 6. Giao dịch và đồng thời

### 6.1 Ranh giới giao dịch

Một request = một giao dịch, mở ở dependency `get_session`, commit khi handler trả về bình thường, rollback khi có exception. Service **không tự commit** — nếu service commit giữa chừng thì một lỗi ở bước sau sẽ để lại dữ liệu nửa vời.

### 6.2 Các thao tác bắt buộc nằm trong một giao dịch

| Thao tác                                             | Vì sao                                                                                                 |
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| Tạo dự án + tạo `ProjectMember` PM                   | BR-04; nếu tách thì có thể tạo ra dự án không có PM, vi phạm BR-08 ngay từ đầu                         |
| **Bàn giao PM** (nâng người mới + hạ người cũ)       | Constraint trigger DEFERRABLE chỉ kiểm tra ở cuối giao dịch — tách ra là bị chặn (đã kiểm chứng ở T18) |
| **Đổi vai trò Admin** (nâng người mới + hạ người cũ) | Tương tự, BR-05 (đã kiểm chứng ở T21)                                                                  |
| Chuyển trạng thái lỗ hổng + ghi dòng lịch sử         | BR-14; lịch sử thiếu một dòng là dấu vết kiểm toán hỏng                                                |
| Khóa tài khoản + thu hồi refresh token               | Nếu tách, người bị khóa vẫn dùng được phiên cũ                                                         |
| Thay trọn danh sách repository                       | Tránh trạng thái nửa vời khi người dùng bấm Lưu một lần                                                |

### 6.3 Khóa lạc quan

```python
async def update_with_version_check(session, model, obj_id, expected_updated_at, values):
    stmt = (update(model)
            .where(model.id == obj_id, model.updated_at == expected_updated_at)
            .values(**values).returning(model))
    result = (await session.execute(stmt)).scalar_one_or_none()
    if result is None:
        current = await session.get(model, obj_id)
        if current is None:
            raise NotFoundError()
        raise ConcurrentUpdateError(current=serialize(current))   # MSG-BIZ-020
    return result
```

Đưa `updated_at` vào mệnh đề `WHERE` là điểm mấu chốt — kiểm tra và ghi diễn ra **trong một câu lệnh nguyên tử**, không có khe hở giữa đọc và ghi.

Với lỗ hổng, dùng `VulnerabilityStateChangedError` (`MSG-BIZ-021`) thay vì `MSG-BIZ-020`, và kèm `current_status` để FE nói được _"vừa được người khác chuyển sang Đã xử lý"_ — Screen Spec yêu cầu đúng như vậy.

### 6.4 Máy trạng thái lỗ hổng

```python
# modules/security/transitions.py
ALLOWED_TRANSITIONS: dict[str, set[str]] = {
    "new":         {"in_progress", "accepted"},
    "in_progress": {"resolved", "accepted"},
    "resolved":    {"in_progress"},          # mở lại
    "accepted":    {"in_progress"},          # mở lại khi rủi ro thay đổi
}
# "new" KHÔNG BAO GIỜ là đích — khớp sơ đồ BU §5.1

REQUIRED_FIELDS = {
    "in_progress": {"assignee_id"},
    "resolved":    {"resolved_date", "note"},
    "accepted":    {"note"},
}

def check_transition_permission(user, vuln, to_status):
    if to_status == "accepted" and vuln.severity in ("critical", "high"):
        if user.role != "admin":
            raise RiskAcceptanceRequiresAdminError(severity=vuln.severity)  # BR-15
```

Đặt luồng trạng thái thành **dữ liệu** thay vì chuỗi `if` có ba lợi ích: endpoint `GET /vulnerabilities/{id}` trả được danh sách đích hợp lệ cho FE dựng popup; kiểm thử duyệt được toàn bộ tổ hợp; và khi nghiệp vụ đổi luồng thì sửa một chỗ.

## 7. Truy vấn cần chú ý

### 7.1 Danh sách dự án kèm số lỗ hổng còn mở

`SCR-PRJ-10` hiển thị 4 con số theo mức cho mỗi dòng. Làm ngây thơ sẽ thành N+1 truy vấn.

**Cách làm**: dùng view `v_project_summary` (đã định nghĩa ở `22-database-design.md`) — một truy vấn duy nhất, tận dụng partial index `vuln_open_idx`. Định nghĩa "còn mở" nằm ở **một chỗ duy nhất** trong view, nên không có nguy cơ Dashboard và danh sách hiểu khác nhau.

### 7.2 Gom nhóm theo CVE

`GET /vulnerabilities/grouped` trả một dòng cho mỗi `cve_id` kèm số dự án bị ảnh hưởng và phân bố trạng thái. Dòng con **tải lười** khi người dùng mở rộng, qua `GET /vulnerabilities?cve_id=...` — không tải sẵn tất cả, vì một CVE có thể ảnh hưởng hàng chục dự án.

### 7.3 Bốn truy vấn Dashboard

Mỗi khối một truy vấn tổng hợp riêng. Ở quy mô 5.000 bản ghi, mỗi truy vấn nằm trong khoảng vài chục mili-giây với các index đã có — không cần cache (ADR-06). Ngưỡng cần theo dõi ghi ở `26-security-nfr.md` §7.

### 7.4 Kết xuất CSV

```python
async def stream_vulnerabilities_csv(session, filters):
    yield b"\xef\xbb\xbf"                     # BOM cho Excel
    yield csv_line(VIETNAMESE_HEADERS)
    stmt = build_query(filters).execution_options(yield_per=500)
    async for row in await session.stream(stmt):
        yield csv_line(format_row(row))
```

`yield_per` giữ bộ nhớ ổn định bất kể số dòng. Kiểm tra giới hạn 10.000 dòng bằng một `COUNT` **trước khi** bắt đầu stream — vì một khi đã gửi byte đầu tiên thì không đổi được mã HTTP nữa.

## 8. Ghi log

| Nguyên tắc            | Chi tiết                                                                                          |
| --------------------- | ------------------------------------------------------------------------------------------------- |
| Định dạng             | JSON một dòng, ra `stdout` (Docker thu thập)                                                      |
| Trường bắt buộc       | `timestamp`, `level`, `request_id`, `user_id`, `method`, `path`, `status`, `duration_ms`          |
| **Không bao giờ log** | Mật khẩu, hash mật khẩu, access/refresh token, nội dung `risk_accept_reason` và `resolution_note` |
| Lỗi nghiệp vụ         | `INFO` kèm `code` — đây là hoạt động bình thường, không phải sự cố                                |
| Lỗi hệ thống          | `ERROR` kèm stack trace và `request_id`                                                           |

> **Vì sao không log nội dung ghi chú lỗ hổng.** `resolution_note` và `risk_accept_reason` mô tả **điểm yếu cụ thể và cách khai thác** của hệ thống nội bộ. Đưa chúng vào log là nhân bản dữ liệu nhạy cảm nhất ra một nơi thường có kiểm soát truy cập lỏng hơn database.

`request_id` sinh ở Nginx và truyền xuyên suốt Nginx → Next.js → FastAPI, để truy vết một request qua cả ba tầng.

## 9. Chiến lược kiểm thử

| Loại              | Phạm vi                                                                    | Công cụ                                     |
| ----------------- | -------------------------------------------------------------------------- | ------------------------------------------- |
| **Business rule** | 23 BR + 12 R-ENT — mỗi quy tắc ít nhất một ca đạt và một ca vi phạm        | pytest + testcontainers **PostgreSQL 17.9** |
| Máy trạng thái    | Toàn bộ tổ hợp `(from, to, role, severity)`                                | pytest parametrize                          |
| Endpoint          | Mã HTTP và mã `MSG-*` cho từng ca lỗi ở `23-api-specification.md` §4       | httpx AsyncClient                           |
| Đồng thời         | Hai request song song vào cùng bản ghi → một cái phải nhận `409`           | pytest-asyncio                              |
| Đồng bộ catalog   | Mọi mã trong code tồn tại trong `10-error-message-catalog.md` và ngược lại | test tự viết                                |
| Bảo vệ phân quyền | Mọi route có dependency xác thực; User không gọi được `/admin/*`           | test duyệt route                            |

**Dùng database thật, không mock.** Vì phần lớn ràng buộc nằm ở tầng DB (ADR-04, §5), mock database sẽ khiến kiểm thử xanh trong khi thực tế hỏng. Testcontainers dựng PostgreSQL 17.9 thật cho mỗi lần chạy. Kịch bản `sql/verify_rules.sql` (đã đạt 21/21) nên được chuyển thành pytest và chạy trong CI như bộ kiểm tra hồi quy của schema.

**Ba ca kiểm thử dễ bị bỏ sót**, đã nêu ở `10-error-message-catalog.md` §11 và nhắc lại vì thuộc trách nhiệm BE:

1. `MSG-AUTH-001` phải **giống hệt nhau** khi email không tồn tại và khi mật khẩu sai — kiểm tra cả thời gian phản hồi không chênh lệch rõ rệt (tấn công đo thời gian).
2. `MSG-AUTH-006` phải do **máy chủ** chặn — gọi thẳng API bằng token của User với lỗ hổng Critical phải nhận `403`.
3. `MSG-BIZ-011` (gỡ tech stack có lỗ hổng liên quan) **không** được chặn — `DELETE` phải trả `204`.

## 10. Câu hỏi mở

| Mã      | Câu hỏi                                                              | Ảnh hưởng                                                               |
| ------- | -------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| Q-BE-01 | ADR-12 — giữ FastAPI 0.115.9 hay nâng?                               | Cần chốt trước khi viết dòng code đầu tiên                              |
| Q-BE-02 | Số worker Uvicorn phù hợp, xét việc Argon2id tốn 64 MB/lần xác thực? | Cấu hình tài nguyên — xem TD 27 §3                                      |
| Q-BE-03 | Q-09 (BU) — có cần lọc lỗ hổng Critical theo quyền đọc không?        | Ảnh hưởng `queries.py` của cả module `security` lẫn `dashboard`         |
| Q-BE-04 | Có cần idempotency key cho `POST` không?                             | Hiện chống trùng bằng unique constraint; đủ cho mọi trường hợp trong BA |

**Last Updated**: 2026-08-26

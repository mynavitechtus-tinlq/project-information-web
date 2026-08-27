# Frontend Design — Next.js 16.3 LTS

> **Phase**: Design — Technical | **Trạng thái**: Draft v0.1 — chờ Tech Lead review
> **Upstream**: `05-screen-flow.md`, `07/08/09-screen-spec-*.md`, `10-error-message-catalog.md`, `23-api-specification.md`
> **Vai trò kép**: đây **không chỉ** là frontend — container này còn là **lớp giữ token** (ADR-02). Trình duyệt không bao giờ chạm vào JWT và không có đường mạng nào tới FastAPI.

---

## 1. Tech stack

| Hạng mục   | Chọn                                  | Ghi chú                                                 |
| ---------- | ------------------------------------- | ------------------------------------------------------- |
| Framework  | **Next.js 16.3.2 LTS**, App Router    | ADR-09 — bản 15 hết hỗ trợ bảo mật 21/10/2026           |
| Runtime    | React 19 (Server + Client Components) | Đi kèm Next.js 16                                       |
| Ngôn ngữ   | TypeScript 5.8+, `strict: true`       | —                                                       |
| Styling    | Tailwind CSS 4                        | Chuẩn nội bộ                                            |
| Component  | shadcn/ui (Radix)                     | Chuẩn nội bộ — **không sửa** tệp trong `components/ui/` |
| Bảng       | `@tanstack/react-table` 8             | Sắp xếp, phân trang, cột động                           |
| Form       | `react-hook-form` 7 + `zod` 3         | Validate phía trình duyệt khớp `MSG-VAL-*`              |
| Ngày tháng | `date-fns` 4                          | Hiển thị `dd/MM/yyyy`, múi giờ GMT+7                    |
| Node       | 22 LTS                                | —                                                       |

**Không có** trong stack: thư viện biểu đồ. Cả bốn khối Dashboard và mọi khối chỉ số đều là **bảng HTML thuần** — Screen Spec đã khai báo tường minh "không dùng thư viện chart, không có tooltip/legend". Thêm `recharts` vào đây là đi ngược lại đặc tả và làm nặng bundle vô ích.

**Không có** state management toàn cục (Redux/Zustand). Dữ liệu máy chủ lấy qua Server Components; state cục bộ dùng `useState`; bộ lọc lưu ở **query string** (yêu cầu của Screen Spec: chia sẻ được link kết quả lọc). Đây là lý do không cần thư viện quản lý state.

## 2. Cấu trúc thư mục

```
app-fe/
├── src/
│   ├── app/
│   │   ├── layout.tsx                       # html, providers, font
│   │   ├── (auth)/                          # nhóm route KHÔNG có thanh điều hướng
│   │   │   ├── login/page.tsx               # SCR-AUTH-10
│   │   │   └── change-password/page.tsx     # SCR-AUTH-11
│   │   ├── (app)/                           # nhóm route CÓ thanh điều hướng
│   │   │   ├── layout.tsx                   # ★ guard phiên + cờ must_change_password
│   │   │   ├── page.tsx                     # SCR-DASH-10  (route "/")
│   │   │   ├── projects/
│   │   │   │   ├── page.tsx                 # SCR-PRJ-10
│   │   │   │   ├── new/page.tsx             # SCR-PRJ-11 (tạo)
│   │   │   │   └── [id]/
│   │   │   │       ├── layout.tsx           # ★ đầu trang + thanh tab dùng chung
│   │   │   │       ├── page.tsx             # SCR-PRJ-20
│   │   │   │       ├── edit/page.tsx        # SCR-PRJ-11 (sửa)
│   │   │   │       ├── members/page.tsx     # SCR-PRJ-21
│   │   │   │       ├── tech-stack/page.tsx  # SCR-PRJ-22 (+ SCR-PRJ-23 dạng modal)
│   │   │   │       └── security/page.tsx    # SCR-PRJ-24
│   │   │   ├── security/
│   │   │   │   ├── page.tsx                 # SCR-SEC-10
│   │   │   │   ├── new/page.tsx             # SCR-SEC-11 (tạo)
│   │   │   │   └── [id]/page.tsx            # SCR-SEC-11 (xem/cập nhật)
│   │   │   └── admin/users/page.tsx         # SCR-ADM-10 (+ SCR-ADM-11 dạng modal)
│   │   ├── forbidden.tsx                    # trang 403 — MSG-AUTH-005
│   │   └── not-found.tsx                    # trang 404 — MSG-NF-001
│   │
│   ├── actions/                             # ★ Server Actions — biên giới duy nhất tới BE
│   │   ├── auth.action.ts
│   │   ├── project.action.ts
│   │   ├── member.action.ts
│   │   ├── tech-stack.action.ts
│   │   ├── vulnerability.action.ts
│   │   └── dashboard.action.ts
│   │
│   ├── libs/
│   │   ├── api-client.ts                    # ★ fetch có gắn token + tự refresh
│   │   ├── session.ts                       # ★ đọc/ghi httpOnly cookie
│   │   ├── messages.ts                      # ★ catalog MSG-* → câu tiếng Việt
│   │   ├── labels.ts                        # giá trị enum → nhãn tiếng Việt
│   │   ├── date-format.ts                   # dd/MM/yyyy, GMT+7
│   │   └── query-params.ts                  # đọc/ghi bộ lọc trên query string
│   │
│   ├── components/
│   │   ├── ui/                              # shadcn/ui — KHÔNG sửa
│   │   ├── common/                          # DataTable, Pagination, EmptyState, ErrorState…
│   │   ├── templates/                       # AppHeader, ProjectTabs, Breadcrumb
│   │   └── {feature}/                       # component riêng từng màn
│   │
│   ├── entities/                            # type khớp response API (snake_case)
│   ├── types/                               # ActionResult<T>, DataResponse<T>, Pagination
│   └── middleware.ts                        # ★ guard route + chuyển hướng
└── next.config.ts                           # output: 'standalone'
```

## 3. Ranh giới Server / Client Component

Đây là nguồn lỗi phổ biến nhất khi mới dùng App Router (RISK-A5), nên quy ước phải rõ và không có ngoại lệ.

| Loại               | Mặc định                                            | Khi nào dùng `"use client"`                   |
| ------------------ | --------------------------------------------------- | --------------------------------------------- |
| Trang (`page.tsx`) | **Luôn là Server Component**                        | Không bao giờ                                 |
| Layout             | **Luôn là Server Component**                        | Không bao giờ                                 |
| Bảng dữ liệu       | Server render dữ liệu, Client cho tương tác sắp xếp | Component bảng con                            |
| Form               | Client                                              | Có — cần `react-hook-form`                    |
| Modal/Dialog       | Client                                              | Có — cần trạng thái đóng/mở                   |
| Bộ lọc             | Client                                              | Có — cần `useRouter` để cập nhật query string |

**Ba quy tắc bắt buộc:**

1. **`"use client"` đặt càng sâu càng tốt.** Đặt ở `page.tsx` là biến cả cây thành client và mất toàn bộ lợi ích render phía máy chủ. Trang lấy dữ liệu, rồi truyền xuống một component client nhỏ chỉ lo tương tác.
2. **Bí mật không bao giờ đi qua props tới Client Component.** Access token, refresh token, biến môi trường server-only nằm trong Server Action và `libs/session.ts`. Một biến `NEXT_PUBLIC_*` chứa thứ nhạy cảm là lỗi bảo mật, không phải lỗi kiểu dữ liệu.
3. **Mọi lời gọi tới FastAPI đi qua Server Action.** Client Component **không bao giờ** `fetch` tới API. Đây là điều làm cho ADR-02 thành hiện thực chứ không chỉ là ý định.

## 4. Quản lý phiên

### 4.1 Cookie

| Cookie           | Nội dung                    | Thuộc tính                               |
| ---------------- | --------------------------- | ---------------------------------------- |
| `__Host-access`  | JWT access (15 phút)        | `httpOnly; Secure; SameSite=Lax; Path=/` |
| `__Host-refresh` | Refresh token (8 giờ trượt) | `httpOnly; Secure; SameSite=Lax; Path=/` |

Tiền tố `__Host-` buộc trình duyệt chỉ chấp nhận cookie khi có `Secure`, `Path=/` và **không** có `Domain` — chặn tấn công cố định cookie từ tên miền con.

### 4.2 Tự làm mới token

```ts
// libs/api-client.ts (server-only)
export async function apiFetch<T>(
  path: string,
  init?: RequestInit,
): Promise<ApiResult<T>> {
  let res = await callWithToken(path, init, await getAccessToken());

  if (res.status === 401) {
    const refreshed = await tryRefresh(); // POST /auth/refresh
    if (!refreshed) {
      await clearSession();
      redirect('/login?reason=session_expired'); // → MSG-AUTH-004
    }
    res = await callWithToken(path, init, refreshed.access_token);
  }
  return toApiResult<T>(res);
}
```

Toàn bộ việc làm mới token nằm ở **một hàm duy nhất**. Không rải logic refresh vào từng action — làm vậy là chắc chắn sẽ có chỗ quên.

### 4.3 Guard route trong `middleware.ts`

| Điều kiện                                  | Hành vi                                                                            | Nguồn                                   |
| ------------------------------------------ | ---------------------------------------------------------------------------------- | --------------------------------------- |
| Không có cookie phiên, route thuộc `(app)` | Chuyển về `/login?next=<đường dẫn>`                                                | Screen Flow §6                          |
| Có cờ `must_change_password`               | Mọi route **trừ** `/change-password` và `/logout` đều chuyển về `/change-password` | DEC-12                                  |
| Route `/admin/*` mà `role !== "admin"`     | Hiển thị **trang 403**, **không** chuyển hướng âm thầm                             | EC-07                                   |
| Đã có phiên, mở `/login`                   | Chuyển về `/`                                                                      | Screen Spec `SCR-AUTH-10` §1.4 F-A10-01 |

Middleware chỉ đọc cờ từ phiên; **không** gọi API (middleware chạy ở edge runtime, mỗi request đều đi qua — gọi API ở đây sẽ nhân đôi tải).

## 5. Server Actions

### 5.1 Hình dạng thống nhất

```ts
'use server';
export async function updateProject(
  id: string,
  input: ProjectUpdateInput,
): Promise<ActionResult<Project>> {
  const res = await apiFetch<Project>(`/projects/${id}`, {
    method: 'PATCH',
    body: JSON.stringify(input),
  });
  if (!res.ok) {
    return { success: false, error: res.error }; // error giữ nguyên {code, message, field, details}
  }
  revalidatePath(`/projects/${id}`);
  return { success: true, data: res.data };
}
```

`ActionResult<T>` giữ đúng hình dạng của starter nội bộ. Điểm khác biệt quan trọng: `error` **không phải chuỗi** mà là đối tượng đầy đủ từ API, vì giao diện cần `field` để đặt lỗi inline đúng ô và cần `details` để dựng liên kết (ví dụ `MSG-BIZ-030` cần `existing_id`).

### 5.2 Xử lý lỗi ở giao diện

```ts
// libs/messages.ts — sinh từ 10-error-message-catalog.md
export const MESSAGES: Record<string, string> = {
  'MSG-BIZ-003': 'Không thể kết thúc dự án khi còn {n} lỗ hổng chưa xử lý. …',
  // …111 mã
};
export function renderMessage(
  code: string,
  details?: Record<string, unknown>,
): string;
```

**Giao diện hiển thị theo `code`, không parse `message` từ API.** Nếu câu chữ trong catalog đổi, chỉ sửa `messages.ts`. API vẫn trả `message` — dùng cho log, không dùng để hiển thị.

Vị trí hiển thị quyết định bởi `error.field`:

| `field`               | Vị trí                                       | Ví dụ                           |
| --------------------- | -------------------------------------------- | ------------------------------- |
| Có giá trị            | Inline dưới ô tương ứng                      | `MSG-BIZ-001` → dưới ô Mã dự án |
| `null`, lỗi mức form  | Banner đầu form                              | `MSG-BIZ-003`                   |
| `null`, thao tác ngắn | Toast                                        | `MSG-BIZ-051`                   |
| Lỗi tải danh sách     | **Inline trong vùng bảng** kèm nút "Thử lại" | `MSG-SYS-003`                   |

> Quy tắc cuối là điều Screen Spec nhấn đi nhấn lại: lỗi tải danh sách **không dùng toast**, vì toast biến mất và người dùng ở lại với một vùng trống không giải thích được.

### 5.3 Nguyên tắc bất di bất dịch khi lưu thất bại

**Không bao giờ đóng form, không bao giờ rời màn, không bao giờ xóa dữ liệu người dùng đã nhập.** Điều này xuất hiện ở §5 của cả 14 màn trong Screen Spec và là lỗi trải nghiệm nghiêm trọng nhất nếu làm sai. Cụ thể trong React: giữ state của form, chỉ đặt lỗi; không gọi `reset()`, không đổi `open` của modal về `false`.

## 6. Ánh xạ màn hình → route

| Screen ID   | Route                                  | Kiểu render                       | Ghi chú                                         |
| ----------- | -------------------------------------- | --------------------------------- | ----------------------------------------------- |
| SCR-AUTH-10 | `/login`                               | Server + form client              | Ngoài nhóm `(app)` — không có thanh điều hướng  |
| SCR-AUTH-11 | `/change-password`                     | Server + form client              | Chế độ bắt buộc: ẩn thanh điều hướng và nút Hủy |
| SCR-DASH-10 | `/`                                    | Server, **4 khối stream độc lập** | Xem §7.1                                        |
| SCR-PRJ-10  | `/projects`                            | Server, bộ lọc client             | Bộ lọc ở query string                           |
| SCR-PRJ-11  | `/projects/new`, `/projects/[id]/edit` | Server + form client              | Trang đầy (không phải modal)                    |
| SCR-PRJ-20  | `/projects/[id]`                       | Server                            | Chỉ số tải song song, lỗi độc lập               |
| SCR-PRJ-21  | `/projects/[id]/members`               | Server + khối thêm client         | Khối thêm inline, không phải modal              |
| SCR-PRJ-22  | `/projects/[id]/tech-stack`            | Server + lọc client               | —                                               |
| SCR-PRJ-23  | _(modal trên SCR-PRJ-22)_              | Client                            | **Dialog** có backdrop + focus trap             |
| SCR-PRJ-24  | `/projects/[id]/security`              | Server + bộ lọc client            | —                                               |
| SCR-SEC-10  | `/security`                            | Server, bộ lọc client             | Gom nhóm theo CVE qua query `?group=cve`        |
| SCR-SEC-11  | `/security/new`, `/security/[id]`      | Server + popup client             | Lịch sử tải độc lập                             |
| SCR-ADM-10  | `/admin/users`                         | Server, guard Admin               | —                                               |
| SCR-ADM-11  | _(modal trên SCR-ADM-10)_              | Client                            | **Dialog** có backdrop + focus trap             |

Thanh tab của dự án đặt ở `projects/[id]/layout.tsx` nên chuyển tab **không tải lại phần đầu trang** — đúng yêu cầu Screen Spec `SCR-PRJ-20` §3.4 F-P20-02.

## 7. Ba mẫu triển khai đáng chú ý

### 7.1 Dashboard — bốn khối độc lập

Screen Spec yêu cầu: lỗi ở một khối **không** được làm hỏng ba khối còn lại, và mỗi khối có nút "Thử lại" riêng.

```tsx
// app/(app)/page.tsx  (Server Component)
export default function DashboardPage({ searchParams }) {
  const includeClosed = searchParams.include_closed === 'true';
  return (
    <>
      <Suspense fallback={<AlertsSkeleton />}>
        <SecurityAlertsBlock includeClosed={includeClosed} />
      </Suspense>
      <Suspense fallback={<BlockSkeleton />}>
        <ProjectStatusBlock includeClosed={includeClosed} />
      </Suspense>
      {/* …2 khối còn lại */}
    </>
  );
}
```

Mỗi khối là một Server Component tự lấy dữ liệu và **tự bắt lỗi**, trả về `<ErrorState code="MSG-SYS-006" onRetry=… />` khi hỏng. Bốn `Suspense` riêng cho phép khối nào xong trước hiện trước.

**Chi tiết đặc biệt của khối cảnh báo**: khi lỗi thì **không hiển thị con số nào**. Screen Spec nói rõ lý do — số sai ở khối cảnh báo bảo mật nguy hiểm hơn là không có số.

### 7.2 Phân biệt ba trạng thái rỗng của `SCR-SEC-10`

Đây là chỗ dễ gộp nhầm nhất trong toàn hệ thống:

```tsx
function VulnerabilityEmptyState({
  hasFilters,
  isDefaultOpenFilter,
  totalInSystem,
}) {
  if (totalInSystem === 0) return <EmptyState code="MSG-INF-037" />; // hệ thống chưa có gì
  if (isDefaultOpenFilter) return <EmptyState code="MSG-INF-038" action="…" />; // không còn lỗ hổng mở — tin TỐT
  if (hasFilters) return <EmptyState code="MSG-INF-036" action="clear" />;
  return null;
}
```

`MSG-INF-038` là tin tốt và phải được trình bày như tin tốt — nền trung tính, không phải màu cảnh báo. Cùng logic áp dụng cho khối 1 Dashboard (`MSG-INF-042`).

### 7.3 Ẩn nút hay vô hiệu hóa nút

Quy ước từ `04-role-matrix.md` §5, hiện thực trực tiếp:

```tsx
// ẨN: người dùng không bao giờ làm được việc này ở màn này
{
  canWriteProject && <Button>Thêm hạng mục</Button>;
}

// VÔ HIỆU HÓA + tooltip: làm được trong hoàn cảnh khác, cần biết phải nhờ ai
<Tooltip content={renderMessage('MSG-AUTH-006')}>
  <RadioOption value="accepted" disabled={isHighSeverity && !user.is_admin}>
    Chấp nhận rủi ro
  </RadioOption>
</Tooltip>;
```

Sự khác biệt không phải chuyện thẩm mỹ: ẩn nút "Chấp nhận rủi ro" với lỗ hổng Critical sẽ khiến người dùng tưởng chức năng không tồn tại, trong khi thực ra họ chỉ cần nhờ quản trị viên.

## 8. Hiển thị dữ liệu

| Loại                    | Quy tắc                                                 | Nguồn                                         |
| ----------------------- | ------------------------------------------------------- | --------------------------------------------- |
| Ngày                    | `dd/MM/yyyy`                                            | ASM-05                                        |
| Thời điểm               | `dd/MM/yyyy HH:mm`, đổi UTC → GMT+7                     | ASM-05                                        |
| Giá trị rỗng            | Hiển thị `—`, **không** để trống, **không** hiện `null` | Screen Spec `SCR-PRJ-20` §3.3                 |
| Chưa đăng nhập lần nào  | "Chưa đăng nhập" bằng chữ                               | `SCR-ADM-10`                                  |
| Người phụ trách rỗng    | "Chưa gán" **màu cam**                                  | `SCR-SEC-10` — đây là tín hiệu cần thấy       |
| Phiên bản               | Chữ đều (monospace)                                     | Dễ so `2.17.1` với `2.7.11` khi đối chiếu CVE |
| Mức nghiêm trọng        | Màu **kèm chữ**, không chỉ màu                          | Yêu cầu trợ năng cho người mù màu             |
| Số ngày còn mở > 30     | Màu cam kèm nhãn "Quá hạn"                              | DEC-08b                                       |
| Lỗ hổng đã đóng         | Cột số ngày hiện `—`, **không** hiện `0`                | `SCR-SEC-10` §1.3                             |
| 4 số lỗ hổng đều bằng 0 | Hiện `—` thay vì `0 / 0 / 0 / 0`                        | `SCR-PRJ-10` §1.3                             |

## 9. Trợ năng và hiệu năng

**Trợ năng** (mức tối thiểu bắt buộc):

- Mọi `Icon button` có `aria-label` tiếng Việt mô tả hành động và đối tượng — "Xóa repository paygw-api", không phải "Xóa".
- Thông báo lỗi đặt trong vùng `role="alert"`; thông báo thông tin dùng `role="status"`.
- Dialog có focus trap, đóng bằng `Escape`, trả focus về phần tử đã mở nó.
- Không truyền tải thông tin **chỉ bằng màu sắc** — mức nghiêm trọng và trạng thái luôn có chữ.

**Hiệu năng** — chỉ tiêu ≤ 3 giây (NFR-PERF):

| Kỹ thuật                                     | Áp dụng ở                                              |
| -------------------------------------------- | ------------------------------------------------------ |
| Server Component lấy dữ liệu                 | Mọi trang — bỏ được một vòng round-trip từ trình duyệt |
| `Suspense` theo khối                         | Dashboard, chỉ số của `SCR-PRJ-20`                     |
| Phân trang phía máy chủ                      | Mọi danh sách, mặc định 20 dòng                        |
| Debounce 400ms cho tìm kiếm, 300ms cho gợi ý | Ô tìm và Autocomplete                                  |
| Hủy request cũ khi bộ lọc đổi                | Tránh kết quả về sai thứ tự — Screen Spec nêu rõ       |
| `output: 'standalone'`                       | Ảnh Docker nhỏ hơn nhiều                               |

## 10. Biến môi trường

| Biến                    | Phạm vi         | Ví dụ                                 | Ghi chú                             |
| ----------------------- | --------------- | ------------------------------------- | ----------------------------------- |
| `API_BASE_URL`          | **Server only** | `http://api:8000/api/v1`              | **Không** có tiền tố `NEXT_PUBLIC_` |
| `SESSION_COOKIE_SECRET` | **Server only** | _(chuỗi ngẫu nhiên 32 byte)_          | Ký cookie                           |
| `NODE_ENV`              | Cả hai          | `production`                          | —                                   |
| `NEXT_PUBLIC_APP_NAME`  | Client          | `Quản lý Dự án, Tech Stack & Bảo mật` | Chỉ dữ liệu hiển thị                |

> **Không có biến `NEXT_PUBLIC_*` nào chứa URL của API.** Trình duyệt không cần biết FastAPI tồn tại — đó chính là điểm của ADR-02. Nếu trong quá trình làm ai đó thêm `NEXT_PUBLIC_API_URL`, đó là dấu hiệu có chỗ đang gọi API từ Client Component và cần sửa lại.

Validate biến môi trường lúc khởi động bằng `@t3-oss/env-nextjs` + zod — thiếu biến thì container **fail nhanh** thay vì lỗi mơ hồ lúc chạy.

## 11. Câu hỏi mở

| Mã      | Câu hỏi                                                                                         | Ảnh hưởng                                                                                                          |
| ------- | ----------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| Q-FE-01 | Có cần cảnh báo trước 2 phút khi phiên sắp hết hạn trong lúc đang nhập form dài không?          | Câu hỏi mở ở `08-screen-spec-project.md` §2.11; hiện chưa có                                                       |
| Q-FE-02 | Ô "Xác nhận mật khẩu mới" có chặn dán không?                                                    | `07-screen-spec-auth-admin.md` §2.11                                                                               |
| Q-FE-03 | Trạng thái công tắc "bao gồm dự án đã kết thúc" có ghi nhớ giữa các phiên không?                | Hiện chỉ ghi vào query string                                                                                      |
| Q-FE-04 | Hệ thống một ngôn ngữ (ASM-04) — có cần dựng sẵn `next-intl` để sau này thêm ngôn ngữ dễ không? | Dựng sẵn tốn công ban đầu; thêm sau tốn hơn. Khuyến nghị: **dựng sẵn cấu trúc tệp dịch**, chỉ có một ngôn ngữ `vi` |

**Last Updated**: 2026-08-26

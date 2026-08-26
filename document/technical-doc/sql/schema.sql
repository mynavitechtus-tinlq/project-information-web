-- =====================================================================
-- Hệ thống Quản lý Dự án, Tech Stack & Bảo mật
-- Schema đầy đủ — PostgreSQL 17.9
-- Sinh từ: 03-business-entities.md v0.2 + 01-business-understanding.md v0.2
-- =====================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";   -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "unaccent";   -- tìm kiếm bỏ dấu tiếng Việt

-- unaccent() mặc định KHÔNG immutable (phụ thuộc dictionary có thể đổi) nên không
-- dùng trực tiếp trong index expression được. Bọc lại thành hàm immutable.
-- Đánh đổi: nếu đổi cấu hình dictionary thì phải REINDEX các index dùng hàm này.
CREATE OR REPLACE FUNCTION immutable_unaccent(text)
RETURNS text
LANGUAGE sql IMMUTABLE PARALLEL SAFE STRICT AS
$$ SELECT public.unaccent('public.unaccent'::regdictionary, $1) $$;

-- ---------------------------------------------------------------------
-- 1. users  (Entity: User)
-- ---------------------------------------------------------------------
CREATE TABLE users (
    id                    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    email                 TEXT        NOT NULL,
    full_name             TEXT        NOT NULL,
    password_hash         TEXT        NOT NULL,
    must_change_password  BOOLEAN     NOT NULL DEFAULT TRUE,
    role                  TEXT        NOT NULL DEFAULT 'user',
    status                TEXT        NOT NULL DEFAULT 'active',
    locked_until          TIMESTAMPTZ,
    last_login_at         TIMESTAMPTZ,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by            UUID        REFERENCES users(id) ON DELETE RESTRICT,
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_by            UUID        REFERENCES users(id) ON DELETE RESTRICT,

    CONSTRAINT users_email_lowercase   CHECK (email = lower(email)),
    CONSTRAINT users_email_format      CHECK (email ~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'),
    CONSTRAINT users_email_length      CHECK (char_length(email) BETWEEN 5 AND 255),
    CONSTRAINT users_full_name_length  CHECK (char_length(btrim(full_name)) BETWEEN 2 AND 100),
    CONSTRAINT users_role_values       CHECK (role   IN ('admin','user')),
    CONSTRAINT users_status_values     CHECK (status IN ('active','locked'))
);

CREATE UNIQUE INDEX users_email_uq ON users (email);
CREATE INDEX users_role_status_idx  ON users (role, status);
-- Hỗ trợ tìm kiếm theo họ tên, bỏ dấu tiếng Việt (SCR-ADM-10)
CREATE INDEX users_full_name_search_idx ON users USING gin (to_tsvector('simple', immutable_unaccent(full_name)));

COMMENT ON TABLE  users IS 'Tài khoản đăng nhập. Chỉ khóa, không xóa (BR-23).';
COMMENT ON COLUMN users.must_change_password IS 'Bật khi Admin tạo tài khoản hoặc đặt lại mật khẩu (DEC-12).';
COMMENT ON COLUMN users.locked_until IS 'Khóa tạm do sai mật khẩu 5 lần / 15 phút (BR-21). Khác với status=locked.';

-- ---------------------------------------------------------------------
-- 2. refresh_tokens  (kỹ thuật — ADR-03)
-- ---------------------------------------------------------------------
CREATE TABLE refresh_tokens (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash    TEXT        NOT NULL,
    issued_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at    TIMESTAMPTZ NOT NULL,
    revoked_at    TIMESTAMPTZ,
    replaced_by   UUID        REFERENCES refresh_tokens(id) ON DELETE SET NULL,
    user_agent    TEXT,
    ip_address    INET,

    CONSTRAINT refresh_tokens_expiry_after_issue CHECK (expires_at > issued_at)
);

CREATE UNIQUE INDEX refresh_tokens_hash_uq ON refresh_tokens (token_hash);
CREATE INDEX refresh_tokens_user_active_idx
    ON refresh_tokens (user_id) WHERE revoked_at IS NULL;

COMMENT ON TABLE refresh_tokens IS 'Lưu HASH của refresh token, xoay vòng mỗi lần dùng. Khóa tài khoản = revoke toàn bộ hàng của user đó.';
COMMENT ON COLUMN refresh_tokens.replaced_by IS 'Trỏ tới token thay thế. Dùng lại token đã bị thay = dấu hiệu đánh cắp, revoke cả chuỗi.';

-- ---------------------------------------------------------------------
-- 3. login_attempts  (kỹ thuật — BR-21, thay cho Redis theo ADR-06)
-- ---------------------------------------------------------------------
CREATE TABLE login_attempts (
    id           BIGINT      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email        TEXT        NOT NULL,
    succeeded    BOOLEAN     NOT NULL,
    attempted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    ip_address   INET
);

CREATE INDEX login_attempts_email_time_idx ON login_attempts (email, attempted_at DESC);

COMMENT ON TABLE login_attempts IS 'Đếm số lần sai trong cửa sổ 15 phút (BR-21). Dọn định kỳ, giữ 30 ngày.';

-- ---------------------------------------------------------------------
-- 4. projects  (Entity: Project)
-- ---------------------------------------------------------------------
CREATE TABLE projects (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    code        TEXT        NOT NULL,
    name        TEXT        NOT NULL,
    description TEXT,
    status      TEXT        NOT NULL DEFAULT 'init',
    customer    TEXT,
    start_date  DATE,
    end_date    DATE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by  UUID        NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_by  UUID        NOT NULL REFERENCES users(id) ON DELETE RESTRICT,

    CONSTRAINT projects_code_format    CHECK (code ~ '^[A-Z0-9_]{2,20}$'),
    CONSTRAINT projects_name_length    CHECK (char_length(btrim(name)) BETWEEN 3 AND 100),
    CONSTRAINT projects_desc_length    CHECK (description IS NULL OR char_length(description) <= 1000),
    CONSTRAINT projects_customer_length CHECK (customer IS NULL OR char_length(customer) <= 100),
    CONSTRAINT projects_status_values  CHECK (status IN ('init','dev','live','paused','closed')),
    -- R-ENT-008: end_date không trước start_date, và bắt buộc khi status='closed'
    CONSTRAINT projects_date_order     CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date),
    CONSTRAINT projects_closed_needs_end_date CHECK (status <> 'closed' OR end_date IS NOT NULL)
);

CREATE UNIQUE INDEX projects_code_uq      ON projects (code);
-- BR-06: tên duy nhất, không phân biệt hoa/thường, đã cắt khoảng trắng
CREATE UNIQUE INDEX projects_name_uq      ON projects (lower(btrim(name)));
CREATE INDEX projects_status_idx          ON projects (status);
CREATE INDEX projects_name_search_idx     ON projects USING gin (to_tsvector('simple', immutable_unaccent(name)));

COMMENT ON COLUMN projects.code   IS 'Không sửa được sau khi tạo (R-ENT-010) — enforce ở tầng service.';
COMMENT ON COLUMN projects.status IS 'init/dev/live/paused/closed = Khởi tạo/Đang phát triển/Đang vận hành/Tạm dừng/Kết thúc (DEC-08).';

-- ---------------------------------------------------------------------
-- 5. repositories  (Entity: Repository)
-- ---------------------------------------------------------------------
CREATE TABLE repositories (
    id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID        NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name       TEXT        NOT NULL,
    url        TEXT        NOT NULL,
    note       TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID        NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_by UUID        NOT NULL REFERENCES users(id) ON DELETE RESTRICT,

    CONSTRAINT repositories_name_length CHECK (char_length(btrim(name)) BETWEEN 1 AND 100),
    CONSTRAINT repositories_url_scheme  CHECK (url ~* '^https?://'),
    CONSTRAINT repositories_url_length  CHECK (char_length(url) <= 500),
    CONSTRAINT repositories_note_length CHECK (note IS NULL OR char_length(note) <= 200)
);

CREATE UNIQUE INDEX repositories_project_name_uq ON repositories (project_id, lower(btrim(name)));
CREATE INDEX repositories_project_idx ON repositories (project_id);

COMMENT ON TABLE repositories IS 'Chỉ lưu đường dẫn (BR-10, DEC-07). Hệ thống không gọi API GitHub/GitLab.';

-- ---------------------------------------------------------------------
-- 6. project_members  (Entity: ProjectMember)
-- ---------------------------------------------------------------------
CREATE TABLE project_members (
    id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id   UUID        NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    user_id      UUID        NOT NULL REFERENCES users(id)    ON DELETE RESTRICT,
    project_role TEXT        NOT NULL DEFAULT 'dev',
    joined_date  DATE        NOT NULL DEFAULT CURRENT_DATE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by   UUID        NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_by   UUID        NOT NULL REFERENCES users(id) ON DELETE RESTRICT,

    CONSTRAINT project_members_role_values CHECK (project_role IN ('pm','tech_lead','dev','qa','other'))
    -- LƯU Ý: "joined_date không được là ngày tương lai" KHÔNG đặt ở CHECK.
    -- CURRENT_DATE không immutable: hàng hợp lệ hôm nay có thể fail khi pg_restore,
    -- và ALTER TABLE ... VALIDATE sẽ đánh giá lại theo ngày chạy lệnh.
    -- Ràng buộc này enforce ở tầng service (MSG-VAL-040).
);

CREATE UNIQUE INDEX project_members_project_user_uq ON project_members (project_id, user_id);
CREATE INDEX project_members_user_idx    ON project_members (user_id);
CREATE INDEX project_members_project_idx ON project_members (project_id);
-- Truy vấn nóng nhất của hệ thống: "người này có quyền ghi trên dự án nào"
CREATE INDEX project_members_pm_idx ON project_members (project_id) WHERE project_role = 'pm';

COMMENT ON COLUMN project_members.user_id IS 'ON DELETE RESTRICT — user không bao giờ bị xóa, chỉ khóa (BR-23).';

-- ---------------------------------------------------------------------
-- 7. tech_stack_items  (Entity: TechStackItem)
-- ---------------------------------------------------------------------
CREATE TABLE tech_stack_items (
    id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID        NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    category   TEXT        NOT NULL,
    name       TEXT        NOT NULL,
    version    TEXT        NOT NULL,
    note       TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID        NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_by UUID        NOT NULL REFERENCES users(id) ON DELETE RESTRICT,

    CONSTRAINT tech_stack_category_values CHECK (category IN ('language','framework','database','cache','cloud')),
    CONSTRAINT tech_stack_name_length    CHECK (char_length(btrim(name))    BETWEEN 1 AND 50),
    CONSTRAINT tech_stack_version_length CHECK (char_length(btrim(version)) BETWEEN 1 AND 30),
    CONSTRAINT tech_stack_note_length    CHECK (note IS NULL OR char_length(note) <= 200)
);

-- R-ENT-005 / BR-09: không trùng loại + tên trong cùng dự án
CREATE UNIQUE INDEX tech_stack_project_cat_name_uq
    ON tech_stack_items (project_id, category, lower(btrim(name)));
CREATE INDEX tech_stack_project_idx ON tech_stack_items (project_id);
-- Lọc dự án theo công nghệ (SCR-PRJ-10) và phân bố công nghệ (Dashboard khối 3)
CREATE INDEX tech_stack_name_lower_idx ON tech_stack_items (lower(btrim(name)));

-- ---------------------------------------------------------------------
-- 8. vulnerabilities  (Entity: Vulnerability)
-- ---------------------------------------------------------------------
CREATE TABLE vulnerabilities (
    id                 UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id         UUID        NOT NULL REFERENCES projects(id) ON DELETE RESTRICT,
    cve_id             TEXT        NOT NULL,
    library            TEXT        NOT NULL,
    affected_version   TEXT        NOT NULL,
    severity           TEXT        NOT NULL,
    status             TEXT        NOT NULL DEFAULT 'new',
    recommendation     TEXT,
    assignee_id        UUID        REFERENCES users(id) ON DELETE RESTRICT,
    detected_date      DATE        NOT NULL DEFAULT CURRENT_DATE,
    resolved_date      DATE,
    resolution_note    TEXT,
    risk_accept_reason TEXT,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by         UUID        NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_by         UUID        NOT NULL REFERENCES users(id) ON DELETE RESTRICT,

    CONSTRAINT vuln_cve_format      CHECK (cve_id ~ '^CVE-[0-9]{4}-[0-9]{4,7}$'),
    CONSTRAINT vuln_cve_uppercase   CHECK (cve_id = upper(cve_id)),
    CONSTRAINT vuln_library_length  CHECK (char_length(btrim(library)) BETWEEN 1 AND 100),
    CONSTRAINT vuln_version_length  CHECK (char_length(btrim(affected_version)) BETWEEN 1 AND 30),
    CONSTRAINT vuln_severity_values CHECK (severity IN ('critical','high','medium','low')),
    CONSTRAINT vuln_status_values   CHECK (status   IN ('new','in_progress','resolved','accepted')),
    -- R-ENT-003
    -- R-ENT-003 (phần so sánh hai cột — immutable nên đặt được ở DB)
    CONSTRAINT vuln_resolved_after_detected
        CHECK (resolved_date IS NULL OR resolved_date >= detected_date),
    -- LƯU Ý: "không được là ngày tương lai" (detected_date, resolved_date) enforce ở
    -- tầng service, KHÔNG ở CHECK — vì CURRENT_DATE không immutable (xem project_members).
    -- R-ENT-002: 'resolved' bắt buộc có ngày xử lý + ghi chú
    CONSTRAINT vuln_resolved_requires_fields
        CHECK (status <> 'resolved' OR (resolved_date IS NOT NULL AND btrim(coalesce(resolution_note,'')) <> '')),
    -- resolved_date chỉ có nghĩa khi đã xử lý
    CONSTRAINT vuln_resolved_date_only_when_resolved
        CHECK (resolved_date IS NULL OR status = 'resolved'),
    -- R-ENT-004: 'accepted' bắt buộc có lý do
    CONSTRAINT vuln_accepted_requires_reason
        CHECK (status <> 'accepted' OR btrim(coalesce(risk_accept_reason,'')) <> ''),
    -- R-ENT-007: 'in_progress' bắt buộc có người phụ trách
    CONSTRAINT vuln_in_progress_requires_assignee
        CHECK (status <> 'in_progress' OR assignee_id IS NOT NULL),
    CONSTRAINT vuln_recommendation_length CHECK (recommendation     IS NULL OR char_length(recommendation)     <= 500),
    CONSTRAINT vuln_resolution_note_length CHECK (resolution_note   IS NULL OR char_length(resolution_note)    <= 500),
    CONSTRAINT vuln_risk_reason_length     CHECK (risk_accept_reason IS NULL OR char_length(risk_accept_reason) <= 500)
);

-- R-ENT-009 / BR-12 / DEC-04: (dự án + CVE + thư viện) duy nhất
CREATE UNIQUE INDEX vuln_project_cve_library_uq
    ON vulnerabilities (project_id, cve_id, lower(btrim(library)));

CREATE INDEX vuln_project_idx  ON vulnerabilities (project_id);
CREATE INDEX vuln_cve_idx      ON vulnerabilities (cve_id);
CREATE INDEX vuln_assignee_idx ON vulnerabilities (assignee_id) WHERE assignee_id IS NOT NULL;
CREATE INDEX vuln_library_lower_idx ON vulnerabilities (lower(btrim(library)));

-- Truy vấn nóng nhất: "lỗ hổng CÒN MỞ" — dùng ở Dashboard, danh sách, BR-18, EC-03
CREATE INDEX vuln_open_idx
    ON vulnerabilities (project_id, severity, detected_date)
    WHERE status IN ('new','in_progress');

-- Danh sách toàn hệ thống sắp theo số ngày còn mở giảm dần
CREATE INDEX vuln_open_detected_idx
    ON vulnerabilities (detected_date)
    WHERE status IN ('new','in_progress');

-- Ma trận mức × trạng thái (Dashboard khối 4)
CREATE INDEX vuln_severity_status_idx ON vulnerabilities (severity, status);

COMMENT ON TABLE vulnerabilities IS 'KHÔNG BAO GIỜ XÓA (BR-13). DB role của ứng dụng không có quyền DELETE trên bảng này.';
COMMENT ON COLUMN vulnerabilities.library IS 'Văn bản tự do, KHÔNG phải khóa ngoại tới tech_stack_items — lỗ hổng có thể ở thư viện phụ thuộc gián tiếp (Q-ENT-05).';
COMMENT ON COLUMN vulnerabilities.project_id IS 'ON DELETE RESTRICT — không có chức năng xóa dự án ở giai đoạn 1.';

-- ---------------------------------------------------------------------
-- 9. vulnerability_status_history  (Entity: VulnerabilityStatusHistory)
--    BẤT BIẾN — BR-14, ADR-04
-- ---------------------------------------------------------------------
CREATE TABLE vulnerability_status_history (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    vulnerability_id UUID        NOT NULL REFERENCES vulnerabilities(id) ON DELETE RESTRICT,
    from_status      TEXT,
    to_status        TEXT        NOT NULL,
    changed_by       UUID        NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    changed_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    note             TEXT,

    CONSTRAINT vsh_from_status_values CHECK (from_status IS NULL OR from_status IN ('new','in_progress','resolved','accepted')),
    CONSTRAINT vsh_to_status_values   CHECK (to_status IN ('new','in_progress','resolved','accepted')),
    CONSTRAINT vsh_note_length        CHECK (note IS NULL OR char_length(note) <= 500),
    -- Dòng đầu tiên (ghi nhận mới) có from_status NULL và to_status='new'
    CONSTRAINT vsh_initial_row_shape  CHECK (from_status IS NOT NULL OR to_status = 'new')
);

CREATE INDEX vsh_vulnerability_idx ON vulnerability_status_history (vulnerability_id, changed_at DESC);
CREATE INDEX vsh_changed_by_idx    ON vulnerability_status_history (changed_by);

COMMENT ON TABLE vulnerability_status_history IS 'BẤT BIẾN (BR-14). Không UPDATE, không DELETE ở bất kỳ vai trò nào. Enforce bằng DB grant + trigger.';

-- =====================================================================
-- TRIGGERS
-- =====================================================================

-- --- T1: tự cập nhật updated_at (dùng cho khóa lạc quan — ADR-11) ------
CREATE OR REPLACE FUNCTION trg_set_updated_at() RETURNS trigger AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_set_updated_at            BEFORE UPDATE ON users            FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();
CREATE TRIGGER projects_set_updated_at         BEFORE UPDATE ON projects         FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();
CREATE TRIGGER repositories_set_updated_at     BEFORE UPDATE ON repositories     FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();
CREATE TRIGGER project_members_set_updated_at  BEFORE UPDATE ON project_members  FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();
CREATE TRIGGER tech_stack_set_updated_at       BEFORE UPDATE ON tech_stack_items FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();
CREATE TRIGGER vulnerabilities_set_updated_at  BEFORE UPDATE ON vulnerabilities  FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();

-- --- T2: lịch sử bất biến (BR-14) --------------------------------------
CREATE OR REPLACE FUNCTION trg_block_history_mutation() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'vulnerability_status_history là bất biến (BR-14): không cho phép % ', TG_OP
        USING ERRCODE = 'raise_exception';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER vsh_block_update BEFORE UPDATE ON vulnerability_status_history
    FOR EACH ROW EXECUTE FUNCTION trg_block_history_mutation();
CREATE TRIGGER vsh_block_delete BEFORE DELETE ON vulnerability_status_history
    FOR EACH ROW EXECUTE FUNCTION trg_block_history_mutation();

-- --- T3: không xóa lỗ hổng (BR-13) -------------------------------------
CREATE OR REPLACE FUNCTION trg_block_vuln_delete() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'Không được xóa lỗ hổng đã ghi nhận (BR-13)'
        USING ERRCODE = 'raise_exception';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER vuln_block_delete BEFORE DELETE ON vulnerabilities
    FOR EACH ROW EXECUTE FUNCTION trg_block_vuln_delete();

-- --- T4: mỗi dự án luôn còn ít nhất 1 PM (BR-08) -----------------------
-- CONSTRAINT TRIGGER DEFERRABLE: cho phép đổi PM trong cùng một giao dịch
CREATE OR REPLACE FUNCTION trg_project_needs_pm() RETURNS trigger AS $$
DECLARE
    v_project_id UUID;
    v_pm_count   INT;
    v_exists     BOOLEAN;
BEGIN
    v_project_id := COALESCE(OLD.project_id, NEW.project_id);

    SELECT EXISTS(SELECT 1 FROM projects WHERE id = v_project_id) INTO v_exists;
    IF NOT v_exists THEN
        RETURN NULL;   -- dự án đã bị xóa cùng giao dịch: không cần kiểm tra
    END IF;

    SELECT count(*) INTO v_pm_count
    FROM project_members
    WHERE project_id = v_project_id AND project_role = 'pm';

    IF v_pm_count = 0 THEN
        RAISE EXCEPTION 'Dự án phải có ít nhất một PM (BR-08)'
            USING ERRCODE = 'raise_exception';
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER project_members_require_pm
    AFTER UPDATE OR DELETE ON project_members
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION trg_project_needs_pm();

-- --- T5: hệ thống luôn còn ít nhất 1 Admin đang hoạt động (BR-05) ------
CREATE OR REPLACE FUNCTION trg_require_active_admin() RETURNS trigger AS $$
DECLARE
    v_admin_count INT;
BEGIN
    SELECT count(*) INTO v_admin_count
    FROM users
    WHERE role = 'admin' AND status = 'active';

    IF v_admin_count = 0 THEN
        RAISE EXCEPTION 'Hệ thống phải có ít nhất một quản trị viên đang hoạt động (BR-05)'
            USING ERRCODE = 'raise_exception';
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER users_require_active_admin
    AFTER UPDATE OR DELETE ON users
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION trg_require_active_admin();

-- =====================================================================
-- VIEWS phục vụ Dashboard và danh sách (giữ logic "còn mở" ở MỘT chỗ)
-- =====================================================================

CREATE VIEW v_open_vulnerabilities AS
SELECT v.*,
       (CURRENT_DATE - v.detected_date)                     AS days_open,
       ((CURRENT_DATE - v.detected_date) > 30)              AS is_overdue
FROM vulnerabilities v
WHERE v.status IN ('new','in_progress');

COMMENT ON VIEW v_open_vulnerabilities IS 'Định nghĩa DUY NHẤT của "còn mở" (BU §12) và "quá hạn 30 ngày" (DEC-08b).';

CREATE VIEW v_project_summary AS
SELECT p.id AS project_id,
       p.code,
       p.name,
       p.status,
       (SELECT count(*) FROM project_members  pm WHERE pm.project_id = p.id) AS member_count,
       (SELECT count(*) FROM tech_stack_items ts WHERE ts.project_id = p.id) AS tech_stack_count,
       (SELECT count(*) FROM repositories     r  WHERE r.project_id  = p.id) AS repository_count,
       count(ov.id) FILTER (WHERE ov.severity = 'critical') AS open_critical,
       count(ov.id) FILTER (WHERE ov.severity = 'high')     AS open_high,
       count(ov.id) FILTER (WHERE ov.severity = 'medium')   AS open_medium,
       count(ov.id) FILTER (WHERE ov.severity = 'low')      AS open_low,
       count(ov.id)                                          AS open_total
FROM projects p
LEFT JOIN v_open_vulnerabilities ov ON ov.project_id = p.id
GROUP BY p.id, p.code, p.name, p.status;

COMMENT ON VIEW v_project_summary IS 'Nguồn cho cột "Lỗ hổng còn mở" ở SCR-PRJ-10 và 3 ô chỉ số ở SCR-PRJ-20.';

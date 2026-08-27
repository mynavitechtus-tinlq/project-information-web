-- Kịch bản kiểm chứng: mỗi khối phải cho ra đúng kết quả mong đợi
\set ON_ERROR_STOP off
\pset pager off

-- ===== Dữ liệu nền =====
INSERT INTO users (id,email,full_name,password_hash,role,status,must_change_password,created_by,updated_by)
VALUES ('11111111-1111-1111-1111-111111111111','admin@cty.vn','Nguyen Van An','x','admin','active',false,NULL,NULL);
UPDATE users SET created_by=id, updated_by=id WHERE id='11111111-1111-1111-1111-111111111111';

INSERT INTO users (id,email,full_name,password_hash,role,status,created_by,updated_by) VALUES
 ('22222222-2222-2222-2222-222222222222','binh@cty.vn','Tran Thi Binh','x','user','active','11111111-1111-1111-1111-111111111111','11111111-1111-1111-1111-111111111111'),
 ('33333333-3333-3333-3333-333333333333','cuong@cty.vn','Le Van Cuong','x','user','active','11111111-1111-1111-1111-111111111111','11111111-1111-1111-1111-111111111111');

INSERT INTO projects (id,code,name,status,created_by,updated_by)
VALUES ('aaaaaaaa-0000-0000-0000-000000000001','PAYGW','Cổng thanh toán','live',
        '22222222-2222-2222-2222-222222222222','22222222-2222-2222-2222-222222222222');

INSERT INTO project_members (project_id,user_id,project_role,created_by,updated_by)
VALUES ('aaaaaaaa-0000-0000-0000-000000000001','22222222-2222-2222-2222-222222222222','pm',
        '22222222-2222-2222-2222-222222222222','22222222-2222-2222-2222-222222222222');

\echo '=== T01 BR-06 tên dự án trùng khác hoa/thường => PHẢI LỖI ==='
INSERT INTO projects (code,name,status,created_by,updated_by)
VALUES ('PAYGW2','  cổng THANH TOÁN  ','init','22222222-2222-2222-2222-222222222222','22222222-2222-2222-2222-222222222222');

\echo '=== T02 mã dự án sai định dạng (chữ thường) => PHẢI LỖI ==='
INSERT INTO projects (code,name,status,created_by,updated_by)
VALUES ('paygw3','Dự án ba','init','22222222-2222-2222-2222-222222222222','22222222-2222-2222-2222-222222222222');

\echo '=== T03 R-ENT-008 status=closed thiếu end_date => PHẢI LỖI ==='
INSERT INTO projects (code,name,status,created_by,updated_by)
VALUES ('CLOSED1','Dự án đã đóng','closed','22222222-2222-2222-2222-222222222222','22222222-2222-2222-2222-222222222222');

\echo '=== T04 R-ENT-005 tech stack trùng loại+tên khác hoa/thường => PHẢI LỖI ==='
INSERT INTO tech_stack_items (project_id,category,name,version,created_by,updated_by) VALUES
 ('aaaaaaaa-0000-0000-0000-000000000001','framework','Spring Boot','2.7.11','22222222-2222-2222-2222-222222222222','22222222-2222-2222-2222-222222222222');
INSERT INTO tech_stack_items (project_id,category,name,version,created_by,updated_by) VALUES
 ('aaaaaaaa-0000-0000-0000-000000000001','framework','spring boot','3.2.1','22222222-2222-2222-2222-222222222222','22222222-2222-2222-2222-222222222222');

\echo '=== T05 mã CVE sai định dạng => PHẢI LỖI ==='
INSERT INTO vulnerabilities (project_id,cve_id,library,affected_version,severity,created_by,updated_by)
VALUES ('aaaaaaaa-0000-0000-0000-000000000001','CVE-24-123','log4j-core','2.14.1','critical','22222222-2222-2222-2222-222222222222','22222222-2222-2222-2222-222222222222');

\echo '=== T06 ghi nhận lỗ hổng hợp lệ => PHẢI THÀNH CÔNG ==='
INSERT INTO vulnerabilities (id,project_id,cve_id,library,affected_version,severity,status,created_by,updated_by)
VALUES ('bbbbbbbb-0000-0000-0000-000000000001','aaaaaaaa-0000-0000-0000-000000000001','CVE-2024-12345','log4j-core','2.14.1','critical','new',
        '22222222-2222-2222-2222-222222222222','22222222-2222-2222-2222-222222222222');
INSERT INTO vulnerability_status_history (vulnerability_id,from_status,to_status,changed_by)
VALUES ('bbbbbbbb-0000-0000-0000-000000000001',NULL,'new','22222222-2222-2222-2222-222222222222');

\echo '=== T07 R-ENT-009 trùng (dự án+CVE+thư viện) khác hoa/thường => PHẢI LỖI ==='
INSERT INTO vulnerabilities (project_id,cve_id,library,affected_version,severity,created_by,updated_by)
VALUES ('aaaaaaaa-0000-0000-0000-000000000001','CVE-2024-12345','LOG4J-CORE','2.14.0','high','22222222-2222-2222-2222-222222222222','22222222-2222-2222-2222-222222222222');

\echo '=== T08 R-ENT-007 in_progress không có assignee => PHẢI LỖI ==='
UPDATE vulnerabilities SET status='in_progress' WHERE id='bbbbbbbb-0000-0000-0000-000000000001';

\echo '=== T09 in_progress CÓ assignee => PHẢI THÀNH CÔNG ==='
UPDATE vulnerabilities SET status='in_progress', assignee_id='33333333-3333-3333-3333-333333333333'
WHERE id='bbbbbbbb-0000-0000-0000-000000000001';

\echo '=== T10 R-ENT-002 resolved thiếu ghi chú => PHẢI LỖI ==='
UPDATE vulnerabilities SET status='resolved', resolved_date=CURRENT_DATE
WHERE id='bbbbbbbb-0000-0000-0000-000000000001';

\echo '=== T11 R-ENT-003 ngày xử lý TRƯỚC ngày ghi nhận => PHẢI LỖI ==='
UPDATE vulnerabilities SET status='resolved', resolved_date=CURRENT_DATE-400, resolution_note='xong'
WHERE id='bbbbbbbb-0000-0000-0000-000000000001';

\echo '=== T12 resolved đầy đủ => PHẢI THÀNH CÔNG ==='
UPDATE vulnerabilities SET status='resolved', resolved_date=CURRENT_DATE, resolution_note='Da nang log4j len 2.17.1'
WHERE id='bbbbbbbb-0000-0000-0000-000000000001';

\echo '=== T13 BR-13 xóa lỗ hổng => PHẢI LỖI ==='
DELETE FROM vulnerabilities WHERE id='bbbbbbbb-0000-0000-0000-000000000001';

\echo '=== T14 BR-14 sửa lịch sử => PHẢI LỖI ==='
UPDATE vulnerability_status_history SET note='sua trom' WHERE vulnerability_id='bbbbbbbb-0000-0000-0000-000000000001';

\echo '=== T15 BR-14 xóa lịch sử => PHẢI LỖI ==='
DELETE FROM vulnerability_status_history WHERE vulnerability_id='bbbbbbbb-0000-0000-0000-000000000001';

\echo '=== T16 BR-08 xóa PM cuối cùng => PHẢI LỖI ==='
DELETE FROM project_members
WHERE project_id='aaaaaaaa-0000-0000-0000-000000000001' AND user_id='22222222-2222-2222-2222-222222222222';

\echo '=== T17 BR-08 hạ vai trò PM cuối cùng => PHẢI LỖI ==='
UPDATE project_members SET project_role='dev'
WHERE project_id='aaaaaaaa-0000-0000-0000-000000000001' AND user_id='22222222-2222-2222-2222-222222222222';

\echo '=== T18 BR-08 CHUYỂN GIAO PM trong cùng 1 giao dịch => PHẢI THÀNH CÔNG (nhờ DEFERRABLE) ==='
BEGIN;
  INSERT INTO project_members (project_id,user_id,project_role,created_by,updated_by)
  VALUES ('aaaaaaaa-0000-0000-0000-000000000001','33333333-3333-3333-3333-333333333333','pm',
          '22222222-2222-2222-2222-222222222222','22222222-2222-2222-2222-222222222222');
  UPDATE project_members SET project_role='dev'
  WHERE project_id='aaaaaaaa-0000-0000-0000-000000000001' AND user_id='22222222-2222-2222-2222-222222222222';
COMMIT;
\echo '--- kiểm tra sau T18: phải có đúng 1 PM là Cuong ---'
SELECT u.full_name, pm.project_role FROM project_members pm JOIN users u ON u.id=pm.user_id
WHERE pm.project_id='aaaaaaaa-0000-0000-0000-000000000001' ORDER BY pm.project_role;

\echo '=== T19 BR-05 hạ vai trò Admin cuối cùng => PHẢI LỖI ==='
UPDATE users SET role='user' WHERE id='11111111-1111-1111-1111-111111111111';

\echo '=== T20 BR-05 khóa Admin cuối cùng => PHẢI LỖI ==='
UPDATE users SET status='locked' WHERE id='11111111-1111-1111-1111-111111111111';

\echo '=== T21 BR-05 có 2 Admin thì khóa 1 => PHẢI THÀNH CÔNG ==='
BEGIN;
  UPDATE users SET role='admin' WHERE id='22222222-2222-2222-2222-222222222222';
  UPDATE users SET status='locked' WHERE id='11111111-1111-1111-1111-111111111111';
COMMIT;
SELECT count(*) AS active_admins FROM users WHERE role='admin' AND status='active';

\echo '=== T22 VIEW v_project_summary => phải đếm đúng ==='
SELECT code, member_count, tech_stack_count, open_critical, open_total FROM v_project_summary;

\echo '=== T23 trigger updated_at có tự chạy không ==='
SELECT (updated_at > created_at) AS updated_at_moved FROM vulnerabilities WHERE id='bbbbbbbb-0000-0000-0000-000000000001';

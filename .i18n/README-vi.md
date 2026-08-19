# i18n

Source base mặc định cài đặt sẵn Tiếng Anh, Tiếng Nhật

Các messages đa ngôn ngữ có thể được quản lý bằng 1 trong 2 cách dưới đây

## Khai báo trực tiếp

Mặc định các file dịch ngôn ngữ sẽ được đặt trong thư mục `public/locales`, mỗi ngôn ngữ sẽ là 1 file đặt tên như bên dưới

```
public
└── locales
    ├── en
    |   ├──<namespace>.json
    |   └── index.ts
    ├── ja
    |   ├──<namespace>.json
    |   └── index.ts
    └── index.ts
```

## Quản lý thông qua file XLSX `(Recommended)`

Trước hết, cần hiểu về nhiệm vụ của mỗi file trong thư mục `.i18n`, có 2 files:

```
.i18n
├── script.js
└── source.xlsx
```

### File `script.js`

Chứa đoạn mã hỗ trợ việc import file XLSX sang message đa ngôn ngữ.

> **Khuyến cáo:**
>
> không nên thực hiện chỉnh sửa nội dung bên trong file `script.js` khi không cần thiết để tránh quá trình parse dữ liệu bị sai.

Việc thay đổi các thông tin mặc định trong file excel sẽ cần phải khai báo lại các options khi chạy command ([xem hướng dẫn](#import-command-options)), hoặc cập nhật lại các hằng số được cài đặt sẵn trong file `script.js` (không khuyến khích).

```js
const SOURCE_FILE = './i18n/source.xlsx'; // Đường dẫn tới file excel chứa đa ngôn ngữ
const OUTPUT_DIR = './public/locales'; // Thư mục chứa các file json sau khi import thành công
const SHEET_NAMES = 'Locale Messages'; // DS các sheet cần import, ngăn cách bởi dấu phẩy ","
const IGNORED_COLS = 'Screen ID, Note, Type, Description'; // DS các cột không cần thiết
```

### File `source.xlsx`

File excel chứa thông tin message ở nhiều ngôn ngữ khác nhau, với cấu trúc như sau:

| Screen ID | Key            | Module  | Type | Description          | Note | ja             | en            |
| --------- | -------------- | ------- | ---- | -------------------- | ---- | -------------- | ------------- |
| A001      | `form_title`   | `login` | Text | The login form title |      | ログイン         | Login         |
| A001      | `labels.email` | `login` | Text | The email label      |      | メールアドレス    | Email Address |

Sau khi khi import sẽ tạo ra các file yaml như sau:

- `ja/login.json`
  ```json
  "form_title": "ログイン",
  "labels": {
    "email": "メールアドレス"
  }
  ```
- `en/login.json`
  ```json
  "form_title": "Login",
  "labels": {
    "email": "Email Address"
  }
  ```

#### Giải thích

- Các cột `Screen ID`, `Note`, `Type`, `Description` là các cột chỉ có tác dụng mô tả, phục vụ người đọc và tìm kiếm dễ dàng hơn, sẽ bị bỏ qua trong quá trình import.
- Cột `Key` và `Module` sẽ là căn cứ để tạo ra các keys cho file `json`. Key có thể phân cấp bằng cách dấu chấm (.)
- Cột `ja`, `en` chứa text được dịch sang các ngôn ngữ tương ứng. Nếu có thêm ngôn ngữ mới, chỉ cần thêm một cột vào phía sau, quá trình import sẽ tự động tạo ra ngôn ngữ mới.

#### Best practices

- ❌ Không nên thay các tên cột hoặc thêm cột **trừ khi mục đích muốn thêm ngôn ngữ mới**.
- ✅ Thực hiện cập nhật trực tiếp file `source.xlsx` trên MS Excel hoặc Google Sheet rồi lưu lại định dạng xlsx sau đó [chạy lệnh import](#import-command), tránh bị miss message khi sửa trực tiếp trong các file `json`.
- ✅ Nên điền cột `Module` để nhóm các message liên quan lại một nhóm cho dễ quản lý. Khuyến khích sử dụng dấu chấm (.) cho cột `Key` để phân cấp key nếu cần.
- ✅ Với các dự án lớn, có thể chia ra nhiều sheets nhỏ để dễ quản lý, tránh 1 sheet quá dài.

### Import command

Chạy lệnh bên dưới để chuyển message từ file XLSX sang các file json

```bash
$ npm run i18n:import
```

Trên màn hình console sẽ xuất hiện thông tin xác nhận trước khi import.

```
🛠  Import language from XLSX file

Input file:
  • Path: 		 /Users/<user_name>/Projects/nals-fe-reactjs/.i18n/source.xlsx
  • Size: 		 29 KB
  • Last updated at: 	 12/26/2022, 4:40:12 PM
  • Found locales: 	 ja-JP, en-US, vi-VN
  • Total rows: 	 7 rows
Output directory:
  • Path: 		  /Users/<user_name>/Projects/nals-fe-reactjs/public/locales

Current json files (if any) will be overwritten, do you want to continue? (Y/n)
```

gõ `Y` (yes) và nhấn `enter` để tiếp tục.

> **Chú ý:**
>
> Các file ngôn ngữ có sẵn trong thư mục `i18n` nếu trùng tên với các ngôn ngữ được phát hiện sẽ bị ghi đè.

Sau khi quá trình import kết thúc sẽ có thông báo trên console

```
 ✔ Imported /public/locales/ja/errors.json
 ✔ Imported /public/locales/en/errors.json

✨  Imported successful 2 languages in 9.17ms.
```

### Import command options

- `--source` đường dẫn tới **file** xlsx, có thể là đường dẫn relative hoặc absolute, mặc định là `.i18n/source.xlsx`. VD:

  ```bash
    $ npm run i18n:import --source /users/root/Downloads/MessageList.xlsx
    # or
    $ npm run i18n:import --source ./i18n/messages.xlsx
  ```

- `--out-dir` đường dẫn tới **thư mục** chứa các file `json` sau khi import. Có thể sử dụng đường dẫn relative lẫn absolute, mặc định là `./public/locales`.
  ```bash
    $ npm run i18n:import --out-dir ./i18n
  ```
- `--sheet-names` danh sách tên các sheet trong file xlsx, ngăn cách nhau bởi dấu phẩy, mặc định là sheet `"Locale Messages"`
  ```bash
    $ npm run i18n:import --sheet-names "Locale Messages, API Messages, Common Messages"
  ```
- `--ignored-cols` danh sách tên các columns bị bỏ qua, ngăn cách nhau bởi dấu phẩy, mặc định các columns `Screen ID`, `Note`, `Type`, `Description` sau sẽ bị bỏ qua. Trường hợp cấu trúc file xlsx bị thay đổi, ví dụ có thêm 1 colum, hãy đảm bảo bạn có thêm column đó vào trong lệnh import:
  ```bash
    $ npm run i18n:import --ignored-cols "No, Screen ID, Note, Type, Description"
  ```

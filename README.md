# KTGK OS 2000 — Quản lý sản phẩm (Flutter + Firebase)

Ứng dụng quản trị sản phẩm (thêm / hiển thị / sửa / xóa) chạy trên **Web** và **Android**, giao diện phong cách **Y2K "retro desktop"** (cửa sổ vát nổi, thanh tiêu đề gradient, taskbar, font pixel).

| Thành phần | Công nghệ |
|---|---|
| Framework | Flutter 3.41 (Dart 3.11) |
| Cơ sở dữ liệu | Firebase Cloud Firestore, collection `products` |
| Đăng nhập | Firebase Authentication (Email/Mật khẩu) |
| Lưu ảnh | Cloudinary (unsigned upload) — chỉ lưu **URL** vào trường `image` |

## Cấu trúc CSDL

Collection `products`, mỗi document có **đúng 4 trường** (không thêm trường nào khác):

| Trường | Kiểu | Ý nghĩa |
|---|---|---|
| `name` | string | Tên sản phẩm |
| `price` | number | Giá (VNĐ) |
| `soluong` | int | Số lượng |
| `image` | string | URL hình ảnh (Cloudinary) |

Firestore Rules ([database/firestore.rules](database/firestore.rules)) chặn mọi ghi dữ liệu có trường khác 4 trường trên.
File dữ liệu xuất ra: [database/products.json](database/products.json).

## Chức năng

- Đăng nhập / đăng xuất (Firebase Auth), chỉ admin đã đăng nhập mới đọc/ghi được dữ liệu.
- Thêm sản phẩm: nhập tên, giá, số lượng, chọn ảnh (web: chọn file; Android: thư viện hoặc máy ảnh), tải ảnh lên Cloudinary có thanh tiến trình.
- Hiển thị danh sách dạng lưới, cập nhật realtime.
- Sửa, xóa (có hộp thoại xác nhận).
- Tìm kiếm theo tên (không phân biệt dấu: "giay" tìm được "Giày").
- Sắp xếp theo tên / giá tăng / giá giảm / số lượng; lọc Tất cả / Còn hàng / Hết hàng.
- Xem chi tiết sản phẩm (cửa sổ "Thuộc tính").
- Xuất toàn bộ CSDL ra `products.json` (menu Tệp › Xuất JSON).
- Kiểm tra dữ liệu nhập (giá, số lượng là số ≥ 0; bắt buộc có ảnh).

## Cài đặt & chạy

```bash
# 1. Cài thư viện
cd product_admin
flutter pub get

# (các thư viện đã dùng)
flutter pub add firebase_core firebase_auth cloud_firestore image_picker dio intl web

# 2. Chạy trên Web
flutter run -d web-server --web-port 8080      # mở http://localhost:8080
# hoặc bản release:
flutter build web --release && python3 -m http.server 8082 -d build/web

# 3. Chạy trên Android (điện thoại bật USB debugging)
flutter devices
flutter run -d <device-id>
# hoặc cài APK:
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk

# 4. Xem thử giao diện không cần Firebase (dữ liệu mẫu trong bộ nhớ)
flutter run -d web-server --web-port 8081 -t lib/main_preview.dart

# 5. Kiểm thử
flutter analyze
flutter test
```

Cấu hình Firebase nằm ở `lib/firebase_options.dart`, Cloudinary ở `lib/config.dart`
(các giá trị này là định danh công khai phía client, dữ liệu được bảo vệ bằng Auth + Firestore Rules).
Hướng dẫn tạo project Firebase/Cloudinary: [docs/SETUP_CONSOLE.md](docs/SETUP_CONSOLE.md).

## Cấu trúc mã nguồn

```
product_admin/lib/
├── main.dart                  # Khởi tạo Firebase, màn hình khởi động, AuthGate
├── main_preview.dart          # Chế độ xem thử giao diện (dữ liệu mẫu)
├── config.dart                # Cloudinary cloud name + upload preset
├── firebase_options.dart      # Cấu hình Firebase Web + Android
├── models/product.dart        # Product {name, price, soluong, image}
├── services/
│   ├── auth_service.dart      # Đăng nhập / đăng xuất, thông báo lỗi tiếng Việt
│   ├── product_service.dart   # CRUD Firestore + xuất JSON
│   ├── cloudinary_service.dart# Upload ảnh (dio, có tiến trình)
│   └── file_saver*.dart       # Tải file JSON trên web
├── screens/                   # boot, login, product_list, product_form, product_detail
├── widgets/product_card.dart  # Thẻ sản phẩm dạng "cửa sổ mini"
└── ui/                        # Bộ widget retro: Bevel, RetroWindow, RetroButton, dialog, menu, taskbar, PixelIcon…
```

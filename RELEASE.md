# Phát hành OTA qua GitHub Releases

Repo: https://github.com/uchihaobitook/gym-coach

## Yêu cầu

- Repo phải **Public** (hoặc app không tải được APK từ GitHub).
- Mỗi bản mới phải tăng `version` trong `pubspec.yaml`, ví dụ `1.0.1+2`.
- Số sau dấu `+` là **build number** — app so sánh số này để biết có bản mới.

## Các bước mỗi lần phát hành

1. Sửa `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2
   ```

2. Build APK:
   ```powershell
   flutter build apk --release
   ```

3. Trên GitHub → **Releases** → **Draft a new release**
   - **Tag:** `1.0.1+2` (khớp với pubspec)
   - **Title:** `Gym Coach 1.0.1`
   - **Attach:** `build/app/outputs/flutter-apk/app-release.apk`
   - **Publish release**

4. Mở app trên điện thoại → tự báo cập nhật (hoặc Cài đặt → Kiểm tra cập nhật).

## Lưu ý ký APK

- Các bản OTA phải dùng **cùng chữ ký** (cùng keystore).
- Nếu đổi chữ ký, phải gỡ app cũ và cài lại một lần.

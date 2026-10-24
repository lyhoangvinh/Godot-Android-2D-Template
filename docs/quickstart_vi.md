# Hướng dẫn nhanh (Tiếng Việt)

## Mở project

1. Tải **Godot 4.7.2 Standard** cho Windows. Không cần bản .NET/C#.
2. Giải nén ZIP rồi mở `project.godot` trong Project Manager của Godot.
3. Chạy bằng **F5**. Game demo kiểu top-down: di chuyển bằng **WASD/mũi tên** hoặc joystick cảm ứng góc trái; nhặt đồng xu và tránh quái màu hồng.
4. Vào `features/` để đọc từng phần. Luồng khởi động ở `app/main.gd`, logic gameplay ở `arena_world.gd`, dữ liệu lưu ở `core/persistence/`.
5. Chạy `python tools/validate_project.py` và `tools/test_godot.ps1` như README.

## Điều cần ghi nhớ

- **Không phải game thương mại hoàn chỉnh.** AdMob và Billing thật CHƯA được tích hợp. Nút quảng cáo giả chỉ dành cho Godot Editor và bị ẩn khi export.
- **Không có file ký JKS trong template.** File ký từng game tạo bằng Android Studio, cất riêng trên máy. Project mới phải thiết lập package name riêng, Android export preset riêng.
- File save nằm trong `user://`, format JSON phiên bản 2, có migration v1 và backup. Thêm dữ liệu lưu mới phải đi cùng test migration.
- Mỗi game mới tạo bằng nút **Use this template** trên GitHub hoặc copy bộ base đã test. Ghi lại tag/commit base trong README game.
- Template không tự đồng bộ tới các game đã xuất phát từ đó; cập nhật phiên bản cần nhánh, test, kiểm tra Android rồi mới merge.

## Bắt đầu học Godot từ đâu?

- `Node`: thành phần chức năng; `Scene (.tscn)`: tập hợp node, có thể tái sử dụng.
- `Script (.gd)`: code chạy theo Node; `Resource (.tres)`: dữ liệu cấu hình; `Signal`: giao tiếp sự kiện.
- `SceneTree`: cấu trúc sống của game; khác với Git tree hay thư mục source.
- `_ready`, `_process`, `_physics_process`: vòng đời/nhịp cập nhật Godot.
- `Area2D`, `CharacterBody2D`, `CollisionShape2D`, `Input Map`, `CanvasLayer`: các công cụ gameplay chính.

## Sau khi nhập project và chạy được

Commit source và file `.gd.uid` (nếu Godot tạo) lên repository của bạn. Không commit cache `.godot/`. Muốn xuất Android AAB thì cần cài Android SDK, Godot export templates và Gradle Build Template theo `docs/android_release.md`.

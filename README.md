# Premium Windows Dev Server (GitHub Actions RDP)

Môi trường máy chủ Windows RDP chạy trên GitHub Actions (`windows-2022`), được tối ưu hóa cho tốc độ khởi động (Zero-Wait RDP), trải nghiệm viết code và dịch ngược mã nguồn (Reverse Engineering).

## Cấu Trúc Dự Án

```
d:\99\
├── .github/
│   └── workflows/
│       ├── blank.yml            # Pipeline chính khởi tạo server & Cloudflare Tunnel 1
│       └── blank2.yml           # Pipeline phụ sử dụng Cloudflare Tunnel 2
├── assets/
│   └── recaf.ico                # Icon cho Recaf 4.x shortcut
├── docs/                        # Tài liệu đặc tả và kế hoạch thực hiện
└── scripts/                     # Toàn bộ script cài đặt và tối ưu hóa
    ├── cloudflared.bat          # Cài đặt và cấu hình Cloudflare Tunnel service
    ├── install.bat              # Script cài đặt chính (gọi trong workflow runner)
    ├── recaf.bat                # Script tải và cấu hình Recaf 4.x
    ├── setup-performance.ps1    # Tối ưu Windows Defender exclusions & RDP Graphics
    ├── setup-profile.ps1        # Cấu hình PowerShell profile với hàm set-java
    ├── setup-shortcuts.ps1      # Tự động tạo Desktop shortcuts cho các công cụ dev
    ├── sleep.bat                # Duy trì runner hoạt động
    └── uninstall.bat            # Gỡ bỏ các phần mềm mặc định không cần thiết
```

## Các Tính Năng Đã Tối Ưu

1. **Zero-Wait RDP**:
   - Toàn bộ công cụ (VS Code, IntelliJ IDEA, Antigravity IDE, Ghidra, Recaf 4.x, Bun, AI agents) được cài đặt trước (pre-installed) ngay trong GitHub Actions runner.
   - Khi kết nối RDP vào máy, toàn bộ ứng dụng đã sẵn sàng 100% trên màn hình Desktop.

2. **Chuyển Đổi Nhanh Phiên Bản Java (`set-java`)**:
   - Tận dụng kho JDK có sẵn của runner (`C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk`).
   - Mở terminal PowerShell và gõ:
     ```powershell
     set-java 8    # Đổi sang OpenJDK 8
     set-java 11   # Đổi sang OpenJDK 11
     set-java 17   # Đổi sang OpenJDK 17
     set-java 21   # Đổi sang OpenJDK 21
     set-java 25   # Đổi sang OpenJDK 25
     ```

3. **Mượt Mà & Không Giật Lag (Performance)**:
   - Thư mục code (`D:\`), toolcache và các tiến trình dev (`java.exe`, `node.exe`, `bun.exe`, `code.exe`, `git.exe`) đã được thêm vào danh sách loại trừ (Exclusion) của Windows Defender, giúp compile code và thao tác file cực nhanh.
   - Tinh chỉnh đồ họa RDP: Tắt animation chuyển cảnh của Windows, giữ font ClearType sắc nét.

# Premium Windows Dev Server (GitHub Actions)

Môi trường máy chủ Windows chạy trên GitHub Actions (`windows-2022`), được tối ưu hóa cho tốc độ khởi động (Zero-Wait), trải nghiệm viết code và dịch ngược mã nguồn (Reverse Engineering).

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
    ├── install.bat              # Script cài đặt chính (gọi qua Scheduled Task onlogon)
    ├── paseo.bat                # Script tải và cài đặt Paseo Desktop & CLI
    ├── recaf.bat                # Script tải và cấu hình Recaf 4.x
    ├── setup-performance.bat    # Tối ưu Windows Defender exclusions & Graphics
    ├── sleep.bat                # Duy trì runner hoạt động
    └── uninstall.bat            # Gỡ bỏ các phần mềm mặc định không cần thiết
```

## Các Tính Năng Đã Tối Ưu

1. **Khởi Động Siêu Tốc & Cài Đặt Tự Động**:
   - Pipeline GitHub Actions sẵn sàng kết nối chỉ trong 15-30 giây (tạo user, đăng ký Scheduled Task, mở Cloudflare Tunnel).
   - Khi đăng nhập vào `ServerPremium`, Scheduled Task kích hoạt `scripts/install.bat` để cài đặt đầy đủ các ứng dụng người dùng (`antigravity-ide`, `bun`, `opencode`, `pi`, `paseo` (Desktop & CLI), `unikey`, `intellijidea-community 2024.3`, `ghidra`, `recaf`, v.v.).

2. **Mượt Mà & Không Giật Lag (Performance)**:
   - Thư mục code (`D:\`), toolcache và các tiến trình dev (`java.exe`, `node.exe`, `bun.exe`, `code.exe`, `git.exe`) đã được thêm vào danh sách loại trừ (Exclusion) của Windows Defender, giúp compile code và thao tác file cực nhanh.
   - Tinh chỉnh đồ họa: Tắt animation chuyển cảnh của Windows, giữ font ClearType sắc nét.

3. **Tối Ưu Dung Lượng & Dọn Sạch Bloatware (`uninstall.bat`)**:
   - Tự động tắt và vô hiệu hóa các service chạy ngầm tốn RAM/CPU: Docker, IIS (`W3SVC`), `SQLWriter`, `MySQL`, `PostgreSQL`, `MongoDB`.
   - Gỡ bỏ các ứng dụng và database cồng kềnh: Azure Cosmos DB Emulator, MongoDB, MySQL, PostgreSQL, Epic Games Launcher, Unity Hub.
   - Dọn sạch các bộ toolchain/SDK dung lượng lớn không cần thiết (Android SDK/NDK, Haskell GHCup, Julia, Miniconda, R/Rtools, LLVM, InnoSetup/NSIS), giải phóng hơn 40 - 50 GB dung lượng ổ C.


# Thiết Kế Tối Ưu Tốc Độ Setup & Trải Nghiệm Viết Code (GitHub Actions Windows RDP)

## 1. Mục tiêu (Goals)
- **Zero-Wait RDP**: Loại bỏ việc phải chờ 10-15 phút sau khi đăng nhập RDP để cài đặt phần mềm. Mọi IDE, Java, Ghidra, Recaf, AI agent đều sẵn sàng ngay khi kết nối.
- **Tận dụng tài nguyên có sẵn**: Sử dụng trực tiếp Java 8, 11, 17, 21, 25 trong `C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk`, loại bỏ việc tải lại bằng Chocolatey.
- **Tối ưu trải nghiệm lập trình (DX)**: Cung cấp PowerShell Profile tiện ích với lệnh switch Java nhanh (`set-java`), alias cho Git và AI agents (`pi`, `opencode`), tự động tạo Desktop shortcut cho toàn bộ công cụ.
- **Tối ưu hiệu năng Windows & RDP**: Loại trừ Windows Defender cho các thư mục lập trình và tiến trình dev; tắt animations để cuộn màn hình và gõ phím qua RDP mượt mà nhất.

---

## 2. Kiến trúc & Các thành phần chính

### 2.1. Module Tối ưu Hệ thống & Hiệu năng RDP (`setup-performance.ps1`)
Chạy với quyền Administrator ngay khi khởi tạo runner:
- **Windows Defender Exclusions**:
  - Paths: `d:\`, `C:\hostedtoolcache`, `C:\Users\ServerPremium`, `C:\ProgramData\chocolatey`, `C:\Cloudflared`.
  - Processes: `java.exe`, `javaw.exe`, `node.exe`, `bun.exe`, `code.exe`, `git.exe`.
  - Mục đích: Tăng tốc độ disk I/O khi build Java, chạy package manager, gõ code không bị CPU 100%.
- **RDP Visual Performance**:
  - Tắt hiệu ứng hoạt họa Windows (VisualFXSetting = 2, UserPreferencesMask, MenuShowDelay = 0).
  - Giữ lại font smoothing (ClearType) để chữ nét nhưng không bị trễ băng thông RDP.

### 2.2. Module Cài đặt & Cấu hình Công cụ (`setup-tools.ps1` / `install.bat`)
Chạy trực tiếp trong pipeline GitHub Actions:
- **Tận dụng Java Toolcache**:
  - Cấu hình mặc định `JAVA_HOME` trỏ tới `C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\17.0.20-101` (hoặc 21).
  - Cấu hình Ghidra sử dụng Java 17/21 từ toolcache mà không cần tải JDK mới.
- **Tối ưu cài đặt Chocolatey**:
  - Bỏ `temurin17`, `temurin8`.
  - Chỉ cài đặt các ứng dụng cần thiết: `vscode`, `github-desktop`, `intellijidea-community`, `antigravity-ide`, `ghidra` với cờ `--no-progress --yes`.
- **Cài đặt Bun & AI Coding Agents**:
  - Cài đặt Bun qua script chính thức.
  - Cài đặt `@earendil-works/pi-coding-agent` và `opencode-ai` global.
- **Tích hợp Recaf 4.x**:
  - Tự động tải Recaf 4.x và liên kết với Java 25 trong toolcache.
- **Tự động tạo Desktop Shortcuts**:
  - Tạo shortcut trên màn hình chính của `ServerPremium`:
    - IntelliJ IDEA Community
    - Antigravity IDE
    - VS Code
    - GitHub Desktop
    - Ghidra
    - Recaf 4.x

### 2.3. Module PowerShell Profile (`Microsoft.PowerShell_profile.ps1`)
Tự động copy vào thư mục Profile của user `ServerPremium` (`Documents\PowerShell\Microsoft.PowerShell_profile.ps1` & `WindowsPowerShell`):
- **Hàm `set-java`**:
  ```powershell
  function set-java($version) { ... }
  ```
  Cho phép chuyển đổi linh hoạt giữa các JDK trong toolcache:
  - `set-java 8` -> Java 8.0.504-1
  - `set-java 11` -> Java 11.0.32-101
  - `set-java 17` -> Java 17.0.20-101
  - `set-java 21` -> Java 21.0.12-101.0
  - `set-java 25` -> Java 25.0.4-101.0
- **Git Aliases**:
  - `gs` -> `git status`
  - `ga` -> `git add`
  - `gc` -> `git commit`
  - `gp` -> `git push`
  - `gl` -> `git log --oneline -n 10`
  - `gd` -> `git diff`
- **AI Agent Aliases**:
  - `pi` -> `bunx @earendil-works/pi-coding-agent` hoặc `pi-coding-agent`
  - `open` -> `opencode-ai`
- **IDE Aliases**:
  - `c` / `code` -> VS Code
  - `idea` -> IntelliJ IDEA

### 2.4. Tối ưu Workflows (`.github/workflows/blank.yml` & `blank2.yml`)
Quy trình thực thi tuần tự trong GitHub Actions:
1. `Checkout`: Kéo mã nguồn về.
2. `Tối ưu hệ thống (System & Defender Optimization)`: Chạy `setup-performance.ps1`.
3. `Cài đặt công cụ (Pre-install Dev Tools)`: Chạy `setup-tools.ps1` (hoặc `install.bat` đã nâng cấp).
4. `Tạo User & Phân quyền`: Tạo user `ServerPremium`.
5. `Cấu hình Profile & Shortcuts`: Triển khai profile và shortcuts vào profile của `ServerPremium`.
6. `Khởi động Cloudflare Tunnel`: Mở tunnel kết nối.
7. `Show credentials & Keep alive`: In thông tin kết nối và duy trì runner.

*(Khi người dùng đăng nhập qua RDP, máy đã sẵn sàng 100%, không còn Scheduled Task Installer gây chặn thao tác)*

---

## 3. Kế hoạch Kiểm tra (Verification Plan)
- Chạy thử nghiệm script tối ưu và profile trong môi trường runner hiện tại.
- Kiểm tra tính hợp lệ của `set-java 8`, `17`, `21`, `25`.
- Kiểm tra Defender exclusions và Registry RDP.
- Kiểm tra shortcuts trên Desktop và Start Menu.
- Commit toàn bộ thay đổi và chuẩn bị workflow mới.

# Chạy một lần trong PowerShell tại thư mục nhac-viec-flutter:
#   powershell -ExecutionPolicy Bypass -File .\setup-git.ps1
# Yêu cầu: đã cài Git và đăng nhập GitHub trên máy (Git Credential Manager sẽ hỏi khi push lần đầu).
$ErrorActionPreference = "Stop"
$remote = "https://github.com/1250080044-PhamMinhGiang-12DHCNPM1/Xay_dung_ung_dung_quan_ly_nhac_nho_cong_viec_ca_nhan.git"

if (-not (Test-Path ".git")) { git init }
git checkout -B main
git add .
git commit -m "chore: khởi tạo tài liệu, script DB và khung thư mục dự án"
if (-not (git remote | Select-String -Quiet "^origin$")) { git remote add origin $remote }
git push -u origin main

$branches = "dev-giang", "dev-bao", "dev-hieu", "dev-an", "debug", "test"
foreach ($b in $branches) {
    git branch $b main
    git push -u origin $b
}
git checkout main
git branch -a
Write-Host "Xong. Các nhánh đã có trên GitHub."

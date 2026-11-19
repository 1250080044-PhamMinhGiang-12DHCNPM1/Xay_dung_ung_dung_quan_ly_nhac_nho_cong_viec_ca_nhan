# Task 05 — Đăng nhập bằng Gmail (Giang)
- [ ] Hướng dẫn tạo OAuth Client trên Google Cloud Console (Android client với SHA-1 debug, Web client để lấy serverClientId); ghi vào `docs/explain/google-login.md`.
- [ ] Flutter: package `google_sign_in`, nút "Đăng nhập bằng Google" ở màn đăng nhập, lấy `idToken` gửi `POST /auth/google`.
- [ ] API: xác minh idToken bằng `Google.Apis.Auth` (`GoogleJsonWebSignature.ValidateAsync`, audience = Web ClientId); có user theo email thì gắn GoogleId, chưa có thì tạo Member với `EmailConfirmed=1`; trả JWT như login.
- [ ] Tài khoản bị khóa vẫn bị chặn.

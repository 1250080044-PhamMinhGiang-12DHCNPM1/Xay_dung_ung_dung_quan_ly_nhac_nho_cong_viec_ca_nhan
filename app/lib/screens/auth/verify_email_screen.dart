import 'package:flutter/material.dart';

import '../../core/validators.dart';
import '../../services/auth_service.dart';
import '../../widgets/resend_otp_button.dart';

/// Nhập mã OTP xác thực email (sau khi đăng ký, hoặc khi đăng nhập bị báo chưa xác thực).
/// Xác thực thành công → pop(true).
class VerifyEmailScreen extends StatefulWidget {
  final String email;

  /// true nếu mã vừa được gửi (đăng ký xong) → nút gửi lại phải chờ 60 giây.
  final bool codeJustSent;

  const VerifyEmailScreen({super.key, required this.email, this.codeJustSent = true});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final message = await _authService.verifyEmail(widget.email, _codeController.text);
      if (!mounted) return;
      _showMessage(message);
      Navigator.of(context).pop(true);
    } catch (e) {
      // Sai mã: API báo số lần thử còn lại; sai 5 lần thì mã bị hủy, cần gửi lại
      _showMessage(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _resend() async {
    try {
      _showMessage(await _authService.resendOtp(widget.email, 'VerifyEmail'));
      _codeController.clear();
      return true;
    } catch (e) {
      _showMessage(e.toString());
      return false;
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác thực email')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.mark_email_read_outlined, size: 64),
              const SizedBox(height: 12),
              Text(
                'Nhập mã 6 số đã gửi tới\n${widget.email}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              const Text('Mã có hiệu lực 5 phút, nhập sai 5 lần sẽ bị hủy.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextFormField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, letterSpacing: 12),
                decoration: const InputDecoration(hintText: '••••••', counterText: ''),
                validator: Validators.otp,
                onFieldSubmitted: (_) => _verify(),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loading ? null : _verify,
                child: _loading
                    ? const SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Xác thực'),
              ),
              ResendOtpButton(
                onResend: _resend,
                initialSeconds: widget.codeJustSent ? 60 : 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

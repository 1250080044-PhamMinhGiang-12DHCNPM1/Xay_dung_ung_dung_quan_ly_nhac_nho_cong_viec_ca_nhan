import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/validators.dart';
import '../../providers/auth_provider.dart';
import 'forgot_password_screen.dart';
import 'verify_email_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().login(_emailController.text, _passwordController.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } on ApiException catch (e) {
      if (!mounted) return;
      // 403 "chưa xác thực email" (khi bật RequireEmailConfirmation) → mời nhập mã OTP
      if (e.statusCode == 403 && e.message.contains('xác thực email')) {
        await _askVerifyEmail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _askVerifyEmail() async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chưa xác thực email'),
        content: const Text('Bạn cần nhập mã OTP đã gửi qua email trước khi đăng nhập.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Để sau')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Nhập mã')),
        ],
      ),
    );
    if (go != true || !mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
      // Có thể mã cũ đã hết hạn → cho bấm "Gửi lại mã" ngay
      builder: (_) => VerifyEmailScreen(email: _emailController.text.trim(), codeJustSent: false),
    ));
  }

  Future<void> _openForgotPassword() async {
    final email = await Navigator.of(context).push<String>(MaterialPageRoute(
      builder: (_) => ForgotPasswordScreen(initialEmail: _emailController.text.trim()),
    ));
    if (email != null) {
      _emailController.text = email;
      _passwordController.clear();
    }
  }

  Future<void> _openRegister() async {
    // Màn đăng ký trả về email vừa đăng ký để điền sẵn
    final email = await Navigator.of(context).pushNamed('/register');
    if (email is String) _emailController.text = email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.alarm_on, size: 72, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 8),
                  Text('Đăng nhập',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                        labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => Validators.required(v, 'Vui lòng nhập mật khẩu'),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Đăng nhập'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loading ? null : _openRegister,
                    child: const Text('Chưa có tài khoản? Đăng ký'),
                  ),
                  TextButton(
                    onPressed: _loading ? null : _openForgotPassword,
                    child: const Text('Quên mật khẩu?'),
                  ),
                  // Task 05 (Giang): nút "Đăng nhập bằng Google".
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

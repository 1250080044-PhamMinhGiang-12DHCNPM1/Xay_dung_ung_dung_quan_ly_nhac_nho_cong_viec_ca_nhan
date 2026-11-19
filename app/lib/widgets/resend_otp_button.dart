import 'dart:async';

import 'package:flutter/material.dart';

/// Nút "Gửi lại mã" có đếm ngược 60 giây (khớp giới hạn gửi lại của API).
/// [onResend] trả về true nếu gửi thành công → bắt đầu đếm ngược lại.
class ResendOtpButton extends StatefulWidget {
  final Future<bool> Function() onResend;

  /// Số giây chờ ban đầu (60 nếu mã vừa được gửi, 0 nếu cho bấm ngay).
  final int initialSeconds;

  const ResendOtpButton({super.key, required this.onResend, this.initialSeconds = 60});

  @override
  State<ResendOtpButton> createState() => _ResendOtpButtonState();
}

class _ResendOtpButtonState extends State<ResendOtpButton> {
  static const _cooldown = 60;
  Timer? _timer;
  int _secondsLeft = 0;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _start(widget.initialSeconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Đếm ngược mỗi giây; về 0 thì cho bấm lại.
  void _start(int seconds) {
    _timer?.cancel();
    setState(() => _secondsLeft = seconds);
    if (seconds <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) t.cancel();
    });
  }

  Future<void> _resend() async {
    setState(() => _sending = true);
    final ok = await widget.onResend();
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) _start(_cooldown);
  }

  @override
  Widget build(BuildContext context) {
    final waiting = _secondsLeft > 0;
    return TextButton(
      onPressed: waiting || _sending ? null : _resend,
      child: Text(waiting ? 'Gửi lại mã sau $_secondsLeft giây' : 'Gửi lại mã'),
    );
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:task_reminder/core/validators.dart';
import 'package:task_reminder/models/session.dart';

void main() {
  group('Validators', () {
    test('email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('abc'), isNotNull);
      expect(Validators.email('a@b.vn'), isNull);
    });

    test('password tối thiểu 6 ký tự', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });
  });

  test('Session đọc từ response đăng nhập và lưu/đọc SQLite map', () {
    final session = Session.fromLoginJson({
      'token': 'abc',
      'expiresAt': '2030-01-01T00:00:00Z',
      'user': {'id': 1, 'email': 'admin@nhacviec.local', 'fullName': 'Quản trị viên', 'role': 'Admin'},
    });
    expect(session.isAdmin, isTrue);
    expect(session.isExpired, isFalse);

    final restored = Session.fromMap(session.toMap());
    expect(restored.token, 'abc');
    expect(restored.expiresAt, session.expiresAt);
  });
}

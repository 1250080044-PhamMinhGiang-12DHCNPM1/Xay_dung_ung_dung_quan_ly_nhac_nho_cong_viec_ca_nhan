/// Hiển thị số phút dạng dễ đọc: 45 → "45 phút", 90 → "1 giờ 30 phút", 120 → "2 giờ".
String formatMinutes(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '$m phút';
  return m == 0 ? '$h giờ' : '$h giờ $m phút';
}

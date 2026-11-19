import 'package:flutter/material.dart';

/// Màn hình tạm cho các module chưa làm. Người phụ trách thay bằng màn hình thật.
class PlaceholderView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String owner;

  const PlaceholderView({
    super.key,
    required this.icon,
    required this.title,
    required this.owner,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Đang phát triển - $owner',
                style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

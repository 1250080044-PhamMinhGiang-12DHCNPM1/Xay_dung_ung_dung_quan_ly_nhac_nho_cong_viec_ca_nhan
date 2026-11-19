import 'package:flutter/material.dart';

import '../core/config.dart';

/// Ảnh lấy từ API (/uploads/...). Không có ảnh hoặc tải lỗi thì hiện icon thay thế.
class AppNetworkImage extends StatelessWidget {
  final String? path;
  final double width;
  final double height;
  final IconData fallbackIcon;
  final BorderRadius borderRadius;

  const AppNetworkImage({
    super.key,
    required this.path,
    this.width = 56,
    this.height = 56,
    this.fallbackIcon = Icons.image_outlined,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(fallbackIcon, color: Theme.of(context).colorScheme.onSurfaceVariant),
    );

    final url = AppConfig.imageUrl(path);
    return ClipRRect(
      borderRadius: borderRadius,
      child: url.isEmpty
          ? fallback
          : Image.network(
              url,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            ),
    );
  }
}

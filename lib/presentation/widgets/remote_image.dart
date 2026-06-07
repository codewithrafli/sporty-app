import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class RemoteImage extends StatelessWidget {
  const RemoteImage({
    required this.url,
    super.key,
    this.fit = BoxFit.cover,
    this.fallbackAsset = 'assets/images/run3.png',
  });

  final String? url;
  final BoxFit fit;
  final String fallbackAsset;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Image.asset(fallbackAsset, fit: fit);
    }

    return CachedNetworkImage(
      imageUrl: url!,
      fit: fit,
      placeholder: (context, value) => const ColoredBox(
        color: AppColors.border,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, value, error) =>
          Image.asset(fallbackAsset, fit: fit),
    );
  }
}

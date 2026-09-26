import 'package:flutter/material.dart';

class AssetIcon extends StatelessWidget {
  const AssetIcon({
    super.key,
    required this.path,
    this.size = 26,
    this.opacity = 1.0,
  });

  final String path;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(
          Icons.image_not_supported_outlined,
          size: size,
          color: Colors.white54,
        ),
      ),
    );
  }
}

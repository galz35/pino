import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double? borderRadius;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.size = 50,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 8),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildShimmer(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
        fadeOutDuration: const Duration(milliseconds: 300),
        fadeInDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey.shade400,
        size: size * 0.5,
      ),
    );
  }

  Widget _buildShimmer() {
    return Container(
      width: size,
      height: size,
      color: Colors.grey.shade100, // Placeholder for shimmer effect
    );
  }
}

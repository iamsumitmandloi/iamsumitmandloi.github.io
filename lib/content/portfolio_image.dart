import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PortfolioImage extends StatelessWidget {
  final String url;
  final String alt;
  final double? height;
  final BoxFit fit;

  const PortfolioImage({
    required this.url,
    this.alt = '',
    this.height,
    this.fit = BoxFit.cover,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url);
    final valid =
        uri != null && uri.scheme == 'https' && uri.host == 'cdn.sanity.io';
    final placeholder = SizedBox(
      height: height ?? 160,
      child: const Center(
          child: Icon(Icons.image_outlined, color: Colors.white38)),
    );
    if (!valid) return placeholder;
    if (uri.path.endsWith('.svg')) {
      return Container(
        height: height,
        color: const Color(0xFFF3F1FA),
        padding: const EdgeInsets.all(32),
        child:
            SvgPicture.network(url, semanticsLabel: alt, fit: BoxFit.contain),
      );
    }
    final optimized = uri.replace(queryParameters: {
      ...uri.queryParameters,
      'auto': 'format',
      'w': '1600',
      'q': '85',
    });
    return Image.network(
      optimized.toString(),
      height: height,
      width: double.infinity,
      fit: fit,
      semanticLabel: alt.isEmpty ? null : alt,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}

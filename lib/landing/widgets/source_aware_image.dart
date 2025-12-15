import 'package:flutter/material.dart';

// Widget displays Image.network or Image.asset on the basis of source.
class SourceAwareImage extends StatelessWidget {
  final String image;
  final bool isNetworkImage;
  final double? height;
  final BoxFit fit;

  const SourceAwareImage({
    required this.image,
    required this.isNetworkImage,
    this.height = 500,
    this.fit = BoxFit.cover,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: isNetworkImage
          ? Image.network(
              image,
              fit: fit,
              height: height,
              width: double.infinity,
            )
          : Image.asset(
              image,
              fit: fit,
              height: height,
              width: double.infinity,
            ),
    );
  }
}

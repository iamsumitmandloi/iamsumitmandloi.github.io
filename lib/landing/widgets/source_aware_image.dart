import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Background behind SVG logos, which are drawn for light surfaces.
const _logoBackgroundColor = Color(0xFFF3F1FA);

// Widget displays Image.network, Image.asset or an SVG logo on the basis of
// source.
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

  bool get _isSvg => image.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: _isSvg ? _buildLogo() : _buildImage(),
    );
  }

  // Logos are shown whole, centred on a light background.
  Widget _buildLogo() {
    return Container(
      color: _logoBackgroundColor,
      padding: const EdgeInsets.all(40.0),
      alignment: Alignment.center,
      child: isNetworkImage
          ? SvgPicture.network(image, fit: BoxFit.contain)
          : SvgPicture.asset(image, fit: BoxFit.contain),
    );
  }

  Widget _buildImage() {
    return isNetworkImage
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
          );
  }
}

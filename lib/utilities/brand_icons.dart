import 'package:flutter/widgets.dart';

// Font Awesome Free brand icons, from the font bundled in
// assets/fonts/FontAwesome (icons CC BY 4.0, font SIL OFL 1.1).
abstract final class BrandIcons {
  static const _family = 'FontAwesomeBrands';

  static const github = IconData(0xf09b, fontFamily: _family);
  static const squareGithub = IconData(0xf092, fontFamily: _family);
  static const linkedin = IconData(0xf08c, fontFamily: _family);
  static const xTwitter = IconData(0xe61b, fontFamily: _family);
  static const instagram = IconData(0xf16d, fontFamily: _family);
  static const googlePlay = IconData(0xf3ab, fontFamily: _family);
  static const appStoreIos = IconData(0xf370, fontFamily: _family);
}

// Draws a brand icon the way font_awesome_flutter's FaIcon does: as text at
// the icon size, without the square box a regular Icon clips glyphs to, so
// wide glyphs are not cut off.
class BrandIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;

  const BrandIcon(this.icon, {this.size, this.color, super.key});

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final iconSize = size ?? iconTheme.size ?? kDefaultFontSize;
    var iconColor = color ?? iconTheme.color!;
    final iconOpacity = iconTheme.opacity ?? 1.0;
    if (iconOpacity != 1.0) {
      iconColor = iconColor.withValues(alpha: iconColor.a * iconOpacity);
    }

    return ExcludeSemantics(
      child: RichText(
        overflow: TextOverflow.visible,
        textDirection: Directionality.of(context),
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontVariations: const <FontVariation>[],
            inherit: false,
            color: iconColor,
            fontSize: iconSize,
            fontFamily: icon.fontFamily,
            height: 1.0,
            leadingDistribution: TextLeadingDistribution.even,
          ),
        ),
      ),
    );
  }
}

import 'package:app/utilities/app_constants.dart';
import 'package:app/landing/widgets/social_media_button.dart';
import 'package:app/utilities/extensions.dart';
import 'package:flutter/material.dart';
import 'package:app/utilities/brand_icons.dart';

class SocialMediaButtons extends StatelessWidget {
  const SocialMediaButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final alignment =
        context.isDesktop ? WrapAlignment.start : WrapAlignment.center;
    final wrapAlignment = context.isMobile ? Alignment.center : null;
    // Phones get tighter spacing so all the icons fit on one row.
    final spacing = context.isDesktop || context.isTablet ? 16.0 : 8.0;

    return Container(
      alignment: wrapAlignment,
      child: Wrap(
        spacing: spacing,
        runSpacing: 16.0,
        alignment: alignment,
        children: const [
          SocialMediaButton(
            index: 0,
            url: AppConstants.gitHubProfileURL,
            icon: BrandIcon(BrandIcons.github),
          ),
          SocialMediaButton(
            index: 1,
            url: AppConstants.eMail,
            icon: Icon(Icons.alternate_email_rounded),
          ),
          SocialMediaButton(
            index: 2,
            url: AppConstants.linkedInProfileURL,
            icon: BrandIcon(BrandIcons.linkedin),
          ),
          SocialMediaButton(
            index: 3,
            url: AppConstants.twitterURL,
            icon: BrandIcon(BrandIcons.xTwitter),
          ),
          SocialMediaButton(
            index: 4,
            url: AppConstants.instagramProfileURL,
            icon: BrandIcon(BrandIcons.instagram),
          ),
          SocialMediaButton(
            index: 5,
            url: AppConstants.mediumProfileURL,
            icon: BrandIcon(BrandIcons.medium),
          ),
          SocialMediaButton(
            index: 6,
            url: AppConstants.youtubeURL,
            icon: BrandIcon(BrandIcons.youtube),
          ),
        ],
      ),
    );
  }
}

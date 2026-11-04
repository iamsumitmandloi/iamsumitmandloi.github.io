import 'package:app/utilities/app_constants.dart';
import 'package:app/landing/widgets/social_media_button.dart';
import 'package:app/utilities/extensions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialMediaButtons extends StatelessWidget {
  const SocialMediaButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final alignment =
        context.isDesktop ? WrapAlignment.start : WrapAlignment.center;
    final wrapAlignment = context.isMobile ? Alignment.center : null;

    return Container(
      alignment: wrapAlignment,
      child: Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        alignment: alignment,
        children: const [
          SocialMediaButton(
            index: 0,
            url: AppConstants.gitHubProfileURL,
            icon: FaIcon(FontAwesomeIcons.github),
          ),
          SocialMediaButton(
            index: 1,
            url: AppConstants.eMail,
            icon: Icon(Icons.alternate_email_rounded),
          ),
          SocialMediaButton(
            index: 2,
            url: AppConstants.linkedInProfileURL,
            icon: FaIcon(FontAwesomeIcons.linkedin),
          ),
          SocialMediaButton(
            index: 3,
            url: AppConstants.twitterURL,
            icon: FaIcon(FontAwesomeIcons.xTwitter),
          ),
          SocialMediaButton(
            index: 4,
            url: AppConstants.instagramProfileURL,
            icon: FaIcon(FontAwesomeIcons.instagram),
          ),
        ],
      ),
    );
  }
}

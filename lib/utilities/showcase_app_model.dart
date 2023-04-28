// A model that represents portfolio apps on landing page.
import 'package:app/utilities/asset_const.dart';

class ShowcaseAppModel {
  final String name;
  final String? appStoreURL;
  final String? playStoreURL;
  final String? githubURL;
  final String image;
  final String topic;

  const ShowcaseAppModel.withNetworkAsset({
    required this.name,
    this.appStoreURL,
    this.playStoreURL,
    this.githubURL,
    required this.image,
    required this.topic,
  }) : _isNetworkImage = true;

  const ShowcaseAppModel.withLocalAsset({
    required this.name,
    this.appStoreURL,
    this.playStoreURL,
    this.githubURL,
    required this.image,
    required this.topic,
  }) : _isNetworkImage = false;

  final bool _isNetworkImage;
  bool get isNetworkImage => _isNetworkImage;
}

// List of apps that will be listed on landing page.
const apps = [
  ShowcaseAppModel.withLocalAsset(
    name: 'Investmates',
    image: AssetConstant.investmates,
    playStoreURL:
        'https://play.google.com/store/apps/details?id=com.investmates.io',
    appStoreURL: 'https://apps.apple.com/in/app/investmates/id1618762983',
    topic: 'Social Networking App for Investments',
  ),
  ShowcaseAppModel.withLocalAsset(
    name: 'Ihl Care',
    image: AssetConstant.ihlc,
    playStoreURL:
        'https://play.google.com/store/apps/details?id=com.indiahealthlink.ihlhealth',
    appStoreURL: 'https://apps.apple.com/us/app/ihl-care/id1531266761',
    topic: 'Ihl Care',
  ),
  ShowcaseAppModel.withLocalAsset(
    name: 'Ihl Partner',
    image: AssetConstant.ihlp,
    playStoreURL:
        'https://play.google.com/store/apps/details?id=com.indiahealthlink.ihlpartner',
    appStoreURL: 'https://apps.apple.com/us/app/ihl-care/id1531266761',
    topic: 'Admin App',
  ),
];

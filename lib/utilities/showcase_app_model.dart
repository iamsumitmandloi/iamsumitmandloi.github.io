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
    name: 'NSE India',
    image: AssetConstant.nseIndia,
    playStoreURL:
        'https://play.google.com/store/apps/details?id=com.nse.nseindia',
    appStoreURL: 'https://apps.apple.com/in/app/nseindia/id6736678487',
    topic: 'Markets, stocks and indices from the National Stock Exchange',
  ),
  ShowcaseAppModel.withLocalAsset(
    name: 'NSE EGR',
    image: AssetConstant.egr,
    playStoreURL:
        'https://play.google.com/store/apps/details?id=com.nseindia.egr',
    appStoreURL: null,
    topic: 'Create and track Electronic Gold Receipt requests',
  ),
  ShowcaseAppModel.withLocalAsset(
    name: 'NSE MF Invest Biz',
    image: AssetConstant.mfInvestBiz,
    playStoreURL:
        'https://play.google.com/store/apps/details?id=com.nseindia.mf_invest',
    appStoreURL: 'https://apps.apple.com/in/app/nse-mf-invest-biz/id6768894925',
    topic: 'Mutual fund transactions for distributors',
  ),
  ShowcaseAppModel.withLocalAsset(
    name: 'NEAPS',
    image: AssetConstant.neaps,
    playStoreURL:
        'https://play.google.com/store/apps/details?id=com.nseindia.corporate',
    appStoreURL: 'https://apps.apple.com/in/app/neaps-app/id6752997651',
    topic: 'Announcements, circulars and filings for listed companies',
  ),
  ShowcaseAppModel.withLocalAsset(
    name: 'NSE GoBID',
    image: AssetConstant.gobidLogo,
    playStoreURL: null,
    appStoreURL: null,
    topic: 'IPO bidding app',
  ),
  ShowcaseAppModel.withLocalAsset(
    name: 'Tata Neu',
    image: AssetConstant.tataneu,
    playStoreURL:
        'https://play.google.com/store/apps/details?id=com.tatadigital.tcp',
    appStoreURL: 'https://apps.apple.com/in/app/tata-neu-shop-travel-finance/id1584669293',
    topic: 'Super App - Shop, Travel & Finance',
  ),
  ShowcaseAppModel.withLocalAsset(
    name: 'Agbiz',
    image: AssetConstant.agbiz,
    playStoreURL:
        'https://play.google.com/store/apps/details?id=com.censa.agbiz',
    appStoreURL: null,
    topic: 'Agriculture Business App for Farmers & FPOs',
  ),
  ShowcaseAppModel.withLocalAsset(
    name: 'Investmates',
    image: AssetConstant.investmates,
    playStoreURL:
        'https://play.google.com/store/apps/details?id=com.investmates.io',
    appStoreURL: 'https://apps.apple.com/in/app/investmates/id1618762983',
    topic: 'Social Networking App for Investments',
  ),
  ShowcaseAppModel.withLocalAsset(
    name: 'IHL Care',
    image: AssetConstant.ihlc,
    playStoreURL:
        'https://play.google.com/store/apps/details?id=com.indiahealthlink.ihlhealth',
    appStoreURL: 'https://apps.apple.com/us/app/ihl-care/id1531266761',
    topic: 'Healthcare App',
  ),
  ShowcaseAppModel.withLocalAsset(
    name: 'IHL Partner',
    image: AssetConstant.ihlp,
    playStoreURL:
        'https://play.google.com/store/apps/details?id=com.indiahealthlink.ihlpartner',
    appStoreURL: null,
    topic: 'Healthcare Admin App',
  ),
];

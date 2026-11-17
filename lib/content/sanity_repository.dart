import 'dart:convert';
import 'package:http/http.dart' as http;

typedef Document = Map<String, dynamic>;

String text(Document data, String key) =>
    data[key] is String ? data[key] as String : '';
List<Document> documents(dynamic value) =>
    value is List ? value.whereType<Document>().toList() : [];

bool safeLink(String value) {
  final uri = Uri.tryParse(value);
  return uri != null &&
      ((['http', 'https'].contains(uri.scheme) && uri.host.isNotEmpty) ||
          ['mailto', 'tel'].contains(uri.scheme));
}

class PortfolioData {
  final Document settings;
  final List<Document> projects;
  final List<Document> articles;
  final Document? article;

  PortfolioData.fromJson(Document json)
      : settings = json['settings'] as Document? ?? {},
        projects = documents(json['projects']),
        articles = documents(json['articles']),
        article = json['article'] as Document? {
    if (text(settings, 'name').isEmpty) {
      throw const FormatException(
          'Portfolio settings have not been published.');
    }
  }

  List<String> get sections =>
      (settings['sections'] as List? ?? []).whereType<String>().toList();
}

class SanityRepository {
  static const projectId = '8egglvol';
  static const dataset = 'production';
  static const apiVersion = '2025-02-19';

  final http.Client client;
  SanityRepository(this.client);

  Future<PortfolioData> load({String? slug}) async {
    const query = r'''{
      "settings": *[_id == "siteSettings"][0]{
        ..., "portraitUrl": portrait.asset->url,
        "backgroundUrl": background.asset->url,
        "buttons": buttons[visible != false]{..., "fileUrl": file.asset->url},
        "socials": socials[visible != false]
      },
      "projects": *[_type == "project" && hidden != true] | order(order asc, title asc){
        _id, title, description, imageFit, "imageUrl": image.asset->url,
        "imageAlt": image.alt, "links": links[visible != false]
      },
      "articles": *[_type == "article" && hidden != true] | order(order asc, title asc){
        _id, title, summary, "slug": slug.current, publishedAt, tags
      },
      "article": *[_type == "article" && hidden != true && slug.current == $slug][0]{
        ..., "slug": slug.current, "coverUrl": cover.asset->url,
        "coverAlt": cover.alt, "body": body[]{..., "imageUrl": asset->url}
      }
    }''';
    final uri = Uri.https(
        '$projectId.apicdn.sanity.io', '/v$apiVersion/data/query/$dataset', {
      'query': query,
      'perspective': 'published',
      r'$slug': jsonEncode(slug),
    });
    final response = await client.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw StateError(
          'Content request failed (' + response.statusCode.toString() + ').');
    }
    final decoded = jsonDecode(response.body) as Document;
    return PortfolioData.fromJson(decoded['result'] as Document);
  }
}

import 'dart:convert';
import 'package:app/content/sanity_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('requests published content and passes the article slug as a parameter',
      () async {
    final client = MockClient((request) async {
      expect(request.url.host, '8egglvol.apicdn.sanity.io');
      expect(request.url.queryParameters['perspective'], 'published');
      expect(jsonDecode(request.url.queryParameters[r'$slug']!), 'first-post');
      expect(request.headers.containsKey('authorization'), isFalse);
      return http.Response(
          jsonEncode({
            'result': {
              'settings': {
                'name': 'Edited name',
                'sections': ['articles', 'projects']
              },
              'projects': [],
              'articles': [
                {'title': 'First post', 'slug': 'first-post'}
              ],
              'article': {'title': 'First post', 'body': []},
            }
          }),
          200);
    });
    final data = await SanityRepository(client).load(slug: 'first-post');
    expect(data.settings['name'], 'Edited name');
    expect(data.sections, ['articles', 'projects']);
    expect(data.projects, isEmpty);
    expect(data.article!['title'], 'First post');
    client.close();
  });

  test('missing or unpublished settings are an error, with no bundled fallback',
      () async {
    final client = MockClient((_) async => http.Response(
        jsonEncode({
          'result': {'settings': null}
        }),
        200));
    await expectLater(SanityRepository(client).load(), throwsFormatException);
    client.close();
  });

  test('a missing article stays missing instead of substituting another post',
      () async {
    final client = MockClient((_) async => http.Response(
        jsonEncode({
          'result': {
            'settings': {'name': 'Author'},
            'article': null,
          }
        }),
        200));
    expect(
        (await SanityRepository(client).load(slug: 'deleted')).article, isNull);
    client.close();
  });

  test('failed content requests report failure', () async {
    final client = MockClient((_) async => http.Response('Unavailable', 503));
    await expectLater(SanityRepository(client).load(), throwsStateError);
    client.close();
  });

  test('links reject executable and relative URLs', () {
    expect(safeLink('javascript:alert(1)'), isFalse);
    expect(safeLink('data:text/html,test'), isFalse);
    expect(safeLink('//example.com'), isFalse);
    expect(safeLink('https://example.com/article'), isTrue);
    expect(safeLink('mailto:hello@example.com'), isTrue);
  });
}

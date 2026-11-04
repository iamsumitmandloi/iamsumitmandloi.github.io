// Regenerates the text copy of the page that web/index.html carries for search
// engines and screen readers, from the same data the Flutter app renders.
// Run it after changing the apps or the texts, before building:
//
//   dart run tool/generate_seo_content.dart
import 'dart:io';

import 'package:app/utilities/app_constants.dart';
import 'package:app/utilities/showcase_app_model.dart';

const _indexPath = 'web/index.html';
const _start = '<!-- seo-content:start -->';
const _end = '<!-- seo-content:end -->';

String _escape(String text) => text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

String _link(String url, String label) =>
    '<a href="${_escape(url)}">${_escape(label)}</a>';

String _buildContent() {
  final out = StringBuffer()
    ..writeln(_start)
    ..writeln('  <main id="seo-content">')
    ..writeln('    <h1>Sumit Mandloi, Flutter Developer</h1>')
    ..writeln('    <p>${_escape(AppConstants.landingMotto)}</p>')
    ..writeln('    <ul>');
  const profiles = {
    'GitHub': AppConstants.gitHubProfileURL,
    'LinkedIn': AppConstants.linkedInProfileURL,
    'X': AppConstants.twitterURL,
    'Instagram': AppConstants.instagramProfileURL,
  };
  profiles.forEach((label, url) {
    out.writeln('      <li>${_link(url, label)}</li>');
  });
  out
    ..writeln('    </ul>')
    ..writeln('    <h2>Showcase</h2>')
    ..writeln('    <p>${_escape(AppConstants.showcaseDescription)}</p>')
    ..writeln('    <p>${_escape(AppConstants.disclaimer)}</p>')
    ..writeln('    <ul>');
  for (final app in apps) {
    final links = [
      if (app.playStoreURL != null)
        _link(app.playStoreURL!, '${app.name} on Google Play'),
      if (app.appStoreURL != null)
        _link(app.appStoreURL!, '${app.name} on the App Store'),
    ];
    final suffix = links.isEmpty ? '' : ': ${links.join(', ')}';
    out.writeln('      <li>${_escape(app.name)}$suffix</li>');
  }
  out
    ..writeln('    </ul>')
    ..writeln('  </main>')
    ..write('  $_end');
  return out.toString();
}

void main() {
  final file = File(_indexPath);
  final html = file.readAsStringSync();
  final start = html.indexOf(_start);
  final end = html.indexOf(_end);
  if (start < 0 || end < start) {
    stderr.writeln('$_indexPath has no $_start ... $_end block.');
    exit(1);
  }
  final updated = html.replaceRange(start, end + _end.length, _buildContent());
  file.writeAsStringSync(updated);
  stdout.writeln('Updated the text copy in $_indexPath (${apps.length} apps).');
}

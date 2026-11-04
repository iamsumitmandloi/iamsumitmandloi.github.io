import 'dart:js_interop';

@JS('open')
external JSAny? _windowOpen(String url, String target);

void launchUrl(String url, {bool newTab = true}) {
  _windowOpen(url, newTab ? '_blank' : '_self');
}

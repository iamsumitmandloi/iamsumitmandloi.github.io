import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/utilities/url_launcher.dart';
import 'sanity_repository.dart';

class ContactPage extends StatefulWidget {
  final Document settings;
  const ContactPage(this.settings, {super.key});
  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();
  bool _sending = false;
  String _status = '';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending || !_form.currentState!.validate()) return;
    final endpoint = text(widget.settings, 'formspreeEndpoint');
    if (!RegExp(r'^https://formspree\.io/f/[a-z0-9]+$', caseSensitive: false)
        .hasMatch(endpoint)) return;
    setState(() {
      _sending = true;
      _status = '';
    });
    try {
      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: jsonEncode({
              'name': _name.text.trim(),
              'email': _email.text.trim(),
              'message': _message.text.trim(),
              '_gotcha': '',
            }),
          )
          .timeout(const Duration(seconds: 15));
      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _form.currentState!.reset();
        _name.clear();
        _email.clear();
        _message.clear();
        _status = 'Message sent. Thanks for reaching out!';
      } else {
        _status =
            'Your message could not be sent. Please try again later or use email.';
      }
    } catch (_) {
      if (!mounted) return;
      _status =
          'Delivery could not be confirmed. Please wait before trying again, or use email.';
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    final enabled = settings['contactEnabled'] == true;
    final endpoint = text(settings, 'formspreeEndpoint');
    final canSend = enabled &&
        RegExp(r'^https://formspree\.io/f/[a-z0-9]+$', caseSensitive: false)
            .hasMatch(endpoint);
    final email = text(settings, 'email');
    return SingleChildScrollView(
        child: Center(
            child: Container(
      constraints: const BoxConstraints(maxWidth: 650),
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => launchUrl('/', newTab: false),
              child: const Text('← Back to portfolio'),
            )),
        const SizedBox(height: 24),
        Text(
            enabled
                ? text(settings, 'contactTitle')
                : 'Contact is unavailable.',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        if (enabled) ...[
          const SizedBox(height: 12),
          Text(text(settings, 'contactDescription'),
              style: const TextStyle(height: 1.6)),
          if (canSend) ...[
            const SizedBox(height: 24),
            Form(
                key: _form,
                child: Column(children: [
                  TextFormField(
                    controller: _name,
                    maxLength: 100,
                    enabled: !_sending,
                    autofillHints: const [AutofillHints.name],
                    decoration: const InputDecoration(labelText: 'Your name'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter your name.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    maxLength: 254,
                    enabled: !_sending,
                    autofillHints: const [AutofillHints.email],
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Your email'),
                    validator: (v) => v != null &&
                            RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                .hasMatch(v.trim())
                        ? null
                        : 'Enter a valid email address.',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _message,
                    maxLength: 3000,
                    minLines: 5,
                    maxLines: 12,
                    enabled: !_sending,
                    decoration:
                        const InputDecoration(labelText: 'Your message'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter a message.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                      onPressed: _sending ? null : _send,
                      child: Text(_sending ? 'Sending…' : 'Send message')),
                ])),
          ],
          const SizedBox(height: 16),
          Semantics(liveRegion: true, child: Text(_status)),
          if (email.isNotEmpty)
            TextButton(
                onPressed: () => launchUrl('mailto:' + email),
                child: const Text('Email me directly')),
        ],
      ]),
    )));
  }
}

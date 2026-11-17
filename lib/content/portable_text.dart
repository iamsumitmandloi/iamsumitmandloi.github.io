import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:app/utilities/url_launcher.dart';
import 'sanity_repository.dart';
import 'portfolio_image.dart';

class PortableText extends StatelessWidget {
  final List<Document> blocks;
  const PortableText(this.blocks, {super.key});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    final numbers = <int, int>{};
    for (final block in blocks) {
      final type = text(block, '_type');
      if (type == 'codeBlock') {
        numbers.clear();
        children.add(Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1D2A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (text(block, 'language').isNotEmpty)
                Text(text(block, 'language'),
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(text(block, 'code'),
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 14, height: 1.6)),
              ),
            ],
          ),
        ));
      } else if (type == 'articleImage' || type == 'image') {
        numbers.clear();
        children.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: PortfolioImage(
            url: text(block, 'imageUrl'),
            alt: text(block, 'alt'),
            fit: BoxFit.contain,
          ),
        ));
      } else if (type == 'block') {
        final style = text(block, 'style');
        final level = (block['level'] as num? ?? 1).toInt().clamp(1, 6);
        final list = text(block, 'listItem');
        numbers.removeWhere((key, _) => key > level);
        String? prefix;
        if (list == 'number') {
          numbers[level] = (numbers[level] ?? 0) + 1;
          prefix = numbers[level].toString() + '.';
        } else if (list == 'bullet') {
          numbers.remove(level);
          prefix = '•';
        } else {
          numbers.clear();
        }
        final paragraph = _Paragraph(
          block,
          style: TextStyle(
            fontSize: style == 'h2'
                ? 25
                : style == 'h3'
                    ? 21
                    : 17,
            fontWeight:
                style.startsWith('h') ? FontWeight.bold : FontWeight.normal,
            height: 1.65,
            color: const Color(0xFFE8E4F0),
            fontStyle:
                style == 'blockquote' ? FontStyle.italic : FontStyle.normal,
          ),
        );
        children.add(Padding(
          padding: EdgeInsets.only(
            top: style.startsWith('h') ? 24 : 4,
            bottom: 10,
            left: list.isNotEmpty ? (level - 1) * 20.0 : 0,
          ),
          child: prefix == null
              ? paragraph
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: 30,
                        child: Text(prefix,
                            style:
                                const TextStyle(height: 1.65, fontSize: 17))),
                    Expanded(child: paragraph),
                  ],
                ),
        ));
      }
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }
}

class _Paragraph extends StatefulWidget {
  final Document block;
  final TextStyle style;
  const _Paragraph(this.block, {required this.style});

  @override
  State<_Paragraph> createState() => _ParagraphState();
}

class _ParagraphState extends State<_Paragraph> {
  final _recognizers = <TapGestureRecognizer>[];

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final definitions = {
      for (final mark in documents(widget.block['markDefs']))
        text(mark, '_key'): mark,
    };
    final spans = documents(widget.block['children']).map((span) {
      final marks = (span['marks'] as List? ?? []).whereType<String>().toList();
      String? href;
      for (final mark in marks) {
        final candidate = text(definitions[mark] ?? {}, 'href');
        if (safeLink(candidate)) href = candidate;
      }
      TapGestureRecognizer? recognizer;
      if (href != null) {
        final target = href;
        recognizer = TapGestureRecognizer()..onTap = () => launchUrl(target);
        _recognizers.add(recognizer);
      }
      return TextSpan(
        text: text(span, 'text'),
        recognizer: recognizer,
        style: TextStyle(
          fontWeight: marks.contains('strong') ? FontWeight.bold : null,
          fontStyle: marks.contains('em') ? FontStyle.italic : null,
          fontFamily: marks.contains('code') ? 'monospace' : null,
          backgroundColor:
              marks.contains('code') ? const Color(0xFF363246) : null,
          color: href != null ? const Color(0xFFDDD0FF) : null,
          decoration: href != null ? TextDecoration.underline : null,
        ),
      );
    }).toList();
    return Text.rich(TextSpan(children: spans), style: widget.style);
  }
}

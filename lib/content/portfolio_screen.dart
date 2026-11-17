import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:app/utilities/brand_icons.dart';
import 'package:app/utilities/url_launcher.dart';
import 'sanity_repository.dart';
import 'portfolio_image.dart';
import 'portable_text.dart';
import 'contact_page.dart';
import 'page_metadata.dart';

const portfolioBackground = Color(0xFF2F3140);
const portfolioCard = Color(0xFF363848);

IconData linkIcon(String name) => switch (name) {
      'github' => BrandIcons.github,
      'linkedin' => BrandIcons.linkedin,
      'x' => BrandIcons.xTwitter,
      'instagram' => BrandIcons.instagram,
      'medium' => BrandIcons.medium,
      'youtube' => BrandIcons.youtube,
      'playStore' => BrandIcons.googlePlay,
      'appStore' => BrandIcons.appStoreIos,
      'email' => Icons.alternate_email,
      _ => Icons.link,
    };

void openArticle(String slug) {
  launchUrl(Uri(path: '/', queryParameters: {'article': slug}).toString(),
      newTab: false);
}

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});
  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen>
    with WidgetsBindingObserver {
  final _client = http.Client();
  final _scroll = ScrollController();
  final _articlesKey = GlobalKey();
  final _articleFocus = FocusNode();
  late final SanityRepository _repository;
  PortfolioData? _data;
  bool _loading = true;
  bool _failed = false;
  bool _refreshing = false;
  int _request = 0;
  Timer? _refreshTimer;
  final _slug = Uri.base.queryParameters['article'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _repository = SanityRepository(_client);
    _load();
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed)
        _load();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    if (_refreshing) return;
    _refreshing = true;
    final request = ++_request;
    try {
      final data = await _repository.load(slug: _slug);
      if (!mounted || request != _request) return;
      final firstLoad = _data == null;
      setState(() {
        _data = data;
        _loading = false;
        _failed = false;
      });
      final title = _slug == null
          ? text(data.settings, 'pageTitle')
          : text(data.article ?? {}, 'title');
      SystemChrome.setApplicationSwitcherDescription(
          ApplicationSwitcherDescription(
        label: title.isEmpty ? text(data.settings, 'name') : title,
        primaryColor: 0xFF2F3140,
      ));
      updatePortfolioMetadata(
        title.isEmpty ? text(data.settings, 'name') : title,
        _slug == null
            ? text(data.settings, 'description')
            : text(data.article ?? {}, 'summary'),
        _slug == null
            ? text(data.settings, 'portraitUrl')
            : text(data.article ?? {}, 'coverUrl'),
      );
      if (firstLoad && Uri.base.queryParameters['section'] == 'articles') {
        WidgetsBinding.instance.addPostFrameCallback((_) => _showArticles());
      }
    } catch (_) {
      if (!mounted || request != _request) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    } finally {
      _refreshing = false;
    }
  }

  void _showArticles({bool animate = false}) {
    final target = _articlesKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: animate && !MediaQuery.disableAnimationsOf(context)
          ? const Duration(milliseconds: 400)
          : Duration.zero,
      alignment: .08,
    ).then((_) {
      if (mounted && animate) _articleFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    _client.close();
    _scroll.dispose();
    _articleFocus.dispose();
    super.dispose();
  }

  Widget _retry() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text(
                'The portfolio could not be loaded. Check your connection and try again.',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _failed = false;
                  });
                  _load();
                },
                child: const Text('Try again')),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return Scaffold(
      backgroundColor: portfolioBackground,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : data == null
              ? _retry()
              : Column(children: [
                  if (_failed)
                    MaterialBanner(
                      content: const Text(
                          'Showing the last loaded content. Refresh failed.'),
                      actions: [
                        TextButton(onPressed: _load, child: const Text('Retry'))
                      ],
                    ),
                  Expanded(child: _content(data)),
                ]),
    );
  }

  Widget _content(PortfolioData data) {
    if (Uri.base.queryParameters['contact'] == '1') {
      return ContactPage(data.settings);
    }
    if (_slug != null) return _articlePage(data);
    return Scrollbar(
      controller: _scroll,
      child: SingleChildScrollView(
        controller: _scroll,
        child: Column(children: [
          _hero(data),
          Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final section in data.sections)
                  if (section == 'projects' && data.projects.isNotEmpty)
                    _projects(data)
                  else if (section == 'articles' && data.articles.isNotEmpty)
                    _articles(data),
                _footer(data.settings),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _hero(PortfolioData data) {
    final settings = data.settings;
    final buttons = documents(settings['buttons']);
    final socials = documents(settings['socials']);
    return Stack(
      children: [
        if (text(settings, 'backgroundUrl').isNotEmpty)
          Positioned.fill(
              child: Opacity(
            opacity: .25,
            child: PortfolioImage(url: text(settings, 'backgroundUrl')),
          )),
        Center(
            child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (text(settings, 'portraitUrl').isNotEmpty) ...[
                ClipOval(
                    child: SizedBox(
                  width: 64,
                  height: 64,
                  child: PortfolioImage(
                      url: text(settings, 'portraitUrl'),
                      alt: text(settings, 'name')),
                )),
                const SizedBox(width: 16),
              ],
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(text(settings, 'name'),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        )),
                    if (text(settings, 'handle').isNotEmpty)
                      Text('@' + text(settings, 'handle'),
                          style: const TextStyle(color: Colors.white70)),
                  ])),
            ]),
            const SizedBox(height: 24),
            const Divider(color: Colors.white24),
            const SizedBox(height: 20),
            SelectableText(text(settings, 'intro'),
                style: const TextStyle(fontSize: 17, height: 1.7)),
            const SizedBox(height: 24),
            Wrap(spacing: 12, runSpacing: 12, children: [
              for (final button in buttons)
                if (_buttonAvailable(button, data))
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE1D5FF),
                      side: const BorderSide(color: Color(0xFFD6C9FF)),
                      minimumSize: const Size(0, 46),
                    ),
                    onPressed: () => _pressButton(button),
                    child: Text(text(button, 'label')),
                  ),
            ]),
            if (socials.isNotEmpty) ...[
              const SizedBox(height: 22),
              Wrap(spacing: 10, runSpacing: 8, children: [
                for (final link in socials)
                  if (safeLink(text(link, 'url')))
                    IconButton(
                      tooltip: text(link, 'label'),
                      icon: Icon(linkIcon(text(link, 'icon'))),
                      onPressed: () => launchUrl(text(link, 'url')),
                      iconSize: 25,
                    ),
              ]),
            ],
          ]),
        )),
      ],
    );
  }

  bool _buttonAvailable(Document button, PortfolioData data) {
    return switch (text(button, 'action')) {
      'articles' =>
        data.sections.contains('articles') && data.articles.isNotEmpty,
      'contact' => data.settings['contactEnabled'] == true,
      'file' => safeLink(text(button, 'fileUrl')),
      'url' => safeLink(text(button, 'url')),
      _ => false,
    };
  }

  void _pressButton(Document button) {
    switch (text(button, 'action')) {
      case 'articles':
        _showArticles(animate: true);
      case 'contact':
        launchUrl('/?contact=1', newTab: false);
      case 'file':
        launchUrl(text(button, 'fileUrl'));
      case 'url':
        launchUrl(text(button, 'url'));
    }
  }

  Widget _heading(String title) => Semantics(
        header: true,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(title,
              style:
                  const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
        ),
      );

  Widget _projects(PortfolioData data) => Padding(
        padding: const EdgeInsets.only(bottom: 64),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _heading(text(data.settings, 'projectsTitle')),
          if (text(data.settings, 'projectsDescription').isNotEmpty)
            Text(text(data.settings, 'projectsDescription'),
                style: const TextStyle(fontSize: 17)),
          if (text(data.settings, 'projectsDisclaimer').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(text(data.settings, 'projectsDisclaimer'),
                  style: const TextStyle(color: Colors.white70)),
            ),
          const SizedBox(height: 28),
          LayoutBuilder(builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1000
                ? 3
                : constraints.maxWidth >= 650
                    ? 2
                    : 1;
            final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
            return Wrap(spacing: 16, runSpacing: 16, children: [
              for (final project in data.projects)
                SizedBox(width: width, child: _projectCard(project)),
            ]);
          }),
        ]),
      );

  Widget _projectCard(Document project) => Card(
        color: portfolioCard,
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (text(project, 'imageUrl').isNotEmpty)
            PortfolioImage(
              url: text(project, 'imageUrl'),
              alt: text(project, 'imageAlt'),
              height: 340,
              fit: text(project, 'imageFit') == 'contain'
                  ? BoxFit.contain
                  : BoxFit.cover,
            ),
          Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text(project, 'title'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  if (text(project, 'description').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(text(project, 'description'),
                        style: const TextStyle(
                            color: Colors.white70, height: 1.5)),
                  ],
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, children: [
                    for (final link in documents(project['links']))
                      if (safeLink(text(link, 'url')))
                        TextButton.icon(
                          onPressed: () => launchUrl(text(link, 'url')),
                          icon: Icon(linkIcon(text(link, 'icon')), size: 16),
                          label: Text(text(link, 'label')),
                        ),
                  ]),
                ],
              )),
        ]),
      );

  Widget _articles(PortfolioData data) => Padding(
        key: _articlesKey,
        padding: const EdgeInsets.only(bottom: 56),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _heading(text(data.settings, 'articlesTitle')),
          for (final (index, article) in data.articles.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton(
                focusNode: index == 0 ? _articleFocus : null,
                onPressed: () => openArticle(text(article, 'slug')),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  backgroundColor: portfolioCard,
                  padding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(text(article, 'title'),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white)),
                      const SizedBox(height: 6),
                      Text(text(article, 'summary'),
                          style: const TextStyle(
                              fontSize: 15, color: Colors.white70)),
                      const SizedBox(height: 10),
                      const Text('Read article →'),
                    ]),
              ),
            ),
        ]),
      );

  Widget _footer(Document settings) {
    final link = settings['footerLink'] as Document? ?? {};
    if (link['visible'] == false || !safeLink(text(link, 'url')))
      return const SizedBox.shrink();
    return Center(
        child: TextButton.icon(
      onPressed: () => launchUrl(text(link, 'url')),
      icon: Icon(linkIcon(text(link, 'icon'))),
      label: Text(text(link, 'label')),
    ));
  }

  Widget _articlePage(PortfolioData data) {
    final article = data.article;
    return SelectionArea(
      child: SingleChildScrollView(
        child: Center(
            child: Container(
          constraints: const BoxConstraints(maxWidth: 760),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () =>
                      launchUrl('/?section=articles', newTab: false),
                  child: const Text('← All articles'),
                )),
            const SizedBox(height: 24),
            if (article == null)
              const Text('This article is unavailable.',
                  style: TextStyle(fontSize: 28))
            else ...[
              Semantics(
                  header: true,
                  child: Text(
                    text(article, 'title'),
                    style: const TextStyle(
                        fontSize: 36, fontWeight: FontWeight.bold, height: 1.2),
                  )),
              const SizedBox(height: 16),
              Text(text(article, 'summary'),
                  style: const TextStyle(
                      fontSize: 19, height: 1.6, color: Colors.white70)),
              const SizedBox(height: 12),
              Text(text(data.settings, 'name'),
                  style: const TextStyle(color: Colors.white60)),
              if (text(article, 'coverUrl').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: PortfolioImage(
                      url: text(article, 'coverUrl'),
                      alt: text(article, 'coverAlt'),
                      fit: BoxFit.contain),
                ),
              const SizedBox(height: 20),
              PortableText(documents(article['body'])),
            ],
            const SizedBox(height: 30),
            TextButton(
              onPressed: () => launchUrl('/?section=articles', newTab: false),
              child: const Text('← Back to selected articles'),
            ),
          ]),
        )),
      ),
    );
  }
}

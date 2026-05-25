import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:pechinchar_online/views/widgets/web_iframe_view.dart';

class AcomodemeWebView extends StatefulWidget {
  const AcomodemeWebView({Key? key}) : super(key: key);

  @override
  State<AcomodemeWebView> createState() => _AcomodemeWebViewState();
}

class _AcomodemeWebViewState extends State<AcomodemeWebView> {
  static final Uri _siteUri = Uri.parse('https://acomodeme.com.br/');
  WebViewController? _controller;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFFFFFFFF))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int value) {
              if (!mounted) return;
              setState(() => _progress = value);
            },
          ),
        )
        ..loadRequest(_siteUri);
    }
  }

  Future<void> _openExternally() async {
    await launchUrl(_siteUri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        floatingActionButton: FloatingActionButton.small(
          tooltip: 'Abrir no navegador',
          onPressed: _openExternally,
          child: const Icon(Icons.open_in_new),
        ),
        body: Column(
          children: [
            Expanded(
              child: buildEmbeddedWebView(_siteUri.toString()),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acomodeme'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Voltar',
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _controller?.canGoBack() ?? false) {
                await _controller?.goBack();
              }
            },
          ),
          IconButton(
            tooltip: 'Avancar',
            icon: const Icon(Icons.arrow_forward),
            onPressed: () async {
              if (await _controller?.canGoForward() ?? false) {
                await _controller?.goForward();
              }
            },
          ),
          IconButton(
            tooltip: 'Recarregar',
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller?.reload(),
          ),
          IconButton(
            tooltip: 'Abrir no navegador',
            icon: const Icon(Icons.open_in_new),
            onPressed: _openExternally,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_progress < 100)
            LinearProgressIndicator(
              value: _progress / 100,
              minHeight: 2,
            ),
          const Divider(height: 1),
          Expanded(
            child: _controller == null
                ? const SizedBox.shrink()
                : WebViewWidget(controller: _controller!),
          ),
        ],
      ),
    );
  }
}

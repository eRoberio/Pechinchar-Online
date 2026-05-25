import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

final Set<String> _registeredViewTypes = <String>{};

Widget buildWebIframe(String url) {
  final String viewType = 'acomodeme-iframe-${url.hashCode}';

  if (!_registeredViewTypes.contains(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final html.IFrameElement element = html.IFrameElement()
        ..src = url
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'fullscreen; autoplay'
        ..setAttribute('referrerpolicy', 'no-referrer-when-downgrade');
      return element;
    });
    _registeredViewTypes.add(viewType);
  }

  return HtmlElementView(viewType: viewType);
}

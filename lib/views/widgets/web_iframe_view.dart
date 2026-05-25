import 'package:flutter/material.dart';

import 'web_iframe_view_stub.dart'
    if (dart.library.html) 'web_iframe_view_web.dart';

Widget buildEmbeddedWebView(String url) => buildWebIframe(url);

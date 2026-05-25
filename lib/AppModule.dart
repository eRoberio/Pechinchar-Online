import 'package:flutter_modular/flutter_modular.dart';

import 'HomeModule.dart';

class AppModule extends Module {
  @override
  void routes(RouteManager r) {
    r.module("/", module: HomeModule());
  }
}
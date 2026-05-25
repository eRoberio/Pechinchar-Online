import 'package:flutter_modular/flutter_modular.dart';
import 'package:pechinchar_online/views/AcomodemeWebView.dart';
import 'package:pechinchar_online/views/AcomodemeWelcome.dart';
import 'package:pechinchar_online/views/Cadastro.dart';
import 'package:pechinchar_online/views/Home.dart';
import 'package:pechinchar_online/views/Login.dart';
import 'package:pechinchar_online/views/Splash.dart';
import 'package:pechinchar_online/views/meusAnuncios.dart';

class HomeModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child("/", child: (context) => const AcomodemeWelcome());
    r.child("/AcomodemeWeb", child: (context) => const AcomodemeWebView());
    r.child("/Splash", child: (context) => Splash());
    r.child("/Login", child: (context) => Login());
    r.child("/Cadastro", child: (context) => Cadastro());
    r.child("/Home", child: (context) => Home());
    r.child("/MeusAnuncios", child: (context) => MeusAnuncios());
  }
}

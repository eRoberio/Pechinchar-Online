import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pechinchar_online/views/Login.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with WidgetsBindingObserver {
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  Timer? _timerLink;

  // Cores da nova identidade visual (Acomodeme)
  final Color corPrincipalAzul = const Color(0xFF0B1C4B);
  final Color corDestaqueLaranja = const Color(0xFFFF8C00);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    Future.delayed(Duration(seconds: 3)).then((value) {
      User? usuarioLogado = FirebaseAuth.instance.currentUser;

      if (usuarioLogado != null) {
        Navigator.pushReplacementNamed(context, "/Home");
      } else {
        Navigator.pushReplacementNamed(context, "/Login");
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kIsWeb) return;

    if (state == AppLifecycleState.resumed) {
      _timerLink = Timer(
        const Duration(milliseconds: 1000),
        () {
          _dynamicLinkService.retrieveDynamicLink(context);
        },
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_timerLink != null) {
      _timerLink!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corPrincipalAzul, // Fundo Azul da marca
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "imagens/logo.jpeg", // Certifique-se de que esta é a logo atualizada do Acomodeme (preferencialmente em PNG com fundo transparente)
              width: 200, // Ajuste o tamanho da logo conforme necessário
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              color: corDestaqueLaranja, // Indicador de carregamento em Laranja
            ),
          ],
        ),
      ),
    );
  }
}

class DynamicLinkService {
  Future<void> retrieveDynamicLink(BuildContext context) async {
    if (kIsWeb) return;

    User? usuarioLogado = FirebaseAuth.instance.currentUser;

    try {
      FirebaseDynamicLinks.instance.onLink.listen(
          (PendingDynamicLinkData? dynamicLink) async {
        final Uri? deepLink = dynamicLink?.link;

        if (deepLink != null) {
          if (usuarioLogado != null) {
            Navigator.pushNamed(context, deepLink.path);
          } else {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Login()));
          }
        }
      }, onError: (Object error) async {
        print('onLinkError');
        print(error);
      });

      final PendingDynamicLinkData? data =
          await FirebaseDynamicLinks.instance.getInitialLink();
      final Uri? deepLink = data?.link;

      if (deepLink != null) {
        if (usuarioLogado != null) {
          Navigator.pushNamed(context, deepLink.path);
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Login()));
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'dart:io' show Platform;
// import 'package:flutter/material.dart';
// import 'package:flutter_modular/flutter_modular.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'AppModule.dart';
// import 'AppWidget.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   if (kIsWeb) {
//     await Firebase.initializeApp(
//       options: const FirebaseOptions(
//         apiKey: "AIzaSyDVKurHgFwqXlfRc4Zp4OfFs_BfZmuJa3o", // ok
//         authDomain: "COLOQUE_AQUI_O_AUTH_DOMAIN_DO_WEB", // pegar no console Firebase Web
//         projectId: "pechinchar-f38be", // ok
//         storageBucket: "pechinchar-f38be.appspot.com", // ok
//         messagingSenderId: "10417094027", // ok
//         appId: "COLOQUE_AQUI_O_APP_ID_WEB", // pegar no console Firebase Web
//         measurementId: "COLOQUE_AQUI_O_MEASUREMENT_ID", // pegar no console Firebase Web
//       ),
//     );
//   } else {
//     await Firebase.initializeApp();
//   }
//   if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
//     await MobileAds.instance.initialize();
//   }
//   runApp(ModularApp(module: AppModule(), child: AppWidget()));
// }

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'AppModule.dart';
import 'AppWidget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? startupError;

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBTbK8jTfDhk_VZSBsUXXR0Gkc6OBU6BfE",
          authDomain: "todo-368a2.firebaseapp.com",
          projectId: "todo-368a2",
          storageBucket: "todo-368a2.firebasestorage.app",
          messagingSenderId: "379249280663",
          appId: "1:379249280663:web:d49ca2382a0646e6f4cbd2",
          measurementId: null, // Nao fornecido no firebaseConfig
        ),
      );
    } else {
      await Firebase.initializeApp();
    }

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await MobileAds.instance.initialize();
    }
  } catch (e) {
    startupError = e.toString();
  }

  if (startupError != null) {
    runApp(_StartupErrorApp(message: startupError));
    return;
  }

  runApp(ModularApp(module: AppModule(), child: AppWidget()));
}

class _StartupErrorApp extends StatelessWidget {
  final String message;

  const _StartupErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off,
                  size: 56,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nao foi possivel iniciar o app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Verifique sua conexao e recarregue a pagina. Se o erro persistir, desative bloqueadores de script no navegador.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

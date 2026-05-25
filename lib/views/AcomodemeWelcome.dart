import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:pechinchar_online/views/AcomodemeWebView.dart';

class AcomodemeWelcome extends StatelessWidget {
  const AcomodemeWelcome({Key? key}) : super(key: key);

  void _openAcomodeme(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 360),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, __, ___) => const AcomodemeWebView(),
        transitionsBuilder: (_, animation, __, child) {
          final CurvedAnimation curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: Tween<double>(begin: 0.2, end: 1).animate(curved),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color azul = Color(0xFF0B1C4B);
    const Color laranja = Color(0xFFFF8C00);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF3FF), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'imagens/logo2.jpeg',
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Acomodeme',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: azul,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Acesse o site completo com uma experiencia direta e rapida.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    height: 1.35,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F8FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDCE3FF)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.language, color: azul),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Voce sera direcionado para acomodeme.com.br',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () => _openAcomodeme(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: azul,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text(
                      'Entrar no Acomodeme',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Modular.to.navigate('/Splash'),
                  child: const Text(
                    'Abrir versao antiga do app',
                    style: TextStyle(color: laranja),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

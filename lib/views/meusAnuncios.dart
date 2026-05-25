import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pechinchar_online/adaptadores/ItemMeusAnuncios.dart';
import 'package:pechinchar_online/models/Anuncio.dart';
import 'package:pechinchar_online/views/NovoAnuncio.dart';
import 'package:pechinchar_online/views/impulsionar.dart';

class MeusAnuncios extends StatefulWidget {
  const MeusAnuncios({Key? key}) : super(key: key);

  @override
  _MeusAnunciosState createState() => _MeusAnunciosState();
}

class _MeusAnunciosState extends State<MeusAnuncios> {
  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    nonPersonalizedAds: true,
  );

  BannerAd? _anchoredBanner;
  bool _loadingAnchoredBanner = false;

  final _controller = StreamController<QuerySnapshot>.broadcast();
  StreamSubscription<QuerySnapshot>? _anunciosSubscription;
  late String _idUsuarioLogado;

  // Cores da nova identidade
  final Color corPrincipalAzul = const Color(0xFF0B1C4B);
  final Color corDestaqueLaranja = const Color(0xFFFF8C00);

  _recuperaDadosUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;
    if (usuarioLogado == null) return;
    _idUsuarioLogado = usuarioLogado.uid;
  }

  Future<Stream<QuerySnapshot>> _adicionarListenerAnuncios() async {
    await _recuperaDadosUsuarioLogado();

    FirebaseFirestore db = FirebaseFirestore.instance;
    Stream<QuerySnapshot> stream = db
        .collection("meus_anuncios")
        .doc(_idUsuarioLogado)
        .collection("anuncios")
        .snapshots();

    _anunciosSubscription?.cancel();
    _anunciosSubscription = stream.listen(
      (dados) {
        if (!_controller.isClosed) {
          _controller.add(dados);
        }
      },
      onError: (Object error) {
        if (!_controller.isClosed) {
          _controller.addError(error);
        }
      },
    );
    return stream;
  }

  _removerAnuncio(Anuncio anuncio) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    // Deleta dos meus anúncios
    db
        .collection("meus_anuncios")
        .doc(_idUsuarioLogado)
        .collection("anuncios")
        .doc(anuncio.id)
        .delete()
        .then((_) {
      // Deleta do mural público
      db
          .collection("anuncios")
          .doc(anuncio.categoria)
          .collection(anuncio.categoria)
          .doc(anuncio.id)
          .delete();
    });
  }

  @override
  void initState() {
    super.initState();
    _adicionarListenerAnuncios();
  }

  @override
  void dispose() {
    _anchoredBanner?.dispose();
    _anunciosSubscription?.cancel();
    _controller.close(); // Sempre bom fechar o stream controller
    super.dispose();
  }

  // Responsável por exibir o banner de anúncios
  Future<void> _createAnchoredBanner(BuildContext context) async {
    if (kIsWeb) return;

    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) return;

    final BannerAd banner = BannerAd(
      size: size,
      request: request,
      adUnitId: 'ca-app-pub-4141006277093451/3137185376',
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => setState(() => _anchoredBanner = ad as BannerAd),
        onAdFailedToLoad: (Ad ad, LoadAdError error) => ad.dispose(),
      ),
    );
    return banner.load();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && !_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }

    // Tela de carregamento modernizada
    var carregandoDados = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(color: corDestaqueLaranja),
          const SizedBox(height: 16),
          Text(
            "Carregando seus anúncios...",
            style:
                TextStyle(color: corPrincipalAzul, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[100], // Fundo suave
      appBar: AppBar(
        backgroundColor: corPrincipalAzul,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text("Meus Anúncios",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset("imagens/logo.jpeg",
                  width: 40, fit: BoxFit.cover),
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: corDestaqueLaranja,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_circle_outline, size: 24),
        label: const Text("Novo Anúncio",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(
              context,
              PageTransition(
                  child: NovoAnuncio(), type: PageTransitionType.bottomToTop));
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _controller.stream,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return carregandoDados;
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text("Erro ao carregar os dados!",
                              style: TextStyle(color: Colors.red)));
                    }

                    final querySnapshot = snapshot.data as QuerySnapshot?;

                    // Empty state modernizado
                    if (querySnapshot == null || querySnapshot.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              "Nenhum anúncio encontrado.",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Que tal criar o seu primeiro?",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(
                          top: 8,
                          bottom:
                              80), // Padding extra no final por causa do botão flutuante
                      itemCount: querySnapshot.docs.length,
                      itemBuilder: (_, indice) {
                        List<DocumentSnapshot> anuncios =
                            querySnapshot.docs.toList();
                        DocumentSnapshot documentSnapshot = anuncios[indice];
                        Anuncio anuncio =
                            Anuncio.fromDocumentSnapshot(documentSnapshot);

                        return ItemMeusAnuncios(
                          anuncio: anuncio,
                          onTapItem: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Impulsionar(
                                        anuncio: anuncio, imagens: const [])));
                          },
                          onPressedRemover: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    title: const Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded,
                                            color: Colors.redAccent),
                                        SizedBox(width: 8),
                                        Text("Atenção"),
                                      ],
                                    ),
                                    content: const Text(
                                        "Deseja realmente excluir este anúncio de forma permanente?"),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text("Cancelar",
                                            style: TextStyle(
                                                color: Colors.grey[600])),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        child: const Text("Excluir",
                                            style:
                                                TextStyle(color: Colors.white)),
                                        onPressed: () {
                                          _removerAnuncio(anuncio);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                });
                          },
                        );
                      },
                    );
                }
              },
            ),
          ),

          // Banner AdMob no rodapé
          if (_anchoredBanner != null)
            Container(
              color: Colors.white,
              width: _anchoredBanner!.size.width.toDouble(),
              height: _anchoredBanner!.size.height.toDouble(),
              child: AdWidget(ad: _anchoredBanner!),
            ),
        ],
      ),
    );
  }
}

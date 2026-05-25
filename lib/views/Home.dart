import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pechinchar_online/models/Anuncio.dart';
import 'package:pechinchar_online/models/debouncer.dart';
import 'package:pechinchar_online/views/Perfil.dart';
import 'package:pechinchar_online/views/detalhesAnuncio.dart';
import 'package:pechinchar_online/views/favoritos.dart';
import 'package:pechinchar_online/views/meusAnuncios.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  BannerAd? _anchoredBanner;
  bool _loadingAnchoredBanner = false;

  late bool _progresBarLinear;
  late TabController _tabController;
  bool searchState = false;
  bool retornoMensagem = true;
  int favoritos = 0;
  int valorControllerTab = 0;
  late String valor;
  List<Anuncio> lista = [];
  final _debouncer = Debouncer(milliseconds: 800);

  // Cores da nova identidade visual (Acomodeme)
  final Color corPrincipalAzul = const Color(0xFF0B1C4B);
  final Color corDestaqueLaranja = const Color(0xFFFF8C00);

  @override
  void initState() {
    super.initState();
    retornarQuantidadeFavoritos();
    _progresBarLinear = true;
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          valorControllerTab = _tabController.index;
          searchState = false;
          lista.clear();
          searchAnuncio();
        });
      }
    });
    searchAnuncio();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _anchoredBanner?.dispose();
  }

  //responsavel por exibir o banner de anúncios
  Future<void> _createAnchoredBanner(BuildContext context) async {
    if (kIsWeb) return;

    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    final BannerAd banner = BannerAd(
      size: size,
      request: request,
      adUnitId: 'ca-app-pub-4141006277093451/3137185376',
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$BannerAd loaded.');
          setState(() {
            _anchoredBanner = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$BannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
      ),
    );
    return banner.load();
  }

  //retorna o id da compra
  Future<dynamic> retornarQuantidadeFavoritos() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String id = user.uid;
    FirebaseFirestore db = FirebaseFirestore.instance;
    db
        .collection("meus_favoritos")
        .doc(id)
        .collection("favoritos")
        .snapshots()
        .listen((event) {
      favoritos = 0;
      for (DocumentSnapshot dados in event.docs) {
        if (dados.exists) {
          setState(() {
            favoritos++;
          });
        }
      }
    });
  }

  Future<dynamic> searchAnuncio({String search = ""}) async {
    _progresBarLinear = true;
    setState(() {
      retornoMensagem = true;
      lista.clear();
    });

    switch (valorControllerTab) {
      case 0:
        valor = "imoveis";
        break;
      case 1:
        valor = "produtos";
        break;
      case 2:
        valor = "moveis";
        break;
      case 3:
        valor = "supermercados";
        break;
      case 4:
        valor = "restaurantes";
        break;
      case 5:
        valor = "transporte";
        break;
      case 6:
        valor = "servicos";
        break;
    }

    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot =
          await db.collection("anuncios").doc(valor).collection(valor).get();

      final String searchTerm = search.toLowerCase();
      final List<Anuncio> anunciosFiltrados = <Anuncio>[];

      for (DocumentSnapshot dados in querySnapshot.docs) {
        if (!dados.exists) continue;

        Anuncio anuncio = Anuncio();
        anuncio.titulo = dados["titulo"];
        anuncio.idUsuario = dados["idUsuario"];
        anuncio.id = dados["id"];
        anuncio.descricao = dados["descricao"];
        anuncio.preco = dados["preco"];
        anuncio.nome = dados["nome"];
        anuncio.categoria = dados["categoria"];
        anuncio.subCategoria = dados["subCategoria"];
        anuncio.estado = dados["estado"];
        anuncio.telefone = dados["telefone"];
        anuncio.cidade = dados["cidade"];
        anuncio.endereco = dados["endereco"];
        anuncio.impulsionar = dados["impulsionar"];
        anuncio.fotos = List<String>.from(dados["fotos"]);
        anuncio.data = dados["data"];
        anuncio.horario = dados["horario"];

        if (searchTerm.isEmpty ||
            anuncio.titulo.toLowerCase().contains(searchTerm) ||
            anuncio.estado.toLowerCase().contains(searchTerm)) {
          anunciosFiltrados.add(anuncio);
        }
      }

      anunciosFiltrados.sort((Anuncio a, Anuncio b) {
        final int impulsoA = int.tryParse(a.impulsionar) ?? 0;
        final int impulsoB = int.tryParse(b.impulsionar) ?? 0;
        if (impulsoA != impulsoB) {
          return impulsoB.compareTo(impulsoA);
        }

        final DateTime dataA = _parseDataHora(a.data, a.horario);
        final DateTime dataB = _parseDataHora(b.data, b.horario);
        return dataB.compareTo(dataA);
      });

      setState(() {
        lista = anunciosFiltrados;
        _progresBarLinear = false;
        retornoMensagem = lista.isNotEmpty;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        retornoMensagem = false;
        _progresBarLinear = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Nao foi possivel carregar os anuncios agora. Tente novamente.",
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  DateTime _parseDataHora(String data, String horario) {
    try {
      final List<String> dataPartes = data.split('/');
      final List<String> horaPartes = horario.split(':');

      final int dia = int.parse(dataPartes[0]);
      final int mes = int.parse(dataPartes[1]);
      final int ano = int.parse(dataPartes[2]);

      final int hora = int.parse(horaPartes[0]);
      final int minuto = int.parse(horaPartes[1]);
      final int segundo = horaPartes.length > 2 ? int.parse(horaPartes[2]) : 0;

      return DateTime(ano, mes, dia, hora, minuto, segundo);
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && !_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    return Scaffold(
        appBar: AppBar(
          // 1. ISSO RESOLVE O ÍCONE DO MENU (HAMBÚRGUER) ESCURO
          iconTheme: const IconThemeData(color: Colors.white),

          title: !searchState
              ? const Text("")
              : TextField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, color: Colors.white),
                    hintText: "Search ...",
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (text) {
                    _debouncer.run(() {
                      String texto = text.toLowerCase();
                      searchAnuncio(search: texto);
                    });
                  },
                ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: !searchState
                  ? IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          searchState = !searchState;
                        });
                      },
                    )
                  : IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          searchState = !searchState;
                        });
                      },
                    ),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    GestureDetector(
                      child: const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                        size: 30,
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                child: const Favoritos(),
                                type: PageTransitionType.bottomToTop));
                      },
                    ),
                    if (favoritos != 0)
                      Container(
                          alignment: Alignment.center,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Text("" + favoritos.toString()),
                          ))
                  ],
                ))
          ],
          backgroundColor: corPrincipalAzul,
          elevation: 0,
        ),

        // 2. ISSO RESOLVE AS CORES ESCURAS DENTRO DO MENU LATERAL
        drawer: Drawer(
          backgroundColor: corPrincipalAzul, // Fundo do menu inteiro azul naval
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 56, bottom: 16),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      "Pechinchar",
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ONLINE",
                      style: GoogleFonts.montserrat(
                        color: corDestaqueLaranja,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.white24, // Divisor clarinho e sutil
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(
                  Icons.account_circle,
                  color: Colors.white, // Ícones brancos
                ),
                title: const Text(
                  "Perfil",
                  style: TextStyle(
                      color: Colors.white, fontSize: 16), // Textos brancos
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          child: const Perfil(),
                          type: PageTransitionType.leftToRight));
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.campaign,
                  color: Colors.white,
                ),
                title: const Text(
                  "Anunciar Produtos",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          child: MeusAnuncios(),
                          type: PageTransitionType.bottomToTop));
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                ),
                title: const Text(
                  "Favoritos",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          child: const Favoritos(),
                          type: PageTransitionType.bottomToTop));
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.white),
                title: const Text(
                  "Sair",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onTap: () {
                  FirebaseAuth auth = FirebaseAuth.instance;
                  auth.signOut();
                  Navigator.pushReplacementNamed(context, "/Login");
                },
              )
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.only(top: 16, left: 16, bottom: 8),
              child: Text(
                "Anúncios principais",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors
                        .white), // Texto alterado para branco para contraste
              ),
              decoration: BoxDecoration(
                color: corPrincipalAzul, // Alterado para o azul principal
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 8, top: 8),
              decoration: BoxDecoration(
                color: corPrincipalAzul, // Alterado para o azul principal
              ),
              child: TabBar(
                isScrollable: true,
                labelColor: Colors.white, // Rótulo ativo em branco
                unselectedLabelColor:
                    Colors.white70, // Rótulos inativos levemente transparentes
                indicatorWeight: 4,
                labelStyle:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                controller: _tabController,
                indicatorColor:
                    corDestaqueLaranja, // Linha indicadora agora é laranja
                tabs: <Widget>[
                  Tab(
                    icon: Icon(
                      Icons.apartment, // ou Icons.home
                      size: 30,
                    ),
                    text: "Imóveis",
                  ),
                  Tab(
                    icon: Icon(
                      Icons.shopping_bag, // ou Icons.inventory_2
                      size: 30,
                    ),
                    text: "Produtos",
                  ),
                  Tab(
                    icon: Icon(
                      Icons.chair, // ou Icons.bed
                      size: 30,
                    ),
                    text: "Móveis",
                  ),
                  Tab(
                    icon: Icon(
                      Icons.local_grocery_store, // ou Icons.shopping_cart
                      size: 30,
                    ),
                    text: "Supermercados",
                  ),
                  Tab(
                    icon: Icon(
                      Icons.restaurant,
                      size: 30,
                    ),
                    text: "Restaurantes",
                  ),
                  Tab(
                    icon: Icon(
                      Icons.directions_car, // ou Icons.commute
                      size: 30,
                    ),
                    text:
                        "Transportes", // Corrigido o erro de digitação original "Transpotes"
                  ),
                  Tab(
                    icon: Icon(
                      Icons.handyman, // ou Icons.build / Icons.design_services
                      size: 30,
                    ),
                    text: "Serviços",
                  )
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    child: Column(
                      children: <Widget>[
                        if (lista.length != 0)
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: lista.length,
                              itemBuilder: (BuildContext context, int index) {
                                Anuncio anuncio = lista[index];
                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DetalhesAnuncio(anuncio, true))),
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 8),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 2,
                                    child: Row(
                                      children: <Widget>[
                                        // IMAGEM COM SELO DE DESTAQUE
                                        Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(12),
                                                bottomLeft: Radius.circular(12),
                                              ),
                                              child: SizedBox(
                                                width: 120,
                                                height: 120,
                                                child: anuncio.fotos.isNotEmpty
                                                    ? CachedNetworkImage(
                                                        imageUrl:
                                                            anuncio.fotos[0],
                                                        fit: BoxFit.cover,
                                                        placeholder: (context,
                                                                url) =>
                                                            const Center(
                                                                child:
                                                                    CircularProgressIndicator()),
                                                      )
                                                    : Container(
                                                        color: Colors.grey[200],
                                                        child: const Icon(
                                                            Icons.image)),
                                              ),
                                            ),
                                            // SE O ANÚNCIO FOR DESTAQUE (impulsionar == "1")
                                            if (anuncio.impulsionar == "1")
                                              Positioned(
                                                top: 8,
                                                left: 8,
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: corDestaqueLaranja,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 2)
                                                    ],
                                                  ),
                                                  child: const Text("DESTAQUE",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                              ),
                                          ],
                                        ),

                                        // DADOS DO ANÚNCIO
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  anuncio.titulo,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "R\$ ${anuncio.preco}",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color:
                                                          corDestaqueLaranja),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "${anuncio.cidade} • ${anuncio.data}",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        if (retornoMensagem == false && lista.length == 0)
                          Container(
                            padding: EdgeInsets.all(25),
                            child: Text(
                              "Nenhum anúncio! :( ",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Center(
                      child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 8),
                        child: _progresBarLinear
                            ? CircularProgressIndicator(
                                color:
                                    corDestaqueLaranja, // Cor do loading alterada para laranja
                              )
                            : Center(),
                      ),
                    ],
                  )),
                ],
              ),
            ),
            Column(
              children: [
                if (_anchoredBanner != null)
                  Container(
                    color: Colors.white,
                    width: _anchoredBanner!.size.width.toDouble(),
                    height: _anchoredBanner!.size.height.toDouble(),
                    child: AdWidget(ad: _anchoredBanner!),
                  ),
              ],
            )
          ],
        ));
  }
}

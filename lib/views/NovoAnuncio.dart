import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pechinchar_online/external/ImgBbApi.dart';
import 'package:pechinchar_online/models/Anuncio.dart';
import 'package:pechinchar_online/util/Configuracoes.dart';
import 'package:pechinchar_online/views/impulsionar.dart';

class NovoAnuncio extends StatefulWidget {
  @override
  _NovoAnuncioState createState() => _NovoAnuncioState();
}

class _NovoAnuncioState extends State<NovoAnuncio> {
  late String data;
  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    nonPersonalizedAds: true,
  );

  BannerAd? _anchoredBanner;
  bool _loadingAnchoredBanner = false;

  final Color corPrincipalAzul = const Color(0xFF0B1C4B);
  final Color corDestaqueLaranja = const Color(0xFFFF8C00);

  List<XFile> _listaImagens = [];
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _usuarioSub;
  List<DropdownMenuItem<String>> _listaItensDropCategorias = [];
  List<DropdownMenuItem<String>> _listaItensDropSubCategorias = [];
  List<DropdownMenuItem<String>> _listaItensDropSubCategoriasImoveis = [];
  List<DropdownMenuItem<String>> _listaItensDropSubCategoriasProdutos = [];
  List<DropdownMenuItem<String>> _listaItensDropSubCategoriasMoveis = [];
  List<DropdownMenuItem<String>> _listaItensDropSubCategoriasSupermercados = [];
  List<DropdownMenuItem<String>> _listaItensDropSubCategoriasRestaurantes = [];
  List<DropdownMenuItem<String>> _listaItensDropSubCategoriasTransporte = [];
  List<DropdownMenuItem<String>> _listaItensDropSubCategoriasServicos = [];

  final _formKey = GlobalKey<FormState>();
  late Anuncio _anuncio;
  late BuildContext _dialogContext;

  String? _itemSelecionadoCategoria;
  String? _itemSelecionadoSubCategoria;

  TextEditingController _controllerTitulo = TextEditingController();
  TextEditingController _controllerPreco = TextEditingController();
  TextEditingController _controllerDescricao = TextEditingController();

  late bool _progressBarLinear;
  String nome = "";
  String telefone = "";
  String cidade = "";
  String estado = "";
  String endereco = "";

  @override
  void initState() {
    super.initState();
    _anuncio = Anuncio.gerarId();
    _carregarItensDropdown();
    _progressBarLinear = false;
    _retornaDados();

    DateTime date = DateTime.now();
    data = DateFormat("dd/MM/yyyy").format(date);
  }

  @override
  void dispose() {
    _controllerTitulo.dispose();
    _controllerPreco.dispose();
    _controllerDescricao.dispose();
    _anchoredBanner?.dispose();
    _usuarioSub?.cancel();
    super.dispose();
  }

  Future<dynamic> _retornaDados() async {
    if (!mounted) return;
    setState(() => _progressBarLinear = true);
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _usuarioSub = FirebaseFirestore.instance
        .collection("usuarios")
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      var dados = snapshot.data();
      if (!mounted) return;
      setState(() {
        nome = dados?["nome"] ?? "";
        telefone = dados?["telefone"] ?? "";
        cidade = dados?["cidade"] ?? "";
        estado = dados?["estado"] ?? "";
        endereco = dados?["endereco"] ?? "";
        _progressBarLinear = false;
      });
    }, onError: (_) {
      if (!mounted) return;
      setState(() => _progressBarLinear = false);
    });
  }

  _selecionarImagemGaleria() async {
    // No Flutter Web, abrir o seletor de arquivos com um TextField ativo
    // pode acionar assert interno do engine.
    FocusManager.instance.primaryFocus?.unfocus();
    if (kIsWeb) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    final ImagePicker _picker = ImagePicker();

    // CORREÇÃO DE UPLOAD: imageQuality comprime a foto para evitar o Timeout da ImgBB API
    final XFile? imagemSelecionada = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );

    if (imagemSelecionada != null) {
      if (_listaImagens.length < 6) {
        setState(() {
          _listaImagens.add(imagemSelecionada);
        });
      } else {
        _mostrarSnackBar(
            "Você só pode adicionar até 6 imagens!", Colors.orange);
      }
    }
  }

  void _mostrarSnackBar(String mensagem, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: cor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

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

  _validarCampos(String decisao) {
    if (_listaImagens.isEmpty) {
      _mostrarSnackBar("Adicione pelo menos uma foto!", Colors.redAccent);
      return;
    }
    if (_itemSelecionadoCategoria == null) {
      _mostrarSnackBar("Selecione uma categoria!", Colors.redAccent);
      return;
    }
    if (_itemSelecionadoSubCategoria == null) {
      _mostrarSnackBar("Selecione uma subcategoria!", Colors.redAccent);
      return;
    }
    if (_controllerTitulo.text.trim().isEmpty) {
      _mostrarSnackBar("Preencha o título do anúncio!", Colors.redAccent);
      return;
    }
    if (_controllerPreco.text.trim().isEmpty) {
      _mostrarSnackBar("Preencha o preço!", Colors.redAccent);
      return;
    }
    if (_controllerDescricao.text.trim().isEmpty) {
      _mostrarSnackBar("Preencha a descrição!", Colors.redAccent);
      return;
    }

    User? auth = FirebaseAuth.instance.currentUser;
    if (auth == null) return;

    _anuncio.idUsuario = auth.uid;
    _anuncio.titulo = _controllerTitulo.text.trim();
    _anuncio.preco = _controllerPreco.text.trim();
    _anuncio.descricao = _controllerDescricao.text.trim();
    _anuncio.categoria = _itemSelecionadoCategoria!;
    _anuncio.subCategoria = _itemSelecionadoSubCategoria!;
    _anuncio.nome = nome;
    _anuncio.telefone = telefone;
    _anuncio.cidade = cidade;
    _anuncio.estado = estado;
    _anuncio.endereco = endereco;
    _anuncio.data = data;
    _anuncio.horario = DateFormat.Hms().format(DateTime.now());
    _anuncio.impulsionar = "0";

    if (decisao == "cadastrar") {
      _salvarAnuncio(_anuncio);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Impulsionar(anuncio: _anuncio, imagens: _listaImagens)),
      );
    }
  }

  _abrirDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: corDestaqueLaranja),
                const SizedBox(height: 20),
                Text("Enviando imagens e salvando anúncio...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: corPrincipalAzul, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        });
  }

  _salvarAnuncio(Anuncio anuncio) async {
    _dialogContext = context;
    _abrirDialog(_dialogContext);

    try {
      await _uploadImagens(anuncio);

      User? usuarioLogado = FirebaseAuth.instance.currentUser;
      if (usuarioLogado == null) {
        Navigator.pop(_dialogContext);
        _mostrarSnackBar("Sessão expirada. Faça login novamente.", Colors.red);
        return;
      }

      FirebaseFirestore db = FirebaseFirestore.instance;
      await db
          .collection("meus_anuncios")
          .doc(usuarioLogado.uid)
          .collection("anuncios")
          .doc(anuncio.id)
          .set(anuncio.toMap());

      await db
          .collection("anuncios")
          .doc(anuncio.categoria)
          .collection(anuncio.categoria)
          .doc(anuncio.id)
          .set(anuncio.toMap());

      if (!mounted) return;
      Navigator.pop(_dialogContext);
      Navigator.pop(context);
      _mostrarSnackBar("Anúncio publicado com sucesso!", Colors.green);
    } catch (e) {
      print(
          "Erro no upload para ImgBB ou Firestore: $e"); // Log para facilitar o debug

      if (!mounted) return;
      Navigator.pop(_dialogContext);
      _mostrarSnackBar(
        "Tempo esgotado ou erro de rede. Verifique a internet e tente novamente.",
        Colors.redAccent,
      );
    }
  }

  Future<void> _uploadImagens(Anuncio anuncio) async {
    if (_listaImagens.isEmpty || anuncio.fotos.isNotEmpty) {
      return;
    }

    final ImgBbApi imgBbApi = ImgBbApi();
    final List<String> urls = await imgBbApi.uploadImages(_listaImagens);
    anuncio.fotos.addAll(urls);
  }

  _carregarItensDropdown() {
    _listaItensDropCategorias = Configuracoes.getCategorias();
    _listaItensDropSubCategoriasImoveis = Configuracoes.getSubImoveis();
    _listaItensDropSubCategoriasProdutos = Configuracoes.getSubProdutos();
    _listaItensDropSubCategoriasMoveis = Configuracoes.getSubProdutos();
    _listaItensDropSubCategoriasSupermercados =
        Configuracoes.getSubSupermercados();
    _listaItensDropSubCategoriasRestaurantes =
        Configuracoes.getSubRestaurantes();
    _listaItensDropSubCategoriasTransporte = Configuracoes.getSubTransporte();
    _listaItensDropSubCategoriasServicos = Configuracoes.getSubServicos();
  }

  _carregarSubCategoria() {
    _itemSelecionadoSubCategoria = null;
    _listaItensDropSubCategorias.clear();
    List<DropdownMenuItem<String>> tempList = [];

    switch (_itemSelecionadoCategoria) {
      case "imoveis":
        tempList = _listaItensDropSubCategoriasImoveis;
        break;
      case "produtos":
        tempList = _listaItensDropSubCategoriasProdutos;
        break;
      case "supermercados":
        tempList = _listaItensDropSubCategoriasSupermercados;
        break;
      case "moveis":
        tempList = _listaItensDropSubCategoriasMoveis;
        break;
      case "restaurantes":
        tempList = _listaItensDropSubCategoriasRestaurantes;
        break;
      case "transporte":
        tempList = _listaItensDropSubCategoriasTransporte;
        break;
      case "servicos":
        tempList = _listaItensDropSubCategoriasServicos;
        break;
    }

    setState(() {
      _listaItensDropSubCategorias.addAll(tempList);
    });
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[700]),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: corDestaqueLaranja, width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && !_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: corPrincipalAzul,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text("Criar Anúncio",
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
      body: Column(
        children: [
          if (_progressBarLinear)
            LinearProgressIndicator(
                color: corDestaqueLaranja, backgroundColor: corPrincipalAzul),
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text("Fotos do Anúncio",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B1C4B))),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _listaImagens.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _listaImagens.length) {
                              return GestureDetector(
                                onTap: _selecionarImagemGaleria,
                                child: Container(
                                  width: 100,
                                  height:
                                      100, // Garantindo a altura do botão também
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color:
                                            corDestaqueLaranja.withOpacity(0.5),
                                        style: BorderStyle.solid,
                                        width: 2),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo,
                                          color: corDestaqueLaranja, size: 30),
                                      const SizedBox(height: 4),
                                      Text("Adicionar",
                                          style: TextStyle(
                                              color: corDestaqueLaranja,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100, // CORREÇÃO DA IMAGEM INVISÍVEL
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                        image: kIsWeb
                                            ? NetworkImage(
                                                _listaImagens[index].path)
                                            : FileImage(
                                                File(_listaImagens[index].path),
                                              ) as ImageProvider,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 16,
                                  child: GestureDetector(
                                    onTap: () => setState(
                                        () => _listaImagens.removeAt(index)),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _itemSelecionadoCategoria,
                              decoration: _buildInputDecoration("Categoria"),
                              items: _listaItensDropCategorias,
                              onChanged: (valor) => setState(() {
                                _itemSelecionadoCategoria = valor;
                                _carregarSubCategoria();
                              }),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _itemSelecionadoSubCategoria,
                              decoration: _buildInputDecoration("Subcategoria"),
                              items: _listaItensDropSubCategorias,
                              onChanged: (valor) => setState(
                                  () => _itemSelecionadoSubCategoria = valor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _controllerTitulo,
                        decoration: _buildInputDecoration("Título do Anúncio"),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _controllerPreco,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          RealInputFormatter(
                              moeda:
                                  true) // Isso já coloca o R$ automaticamente
                        ],
                        decoration:
                            _buildInputDecoration("Preço"), // Fica só assim!
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _controllerDescricao,
                        maxLines: 4,
                        maxLength: 200,
                        decoration: _buildInputDecoration(
                            "Descrição do produto ou serviço"),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[300]!)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Seus Dados (Públicos)",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: corPrincipalAzul)),
                              const Divider(),
                              Text("Nome: $nome",
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 4),
                              Text("Contato: $telefone",
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 4),
                              Text("Local: $cidade - $estado",
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.rocket_launch,
                              color: corDestaqueLaranja),
                          label: Text("Impulsionar Anúncio",
                              style: TextStyle(
                                  fontSize: 16, color: corDestaqueLaranja)),
                          style: OutlinedButton.styleFrom(
                            side:
                                BorderSide(color: corDestaqueLaranja, width: 2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _validarCampos("impulsionar"),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: corPrincipalAzul,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _validarCampos("cadastrar"),
                          child: const Text("Publicar Grátis",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
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

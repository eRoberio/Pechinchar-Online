import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pechinchar_online/external/ImgBbApi.dart';
import 'package:pechinchar_online/models/Anuncio.dart';
import 'package:url_launcher/url_launcher.dart';

class Impulsionar extends StatefulWidget {
  final Anuncio anuncio;
  final List<XFile> imagens;

  const Impulsionar({Key? key, required this.anuncio, required this.imagens})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ImpulsionarState();
}

class ImpulsionarState extends State<Impulsionar> {
  late BuildContext _dialogContext;
  late String valor;

  final Color corPrincipalAzul = const Color(0xFF0B1C4B);
  final Color corDestaqueLaranja = const Color(0xFFFF8C00);

  @override
  void initState() {
    super.initState();
    // Cálculo de 10% do valor do anúncio
    double valorPagar = ((double.parse(
                widget.anuncio.preco.replaceAll(".", "").replaceAll(',', '.')) /
            100) *
        10);
    valor = valorPagar.toStringAsFixed(2).replaceAll('.', ',');
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
                Text(
                  "Preparando anúncio...",
                  style: TextStyle(
                      color: corPrincipalAzul, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        });
  }

  Future<void> _abrirWhatstapp() async {
    final Uri whatsappUri = Uri.parse(
        "whatsapp://send?phone=+5573981258195&text=Olá! Segue o comprovante do PIX para impulsionar o anúncio: ${widget.anuncio.titulo}");

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("O WhatsApp não está instalado neste dispositivo."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  impulsionarAnuncio(Anuncio anuncio) async {
    _dialogContext = context;
    _abrirDialog(_dialogContext);

    try {
      await _uploadImagens(anuncio);

      FirebaseAuth auth = FirebaseAuth.instance;
      User? usuarioLogado = auth.currentUser;
      if (usuarioLogado == null) {
        Navigator.pop(_dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sessao expirada. Faca login novamente."),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      String idUsuarioLogado = usuarioLogado.uid;

      anuncio.impulsionar = "1";

      FirebaseFirestore db = FirebaseFirestore.instance;

      await db
          .collection("meus_anuncios")
          .doc(idUsuarioLogado)
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Aguardando verificacao do pagamento para destaque!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.pop(_dialogContext);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Nao foi possivel enviar as imagens para o ImgBB. Tente novamente.",
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _uploadImagens(Anuncio anuncio) async {
    if (widget.imagens.isEmpty || anuncio.fotos.isNotEmpty) {
      return;
    }

    final ImgBbApi imgBbApi = ImgBbApi();
    final List<String> urls = await imgBbApi.uploadImages(widget.imagens);
    anuncio.fotos.addAll(urls);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: corPrincipalAzul,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text("Destacar Anúncio",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 1. Resumo do Anúncio (Tratando se a imagem vem de File ou da Web)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 90,
                        height: 90,
                        child: widget.imagens.isNotEmpty
                            ? (kIsWeb
                                ? Image.network(widget.imagens[0].path,
                                    fit: BoxFit.cover)
                                : Image.file(File(widget.imagens[0].path),
                                    fit: BoxFit.cover))
                            : widget.anuncio.fotos.isNotEmpty
                                ? Image.network(widget.anuncio.fotos[0],
                                    fit: BoxFit.cover)
                                : Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.anuncio.titulo,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: corPrincipalAzul),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "R\$ ${widget.anuncio.preco}",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: corDestaqueLaranja),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 2. Benefícios do Impulsionamento
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.rocket_launch,
                      size: 48, color: corDestaqueLaranja),
                  const SizedBox(height: 12),
                  Text(
                    "Alcance mais clientes!",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: corPrincipalAzul),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Seu anúncio ficará em evidência no topo da lista por 30 dias. Mais visibilidade significa vendas mais rápidas.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Valor do destaque",
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[800])),
                      Text("R\$ $valor",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: corDestaqueLaranja)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Pagamento PIX
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), // Fundo verde clarinho
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pix, color: Colors.teal),
                      SizedBox(width: 8),
                      Text("Pague com o PIX",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text("Chave Celular:",
                      style: TextStyle(color: Colors.grey)),
                  const Text(
                    "73 98125-8195",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Após realizar a transferência, clique no botão abaixo para enviar o comprovante e finalizar o destaque.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 4. Botão de Ação Principal
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  _abrirWhatstapp();
                  impulsionarAnuncio(widget.anuncio);
                },
                icon: const Icon(Icons.message),
                label: const Text("Enviar Comprovante e Concluir",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

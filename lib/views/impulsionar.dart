import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    // Cálculo de 10% com tratamento de string seguro
    try {
      String precoLimpo = widget.anuncio.preco
          .replaceAll(RegExp(r'[^0-9,]'), '')
          .replaceAll(',', '.');
      double precoDouble = double.tryParse(precoLimpo) ?? 0.0;
      double valorPagar = (precoDouble / 100) * 10;
      valor = valorPagar.toStringAsFixed(2).replaceAll('.', ',');
    } catch (e) {
      valor = "0,00";
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
                Text("Processando...",
                    style: TextStyle(
                        color: corPrincipalAzul, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        });
  }

  Future<void> _abrirWhatstapp() async {
    final String numero = "5573981275007";
    final String msg = Uri.encodeComponent(
        "Olá! Segue o comprovante do PIX para impulsionar o anúncio: ${widget.anuncio.titulo}");
    final Uri uri = Uri.parse("https://wa.me/$numero?text=$msg");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao abrir WhatsApp")));
    }
  }

  impulsionarAnuncio(Anuncio anuncio) async {
    _dialogContext = context;
    _abrirDialog(_dialogContext);

    try {
      // Se houver imagens locais, faz o upload
      if (widget.imagens.isNotEmpty && anuncio.fotos.isEmpty) {
        final ImgBbApi imgBbApi = ImgBbApi();
        List<String> urls = await imgBbApi.uploadImages(widget.imagens);
        anuncio.fotos.addAll(urls);
      }

      User? usuarioLogado = FirebaseAuth.instance.currentUser;
      if (usuarioLogado == null) return;

      anuncio.impulsionar = "1";

      FirebaseFirestore db = FirebaseFirestore.instance;
      // Salva em ambos os bancos
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

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Solicitação Enviada!"),
          content: const Text(
              "Aguardando confirmação do pagamento para que seu anúncio ganhe o selo de Destaque."),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"))
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(_dialogContext);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Erro ao processar.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: corPrincipalAzul,
        title: const Text("Impulsionar Anúncio",
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resumo do Anúncio Seguro
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: widget.anuncio.fotos.isNotEmpty
                          ? Image.network(widget.anuncio.fotos[0],
                              fit: BoxFit.cover)
                          : const Icon(Icons.image),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Text(widget.anuncio.titulo,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Info PIX
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.green[50],
              child: Column(
                children: [
                  const Text("Chave PIX:",
                      style: TextStyle(color: Colors.grey)),
                  const Text("73 981275007",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("Valor: R\$ $valor",
                      style:
                          TextStyle(fontSize: 18, color: corDestaqueLaranja)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                _abrirWhatstapp();
                impulsionarAnuncio(widget.anuncio);
              },
              icon: const Icon(Icons.send, color: Colors.white),
              label: const Text("Enviar Comprovante",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

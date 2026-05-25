import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pechinchar_online/models/Anuncio.dart';
// Certifique-se de ter o pacote url_launcher no pubspec.yaml para os botões de contato
// import 'package:url_launcher/url_launcher.dart';

class DetalhesAnuncio extends StatefulWidget {
  final Anuncio anuncio;
  final bool
      exibirBotoesContato; // Usado para esconder contato se for o próprio anúncio

  const DetalhesAnuncio(this.anuncio, this.exibirBotoesContato, {Key? key})
      : super(key: key);

  @override
  _DetalhesAnuncioState createState() => _DetalhesAnuncioState();
}

class _DetalhesAnuncioState extends State<DetalhesAnuncio> {
  int _imagemAtual = 0;
  final Color corPrincipalAzul = const Color(0xFF0B1C4B);
  final Color corDestaqueLaranja = const Color(0xFFFF8C00);

  // Método placeholder para o url_launcher
  void _abrirWhatsApp() async {
    // String url = "whatsapp://send?phone=+55${widget.anuncio.telefone}&text=Olá, vi seu anúncio: ${widget.anuncio.titulo}";
    // if (await canLaunchUrl(Uri.parse(url))) { await launchUrl(Uri.parse(url)); }
    print("Abrir WhatsApp: ${widget.anuncio.telefone}");
  }

  void _ligarTelefone() async {
    // String url = "tel:${widget.anuncio.telefone}";
    // if (await canLaunchUrl(Uri.parse(url))) { await launchUrl(Uri.parse(url)); }
    print("Ligar para: ${widget.anuncio.telefone}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors
          .grey[50], // Fundo levemente cinza para destacar os cards brancos
      body: CustomScrollView(
        slivers: <Widget>[
          // 1. App Bar Expansível com Carrossel de Imagens
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: corPrincipalAzul,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    itemCount: widget.anuncio.fotos.length,
                    onPageChanged: (index) {
                      setState(() {
                        _imagemAtual = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: widget.anuncio.fotos[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                              color: corDestaqueLaranja),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      );
                    },
                  ),
                  // Indicador de Páginas (Bolinhas)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.anuncio.fotos.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _imagemAtual == index ? 12 : 8,
                          height: _imagemAtual == index ? 12 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _imagemAtual == index
                                ? corDestaqueLaranja
                                : Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Conteúdo do Anúncio
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "R\$ ${widget.anuncio.preco}",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: corDestaqueLaranja,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.anuncio.titulo,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: corPrincipalAzul,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            color: Colors.grey[600], size: 20),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${widget.anuncio.cidade} - ${widget.anuncio.estado}",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time_outlined,
                            color: Colors.grey[600], size: 20),
                        const SizedBox(width: 4),
                        Text(
                          "Publicado em ${widget.anuncio.data} às ${widget.anuncio.horario}",
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 3. Descrição
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Descrição",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: corPrincipalAzul,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.anuncio.descricao,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                  height:
                      100), // Espaço extra para não esconder conteúdo atrás da bottom bar
            ]),
          ),
        ],
      ),

      // 4. Bottom Bar Fixa para Contato (Call to Action)
      bottomNavigationBar: widget.exibirBotoesContato
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _ligarTelefone,
                        icon: const Icon(Icons.phone),
                        label: const Text("Ligar"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: corPrincipalAzul,
                          side: BorderSide(color: corPrincipalAzul),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _abrirWhatsApp,
                        icon: const Icon(Icons.chat),
                        label: const Text("WhatsApp",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

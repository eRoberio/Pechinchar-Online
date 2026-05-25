import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pechinchar_online/models/Anuncio.dart';

enum AdCardType { normal, favorito, meusAnuncios }

class AdCardModerno extends StatelessWidget {
  final Anuncio anuncio;
  final AdCardType tipo;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onBoost;

  const AdCardModerno({
    Key? key,
    required this.anuncio,
    this.tipo = AdCardType.normal,
    this.onTap,
    this.onRemove,
    this.onBoost,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do anuncio
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: SizedBox(
                width: 130,
                height: 140,
                child: CachedNetworkImage(
                  imageUrl: anuncio.fotos.isNotEmpty ? anuncio.fotos[0] : '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF8C00)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey),
                  ),
                ),
              ),
            ),

            // Informacoes do anuncio
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anuncio.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B1C4B), // Azul Principal
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "R\$ ${anuncio.preco}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF8C00), // Laranja Destaque
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              anuncio.data,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                            Text(
                              anuncio.horario,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        _buildAcoesDinamicas(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Renderiza botoes dependendo da tela onde o card esta sendo chamado
  Widget _buildAcoesDinamicas() {
    if (tipo == AdCardType.favorito || onRemove != null) {
      return IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
        onPressed: onRemove,
        tooltip: "Remover",
      );
    } else if (tipo == AdCardType.meusAnuncios) {
      return Row(
        children: [
          if (anuncio.impulsionar == "0")
            TextButton(
              onPressed: onBoost,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFF8C00).withOpacity(0.1),
                foregroundColor: const Color(0xFFFF8C00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Impulsionar", style: TextStyle(fontSize: 12)),
            ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: onRemove,
            ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

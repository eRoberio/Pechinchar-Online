import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pechinchar_online/models/Anuncio.dart';



class ItemAnuncio extends StatelessWidget {
  final Anuncio anuncio;
  final VoidCallback? onTapItem;
  final VoidCallback? onPressedRemover;

  const ItemAnuncio({
    required this.anuncio,
    this.onTapItem,
    this.onPressedRemover,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapItem,
      child: Card(
        margin: EdgeInsets.only(top: 4, bottom: 4, right: 8, left: 8),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(children: <Widget>[
            SizedBox(
              width: 120,
              height: 120,
              child: CachedNetworkImage(
                imageUrl: anuncio.fotos[0],
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => Transform.scale(
                  scale: 0.3,
                  child: CircularProgressIndicator(
                    color: Color(0xff0f530f),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                  Text(
                      anuncio.titulo,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text("R\$ ${anuncio.preco} "),
                ],),
              ),
            ),
            if (onPressedRemover != null)
              Expanded(
                flex: 1,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: EdgeInsets.all(10),
                  ),
                  onPressed: onPressedRemover,
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
              )
            //botao remover
          ],
          ),
        ),
      ),
    );
  }
}

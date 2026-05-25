import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pechinchar_online/models/Anuncio.dart';

class ItemMeusAnuncios extends StatelessWidget {
  final Anuncio anuncio;
  final VoidCallback? onTapItem;
  final VoidCallback? onPressedRemover;

  const ItemMeusAnuncios({
    required this.anuncio,
    this.onTapItem,
    this.onPressedRemover,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(top: 4, bottom: 4, right: 8, left: 8),
      child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 150,
                    height: 120,
                    child: anuncio.fotos.isNotEmpty
                        ? CachedNetworkImage(
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
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image,
                              color: Colors.grey[500],
                            ),
                          ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            anuncio.titulo,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text("R\$ ${anuncio.preco} "),
                          Padding(padding: EdgeInsets.only(top: 16)),
                          Text(
                            anuncio.data,
                          ),
                          Text(anuncio.horario),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          if (onPressedRemover != null)
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                //padding: EdgeInsets.all(8),
                              ),
                              onPressed: onPressedRemover,
                              child:
                                  const Icon(Icons.delete, color: Colors.red),
                            ),
                        ],
                      ))
                ],
              ),
              if (anuncio.impulsionar == "0")
                Container(
                  padding: EdgeInsets.only(top: 8),
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                      child: Text(
                        "Impulsionar",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                          elevation: 15,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.0),
                              side: BorderSide(color: Colors.black)),
                          padding: EdgeInsets.fromLTRB(32, 16, 32, 16)),
                      onPressed: onTapItem),
                )
            ],
          )),
    );
  }
}

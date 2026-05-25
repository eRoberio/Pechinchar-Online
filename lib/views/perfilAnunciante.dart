import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pechinchar_online/adaptadores/ItemAnuncio.dart';
import 'package:pechinchar_online/models/Anuncio.dart';
import 'package:pechinchar_online/views/detalhesAnuncio.dart';

class PerfilAnunciante extends StatefulWidget {
  Anuncio perfilAnunciante;

  PerfilAnunciante(this.perfilAnunciante);

  @override
  _PerfilAnuncianteState createState() => _PerfilAnuncianteState();
}

class _PerfilAnuncianteState extends State<PerfilAnunciante> {
  late Anuncio anunciante;

  final _controller = StreamController<QuerySnapshot>.broadcast();

  Future<Stream<QuerySnapshot>> _adicionarListenerAnuncios() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Stream<QuerySnapshot> stream = db
        .collection("meus_anuncios")
        .doc(anunciante.idUsuario)
        .collection("anuncios")
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
    return stream;
  }

  @override
  void initState() {
    super.initState();
    anunciante = widget.perfilAnunciante;
    _adicionarListenerAnuncios();
  }

  @override
  Widget build(BuildContext context) {
    var carregandoDados = Center(
      child: Column(
        children: <Widget>[
          Text("Carregando anúncios"),
          CircularProgressIndicator()
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          title: Text("Perfil do anunciante"),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(4.0),
            child: const Icon(
              Icons.storefront,
              color: Colors.white,
              size: 30,
            ),
          )
        ],
        backgroundColor: Color(0xFF129E09),
      ),
      body: Stack(
        children: [
          LayoutBuilder(builder: (_, constraints) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF46b044),
                    const Color(0xff9cd981),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      height: constraints.maxHeight / 3.9,
                      padding: EdgeInsets.only(top: 16, left: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF46b044),
                            const Color(0xff9cd981),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Text(
                                "Anunciante",
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 4),
                                child: Text(
                                  "${anunciante.nome}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 4),
                                child: Text(
                                  "${anunciante.endereco + ", " + anunciante.cidade + "-" + anunciante.estado}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text("Contato"),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 4),
                                child: Text(
                                  "${anunciante.telefone}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Anúncios desse Perfil",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          ],
                        ),
                      )),
                  Container(
                    clipBehavior: Clip.antiAlias,
                    height: constraints.maxHeight / 1.4,
                    decoration: new BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(40.0),
                        topRight: const Radius.circular(40.0),
                      ),
                    ),
                    child: StreamBuilder(
                      stream: _controller.stream,
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                          case ConnectionState.waiting:
                            return carregandoDados;
                            break;
                          case ConnectionState.active:
                          case ConnectionState.done:
                            //Exibe mensagem de erro
                            if (snapshot.hasError)
                              return Text("Erro ao carregar os dados!");

                            final querySnapshot =
                                snapshot.data as QuerySnapshot?;
                            if (querySnapshot == null) {
                              return carregandoDados;
                            }
                            return ListView.builder(
                                itemCount: querySnapshot.docs.length,
                                itemBuilder: (_, indice) {
                                  List<DocumentSnapshot> anuncios =
                                      querySnapshot.docs.toList();
                                  DocumentSnapshot documentSnapshot =
                                      anuncios[indice];
                                  Anuncio anuncio =
                                      Anuncio.fromDocumentSnapshot(
                                          documentSnapshot);

                                  return ItemAnuncio(
                                    anuncio: anuncio,
                                    onTapItem: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DetalhesAnuncio(
                                                      anuncio, false)));
                                    },
                                  );
                                });
                        }
                        return Container();
                      },
                    ),
                  )
                ],
              ),
            );
          })
        ],
      ),
    );
  }
}

/*
Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Perfil do anunciante"),
        actions: [
          Padding(
            padding: EdgeInsets.all(4.0),
            child: Icon(Icons.storefront, color: Colors.white, size: 30),
          )
        ],
        backgroundColor: Color(0xFF129E09),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * (0.3),
            color: Colors.green,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Anunciante",
                  style: TextStyle(
                    fontSize: 14,
                    //fontWeight: FontWeight.bold
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    "${anunciante.nome}",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        "${anunciante.endereco + ", " + anunciante.cidade + "-" + anunciante.estado}",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
                Text("Contato"),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    "${anunciante.telefone}",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Divider(),
              ],
            ),
          ),
          Container(
            decoration: new BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(40.0),
                topRight: const Radius.circular(40.0),
              ),
            ),
            height: MediaQuery.of(context).size.height * .8,
            child: StreamBuilder(
              stream: _controller.stream,
              builder: (context, snapshot){

                switch( snapshot.connectionState ){
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return carregandoDados;
                    break;
                  case ConnectionState.active:
                  case ConnectionState.done:

                  //Exibe mensagem de erro
                    if(snapshot.hasError)
                      return Text("Erro ao carregar os dados!");

                    QuerySnapshot querySnapshot = snapshot.data;

                    return ListView.builder(
                        itemCount: querySnapshot.docs.length,
                        itemBuilder: (_, indice){

                          List<DocumentSnapshot> anuncios = querySnapshot.docs.toList();
                          DocumentSnapshot documentSnapshot = anuncios[indice];
                          Anuncio anuncio = Anuncio.fromDocumentSnapshot(documentSnapshot);

                          return ItemAnuncio(
                            anuncio: anuncio,
                            onTapItem: (){
                              //Navigator.push(context, MaterialPageRoute(builder: (context) => Impulsionar()));
                            },
                            onPressedRemover: (){
                              showDialog(
                                  context: context,
                                  builder: (context){
                                    return AlertDialog(
                                      title: Text("Atenção"),
                                      content: Text("Deseja realmente excluir o anúncio?"),
                                      actions: <Widget>[

                                        TextButton(
                                          child: Text(
                                            "Cancelar",
                                            style: TextStyle(
                                                color: Colors.grey
                                            ),
                                          ),
                                          onPressed: (){
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  }
                              );
                            },
                          );
                        }
                    );
                }
                return Container();
              },
            ),
          )
        ],
      )
    );
 */

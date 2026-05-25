import 'package:cloud_firestore/cloud_firestore.dart';

class Anuncio{

  late String _id;
  late String _impulsionar;
  late String _idUsuario;
  late String _categoria;
  late String _subCategoria;
  late String _titulo;
  late String _preco;
  late String _nome;
  late String _telefone;
  late String _descricao;
  late String _cidade;
  late String _estado;
  late String _endereco;
  late List<String> _fotos;
  late String _data;
  late String _horario;

  Anuncio();

  Anuncio.fromDocumentSnapshot(DocumentSnapshot documentSnapshot){

    this.id           = documentSnapshot.id;
    this.impulsionar  = documentSnapshot["impulsionar"];
    this._idUsuario   = documentSnapshot["idUsuario"];
    this.categoria    = documentSnapshot["categoria"];
    this.subCategoria = documentSnapshot["subCategoria"];
    this.titulo       = documentSnapshot["titulo"];
    this.nome         = documentSnapshot["nome"];
    this.preco        = documentSnapshot["preco"];
    this.telefone     = documentSnapshot["telefone"];
    this.descricao    = documentSnapshot["descricao"];
    this.cidade       = documentSnapshot["cidade"];
    this.estado       = documentSnapshot["estado"];
    this.endereco     = documentSnapshot["endereco"];
    this.fotos        = List<String>.from(documentSnapshot["fotos"]);
    this.data         = documentSnapshot["data"];
    this.horario      = documentSnapshot["horario"];

  }

  Anuncio.gerarId(){

    FirebaseFirestore db = FirebaseFirestore.instance;
    CollectionReference anuncios = db.collection("meus_anuncios");
    this.id = anuncios.doc().id;

    this.fotos = [];

  }

  Map<String, dynamic> toMap(){

    Map<String, dynamic> map = {
      "id"           : this.id,
      "impulsionar"  : this.impulsionar,
      "idUsuario"    : this.idUsuario,
      "categoria"    : this.categoria,
      "subCategoria" : this.subCategoria,
      "titulo"       : this.titulo,
      "preco"        : this.preco,
      "nome"         : this.nome,
      "telefone"     : this.telefone,
      "descricao"    : this.descricao,
      "cidade"       : this.cidade,
      "estado"       : this.estado,
      "endereco"     : this.endereco,
      "fotos"        : this.fotos,
      "data"         : this.data,
      "horario"      : this.horario,
    };

    return map;

  }

  String get horario => _horario;

  set horario(String value){
    _horario = value;
  }

  String get data => _data;

  set data(String value){
    _data = value;
  }

  List<String> get fotos => _fotos;

  set fotos(List<String> value) {
    _fotos = value;
  }

  String get cidade => _cidade;

  set cidade(String value) {
    _cidade = value;
  }

  String get endereco => _endereco;

  set endereco(String value){
    _endereco = value;
  }

  String get nome => _nome;

  set nome(String value){
    _nome = value;
  }

  String get estado => _estado;

  set estado(String value) {
    _estado = value;
  }

  String get descricao => _descricao;

  set descricao(String value) {
    _descricao = value;
  }

  String get telefone => _telefone;

  set telefone(String value) {
    _telefone = value;
  }

  String get preco => _preco;

  set preco(String value) {
    _preco = value;
  }

  String get titulo => _titulo;

  set titulo(String value) {
    _titulo = value;
  }

  String get subCategoria => _subCategoria;

  set subCategoria(String value) {
    _subCategoria = value;
  }

  String get categoria => _categoria;

  set categoria(String value) {
    _categoria = value;
  }

  String get idUsuario => _idUsuario;

  set idUsuario(String value) {
    _idUsuario = value;
  }

  String get impulsionar => _impulsionar;

  set impulsionar(String value){
    _impulsionar = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }


}
class Usuario {

  late String _nome;
  late String _telefone;
  late String _cidade;
  late String _estado;
  late String _endereco;

  Usuario();

  Usuario.fromMap(Map map){

    this._nome     = map["nome"];
    this._telefone = map["telefone"];
    this._cidade   = map["cidade"];
    this._estado   = map["estado"];
    this._endereco = map["endereco"];
  }

  Map toMap(){

    Map<String, dynamic> map = {

      "nome"     : this._nome,
      "telefone" : this._telefone,
      "cidade"   : this._cidade,
      "estado"   : this._estado,
      "endereco" : this._endereco
    };
    return map;
  }

  String get endereco => _endereco;

  set endereco(String value){
    _endereco = value;
  }

  String get estado => _estado;

  set estado(String value) {
    _estado = value;
  }

  String get cidade => _cidade;

  set cidade(String value) {
    _cidade = value;
  }

  String get telefone => _telefone;

  set telefone(String value) {
    _telefone = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }
}
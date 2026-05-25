import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pechinchar_online/customizados/InputCustomizadoAnuncio.dart';
import 'package:pechinchar_online/customizados/inputButtonCustomizados.dart';
import 'package:pechinchar_online/customizados/inputCustomizado.dart';
import 'package:pechinchar_online/customizados/inputDropdownButtonCustomizado.dart';
import 'package:pechinchar_online/external/IbgeApi.dart';
import 'package:pechinchar_online/models/IbgeApiModel.dart';
import 'package:pechinchar_online/models/Usuario.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({Key? key}) : super(key: key);

  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  List<DropdownMenuItem<String>> _listaEstados = [];
  List<DropdownMenuItem<String>> _listaCidades = [];

  final TextEditingController _controllerNome = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerTelefone = TextEditingController();
  final TextEditingController _controllerEndereco = TextEditingController();
  final TextEditingController _controllerSenha = TextEditingController();
  final TextEditingController _controllerConfirmarSenha =
      TextEditingController();

  late FToast fToast;
  Usuario usuario = Usuario();
  String? _estadoSelecionado;
  String? _cidadeSelecionada;
  late bool _progressBarLinear;

  // Cores da nova identidade visual (Acomodeme)
  final Color corPrincipalAzul = const Color(0xFF0B1C4B);
  final Color corDestaqueLaranja = const Color(0xFFFF8C00);

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    _progressBarLinear = false;
    _carregarItensDropdownEstados();
  }

  @override
  void dispose() {
    _controllerNome.dispose();
    _controllerEmail.dispose();
    _controllerTelefone.dispose();
    _controllerEndereco.dispose();
    _controllerSenha.dispose();
    _controllerConfirmarSenha.dispose();
    super.dispose();
  }

  // Método auxiliar para evitar repetição de código (DRY)
  void _exibirToastCustomizado(String mensagem) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: corPrincipalAzul.withOpacity(0.95), // Cor da marca
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 12.0),
          Text(
            mensagem,
            style: TextStyle(fontSize: 16, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: Duration(seconds: 3),
    );
  }

  Future _carregarItensDropdownCidades() async {
    _cidadeSelecionada = null;
    _listaCidades.clear();
    if (_estadoSelecionado == null) return;
    IbgeApi apiCidades = IbgeApi();
    List _listaCidade = await apiCidades.getSearchEstado(_estadoSelecionado!);

    for (int i = 0; i < _listaCidade.length; i++) {
      IbgeApiModel nome = _listaCidade[i];
      setState(() {
        _listaCidades
            .add(DropdownMenuItem(child: Text(nome.nome), value: nome.nome));
      });
    }
  }

  //carrega todos os estados do brasil
  _carregarItensDropdownEstados() {
    for (var estado in Estados.listaEstadosSigla) {
      _listaEstados.add(DropdownMenuItem(
        child: Text(estado),
        value: estado,
      ));
    }
  }

  _validarCampos() {
    //Recupera dados dos campos
    String nome = _controllerNome.text.trim();
    String email = _controllerEmail.text.trim();
    String telefone = _controllerTelefone.text;
    String endereco = _controllerEndereco.text.trim();
    String senha = _controllerSenha.text;
    String confirmarSenha = _controllerConfirmarSenha.text;

    if (nome.isNotEmpty) {
      if (telefone.isNotEmpty) {
        if (_estadoSelecionado != null) {
          if (_cidadeSelecionada != null) {
            if (endereco.isNotEmpty) {
              if (email.isNotEmpty && email.contains("@")) {
                if (senha.isNotEmpty && senha.length > 6) {
                  if (confirmarSenha.isNotEmpty &&
                      confirmarSenha.length > 6 &&
                      confirmarSenha == senha) {
                    setState(() {
                      _progressBarLinear = true;
                    });
                    usuario.nome = nome;
                    usuario.telefone = telefone;
                    usuario.cidade = _cidadeSelecionada ?? '';
                    usuario.estado = _estadoSelecionado ?? '';
                    usuario.endereco = endereco;

                    _cadastrarUsuario(email, senha, usuario);
                  } else {
                    _exibirToastCustomizado(
                        "Senhas não são iguais, por favor corrija as senhas!");
                  }
                } else {
                  _exibirToastCustomizado(
                      "Informe a sua senha de acesso, ela tem que ter mais de seis caracteres!");
                }
              } else {
                _exibirToastCustomizado("Informe o seu e-mail corretamente!");
              }
            } else {
              _exibirToastCustomizado("Informe o seu endereço!");
            }
          } else {
            _exibirToastCustomizado("Informe a sua cidade!");
          }
        } else {
          _exibirToastCustomizado("Informe o seu estado!");
        }
      } else {
        _exibirToastCustomizado("Informe o seu telefone!");
      }
    } else {
      _exibirToastCustomizado("Informe o seu nome!");
    }
  }

  Future<void> _cadastrarUsuario(String email, String senha, Usuario usuario) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: senha);

      var id = FirebaseAuth.instance.currentUser;
      String? idUsuario = id?.uid;
      if (idUsuario == null) {
        setState(() {
          _progressBarLinear = false;
        });
        _exibirToastCustomizado("Nao foi possivel recuperar o usuario criado.");
        return;
      }

      final firestoreInstance = FirebaseFirestore.instance;
      WriteBatch batch = firestoreInstance.batch();

      final usuarioRef = firestoreInstance.collection("usuarios").doc(idUsuario);
      final perfilRef = firestoreInstance.collection("perfis").doc(idUsuario);

      batch.set(usuarioRef, {
        "nome": usuario.nome,
        "telefone": usuario.telefone,
        "cidade": usuario.cidade,
        "estado": usuario.estado,
        "endereco": usuario.endereco
      });

      batch.set(perfilRef, {
        "perfil": "Cliente",
        "admin": false,
        "entregador": false,
        "cliente": true
      });

      await batch.commit();

      setState(() {
        _progressBarLinear = false;
      });

      _exibirToastCustomizado("Cadastrado com sucesso!");
      Navigator.pushReplacementNamed(context, "/Login");
    } catch (erro) {
      setState(() {
        _progressBarLinear = false;
      });
      _exibirToastCustomizado(
          "Erro com sua internet ou email ja foi cadastrado!");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Aplica a cor de fundo Azul da marca
    Widget _builderDrawerBack() => Container(
          decoration: BoxDecoration(
              color: corPrincipalAzul // Substitui o gradiente verde
              ),
        );
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, "/Login");
        return false;
      },
      child: Scaffold(
          body: Stack(
        children: [
          _builderDrawerBack(),
          Container(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: Container(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Image.asset("imagens/logo.jpeg",
                              width: 200.0,
                              height:
                                  200.0), // Use a logo correta aqui também se houver
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 24.0, top: 8.0),
                          child: Text(
                            "Acomodeme",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 1),
                          child: _progressBarLinear
                              ? LinearProgressIndicator(
                                  backgroundColor:
                                      Colors.white24, // Fundo contrastante
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      corDestaqueLaranja // Cor do loading alterada para Laranja
                                      ),
                                )
                              : Center(),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8, right: 8, left: 8),
                          child: InputCustomizado(
                            hint: "Nome",
                            obscure: false,
                            icon: Icon(Icons.person,
                                color: Colors.white), // Ícone Branco
                            controller: _controllerNome,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8, right: 8, left: 8),
                          child: InputCustomizadoAnuncio(
                            controller: _controllerTelefone,
                            hint: "Telefone",
                            type: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              TelefoneInputFormatter()
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Container(
                                padding:
                                    EdgeInsets.only(top: 8, right: 16, left: 8),
                                child: InputDropdownButtonCustomizado(
                                  initialValue: _cidadeSelecionada,
                                  hint: "Cidade",
                                  items: _listaCidades,
                                  icon: Icon(Icons.where_to_vote,
                                      color: Colors.white), // Ícone Branco
                                  onChanged: (valor) {
                                    setState(() {
                                      _cidadeSelecionada = valor;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: EdgeInsets.only(top: 8, right: 8),
                                child: InputDropdownButtonCustomizado(
                                  initialValue: _estadoSelecionado,
                                  hint: "Estado",
                                  items: _listaEstados,
                                  icon: Icon(Icons.vpn_lock_rounded,
                                      color: Colors.white), // Ícone Branco
                                  onChanged: (valor) {
                                    setState(() {
                                      _estadoSelecionado = valor;
                                      _carregarItensDropdownCidades();
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8, right: 8, left: 8),
                          child: InputCustomizado(
                            hint: "Endereço",
                            obscure: false,
                            icon: Icon(Icons.map,
                                color: Colors.white), // Ícone Branco
                            controller: _controllerEndereco,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8.0, right: 8, left: 8),
                          child: InputCustomizado(
                            hint: "E-mail",
                            obscure: false,
                            icon: Icon(Icons.attach_email_outlined,
                                color: Colors.white), // Ícone Branco
                            controller: _controllerEmail,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Padding(
                              padding:
                                  EdgeInsets.only(top: 8, left: 8, right: 2),
                              child: InputCustomizado(
                                hint: "Senha",
                                obscure: true,
                                icon: Icon(Icons.lock,
                                    color: Colors.white), // Ícone Branco
                                controller: _controllerSenha,
                              ),
                            )),
                            Expanded(
                                child: Padding(
                              padding:
                                  EdgeInsets.only(top: 8, right: 8, left: 2),
                              child: InputCustomizado(
                                hint: "Senha",
                                obscure: true,
                                icon: Icon(Icons.lock,
                                    color: Colors.white), // Ícone Branco
                                controller: _controllerConfirmarSenha,
                              ),
                            )),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 16.0, bottom: 16.0, right: 16, left: 16),
                          child: InputButtonCustomizado(
                            text: "Cadastrar",
                            onPressed: () {
                              _validarCampos();
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      )),
    );
  }
}

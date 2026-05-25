import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pechinchar_online/customizados/inputButtonCustomizados.dart';
import 'package:pechinchar_online/customizados/inputCustomizado.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();

  late FToast fToast;
  late bool _progressBarLinear;

  // Cores da nova identidade visual (Acomodeme)
  final Color corPrincipalAzul = const Color(0xFF0B1C4B);
  final Color corDestaqueLaranja = const Color(0xFFFF8C00);

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    _progressBarLinear = false;
    fToast.init(context);
  }

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerSenha.dispose();
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
          SizedBox(
            width: 12.0,
          ),
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

  _validarCampos() {
    //Recupera dados dos campos
    String email = _controllerEmail.text.trim();
    String senha = _controllerSenha.text;

    if (email.isNotEmpty && email.contains("@")) {
      if (senha.isNotEmpty && senha.length > 6) {
        setState(() {
          _progressBarLinear = true;
        });
        _logarUsuario(email, senha);
      } else {
        _exibirToastCustomizado("Sua senha deve ter mais de seis caracteres!");
      }
    } else {
      _exibirToastCustomizado("Preencha o seu email de acesso corretamente!");
    }
  }

  _logarUsuario(String email, String senha) {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth
        .signInWithEmailAndPassword(email: email, password: senha)
        .then((firebaseUser) {
      setState(() {
        _progressBarLinear = false;
      });
      Navigator.pushReplacementNamed(context, "/Home");
    }).catchError((error) {
      setState(() {
        _progressBarLinear = false;
      });
      _exibirToastCustomizado(
          "Algum problema com seus dados ou com sua internet!");
    });
  }

  // Novo método para recuperação de senha
  _recuperarSenha() {
    String email = _controllerEmail.text.trim();

    if (email.isNotEmpty && email.contains("@")) {
      FirebaseAuth auth = FirebaseAuth.instance;
      auth.sendPasswordResetEmail(email: email).then((_) {
        _exibirToastCustomizado(
            "Um link de recuperação foi enviado para o seu e-mail!");
      }).catchError((error) {
        _exibirToastCustomizado(
            "Erro ao tentar recuperar a senha. Verifique o e-mail digitado.");
      });
    } else {
      _exibirToastCustomizado(
          "Digite o seu e-mail no campo acima para recuperar a senha.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Aplica o fundo com a cor principal da marca Acomodeme
    Widget _builderDrawerBack() => Container(
          decoration: BoxDecoration(
            color: corPrincipalAzul, // Substitui o gradiente verde
          ),
        );

    return Scaffold(
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
                            width: 150, height: 150),
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
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    corDestaqueLaranja),
                              )
                            : Center(),
                      ),
                      Padding(
                          padding:
                              EdgeInsets.only(top: 2.0, right: 16, left: 16),
                          child: InputCustomizado(
                            controller: _controllerEmail,
                            hint: "Email",
                            obscure: false,
                            icon: Icon(Icons.person,
                                color:
                                    Colors.white), // Ícone ajustado para branco
                          )),
                      Padding(
                          padding: EdgeInsets.only(top: 8, right: 16, left: 16),
                          child: InputCustomizado(
                            controller: _controllerSenha,
                            hint: "Senha",
                            obscure: true,
                            icon: Icon(Icons.lock,
                                color:
                                    Colors.white), // Ícone ajustado para branco
                          )),
                      Center(
                        child: Container(
                          padding: EdgeInsets.only(top: 16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Não tem conta?",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacementNamed(
                                          context, "/Cadastro");
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Text(
                                        "Cadastre-se",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: corDestaqueLaranja,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              // Botão "Esqueci a senha" adicionado exatamente abaixo
                              Padding(
                                padding: EdgeInsets.only(top: 16.0),
                                child: GestureDetector(
                                  onTap: () {
                                    _recuperarSenha();
                                  },
                                  child: Text(
                                    "Esqueceu a senha?",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors
                                          .white70, // Tom levemente mais apagado para hierarquia visual
                                      decoration: TextDecoration
                                          .underline, // Sublinhado para indicar que é clicável
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                          padding:
                              EdgeInsets.only(top: 24, right: 16, left: 16),
                          child: InputButtonCustomizado(
                            text: "Logar",
                            onPressed: () {
                              _validarCampos();
                            },
                          ))
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    ));
  }
}

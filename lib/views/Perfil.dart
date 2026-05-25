import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Perfil extends StatefulWidget {
  const Perfil({Key? key}) : super(key: key);

  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerTelefone = TextEditingController();
  TextEditingController _controllerCidade = TextEditingController();
  TextEditingController _controllerEndereco = TextEditingController();
  String? _estadoSelecionado;

  final Color corPrincipalAzul = const Color(0xFF0B1C4B);
  final Color corDestaqueLaranja = const Color(0xFFFF8C00);

  String _idUsuarioLogado = "";
  bool _carregando = true;
  bool _cadastroIncompleto = false; // Flag para "forçar" a atualização

  List<String> _estados = [
    "AC",
    "AL",
    "AP",
    "AM",
    "BA",
    "CE",
    "DF",
    "ES",
    "GO",
    "MA",
    "MT",
    "MS",
    "MG",
    "PA",
    "PB",
    "PR",
    "PE",
    "PI",
    "RJ",
    "RN",
    "RS",
    "RO",
    "RR",
    "SC",
    "SP",
    "SE",
    "TO"
  ];

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;

    if (usuarioLogado != null) {
      _idUsuarioLogado = usuarioLogado.uid;

      FirebaseFirestore db = FirebaseFirestore.instance;
      try {
        DocumentSnapshot snapshot =
            await db.collection("usuarios").doc(_idUsuarioLogado).get();
        if (!mounted) return;

        if (snapshot.exists) {
          Map<String, dynamic>? dados =
              snapshot.data() as Map<String, dynamic>?;
          if (dados != null) {
            setState(() {
              _controllerNome.text = dados["nome"] ?? "";
              _controllerTelefone.text = dados["telefone"] ?? "";
              _controllerCidade.text = dados["cidade"] ?? "";
              _controllerEndereco.text = dados["endereco"] ?? "";
              _estadoSelecionado = dados["estado"];
              _carregando = false;
            });
          }
        } else {
          // Documento NÃO existe no novo banco. Força o usuário a preencher.
          setState(() {
            _cadastroIncompleto = true;
            _carregando = false;
          });
        }
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  _atualizarPerfil() {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore db = FirebaseFirestore.instance;

      Map<String, dynamic> dadosAtualizados = {
        "nome": _controllerNome.text,
        "telefone": _controllerTelefone.text, // Ex: 73 98125-8195
        "cidade": _controllerCidade.text,
        "endereco": _controllerEndereco.text,
        "estado": _estadoSelecionado,
      };

      db
          .collection("usuarios")
          .doc(_idUsuarioLogado)
          .set(dadosAtualizados)
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Perfil atualizado com sucesso no novo sistema!"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _cadastroIncompleto = false;
        });
      }).catchError((erro) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao atualizar: $erro"),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  // Estilo padrão dos inputs baseados na sua UI
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.white38),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: corDestaqueLaranja),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      filled: true,
      fillColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Evita que o usuário volte se o cadastro estiver incompleto
      onWillPop: () async {
        if (_cadastroIncompleto) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text("Por favor, atualize seus dados antes de continuar."),
              backgroundColor: Colors.orange,
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: corPrincipalAzul,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("Perfil", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          automaticallyImplyLeading:
              !_cadastroIncompleto, // Esconde botão voltar se incompleto
        ),
        body: _carregando
            ? Center(
                child: CircularProgressIndicator(color: corDestaqueLaranja))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Banner de Alerta Dinâmico
                      if (_cadastroIncompleto)
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orangeAccent),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: Colors.orangeAccent),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Atualização Necessária: Identificamos que seus dados não estão no nosso novo banco. Preencha abaixo para continuar usando o app.",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),

                      TextFormField(
                        controller: _controllerNome,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Nome", Icons.person),
                        validator: (valor) =>
                            valor!.isEmpty ? "Preencha seu nome" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _controllerTelefone,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Telefone", Icons.phone),
                        validator: (valor) =>
                            valor!.isEmpty ? "Preencha seu telefone" : null,
                      ),
                      const SizedBox(height: 16),

                      // Row para Cidade e Estado lado a lado
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _controllerCidade,
                              style: const TextStyle(color: Colors.white),
                              decoration:
                                  _inputDecoration("Cidade", Icons.location_on),
                              validator: (valor) =>
                                  valor!.isEmpty ? "Preencha a cidade" : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              value: _estadoSelecionado,
                              dropdownColor: corPrincipalAzul,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration("Estado", Icons.map),
                              items: _estados.map((String estado) {
                                return DropdownMenuItem<String>(
                                  value: estado,
                                  child: Text(estado),
                                );
                              }).toList(),
                              onChanged: (String? novoEstado) {
                                setState(() {
                                  _estadoSelecionado = novoEstado;
                                });
                              },
                              validator: (valor) =>
                                  valor == null ? "Selecione" : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _controllerEndereco,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Endereço", Icons.home),
                        validator: (valor) =>
                            valor!.isEmpty ? "Preencha seu endereço" : null,
                      ),

                      const SizedBox(height: 40),

                      // Botão Atualizar
                      ElevatedButton(
                        onPressed: _atualizarPerfil,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: corDestaqueLaranja,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Atualizar perfil",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Botão Deletar Conta
                      ElevatedButton(
                        onPressed: () {
                          // Lógica para deletar conta
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Deletar conta",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

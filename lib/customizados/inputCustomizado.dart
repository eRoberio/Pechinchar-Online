import 'package:flutter/material.dart';

class InputCustomizado extends StatelessWidget {
  final String hint;
  final bool obscure;
  final Widget icon;
  final TextEditingController controller;

  const InputCustomizado({
    required this.hint,
    this.obscure = false,
    this.icon = const Icon(Icons.person),
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        controller: controller,
        obscureText: this.obscure,
        // 1. Cor do texto que o usuário digita (Branco)
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          labelText: this.hint,
          // 2. Cor do Label (Branco com leve transparência)
          labelStyle: const TextStyle(color: Colors.white70),

          hintText: this.hint,
          // 3. Cor da dica/placeholder
          hintStyle: const TextStyle(color: Colors.white54),

          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          prefixIcon: this.icon,

          // 4. Borda padrão (quando não está clicado)
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide:
                const BorderSide(color: Colors.white54), // Borda clara sutil
          ),

          // 5. Borda em destaque (quando o usuário clica no campo)
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(
              color: Color(0xFFFF8C00), // O Laranja da Acomodeme
              width:
                  2.0, // Deixa a borda um pouquinho mais grossa para destacar
            ),
          ),

          // Fallback para outros estados
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }
}

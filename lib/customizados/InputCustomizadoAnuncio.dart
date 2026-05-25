import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputCustomizadoAnuncio extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final bool autofocus;
  final TextInputType type;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldSetter<String>? onSaved;

  const InputCustomizadoAnuncio({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.autofocus = false,
    this.type = TextInputType.text,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.onSaved,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: this.controller,
      obscureText: this.obscure,
      autofocus: this.autofocus,
      keyboardType: this.type,
      inputFormatters: this.inputFormatters,
      maxLines: this.maxLines,
      maxLength: this.maxLength,
      onSaved: this.onSaved,
      // 1. Cor do texto que o usuário digita (Branco)
      style: const TextStyle(
        fontSize: 20,
        color: Colors.white,
      ),
      decoration: InputDecoration(
          labelText: this.hint,
          // 2. Cor do Label (Branco com leve transparência)
          labelStyle: const TextStyle(color: Colors.white70),
          contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
          hintText: this.hint,
          // 3. Cor da dica/placeholder
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.transparent,

          // 4. Borda padrão (quando o campo não está focado)
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Colors.white54),
          ),

          // 5. Borda em destaque (quando o usuário clica no campo)
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(
              color: Color(0xFFFF8C00), // O Laranja da Acomodeme
              width: 2.0,
            ),
          ),

          // Fallback
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))),
    );
  }
}

import 'package:flutter/material.dart';

class InputButtonCustomizado extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color?
      color; // Adicionei a opção de passar uma cor diferente caso precise no futuro

  const InputButtonCustomizado({
    required this.text,
    this.onPressed,
    this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        style: TextButton.styleFrom(
          // Se não passarmos nenhuma cor, ele assume o Laranja padrão da Acomodeme
          backgroundColor: color ?? const Color(0xFFFF8C00),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

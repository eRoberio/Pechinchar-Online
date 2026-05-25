import 'package:flutter/material.dart';

class InputDropdownButtonCustomizado extends StatelessWidget {
  final String? initialValue;
  final String hint;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?>? onChanged;
  final Widget icon;

  const InputDropdownButtonCustomizado({
    required this.initialValue,
    required this.hint,
    required this.items,
    this.onChanged,
    this.icon = const Icon(Icons.account_balance_outlined),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        dropdownColor:
            const Color(0xFF0B1C4B), // Fundo do menu que se abre (Azul Naval)
        style: const TextStyle(
            color: Colors.white, fontSize: 20), // Cor do item selecionado
        icon: const Icon(Icons.arrow_drop_down,
            color: Colors.white), // Cor da setinha
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: const TextStyle(color: Colors.white70), // Cor do Label
          prefixIcon: icon,
          contentPadding: const EdgeInsets.fromLTRB(2, 16, 2, 16),
          fillColor: Colors.transparent,
          filled: true,

          // Borda padrão
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Colors.white54),
          ),

          // Borda Laranja quando focado
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Color(0xFFFF8C00), width: 2.0),
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        initialValue: initialValue,
        hint: Text(hint,
            style: const TextStyle(color: Colors.white54)), // Cor da dica
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}

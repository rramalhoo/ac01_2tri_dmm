import 'package:flutter/material.dart';

Widget campoTexto({
  required String label,
  required TextEditingController controller,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number, // Obrigatório pelo documento
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}
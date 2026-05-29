import 'package:flutter/material.dart';

Widget botao({
  required String texto,
  required VoidCallback onPressed,
  required Color cor,
}) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: cor,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        onPressed: onPressed,
        child: Text(texto),
      ),
    ),
  );
}
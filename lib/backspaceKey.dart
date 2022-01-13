import 'package:flutter/material.dart';
import 'package:wordle/main.dart';

class BackspaceKey extends StatelessWidget {
  const BackspaceKey({
    Key? key,
    required this.onBackspace,
    this.flex = 1,
  }) : super(key: key);
  final VoidCallback onBackspace;
  final int flex;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Material(
          color: keysColor,
          child: InkWell(
            onTap: () {
              onBackspace.call();
            },
            child: const Center(
              child: Icon(Icons.backspace, color: letterColor),
            ),
          ),
        ),
      ),
    );
  }
}
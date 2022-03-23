import 'package:flutter/material.dart';
import 'package:wordle/constants/app_colors.dart';

class TextKey extends StatelessWidget {
  const TextKey({
    Key? key,
    required this.text,
    required this.onTextInput,
    this.flex = 1,
    this.wrong = false,
    this.right = false,
  }) : super(key: key);
  final bool wrong;
  final bool right;
  final String text;
  final ValueSetter<String> onTextInput;
  final int flex;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Material(
          color: wrong ? AppColors.disableKeyColor : right ? AppColors.letterRight : AppColors.keysColor,
          child: InkWell(
            onTap: () {
                onTextInput.call(text);
            },
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: wrong ? AppColors.disableLetterColor : AppColors.letterColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:wordle/constants/app_colors.dart';

class SubmitKey extends StatelessWidget {
  const SubmitKey({
    Key? key,
    required this.onSubmit,
    this.flex = 1,
  }) : super(key: key);
  final VoidCallback onSubmit;
  final int flex;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Material(
          color: AppColors.letterRight,
          child: InkWell(
            onTap: () {
              onSubmit.call();
            },
            child: const Center(
              child: Icon(Icons.send, color: AppColors.letterColor),
            ),
          ),
        ),
      ),
    );
  }
}
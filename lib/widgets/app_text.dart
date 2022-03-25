import 'package:flutter/cupertino.dart';
import 'package:wordle/utils/app_colors.dart';
import 'package:wordle/utils/dimensions.dart';

class AppText extends StatelessWidget {
  final Color? color;
  final String text;
  final double size;

  const AppText({ Key? key,
    this.color = AppColors.letterColor,
    required this.text,
    this.size = Dimensions.fontSize,
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
        fontSize: size,
      ),
    );
  }
}
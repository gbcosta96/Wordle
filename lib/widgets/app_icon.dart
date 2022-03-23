import 'package:flutter/material.dart';
import 'package:wordle/constants/app_colors.dart';

class AppIcon extends StatelessWidget {
  final IconData iconData;
  final GestureTapCallback onTap;
  final Color iconColor;

  const AppIcon({ Key? key, required this.iconData, required this.onTap, this.iconColor = AppColors.letterRight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.height*0.05,
        height: MediaQuery.of(context).size.height*0.05,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height*0.025),
          color: iconColor,
        ),
        child: Icon(
          iconData,
          color: Colors.white,
        ),
      ),
    );
  }
}
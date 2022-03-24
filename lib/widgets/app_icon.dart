import 'package:flutter/material.dart';
import 'package:wordle/utils/app_colors.dart';
import 'package:wordle/utils/dimensions.dart';

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
        width: Dimensions.height(Dimensions.appIconSize),
        height: Dimensions.height(Dimensions.appIconSize),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.height(Dimensions.appIconSize)/2),
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
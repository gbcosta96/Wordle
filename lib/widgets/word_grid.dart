import 'package:flutter/material.dart';
import 'package:wordle/utils/dimensions.dart';
import 'package:wordle/widgets/app_icon.dart';
import 'package:wordle/utils/app_colors.dart';
import 'package:wordle/widgets/app_text.dart';

class WordGrid extends StatelessWidget {
  final double gridWidth;
  final double gridHeight;
  final String playerName;
  final List<Widget> stackItems;
  final Color iconColor;

  const WordGrid({ Key? key,
    required this.gridWidth,
    required this.gridHeight,
    required this.playerName,
    this.iconColor = AppColors.letterRight,
    required this.stackItems }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: Dimensions.height(Dimensions.playerHeight),
          padding: const EdgeInsets.all(Dimensions.playerPadding),
          child: Row(
            children: [
              AppIcon(iconData: Icons.person, onTap: () => {}, iconColor: iconColor),
              const SizedBox(width: 5),
              AppText(text: playerName)
            ],
          ),
        ),
        Container(
          width: gridWidth,
          height: gridHeight,
          padding: const EdgeInsets.all(Dimensions.gridPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.gridRadius),
          ),
          child: Stack(
              children: stackItems,
          ),
        ),
      ],
    );
  }
}
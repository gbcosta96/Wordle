import 'dart:math';
import 'package:get/get.dart';

class Dimensions{

  ////////////////////////////////////////////////////////////////////
  static const double gridMaxWidth = 47.0; // %
  static const double gridMaxWidth4 = 22.5; // %
  static const double keyboardPortraitWidth = 100.0; // %
  static const double keyboardLandscapeWidth = 50.0; // %
  static const double headerMarginWidth = 5.0; // %
  static const double iconSeparatorWidth = 5.0; // %

  static const double appIconSize = 5.0; // %

  static const double headerHeight = 13.0; // %
  static const double playerHeight = 8.0; // %
  static const double gridMaxHeight = 50.0; // %
  static const double wordSize = 4.0; // %
  static const double keyboardHeight = 22.0; // %

 static const double gridMaxHeight4 = 22.0; // %

  static const double gridPadding = 1.5; // absolut
  static const double innerGridPadding = 0.2; // %
  static const double innerGridRadius= 0.6; // %
  static const double keyboardWidthPadding = 6; // absolut
  static const double keyboardBottomPadding = 3; // absolut
  static const double gridRadius = 5; // absolut
  static const double playerPadding= 5; // %
  ///////////////////////////////////////////////////////////////////
  
  static const double loginWidth = 70.0; // %
  static const double loginLandscapingWidth = 50.0; // %
  static const double loginSpacingHeight = 5.0; // %
  static const double inputPaddingHeight = 3.0; // %
  static const double inputPrefixWidth = 10.0; // %
  static const double inputHeight = 12.0; // %
  static const double buttonPaddingHeight = 10.0;

  static const double fontSize = 20;
  static const double fontSizeLeaderboard = 2; // %


  static double height(double height){
    return Get.context!.height*height/100.0;
  } 

  static double width(double width){
    return Get.context!.width*width/100.0;
  }

  static double smallest(double size){
    return min(height(size), width(size));
  }

  static double greatest(double size){
    return max(height(size), width(size));
  }

  
}
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dimensions{

  static const double gridMaxWidth = 47.0; // %
  static const double keyboardPortraitWidth = 100.0; // %
  static const double keyboardLandscapeWidth = 50.0; // %
  static const double headerMarginWidth = 5.0; // %
  static const double iconSeparatorWidth = 5.0; // %

  static const double appIconSize = 5.0; // %


  static const double headerMarginHeight = 5.0; // %
  static const double headerHeight = 5.0; // %
  static const double playerHeight = 10.0; // %
  static const double gridMaxHeight = 50.0; // %
  static const double keyboardHeight = 27.0; // %


  static const double gridPadding = 1.5; // absolut
  static const double keyboardWidthPadding = 6; // absolut
  static const double keyboardBottomPadding = 3; // absolut
  static const double gridRadius = 5; // absolut
  static const double playerPadding= 5; // %

  static final double _screenHeight = Get.context!.height;
  static final double _screenWidth = Get.context!.width;

  static final Orientation orientation = Get.context!.orientation;

  static double height(double height){
    return _screenHeight*height/100;
  } 

  static double width(double width){
    return _screenWidth*width/100;
  }

  static double smallest(double size){
    return min(height(size), width(size));
  }

  static double greatest(double size){
    return max(height(size), width(size));
  }

  
}
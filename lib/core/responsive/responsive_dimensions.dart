import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ResponsiveDimensions {
  static ResponsiveDimensions? _instance;
  
  ResponsiveDimensions._(); 
  
  static ResponsiveDimensions get instance {
    _instance ??= ResponsiveDimensions._();
    return _instance!;
  }
  
bool get isLandscape => Get.context!.isLandscape;
bool get isPortrait => Get.context!.isPortrait;

bool get isPhoneLandscape => isPhone && isLandscape;
bool get isTabletPortrait => isTablet && isPortrait;


  // PROPORÇÕES DE LARGURA
  double get width1 => Get.width * 0.01;
  double get width2 => Get.width * 0.02;
  double get width3 => Get.width * 0.03;
  double get width4 => Get.width * 0.04;
  double get width5 => Get.width * 0.05;
  double get width8 => Get.width * 0.08;
  double get width10 => Get.width * 0.10;
  double get width15 => Get.width * 0.15;
  double get width20 => Get.width * 0.20;
  double get width25 => Get.width * 0.25;
  double get width30 => Get.width * 0.30;
  double get width33 => Get.width * 0.33;
  double get width40 => Get.width * 0.40;
  double get width50 => Get.width * 0.50;
  double get width60 => Get.width * 0.60;
  double get width70 => Get.width * 0.70;
  double get width80 => Get.width * 0.80;
  double get width90 => Get.width * 0.90;
  double get width100 => Get.width;
  
  // PROPORÇÕES DE ALTURA 
  double get height1 => Get.height * 0.01;
  double get height2 => Get.height * 0.02;
  double get height3 => Get.height * 0.03;
  double get height4 => Get.height * 0.04;
  double get height5 => Get.height * 0.05;
   double get width6 => Get.width * 0.06;
  double get height8 => Get.height * 0.08;
  double get height10 => Get.height * 0.10;
  double get height15 => Get.height * 0.15;
  double get height20 => Get.height * 0.20;
  double get height25 => Get.height * 0.25;
  double get height30 => Get.height * 0.30;
  double get height40 => Get.height * 0.40;
  double get height50 => Get.height * 0.50;
  double get height60 => Get.height * 0.60;
  double get height70 => Get.height * 0.70;
  double get height80 => Get.height * 0.80;
  double get height90 => Get.height * 0.90;
  double get height100 => Get.height;


  int get optimalNotesColumns {
  if (isPhone) return isLandscape ? 3 : 2;
  if (isSmallTablet) return isLandscape ? 4 : 3;
  if (isLargeTablet) return isLandscape ? 5 : 4;
  return 4; // Desktop
}
  
  
  int getGridColumns() {
  if (GetPlatform.isMobile) {
    if (Get.context!.isPhone) {
      return Get.context!.isLandscape ? 3 : 2;
    }
    if (Get.context!.isTablet) {
      return Get.context!.isLandscape ? 4 : 3;
    }
  }
  
  if (GetPlatform.isDesktop) {
    if (Get.width < 800) return 2;
    if (Get.width < 1200) return 3;
    if (Get.width < 1600) return 4;
    return 5;
  }
  
  return 2;
}
  
  double getCardMaxWidth() {
    if (GetPlatform.isMobile) {
      return (Get.width / getGridColumns()) - (width5 * 2); 
    }
    
    if (GetPlatform.isDesktop) {
      return 320;
    }
    
    return Get.width / getGridColumns() - (width5 * 2); 
  }
  
  EdgeInsets getScreenPadding() {
  if (GetPlatform.isMobile) {
    if (Get.context!.isPhone) {
      return EdgeInsets.symmetric(
        horizontal: width4,
        vertical: height2,
      );
    }
    if (Get.context!.isTablet) {
      return EdgeInsets.symmetric(
        horizontal: width6, // Tablets: mais padding
        vertical: height3,
      );
    }
  }
  
  if (GetPlatform.isDesktop) {
    return EdgeInsets.symmetric(
      horizontal: width8,
      vertical: height3,
    );
  }
  
  return EdgeInsets.symmetric(
    horizontal: width5,
    vertical: height2,
  );
}
  
  // FONTES ADAPTATIVAS 
  double get fontSize12 => GetPlatform.isMobile ? Get.width * 0.03 : 12;
  double get fontSize14 => GetPlatform.isMobile ? Get.width * 0.035 : 14;
  double get fontSize16 => GetPlatform.isMobile ? Get.width * 0.04 : 16;
  double get fontSize18 => GetPlatform.isMobile ? Get.width * 0.045 : 18;
  double get fontSize20 => GetPlatform.isMobile ? Get.width * 0.05 : 20;
  double get fontSize24 => GetPlatform.isMobile ? Get.width * 0.06 : 24;
  
 
 bool get isTablet => Get.context!.isTablet;
bool get isSmallTablet => Get.context!.isSmallTablet;
bool get isLargeTablet => Get.context!.isLargeTablet;
bool get isPhone => Get.context!.isPhone;

double get aspectRatio => Get.width / Get.height;
bool get isUltraWide => aspectRatio > 2.1; // Custom breakpoint
bool get isSquare => (aspectRatio - 1.0).abs() < 0.1; // Custom logic
  
  // safe area padding
  EdgeInsets get safeAreaPadding => EdgeInsets.only(
    top: Get.statusBarHeight,
    bottom: Get.bottomBarHeight,
  );
  
 
 
}


extension ResponsiveExtension on num {
  double get w => Get.width * (this / 100);   
  double get h => Get.height * (this / 100); 
  
  
  double get sp => Get.textScaleFactor * this; // fontes escaláveis
  EdgeInsets get padAll => EdgeInsets.all(w);
  EdgeInsets get padH => EdgeInsets.symmetric(horizontal: w);
  EdgeInsets get padV => EdgeInsets.symmetric(vertical: h);
}
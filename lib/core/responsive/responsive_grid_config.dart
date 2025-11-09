

import 'package:clipstick/core/responsive/responsive_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResponsiveGridConfig {
  static ResponsiveGridConfig? _instance;
  late final ResponsiveDimensions _dimensions;
  
  ResponsiveGridConfig._() {
    _dimensions = ResponsiveDimensions.instance;
  }
  
  static ResponsiveGridConfig get instance {
    _instance ??= ResponsiveGridConfig._();
    return _instance!;
  }
  
  int get crossAxisCount => _dimensions.getGridColumns();
  
  double get crossAxisSpacing {
    if (GetPlatform.isMobile) return _dimensions.width3;
    if (GetPlatform.isDesktop) return _dimensions.width2;
    return _dimensions.width3;
  }
  
  double get mainAxisSpacing {
    if (GetPlatform.isMobile) return _dimensions.height2;
    if (GetPlatform.isDesktop) return _dimensions.height2;
    return _dimensions.height2;
  }
  
  EdgeInsets get padding => _dimensions.getScreenPadding();
  
  double get childAspectRatio {
    if (GetPlatform.isMobile) return 0.8;
    if (GetPlatform.isDesktop) return 1.0;
    return 0.9; // Web/outros
  }
}
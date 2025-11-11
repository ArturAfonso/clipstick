import 'package:flutter/material.dart';
import 'app_colors.dart';

class NoteColorsHelper {
  NoteColorsHelper._();

  
  static List<Color> getAvailableColors(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return isDarkMode ? darkNoteColors : lightNoteColors;
  }

  
  static Color getDefaultColor(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return isDarkMode ? AppColors.darkNoteYellow : AppColors.lightNoteYellow;
  }

  
  static const List<Color> lightNoteColors = [
    AppColors.lightNoteYellow,
    AppColors.lightNotePink,
    AppColors.lightNoteGreen,
    AppColors.lightNoteBlue,
    AppColors.lightNoteOrange,
    AppColors.lightNotePurple,
  ];

  
  static const List<Color> darkNoteColors = [
    AppColors.darkNoteYellow,
    AppColors.darkNotePink,
    AppColors.darkNoteGreen,
    AppColors.darkNoteBlue,
    AppColors.darkNoteOrange,
    AppColors.darkNotePurple,
  ];
}
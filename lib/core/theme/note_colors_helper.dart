import 'package:flutter/material.dart';
import 'app_colors.dart';

class NoteColorsHelper {
  NoteColorsHelper._();

  // 🎨 COR NEUTRA PARA "SEM COR"
  static Color getNeutralColor(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Cinza suave que funciona em ambos os temas
    return isDarkMode 
      ? Color(0xFF2D2D2D) // Cinza escuro suave
      : Color(0xFFF5F5F5); // Cinza claro suave
  }

  // 🎨 Retorna lista de cores baseada no tema atual
  static List<Color> getAvailableColors(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return isDarkMode ? darkNoteColors : lightNoteColors;
  }

  // 🎨 Retorna cor padrão baseada no tema atual
  static Color getDefaultColor(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return isDarkMode ? AppColors.darkNoteYellow : AppColors.lightNoteYellow;
  }

  // 🌞 CORES PARA LIGHT THEME
  static const List<Color> lightNoteColors = [
    AppColors.lightNoteYellow,
    AppColors.lightNotePink,
    AppColors.lightNoteGreen,
    AppColors.lightNoteBlue,
    AppColors.lightNoteOrange,
    AppColors.lightNotePurple,
  ];

  // 🌙 CORES PARA DARK THEME
  static const List<Color> darkNoteColors = [
    AppColors.darkNoteYellow,
    AppColors.darkNotePink,
    AppColors.darkNoteGreen,
    AppColors.darkNoteBlue,
    AppColors.darkNoteOrange,
    AppColors.darkNotePurple,
  ];

  // 🎨 IDENTIFICADOR ESPECIAL PARA COR PERSONALIZADA
  static const Color customColorPlaceholder = Color(0xFFFFFFFF);
}
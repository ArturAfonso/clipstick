import 'package:flutter/material.dart';
import 'app_colors.dart';

class NoteColorsHelper {
  NoteColorsHelper._();

  
  static Color getNeutralColor(BuildContext context) {
    //por enquanto irei retorar uma unica cor que verifiquei nao confklitar com os temas
    //no futuro irei implementar o colorpicker para o text e isso ira resolver

   /*  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Cinza suave que funciona em ambos os temas
    return isDarkMode 
      ? Color.fromARGB(255, 165, 162, 162) // Cinza claro suave
      : Color.fromARGB(255, 165, 162, 162); // Cinza claro suave */
      return Color.fromARGB(255, 165, 162, 162); // Cinza claro suave
  }


  static List<Color> getAvailableColors(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return isDarkMode ? darkNoteColors : lightNoteColors;
  }

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


  static const Color customColorPlaceholder = Color(0xFFFFFFFF);
}
class AppConstants {
  // Nome da aplicação
  static const String appName = 'ClipStick';
  static const String appVersion = '1.0.0';

  // SharedPreferences Keys
  static const String notesKey = 'clipstick_notes';
  static const String themeKey = 'clipstick_theme';
  static const String firstLaunchKey = 'clipstick_first_launch';

  // Configurações de notas
  static const int maxNoteTitle = 100;
  static const int maxNoteContent = 5000;
  static const int maxNotesCount = 1000;

  // Cores disponíveis para as notas
  static const List<int> noteColors = [
    0xFFFFEB3B, // Amarelo
    0xFFFF9800, // Laranja
    0xFFE91E63, // Rosa
    0xFF9C27B0, // Roxo
    0xFF3F51B5, // Azul
    0xFF00BCD4, // Ciano
    0xFF4CAF50, // Verde
    0xFFCDDC39, // Verde Claro
  ];

  // Configurações de UI
  static const double noteCardRadius = 12.0;
  static const double noteCardElevation = 2.0;
  static const double defaultPadding = 16.0;

  // Configurações de animação
  static const int animationDuration = 300; // milissegundos
}

 import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();
  
  // ============================================
  // 🌞 LIGHT THEME - BASEADO NO FIGMA
  // ============================================
  
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Color Scheme - EXATAMENTE DO FIGMA
    colorScheme:  ColorScheme.light(
      brightness: Brightness.light,
      
       primary: _hsl(220, 15, 20), // --primary - preto
      onPrimary: _hsl(0, 0, 100), // --primary-foreground - branco

      
      secondary: _hsl(210, 15, 92), // --secondary - branco
      onSecondary: _hsl(220, 15, 20), // --secondary-foreground  - preto

      tertiary: _hsl(45, 100, 65), // Usando --accent como Tertiary - amarelo
      onTertiary: _hsl(220, 15, 20), // --accent-foreground - preto
      
       error: _hsl(0, 85, 60), // --destructive - vermelho
      onError: _hsl(0, 0, 100), // --destructive-foreground- branco

      
       surface: _hsl(0, 0, 100), // --card  - branco
      onSurface: _hsl(220, 15, 20), // --card-foreground - preto

      
     

      outline: _hsl(210, 15, 88), // --border - cinza
 surfaceContainerHighest: _hsl(210, 15, 95), // --input / --muted - cinza claro
      onSurfaceVariant: _hsl(220, 10, 50), // --muted-foreground - cinza escuro

      
      
     
    
    ),
      elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _hsl(220, 15, 20), // --primary - preto claro
        foregroundColor: _hsl(210, 20, 95), // --primary (Branco)  
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightCard, // #FFFFFF
      foregroundColor: AppColors.darkBackground, // #2D3748
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headingMedium.copyWith(
        color: AppColors.lightForeground,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(
        color: AppColors.lightMutedForeground, // #64748B (cinza)
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: AppColors.lightMutedForeground, // #64748B (cinza)
        size: 24,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    
    scaffoldBackgroundColor: AppColors.lightBackground, // #FAFBFC
    
    cardTheme: CardThemeData(
      color: AppColors.lightCard,
      elevation: 2,
      shadowColor: AppColors.lightBorder.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.lightAccent, // #F6D55C (accent)
      foregroundColor: AppColors.lightAccentForeground, // #2D3748
      elevation: 4,
      shape: const CircleBorder(),
    ),

   
  );
  
  // ============================================
  // 🌙 DARK THEME - BASEADO NO FIGMA
  // ============================================
  
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Color Scheme - EXATAMENTE DO FIGMA
    colorScheme:  ColorScheme.dark(
      brightness: Brightness.dark,
       primary: _hsl(210, 20, 95), // --primary (Branco no dark mode)
      onPrimary: _hsl(220, 20, 12), // --primary-foreground preto
      
      secondary: _hsl(220, 15, 20), // --secondary - preto claro
      onSecondary: _hsl(210, 20, 95), // --secondary-foreground - branco
      
      tertiary: _hsl(45, 95, 60), // --accent - amarelo
      onTertiary: _hsl(220, 20, 12), // --accent-foreground - preto
      
      error: _hsl(0, 75, 55), // --destructive
      onError: _hsl(210, 20, 95), // --destructive-foreground
      
      surface: _hsl(220, 18, 15), // --card  - preto escuro
      onSurface: _hsl(210, 20, 95), // --card-foreground  - branco

      outline: _hsl(220, 15, 22), // --border - cinza escuro
      surfaceContainerHighest: _hsl(220, 15, 20), // --input / --muted - preto claro
      onSurfaceVariant: _hsl(215, 15, 65), // --muted-foreground - cinza claro
    ),

    
    
    appBarTheme: AppBarTheme(
      backgroundColor: _hsl(220, 15, 20), // --input / --muted - preto claro
      foregroundColor: _hsl(210, 20, 95), // --secondary-foreground - branco
      surfaceTintColor: _hsl(220, 15, 20), // --input / --muted - preto claro
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headingMedium.copyWith(
        color:  _hsl(210, 20, 95), // --secondary-foreground - branco
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(
        color:   _hsl(210, 20, 95), // --secondary-foreground - branco
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color:  _hsl(210, 20, 95), // --secondary-foreground - branco
        size: 24,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    
   
    scaffoldBackgroundColor: _hsl(220, 18, 15), //  - preto escuro
    
  
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _hsl(45, 95, 60), // --accent - amarelo
      foregroundColor: _hsl(220, 20, 12), // --accent-foreground - preto
      elevation: 4,
      shape: const CircleBorder(),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _hsl(210, 20, 95), // --primary (Branco no dark mode)
        foregroundColor: _hsl(220, 20, 12), // --primary-foreground preto
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );

  
  static Color _hsl(double h, double s, double l) {
    return HSLColor.fromAHSL(1.0, h, s / 100, l / 100).toColor();
  }
} 


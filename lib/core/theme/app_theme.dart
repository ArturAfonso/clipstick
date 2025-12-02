// ignore_for_file: deprecated_member_use
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
      
       primary: hsl(220, 15, 20), // --primary - preto
      onPrimary: hsl(0, 0, 100), // --primary-foreground - branco

      
      secondary: hsl(210, 15, 92), // --secondary - branco
      onSecondary: hsl(220, 15, 20), // --secondary-foreground  - preto

      tertiary: hsl(45, 100, 65), // Usando --accent como Tertiary - amarelo
      onTertiary: hsl(220, 15, 20), // --accent-foreground - preto
      
       error: hsl(0, 85, 60), // --destructive - vermelho
      onError: hsl(0, 0, 100), // --destructive-foreground- branco

      
       surface: hsl(0, 0, 100), // --card  - branco
      onSurface: hsl(220, 15, 20), // --card-foreground - preto

      
     

      outline: hsl(210, 15, 88), // --border - cinza
 surfaceContainerHighest: hsl(210, 15, 95), // --input / --muted - cinza claro
      onSurfaceVariant: hsl(220, 10, 50), // --muted-foreground - cinza escuro

      
      
     
    
    ),
      elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: hsl(220, 15, 20), // --primary - preto claro
        foregroundColor: hsl(210, 20, 95), // --primary (Branco)  
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
       primary: hsl(210, 20, 95), // --primary (Branco no dark mode)
      onPrimary: hsl(220, 20, 12), // --primary-foreground preto
      
      secondary: hsl(220, 15, 20), // --secondary - preto claro
      onSecondary: hsl(210, 20, 95), // --secondary-foreground - branco
      
      tertiary: hsl(45, 95, 60), // --accent - amarelo
      onTertiary: hsl(220, 20, 12), // --accent-foreground - preto
      
      error: hsl(0, 75, 55), // --destructive
      onError: hsl(210, 20, 95), // --destructive-foreground
      
      surface: hsl(220, 18, 15), // --card  - preto escuro
      onSurface: hsl(210, 20, 95), // --card-foreground  - branco

      outline: hsl(220, 15, 22), // --border - cinza escuro
      surfaceContainerHighest: hsl(220, 15, 20), // --input / --muted - preto claro
      onSurfaceVariant: hsl(215, 15, 65), // --muted-foreground - cinza claro
    ),

    
    
    appBarTheme: AppBarTheme(
      backgroundColor: hsl(220, 15, 20), // --input / --muted - preto claro
      foregroundColor: hsl(210, 20, 95), // --secondary-foreground - branco
      surfaceTintColor: hsl(220, 15, 20), // --input / --muted - preto claro
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headingMedium.copyWith(
        color:  hsl(210, 20, 95), // --secondary-foreground - branco
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(
        color:   hsl(210, 20, 95), // --secondary-foreground - branco
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color:  hsl(210, 20, 95), // --secondary-foreground - branco
        size: 24,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    
   
    scaffoldBackgroundColor: hsl(220, 18, 15), //  - preto escuro
    
  
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: hsl(45, 95, 60), // --accent - amarelo
      foregroundColor: hsl(220, 20, 12), // --accent-foreground - preto
      elevation: 4,
      shape: const CircleBorder(),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: hsl(210, 20, 95), // --primary (Branco no dark mode)
        foregroundColor: hsl(220, 20, 12), // --primary-foreground preto
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );

  
  static Color hsl(double h, double s, double l) {
    return HSLColor.fromAHSL(1.0, h, s / 100, l / 100).toColor();
  }
} 


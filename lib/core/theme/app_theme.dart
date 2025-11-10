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
    colorScheme: const ColorScheme.light(
      brightness: Brightness.light,
      
      // 🎯 CORES PRINCIPAIS DO FIGMA
      primary: AppColors.lightPrimary, // #2D3748 (primary)
      onPrimary: AppColors.lightPrimaryForeground, // #FFFFFF
      
      secondary: AppColors.lightSecondary, // #E2E8F0 (secondary)
      onSecondary: AppColors.lightSecondaryForeground, // #2D3748
      
      surface: AppColors.lightCard, // #FFFFFF (card)
      onSurface: AppColors.lightForeground, // #2D3748
      
      error: AppColors.lightDestructive, // #EF4444
      onError: AppColors.lightDestructiveForeground, // #FFFFFF
      
      outline: AppColors.lightBorder, // #D1D5DB
      outlineVariant: AppColors.lightMuted, // #F1F5F9
      
      // 🎨 CORES ESPECIAIS
      surfaceContainerHighest: AppColors.lightMuted, // #F1F5F9 (muted)
      onSurfaceVariant: AppColors.lightMutedForeground, // #64748B (muted-foreground)
      
      tertiary: AppColors.lightAccent, // #F6D55C (accent)
      onTertiary: AppColors.lightAccentForeground, // #2D3748
    ),
    
    // App Bar Theme - CLEAN E SIMPLES
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightCard, // #FFFFFF
      foregroundColor: AppColors.lightForeground, // #2D3748
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
    
    // Scaffold Background
    scaffoldBackgroundColor: AppColors.lightBackground, // #FAFBFC
    
    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.lightCard,
      elevation: 2,
      shadowColor: AppColors.lightBorder.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // FloatingActionButton Theme
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
    colorScheme: const ColorScheme.dark(
      brightness: Brightness.dark,
      
      // 🎯 CORES PRINCIPAIS DO FIGMA
      primary: AppColors.darkPrimary, // #F1F5F9 (primary)
      onPrimary: AppColors.darkPrimaryForeground, // #1E293B
      
      secondary: AppColors.darkSecondary, // #475569 (secondary)
      onSecondary: AppColors.darkSecondaryForeground, // #F1F5F9
      
      surface: AppColors.darkCard, // #334155 (card)
      onSurface: AppColors.darkForeground, // #F1F5F9
      
      error: AppColors.darkDestructive, // #DC2626
      onError: AppColors.darkDestructiveForeground, // #F1F5F9
      
      outline: AppColors.darkBorder, // #475569
      outlineVariant: AppColors.darkMuted, // #475569
      
      // 🎨 CORES ESPECIAIS
      surfaceContainerHighest: AppColors.darkMuted, // #475569 (muted)
      onSurfaceVariant: AppColors.darkMutedForeground, // #94A3B8 (muted-foreground)
      
      tertiary: AppColors.darkAccent, // #EAB308 (accent)
      onTertiary: AppColors.darkAccentForeground, // #1E293B
    ),
    
    // App Bar Theme - CLEAN E SIMPLES
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkCard, // #334155
      foregroundColor: AppColors.darkForeground, // #F1F5F9
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headingMedium.copyWith(
        color: AppColors.darkForeground,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(
        color: AppColors.darkMutedForeground, // #94A3B8 (cinza claro)
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: AppColors.darkMutedForeground, // #94A3B8 (cinza claro)
        size: 24,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    
    // Scaffold Background
    scaffoldBackgroundColor: AppColors.darkBackground, // #1E293B
    
    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // FloatingActionButton Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.darkAccent, // #EAB308 (accent)
      foregroundColor: AppColors.darkAccentForeground, // #1E293B
      elevation: 4,
      shape: const CircleBorder(),
    ),
  );
}
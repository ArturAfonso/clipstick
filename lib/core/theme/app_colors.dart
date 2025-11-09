

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  
  // ============================================
  // 🌞 LIGHT THEME COLORS 
  // ============================================
  
  // Background & Foreground
  static const Color lightBackground = Color(0xFFFAFAFB); // HSL(210, 20%, 98%)
  static const Color lightForeground = Color(0xFF3D4043); // HSL(220, 15%, 20%)
  
  // Card
  static const Color lightCard = Color(0xFFFFFFFF); // HSL(0, 0%, 100%)
  static const Color lightCardForeground = Color(0xFF3D4043); // HSL(220, 15%, 20%)
  
  // Primary
  static const Color lightPrimary = Color(0xFF3D4043); // HSL(220, 15%, 20%)
  static const Color lightPrimaryForeground = Color(0xFFFFFFFF); // HSL(0, 0%, 100%)
  
  // Secondary
  static const Color lightSecondary = Color(0xFFE8EAF0); // HSL(210, 15%, 92%)
  static const Color lightSecondaryForeground = Color(0xFF3D4043); // HSL(220, 15%, 20%)
  
  // Muted
  static const Color lightMuted = Color(0xFFF2F3F5); // HSL(210, 15%, 95%)
  static const Color lightMutedForeground = Color(0xFF7C7C85); // HSL(220, 10%, 50%)
  
  // Accent
  static const Color lightAccent = Color(0xFFFFD54F); // HSL(45, 100%, 65%)
  static const Color lightAccentForeground = Color(0xFF3D4043); // HSL(220, 15%, 20%)
  
  // Destructive
  static const Color lightDestructive = Color(0xFFE53E3E); // HSL(0, 85%, 60%)
  static const Color lightDestructiveForeground = Color(0xFFFFFFFF); // HSL(0, 0%, 100%)
  
  // Border & Input
  static const Color lightBorder = Color(0xFFDFE2E8); // HSL(210, 15%, 88%)
  static const Color lightInput = Color(0xFFF2F3F5); // HSL(210, 15%, 95%)
  
  // 📝 NOTE COLORS - LIGHT MODE
  static const Color lightNoteYellow = Color(0xFFFFF3C4); // HSL(48, 100%, 85%)
  static const Color lightNotePink = Color(0xFFF8C8DC); // HSL(340, 85%, 85%)
  static const Color lightNoteGreen = Color(0xFFC8E6C9); // HSL(140, 60%, 80%)
  static const Color lightNoteBlue = Color(0xFFBBDEFB); // HSL(200, 80%, 85%)
  static const Color lightNoteOrange = Color(0xFFFFDDB3); // HSL(25, 95%, 80%)
  static const Color lightNotePurple = Color(0xFFE1BEE7); // HSL(270, 70%, 85%)
  
  // ============================================
  // 🌙 DARK THEME COLORS 
  // ============================================
  
  // Background & Foreground
  static const Color darkBackground = Color(0xFF1E1E26); // HSL(220, 20%, 12%)
  static const Color darkForeground = Color(0xFFF2F3F5); // HSL(210, 20%, 95%)
  
  // Card
  static const Color darkCard = Color(0xFF242430); // HSL(220, 18%, 15%)
  static const Color darkCardForeground = Color(0xFFF2F3F5); // HSL(210, 20%, 95%)
  
  // Primary
  static const Color darkPrimary = Color(0xFFF2F3F5); // HSL(210, 20%, 95%)
  static const Color darkPrimaryForeground = Color(0xFF1E1E26); // HSL(220, 20%, 12%)
  
  // Secondary
  static const Color darkSecondary = Color(0xFF3D4043); // HSL(220, 15%, 20%)
  static const Color darkSecondaryForeground = Color(0xFFF2F3F5); // HSL(210, 20%, 95%)
  
  // Muted
  static const Color darkMuted = Color(0xFF3D4043); // HSL(220, 15%, 20%)
  static const Color darkMutedForeground = Color(0xFFA5A5A5); // HSL(215, 15%, 65%)
  
  // Accent
  static const Color darkAccent = Color(0xFFFFD54F); // HSL(45, 95%, 60%)
  static const Color darkAccentForeground = Color(0xFF1E1E26); // HSL(220, 20%, 12%)
  
  // Destructive
  static const Color darkDestructive = Color(0xFFE53E3E); // HSL(0, 75%, 55%)
  static const Color darkDestructiveForeground = Color(0xFFF2F3F5); // HSL(210, 20%, 95%)
  
  // Border & Input
  static const Color darkBorder = Color(0xFF404040); // HSL(220, 15%, 22%)
  static const Color darkInput = Color(0xFF3D4043); // HSL(220, 15%, 20%)
  
  // 📝 NOTE COLORS - DARK MODE (tons mais profundos)
  static const Color darkNoteYellow = Color(0xFFB8860B); // HSL(48, 90%, 45%)
  static const Color darkNotePink = Color(0xFFB85450); // HSL(340, 75%, 45%)
  static const Color darkNoteGreen = Color(0xFF5D7C5F); // HSL(140, 50%, 40%)
  static const Color darkNoteBlue = Color(0xFF4A90B8); // HSL(200, 70%, 45%)
  static const Color darkNoteOrange = Color(0xFFCC8500); // HSL(25, 85%, 45%)
  static const Color darkNotePurple = Color(0xFF8E5A9B); // HSL(270, 60%, 45%)
  
  // ============================================
  // 🎨 COLLECTIONS FOR EASY USE
  // ============================================
  
  static const List<Color> lightNoteColors = [
    lightNoteYellow,
    lightNotePink,
    lightNoteGreen,
    lightNoteBlue,
    lightNoteOrange,
    lightNotePurple,
  ];
  
  static const List<Color> darkNoteColors = [
    darkNoteYellow,
    darkNotePink,
    darkNoteGreen,
    darkNoteBlue,
    darkNoteOrange,
    darkNotePurple,
  ];
  
  // 🎲 GET RANDOM NOTE COLOR
  static Color getRandomNoteColor(bool isDark) {
    final colors = isDark ? darkNoteColors : lightNoteColors;
    return colors[(DateTime.now().millisecondsSinceEpoch % colors.length)];
  }
}
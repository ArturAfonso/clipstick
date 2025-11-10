import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ============================================
  // 🌞 LIGHT THEME - BASEADO NO FIGMA CSS
  // ============================================
  
  // Core Colors (HSL convertido para HEX)
  static const Color lightBackground = Color(0xFFFAFBFC); // --background: 210 20% 98%
  static const Color lightForeground = Color(0xFF2D3748); // --foreground: 220 15% 20%
  
  static const Color lightCard = Color(0xFFFFFFFF); // --card: 0 0% 100%
  static const Color lightCardForeground = Color(0xFF2D3748); // --card-foreground: 220 15% 20%
  
  static const Color lightPrimary = Color(0xFF2D3748); // --primary: 220 15% 20%
  static const Color lightPrimaryForeground = Color(0xFFFFFFFF); // --primary-foreground: 0 0% 100%
  
  static const Color lightSecondary = Color(0xFFE2E8F0); // --secondary: 210 15% 92%
  static const Color lightSecondaryForeground = Color(0xFF2D3748); // --secondary-foreground: 220 15% 20%
  
  static const Color lightMuted = Color(0xFFF1F5F9); // --muted: 210 15% 95%
  static const Color lightMutedForeground = Color(0xFF64748B); // --muted-foreground: 220 10% 50%
  
  static const Color lightAccent = Color(0xFFF6D55C); // --accent: 45 100% 65%
  static const Color lightAccentForeground = Color(0xFF2D3748); // --accent-foreground: 220 15% 20%
  
  static const Color lightDestructive = Color(0xFFEF4444); // --destructive: 0 85% 60%
  static const Color lightDestructiveForeground = Color(0xFFFFFFFF); // --destructive-foreground: 0 0% 100%
  
  static const Color lightBorder = Color(0xFFD1D5DB); // --border: 210 15% 88%
  static const Color lightInput = Color(0xFFF1F5F9); // --input: 210 15% 95%
  static const Color lightRing = Color(0xFF2D3748); // --ring: 220 15% 20%
  
  // Note Colors - Light Theme
  static const Color lightNoteYellow = Color(0xFFFEF3C7); // --note-yellow: 48 100% 85%
  static const Color lightNotePink = Color(0xFFFCE7F3); // --note-pink: 340 85% 85%
  static const Color lightNoteGreen = Color(0xFFD1FAE5); // --note-green: 140 60% 80%
  static const Color lightNoteBlue = Color(0xFFDBEAFE); // --note-blue: 200 80% 85%
  static const Color lightNoteOrange = Color(0xFFFED7AA); // --note-orange: 25 95% 80%
  static const Color lightNotePurple = Color(0xFFE9D5FF); // --note-purple: 270 70% 85%
  
  // Sidebar Colors - Light Theme
  static const Color lightSidebarBackground = Color(0xFFFAFAFA); // --sidebar-background: 0 0% 98%
  static const Color lightSidebarForeground = Color(0xFF374151); // --sidebar-foreground: 240 5.3% 26.1%
  static const Color lightSidebarPrimary = Color(0xFF111827); // --sidebar-primary: 240 5.9% 10%
  static const Color lightSidebarPrimaryForeground = Color(0xFFFAFAFA); // --sidebar-primary-foreground: 0 0% 98%
  static const Color lightSidebarAccent = Color(0xFFF9FAFB); // --sidebar-accent: 240 4.8% 95.9%
  static const Color lightSidebarAccentForeground = Color(0xFF111827); // --sidebar-accent-foreground: 240 5.9% 10%
  static const Color lightSidebarBorder = Color(0xFFE5E7EB); // --sidebar-border: 220 13% 91%

  // ============================================
  // 🌙 DARK THEME - BASEADO NO FIGMA CSS
  // ============================================
  
  // Core Colors (HSL convertido para HEX)
  static const Color darkBackground = Color(0xFF1E293B); // --background: 220 20% 12%
  static const Color darkForeground = Color(0xFFF1F5F9); // --foreground: 210 20% 95%
  
  static const Color darkCard = Color(0xFF334155); // --card: 220 18% 15%
  static const Color darkCardForeground = Color(0xFFF1F5F9); // --card-foreground: 210 20% 95%
  
  static const Color darkPrimary = Color(0xFFF1F5F9); // --primary: 210 20% 95%
  static const Color darkPrimaryForeground = Color(0xFF1E293B); // --primary-foreground: 220 20% 12%
  
  static const Color darkSecondary = Color(0xFF475569); // --secondary: 220 15% 20%
  static const Color darkSecondaryForeground = Color(0xFFF1F5F9); // --secondary-foreground: 210 20% 95%
  
  static const Color darkMuted = Color(0xFF475569); // --muted: 220 15% 20%
  static const Color darkMutedForeground = Color(0xFF94A3B8); // --muted-foreground: 215 15% 65%
  
  static const Color darkAccent = Color(0xFFEAB308); // --accent: 45 95% 60%
  static const Color darkAccentForeground = Color(0xFF1E293B); // --accent-foreground: 220 20% 12%
  
  static const Color darkDestructive = Color(0xFFDC2626); // --destructive: 0 75% 55%
  static const Color darkDestructiveForeground = Color(0xFFF1F5F9); // --destructive-foreground: 210 20% 95%
  
  static const Color darkBorder = Color(0xFF475569); // --border: 220 15% 22%
  static const Color darkInput = Color(0xFF475569); // --input: 220 15% 20%
  static const Color darkRing = Color(0xFFF1F5F9); // --ring: 210 20% 95%
  
  // Note Colors - Dark Theme
  static const Color darkNoteYellow = Color(0xFFCA8A04); // --note-yellow: 48 90% 45%
  static const Color darkNotePink = Color(0xFFBE185D); // --note-pink: 340 75% 45%
  static const Color darkNoteGreen = Color(0xFF059669); // --note-green: 140 50% 40%
  static const Color darkNoteBlue = Color(0xFF0369A1); // --note-blue: 200 70% 45%
  static const Color darkNoteOrange = Color(0xFFEA580C); // --note-orange: 25 85% 45%
  static const Color darkNotePurple = Color(0xFF7C3AED); // --note-purple: 270 60% 45%
  
  // Sidebar Colors - Dark Theme
  static const Color darkSidebarBackground = Color(0xFF111827); // --sidebar-background: 240 5.9% 10%
  static const Color darkSidebarForeground = Color(0xFFF9FAFB); // --sidebar-foreground: 240 4.8% 95.9%
  static const Color darkSidebarPrimary = Color(0xFF3B82F6); // --sidebar-primary: 224.3 76.3% 48%
  static const Color darkSidebarPrimaryForeground = Color(0xFFFFFFFF); // --sidebar-primary-foreground: 0 0% 100%
  static const Color darkSidebarAccent = Color(0xFF374151); // --sidebar-accent: 240 3.7% 15.9%
  static const Color darkSidebarAccentForeground = Color(0xFFF9FAFB); // --sidebar-accent-foreground: 240 4.8% 95.9%
  static const Color darkSidebarBorder = Color(0xFF374151); // --sidebar-border: 240 3.7% 15.9%
}
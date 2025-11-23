import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importe

class ThemeController extends GetxController {
  // Chave usada para persistir o valor
  static const String _themeKey = 'isDarkMode'; 
  
  // Variável observável para o estado atual do tema
  var isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Chama o método assíncrono para carregar e aplicar o tema
    _loadAndSetTheme();
  }

  // Método assíncrono para obter o valor salvo e aplicar o tema
  void _loadAndSetTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // 1. Lê o valor. Se não houver nada salvo, assume 'false' (tema claro padrão).
    final bool savedDarkMode = prefs.getBool(_themeKey) ?? false;
    
    // 2. Aplica o valor lido
    isDarkMode.value = savedDarkMode;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  // Método que alterna o tema e salva a preferência
  void toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    
    // 1. Alterna o tema no GetX
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    
    // 2. Persiste o novo valor
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode.value);
  }
}
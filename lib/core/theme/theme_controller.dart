import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class ThemeController extends GetxController {
  
  static const String _themeKey = 'isDarkMode'; 
  
  
  var isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    _loadAndSetTheme();
  }

  
  void _loadAndSetTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    
    final bool savedDarkMode = prefs.getBool(_themeKey) ?? false;
    
    
    isDarkMode.value = savedDarkMode;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  
  void toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    
    
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    
    
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode.value);
  }
}
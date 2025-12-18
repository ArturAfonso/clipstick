import 'package:shared_preferences/shared_preferences.dart';

class FirstNoteTutorialController {
  static const String _tutorialCompletedKey = 'first_note_tutorial_completed';
 /// Verifica se o tutorial já foi exibido
  Future<bool> shouldShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
     return !(prefs.getBool(_tutorialCompletedKey) ?? false);
   
  }

  /// Marca o tutorial como concluído
  Future<void> markTutorialAsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
   await prefs.setBool(_tutorialCompletedKey, true);
  }

  /// Reseta o tutorial (para testes)
  Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tutorialCompletedKey);
  }
}

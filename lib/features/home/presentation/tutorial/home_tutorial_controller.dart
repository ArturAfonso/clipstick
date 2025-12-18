import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'home_tutorial_targets.dart';

class HomeTutorialController {
  static const String _tutorialCompletedKey = 'home_tutorial_completed';

  TutorialCoachMark? _tutorialCoachMark;

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

  /// Reseta o tutorial (útil para testes ou configurações)
  Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tutorialCompletedKey);
  }

  /// Inicia o tutorial
  void showTutorial({
    required BuildContext context,
    required GlobalKey drawerKey,
    required GlobalKey addButtonKey,
    required GlobalKey viewModeKey,
    VoidCallback? onFinish,
  }) {
    final targets = HomeTutorialTargets.createTargets(
      drawerKey: drawerKey,
      addButtonKey: addButtonKey,
      viewModeKey: viewModeKey,
    );

    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      paddingFocus: 10,
      opacityShadow: 0.8,
      textSkip: "PULAR",
      onSkip: () {
        markTutorialAsCompleted();
        return true;
      },
      onFinish: () {
        markTutorialAsCompleted();
        debugPrint("Tutorial da Home finalizado");
        onFinish?.call();
      },
    );

    _tutorialCoachMark?.show(context: context);
  }

  /// Descarta o tutorial
  void dispose() {
    _tutorialCoachMark = null;
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'drawer_tutorial_targets.dart';

class DrawerTutorialController {
  static const String _tutorialCompletedKey = 'drawer_tutorial_completed';

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

  /// Inicia o tutorial do Drawer
  void showTutorial({
    required BuildContext context,
    required GlobalKey tagsListKey,
    required GlobalKey createTagKey,
    required GlobalKey themeToggleKey,
    required GlobalKey backupRestoreKey,
    VoidCallback? onFinish,
  }) {
    final targets = DrawerTutorialTargets.createTargets(
      tagsListKey: tagsListKey,
      createTagKey: createTagKey,
      themeToggleKey: themeToggleKey,
      backupRestoreKey: backupRestoreKey,
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
        debugPrint("Tutorial do Drawer finalizado");
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

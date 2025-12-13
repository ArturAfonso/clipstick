
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class DrawerTutorialTargets {
  static List<TargetFocus> createTargets({
    required GlobalKey tagsListKey,
    required GlobalKey createTagKey,
    required GlobalKey themeToggleKey,
    required GlobalKey backupRestoreKey,
  }) {
    List<TargetFocus> targets = [];

    // Target 1: Lista de Marcadores
    targets.add(
      TargetFocus(
        identify: "tags-list-key",
        keyTarget: tagsListKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children:  [
                  SizedBox(height: 30),
                  Text(
                    "Marcadores",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Aqui ficarão os marcadores com os quais você pode organizar suas notas.",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    // Target 2: Criar novo marcador
    targets.add(
      TargetFocus(
        identify: "create-tag-key",
        keyTarget: createTagKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children:  [
                  //SizedBox(height: Get.size.height / 3),
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    alignment: Alignment.center,
                      'assets/gerenciar_marcadores.GIF',
                       //width: 100,
                      height: Get.size.height / 3,
                      width: Get.size.width ,
                      fit: BoxFit.scaleDown,
                    
                    ),
                ),
                 SizedBox(height: 10),
                  Text(
                    "Criar Novo Marcador",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Para isto você deve criar o primeiro marcador. Após isso você poderá renomear ou excluir alguma etiqueta desta lista no futuro.",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    // Target 3: Mudar tema de cores
    targets.add(
      TargetFocus(
        identify: "theme-toggle-key",
        keyTarget: themeToggleKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Mudar Tema de Cores",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Aqui você pode alternar o aplicativo entre modos claro e escuro.",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    // Target 4: Fazer backup local & Restaurar backup
    targets.add(
      TargetFocus(
        identify: "backup-restore-key",
        keyTarget: backupRestoreKey,
        alignSkip: Alignment.topRight,
         shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Backup & Restauração",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Você poderá fazer backup das suas notas e restaurá-las sempre que precisar.",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    return targets;
  }
}
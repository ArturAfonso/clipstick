
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class HomeTutorialTargets {
  static List<TargetFocus> createTargets({
    required GlobalKey drawerKey,
    required GlobalKey addButtonKey,
    required GlobalKey viewModeKey,
  }) {
    List<TargetFocus> targets = [];

    

    // Target 1: Botão de adicionar nota
    targets.add(
      TargetFocus(
        identify: "add-button-key",
        keyTarget: addButtonKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Criar Nota",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Toque aqui para criar uma nova nota rapidamente.",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    
    targets.add(
      TargetFocus(
        identify: "view-mode-key",
        keyTarget: viewModeKey,
        alignSkip: Alignment.topLeft,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Modo de Visualização",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Após criar suas primeiras notas, alterne entre visualização em grade ou lista.",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    // Target 3: Botão do Drawer (Menu)
     targets.add(
      TargetFocus(
        identify: "drawer-key",
        keyTarget: drawerKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Menu",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Toque aqui para abrir o menu lateral com opções adicionais.",
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
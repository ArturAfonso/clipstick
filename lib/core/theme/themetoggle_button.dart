import 'package:clipstick/core/theme/app_text_styles.dart';
import 'package:clipstick/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Importe o seu ThemeController

class ThemeToggleButton extends StatelessWidget {
  // 1. Obtém a instância do controlador que está em memória
  // Usamos Get.find() se já foi colocado com Get.put() em outro lugar (ex: MyApp)
  final ThemeController themeController = Get.find();

   ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. O 'Obx' observa a variável reativa 'isDarkMode'
    return Obx(() {
      // O ícone muda instantaneamente com base no estado atual
      final isDark = themeController.isDarkMode.value;

      return Padding(
        padding: const EdgeInsets.only(left:10.0),
        child: IconButton(
          // 3. Ícone dinâmico: mostra sol se for escuro, lua se for claro
          icon: Row(
            children: [ 
              Icon(
                isDark ? Icons.wb_sunny : Icons.dark_mode,
                // Cor que contrasta, dependendo do tema atual do Flutter
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 10),
              Text(isDark ?    'Mudar para tema claro' :'Mudar para tema escuro',
              style: AppTextStyles.bodyLarge,
              
               ),
             
            ],
          ),
          onPressed: () {
            // 4. Chama o método de alternância do controlador
            themeController.toggleTheme();
          },
        ),
      );
    });
  }
}

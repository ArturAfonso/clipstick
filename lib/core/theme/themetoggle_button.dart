import 'package:clipstick/core/theme/app_text_styles.dart';
import 'package:clipstick/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ThemeToggleButton extends StatelessWidget {
  
  
  final ThemeController themeController = Get.find();

   ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Obx(() {
      
      final isDark = themeController.isDarkMode.value;

      return Padding(
        padding: const EdgeInsets.only(left:10.0),
        child: IconButton(
          
          icon: Row(
            children: [ 
              Icon(
                isDark ? Icons.wb_sunny : Icons.dark_mode,
                
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 10),
              Text(isDark ?    'Mudar para tema claro' :'Mudar para tema escuro',
              style: AppTextStyles.bodyLarge,
              
               ),
             
            ],
          ),
          onPressed: () {
            
            themeController.toggleTheme();
          },
        ),
      );
    });
  }
}

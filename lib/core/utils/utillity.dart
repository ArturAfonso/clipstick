

import 'package:clipstick/core/theme/app_colors.dart';
import 'package:clipstick/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Utils {
  static SnackbarController normalException({String? title, required String message}) {
  //  Color backgroundColor = Get.isDarkMode ? AppColors.darkDestructive : AppColors.lightDestructive;
    Color backgroundColor = Get.isDarkMode ? AppColors.darkError : AppColors.lightError;
    return Get.snackbar(
    "", "",
    titleText: Text(
      title ?? "Erro",
      style: AppTextStyles.noteTitle.copyWith(
       // color: AppColors.getTextColor(backgroundColor),
       color: Get.isDarkMode ? AppColors.darkErrorForeground : AppColors.lightErrorForeground
         ),
    ),
    messageText: Text(
      message,
      style:  AppTextStyles.bodyMedium.copyWith(
        color: Get.isDarkMode ? AppColors.darkErrorForeground : AppColors.lightErrorForeground
        
        ),
    ),
    backgroundColor: backgroundColor,
    snackPosition: SnackPosition.TOP, 
    margin: const EdgeInsets.all(12), 
    borderRadius: 16, 
    duration: const Duration(seconds: 4),
  );
  }

  static SnackbarController normalSucess({String? title, required String message}) {
 //   Color backgroundColor = Get.isDarkMode ? hsl(142,69,50)  : hsl(142,76,45);
    Color backgroundColor = Get.isDarkMode ? AppColors.darkSuccess  : AppColors.lightSuccess;
    return  Get.snackbar(
    "", "",
    titleText: Text(
      title ?? "Sucesso",
      style: AppTextStyles.noteTitle.copyWith(
       // color: AppColors.getTextColor(backgroundColor), 
        color: Get.isDarkMode ? AppColors.darkSuccessForeground  : AppColors.lightSuccessForeground, 
        
        ),
    ),
    messageText: Text(
      message,
      style:  AppTextStyles.bodyMedium.copyWith(
        //color: AppColors.getTextColor(backgroundColor), 
        color: Get.isDarkMode ? AppColors.darkSuccessForeground  : AppColors.lightSuccessForeground, 
        ),
    ),
    backgroundColor: backgroundColor,
    snackPosition: SnackPosition.TOP, 
    margin: const EdgeInsets.all(12), 
    borderRadius: 8, 
    duration: const Duration(seconds: 4),
  );
  }

  static SnackbarController normalWarning({String? title, required String message}) {
    //Color backgroundColor = Get.isDarkMode ? hsl(45, 95, 60 )  : hsl(45,100,65);
    Color backgroundColor = Get.isDarkMode ? AppColors.darkWarning  : AppColors.lightWarning;
    return  Get.snackbar(
    "", "",
    titleText: Text(
      title ?? "Aviso",
      style: AppTextStyles.noteTitle.copyWith(
        //color: AppColors.getTextColor(backgroundColor), 
        color:Get.isDarkMode ? AppColors.darkWarningForeground  : AppColors.lightWarningForeground, 
        ),
    ),
    messageText: Text(
      message,
      style:  AppTextStyles.bodyMedium.copyWith(
        color:Get.isDarkMode ? AppColors.darkWarningForeground  : AppColors.lightWarningForeground, 
        ),
    ),
    backgroundColor: backgroundColor,
    snackPosition: SnackPosition.TOP, 
    margin: const EdgeInsets.all(12), 
    borderRadius: 8, 
    duration: const Duration(seconds: 4),
  );
  }
  static SnackbarController normalInfo({String? title, required String message}) {
   // Color backgroundColor = Get.isDarkMode ? hsl( 210,20,95)  : hsl(220,15,20);
    Color backgroundColor = Get.isDarkMode ? AppColors.darkInfo  : AppColors.lightInfo;
    return  Get.snackbar(
    "", "",
    titleText: Text(
      title ?? "Informação",
      style: AppTextStyles.noteTitle.copyWith(
        //color: AppColors.getTextColor(backgroundColor), 
        color: Get.isDarkMode ? AppColors.darkInfoForeground  : AppColors.lightInfoForeground, 
        
        ),
    ),
    messageText: Text(
      message,
      style:  AppTextStyles.bodyMedium.copyWith(
       // color: AppColors.getTextColor(backgroundColor), 
         color: Get.isDarkMode ? AppColors.darkInfoForeground  : AppColors.lightInfoForeground, 
        ),
    ),
    backgroundColor: backgroundColor,
    snackPosition: SnackPosition.TOP, 
    margin: const EdgeInsets.all(12), 
    borderRadius: 8, 
    duration: const Duration(seconds: 4),
  );
  }

    static Color hsl(double h, double s, double l) {
    return HSLColor.fromAHSL(1.0, h, s / 100, l / 100).toColor();
  }
}

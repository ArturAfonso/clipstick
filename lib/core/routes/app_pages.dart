

import 'package:clipstick/features/home/presentation/screens/home_screen.dart';
import 'package:clipstick/features/splash/spash_screen.dart';
import 'package:get/get.dart';

import 'app_routes.dart';

class AppPages {
  static final pages = [
   GetPage(
      name: AppRoutes.initial,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: AppRoutes.splash,
      page: () =>  const SplashScreen(),
    ),
 
  ];
}
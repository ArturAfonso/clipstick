

import 'package:clipstick/features/home/presentation/screens/home_screen.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.initial,
      page: () => BlocProvider(
        create: (context) => HomeCubit()..loadNotes(),
        child: const HomeScreen(),
      ),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => BlocProvider(
        create: (context) => HomeCubit()..loadNotes(),
        child: const HomeScreen(),
      ),
    ),
    // TODO: Adicionar outras rotas
  ];
}
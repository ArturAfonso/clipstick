import 'package:clipstick/core/routes/app_pages.dart';
import 'package:clipstick/core/routes/app_routes.dart';
import 'package:clipstick/core/theme/app_theme.dart';
import 'package:clipstick/core/theme/theme_controller.dart';
import 'package:clipstick/features/home/presentation/cubit/home_cubit.dart';
import 'package:clipstick/features/home/presentation/cubit/view_mode_cubit.dart';
import 'package:clipstick/features/tags/presentation/cubit/tags_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:clipstick/core/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
 await setupServiceLocator();
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    Get.put(ThemeController());
    return MultiBlocProvider(
      providers: [
         BlocProvider<ViewModeCubit>(
          create: (context) => ViewModeCubit()..initializeViewMode(),
          lazy: false, 
        ),

         BlocProvider<HomeCubit>(
          create: (context) => HomeCubit()..loadNotes(),
          lazy: false, 
        ),
         BlocProvider<TagsCubit>(
          create: (context) => TagsCubit()..loadTags(),
          lazy: false, 
        )
      ],
      child: GetMaterialApp(
        title: 'ClipStick',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.home,
        getPages: AppPages.pages,
      ),
    );
  }
}

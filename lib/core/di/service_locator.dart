import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:clipstick/core/database/database.dart';
import 'package:clipstick/data/repositories/note_repository.dart';
import 'package:clipstick/data/repositories/note_repository_impl.dart';
import 'package:clipstick/data/repositories/tag_repository.dart';
import 'package:clipstick/data/repositories/tag_repository_impl.dart';


final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
 
  sl.registerLazySingleton<AppDatabase>(
    () => AppDatabase(),
  );

  
  sl.registerFactory<NoteRepository>(
    () => NoteRepositoryImpl(sl<AppDatabase>()),
  );

  sl.registerFactory<TagRepository>(
    () => TagRepositoryImpl(sl<AppDatabase>()),
  );


  debugPrint('✅ Service Locator configurado com sucesso!');
  debugPrint('   📦 ${sl.isRegistered<AppDatabase>() ? "✓" : "✗"} AppDatabase');
  debugPrint('   📝 ${sl.isRegistered<NoteRepository>() ? "✓" : "✗"} NoteRepository');
  debugPrint('   🏷️ ${sl.isRegistered<TagRepository>() ? "✓" : "✗"} TagRepository');
}

/// 🧹 LIMPAR CACHE


/// @override
/// void dispose() {
///   cleanupServiceLocator();
///   super.dispose();
/// }
Future<void> cleanupServiceLocator() async {
  try {
    
    if (sl.isRegistered<AppDatabase>()) {
      await sl<AppDatabase>().close();
      debugPrint('🗄️ Banco de dados fechado');
    }

   
    await sl.reset();
    debugPrint('🧹 Service Locator limpo');
  } catch (e) {
    debugPrint('⚠️ Erro ao limpar Service Locator: $e');
  }
}

/// ```
bool isDependencyRegistered<T extends Object>() {
  return sl.isRegistered<T>();
}

void printRegisteredDependencies() {
  debugPrint('📋 Dependências registradas:');
  debugPrint('   💾 AppDatabase: ${sl.isRegistered<AppDatabase>()}');
  debugPrint('   📝 NoteRepository: ${sl.isRegistered<NoteRepository>()}');
  debugPrint('   🏷️ TagRepository: ${sl.isRegistered<TagRepository>()}');
}
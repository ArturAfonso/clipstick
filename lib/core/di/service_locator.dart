import 'package:get_it/get_it.dart';
import 'package:clipstick/core/database/database.dart';
import 'package:clipstick/data/repositories/note_repository.dart';
import 'package:clipstick/data/repositories/note_repository_impl.dart';
import 'package:clipstick/data/repositories/tag_repository.dart';
import 'package:clipstick/data/repositories/tag_repository_impl.dart';

/// 💉 SERVICE LOCATOR (DEPENDENCY INJECTION)
/// 
/// Centraliza todas as dependências do app usando get_it.
/// 
/// **Padrão de acesso:**
/// ```dart
/// final noteRepo = sl<NoteRepository>();
/// final tagRepo = sl<TagRepository>();
/// final database = sl<AppDatabase>();
/// ```
/// 
/// **Configuração:**
/// ```dart
/// void main() async {
///   await setupServiceLocator();
///   runApp(MyApp());
/// }
/// ```
final sl = GetIt.instance;

/// ⚙️ CONFIGURAR TODAS AS DEPENDÊNCIAS
/// 
/// **IMPORTANTE:** Chame este método no `main()` ANTES de `runApp()`.
/// 
/// **Ordem de registro:**
/// 1. Database (Singleton)
/// 2. Repositories (Factory)
/// 3. BLoCs/Cubits (opcional)
Future<void> setupServiceLocator() async {
  
  // ═══════════════════════════════════════════════════════════════
  // 💾 BANCO DE DADOS
  // ═══════════════════════════════════════════════════════════════

  /// 💾 AppDatabase - LAZY SINGLETON
  /// 
  /// **Lazy:** Só é criado quando alguém pedir `sl<AppDatabase>()`
  /// **Singleton:** Apenas UMA instância para todo o app
  /// 
  /// **Por que Singleton?**
  /// - Evita múltiplas conexões SQLite
  /// - Compartilha pool de conexões
  /// - Gerencia transações globalmente
  sl.registerLazySingleton<AppDatabase>(
    () => AppDatabase(),
  );

  // ═══════════════════════════════════════════════════════════════
  // 📦 REPOSITORIES
  // ═══════════════════════════════════════════════════════════════

  /// 📝 NoteRepository - FACTORY
  /// 
  /// **Factory:** Cria nova instância a cada chamada
  /// **Por que Factory?**
  /// - Repositories são stateless (sem estado interno)
  /// - Mais seguro para uso em múltiplos BLoCs
  /// - Evita compartilhamento de estado acidental
  /// 
  /// **Uso:**
  /// ```dart
  /// class NotesBloc extends Bloc {
  ///   final NoteRepository _repo = sl<NoteRepository>();
  /// }
  /// ```
  sl.registerFactory<NoteRepository>(
    () => NoteRepositoryImpl(sl<AppDatabase>()),
  );

  /// 🏷️ TagRepository - FACTORY
  sl.registerFactory<TagRepository>(
    () => TagRepositoryImpl(sl<AppDatabase>()),
  );

  // ═══════════════════════════════════════════════════════════════
  // 🧊 BLOCS/CUBITS (OPCIONAL)
  // ═══════════════════════════════════════════════════════════════

  // 💡 DICA: Você PODE registrar BLoCs aqui, mas NÃO É OBRIGATÓRIO!
  // 
  // ✅ OPÇÃO 1: Registrar aqui (recomendado para BLoCs globais)
  // sl.registerFactory<NotesBloc>(
  //   () => NotesBloc(noteRepository: sl<NoteRepository>()),
  // );
  //
  // ✅ OPÇÃO 2: Criar direto no BlocProvider (recomendado para BLoCs locais)
  // BlocProvider(
  //   create: (context) => NotesBloc(noteRepository: sl<NoteRepository>()),
  //   child: NotesScreen(),
  // )

  // ═══════════════════════════════════════════════════════════════
  // ✅ LOG DE CONFIRMAÇÃO
  // ═══════════════════════════════════════════════════════════════

  print('✅ Service Locator configurado com sucesso!');
  print('   📦 ${sl.isRegistered<AppDatabase>() ? "✓" : "✗"} AppDatabase');
  print('   📝 ${sl.isRegistered<NoteRepository>() ? "✓" : "✗"} NoteRepository');
  print('   🏷️ ${sl.isRegistered<TagRepository>() ? "✓" : "✗"} TagRepository');
}

/// 🧹 LIMPAR RECURSOS
/// 
/// **Quando usar:**
/// - Ao fechar o app (dispose global)
/// - Entre testes unitários
/// - Ao fazer logout (limpar cache)
/// 
/// **Exemplo:**
/// ```dart
/// @override
/// void dispose() {
///   cleanupServiceLocator();
///   super.dispose();
/// }
/// ```
Future<void> cleanupServiceLocator() async {
  try {
    // Fechar conexão do banco de dados
    if (sl.isRegistered<AppDatabase>()) {
      await sl<AppDatabase>().close();
      print('🗄️ Banco de dados fechado');
    }

    // Resetar service locator
    await sl.reset();
    print('🧹 Service Locator limpo');
  } catch (e) {
    print('⚠️ Erro ao limpar Service Locator: $e');
  }
}

/// 🔍 VERIFICAR SE DEPENDÊNCIA ESTÁ REGISTRADA
/// 
/// **Uso em debug:**
/// ```dart
/// if (isDependencyRegistered<NoteRepository>()) {
///   print('NoteRepository está disponível!');
/// }
/// ```
bool isDependencyRegistered<T extends Object>() {
  return sl.isRegistered<T>();
}

/// 📊 LISTAR TODAS AS DEPENDÊNCIAS REGISTRADAS
/// 
/// **Útil para debug:**
/// ```dart
/// void main() async {
///   await setupServiceLocator();
///   printRegisteredDependencies(); // Mostra todas
///   runApp(MyApp());
/// }
/// ```
void printRegisteredDependencies() {
  print('📋 Dependências registradas:');
  print('   💾 AppDatabase: ${sl.isRegistered<AppDatabase>()}');
  print('   📝 NoteRepository: ${sl.isRegistered<NoteRepository>()}');
  print('   🏷️ TagRepository: ${sl.isRegistered<TagRepository>()}');
}
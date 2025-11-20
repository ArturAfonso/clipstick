import 'dart:io';
import 'dart:ui';
import 'package:clipstick/data/database/converters/color_converter.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// 🆕 IMPORTAR TODAS AS TABELAS
import 'package:clipstick/data/database/tables/notes_table.dart';
import 'package:clipstick/data/database/tables/tags_table.dart';
import 'package:clipstick/data/database/tables/note_tags_table.dart';

// 🆕 IMPORTAR DAOs
import 'package:clipstick/data/database/daos/notes_dao.dart';
import 'package:clipstick/data/database/daos/tags_dao.dart';

// 🤖 IMPORTANTE: Este arquivo será gerado pelo build_runner
// Rodar: dart run build_runner build --delete-conflicting-outputs
part 'database.g.dart';

/// 💾 BANCO DE DADOS PRINCIPAL DA APLICAÇÃO
/// 
/// Gerencia todas as tabelas e conexões do SQLite usando Drift.
/// 
/// **Tabelas:**
/// - Notes: Armazena as notas
/// - Tags: Armazena as tags/etiquetas
/// - NoteTags: Relacionamento N:N entre Notes e Tags
/// 
/// **Arquivo gerado:**
/// - `clipstick.sqlite` em: `ApplicationDocumentsDirectory`
/// - Android: `/data/data/com.seu.app/app_flutter/clipstick.sqlite`
/// - iOS: `/var/mobile/Containers/Data/Application/.../Documents/clipstick.sqlite`
/// 
/// **Uso:**
/// ```dart
/// final db = AppDatabase();
/// final notes = await db.select(db.notes).get();
/// await db.close();
/// ```
@DriftDatabase(
  tables: [Notes, Tags, NoteTags],
   daos: [NotesDao, TagsDao],
)
class AppDatabase extends _$AppDatabase {
  
  /// ✅ CONSTRUTOR PADRÃO
  /// 
  /// Abre conexão com o banco SQLite.
  /// Se o arquivo não existir, será criado automaticamente.
  AppDatabase() : super(_openConnection());

  /// 🔢 VERSÃO DO SCHEMA
  /// 
  /// **IMPORTANTE:** Incremente este número quando mudar a estrutura do banco!
  /// 
  /// - **v1:** Schema inicial (Notes, Tags, NoteTags)
  /// - **v2:** (futuro) Adicionar campo `syncId` em Notes
  /// - **v3:** (futuro) Adicionar tabela `Attachments` para imagens
  /// 
  /// **Quando incrementar:**
  /// - Adicionar nova coluna
  /// - Adicionar nova tabela
  /// - Alterar tipo de coluna
  /// - Adicionar/remover índices
  @override
  int get schemaVersion => 1;

  /// 🔄 ESTRATÉGIA DE MIGRAÇÃO
  /// 
  /// Define o que acontece quando:
  /// - Banco não existe → `onCreate`
  /// - Versão do schema mudou → `onUpgrade`
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      
      // ✅ CRIAR BANCO PELA PRIMEIRA VEZ
      onCreate: (Migrator m) async {
        // Cria todas as tabelas definidas em @DriftDatabase
        await m.createAll();
        
        // 🆕 OPCIONAL: Inserir dados iniciais (seed)
        // await _insertInitialData();
      },

      // ✅ ATUALIZAR BANCO (quando schemaVersion aumentar)
      onUpgrade: (Migrator m, int from, int to) async {
        // TODO: Implementar migrações futuras
        
        // Exemplo de migração v1 → v2:
        // if (from < 2) {
        //   await m.addColumn(notes, notes.syncId);
        //   await m.addColumn(notes, notes.lastSyncedAt);
        // }
        
        // Exemplo de migração v2 → v3:
        // if (from < 3) {
        //   await m.createTable(attachments);
        // }
      },

      // ✅ ANTES DE ABRIR O BANCO (configurações)
      beforeOpen: (details) async {
        // ✅ HABILITAR FOREIGN KEYS (IMPORTANTE!)
        // Sem isso, CASCADE delete não funciona!
        await customStatement('PRAGMA foreign_keys = ON');
        
        // 🆕 OPCIONAL: Log quando banco for criado
        if (details.wasCreated) {
          print('📦 Banco de dados criado com sucesso!');
        }
        
        // 🆕 OPCIONAL: Log quando banco for atualizado
        if (details.hadUpgrade) {
          print('🔄 Banco de dados atualizado de v${details.versionBefore} → v${details.versionNow}');
        }
      },
    );
  }

  /// 🆕 OPCIONAL: Inserir dados iniciais (seed)
  /// 
  /// Útil para criar tags padrão na primeira vez.
  /// Descomentar se quiser usar.
  /*
  Future<void> _insertInitialData() async {
    // Criar tags padrão
    await batch((batch) {
      batch.insertAll(tags, [
        TagsCompanion.insert(
          id: const Value('tag-trabalho'),
          name: 'Trabalho',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        TagsCompanion.insert(
          id: const Value('tag-pessoal'),
          name: 'Pessoal',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        TagsCompanion.insert(
          id: const Value('tag-urgente'),
          name: 'Urgente',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ]);
    });
    
    print('🏷️ Tags padrão criadas!');
  }
  */
}

/// 🔌 ABRIR CONEXÃO COM SQLITE
/// 
/// Cria/abre o arquivo `clipstick.sqlite` no diretório de documentos.
/// 
/// **Lazy Loading:**
/// - Conexão só é aberta quando realmente necessário
/// - Economiza memória
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // 📁 OBTER DIRETÓRIO DE DOCUMENTOS
    // Android: /data/data/com.seu.app/app_flutter/
    // iOS: /var/mobile/Containers/Data/Application/.../Documents/
    final dbFolder = await getApplicationDocumentsDirectory();
    
    // 📝 CRIAR CAMINHO DO ARQUIVO
    // Resultado: /caminho/para/documentos/clipstick.sqlite
    final file = File(p.join(dbFolder.path, 'clipstick.sqlite'));
    
    // 💾 ABRIR BANCO DE DADOS NATIVO
    return NativeDatabase(file);
  });
}
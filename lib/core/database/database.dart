// ignore_for_file: avoid_print

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

@DriftDatabase(
  tables: [Notes, Tags, NoteTags],
   daos: [NotesDao, TagsDao],
)
class AppDatabase extends _$AppDatabase {
  
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      
     
      onCreate: (Migrator m) async {
        
        await m.createAll();
       
      },

      onUpgrade: (Migrator m, int from, int to) async {
       
      },

     
      beforeOpen: (details) async {
         await customStatement('PRAGMA foreign_keys = ON');
        
         if (details.wasCreated) {
          print('📦 Banco de dados criado com sucesso!');
        }
        
       
        if (details.hadUpgrade) {
          print('🔄 Banco de dados atualizado de v${details.versionBefore} → v${details.versionNow}');
        }
      },
    );
  }

}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
     final dbFolder = await getApplicationDocumentsDirectory();
    
       final file = File(p.join(dbFolder.path, 'clipstick.sqlite'));
    
    
    return NativeDatabase(file);
  });
}
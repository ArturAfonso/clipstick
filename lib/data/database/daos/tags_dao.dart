import 'package:drift/drift.dart';
import 'package:clipstick/core/database/database.dart';
import 'package:clipstick/data/database/tables/tags_table.dart';
import 'package:clipstick/data/database/tables/note_tags_table.dart';
import 'package:clipstick/data/database/tables/notes_table.dart';

// 🤖 Este arquivo será gerado pelo build_runner
part 'tags_dao.g.dart';

/// 🏷️ DATA ACCESS OBJECT PARA TAGS
/// 
/// Centraliza todas as operações CRUD e queries relacionadas a tags.
/// 
/// **Operações disponíveis:**
/// - CRUD básico (Create, Read, Update, Delete)
/// - Adicionar/remover tag de nota
/// - Buscar tags de uma nota
/// - Contar quantas notas têm uma tag
/// - Streams reativos (watch)
@DriftAccessor(tables: [Tags, NoteTags, Notes])
class TagsDao extends DatabaseAccessor<AppDatabase> with _$TagsDaoMixin {
  
  /// ✅ CONSTRUTOR
  /// 
  /// Recebe a instância do banco de dados.
  TagsDao(super.db);

  // ═══════════════════════════════════════════════════════════════
  // 📋 OPERAÇÕES BÁSICAS (CRUD)
  // ═══════════════════════════════════════════════════════════════

  /// ✅ BUSCAR TODAS AS TAGS (ordenadas por nome)
  /// 
  /// **Retorna:** Lista de TagEntity ordenada alfabeticamente
  /// 
  /// **Uso:**
  /// ```dart
  /// final allTags = await tagsDao.getAllTags();
  /// print('Total: ${allTags.length} tags');
  /// ```
  Future<List<TagEntity>> getAllTags() {
    return (select(tags)
      ..orderBy([
        (t) => OrderingTerm.asc(t.name),
      ]))
    .get();
  }

  /// 📺 WATCH: Observar TODAS as tags (Stream reativo)
  /// 
  /// **Retorna:** Stream que emite nova lista quando banco muda
  /// 
  /// **Uso com StreamBuilder:**
  /// ```dart
  /// StreamBuilder<List<TagEntity>>(
  ///   stream: tagsDao.watchAllTags(),
  ///   builder: (context, snapshot) {
  ///     if (!snapshot.hasData) return CircularProgressIndicator();
  ///     return Wrap(
  ///       children: snapshot.data!.map((tag) => Chip(label: Text(tag.name))).toList(),
  ///     );
  ///   },
  /// )
  /// ```
  Stream<List<TagEntity>> watchAllTags() {
    return (select(tags)
      ..orderBy([
        (t) => OrderingTerm.asc(t.name),
      ]))
    .watch();
  }

  /// 🔍 BUSCAR TAG POR ID
  /// 
  /// **Retorna:** TagEntity ou null se não encontrar
  /// 
  /// **Uso:**
  /// ```dart
  /// final tag = await tagsDao.getTagById('tag-trabalho');
  /// if (tag != null) {
  ///   print('Encontrou: ${tag.name}');
  /// }
  /// ```
  Future<TagEntity?> getTagById(String id) {
    return (select(tags)
      ..where((t) => t.id.equals(id)))
    .getSingleOrNull();
  }

  /// 🔍 BUSCAR TAG POR NOME (case-insensitive)
  /// 
  /// **Retorna:** TagEntity ou null se não encontrar
  /// 
  /// **Uso:**
  /// ```dart
  /// final tag = await tagsDao.getTagByName('Trabalho');
  /// if (tag == null) {
  ///   print('Tag não existe, pode criar!');
  /// }
  /// ```
  Future<TagEntity?> getTagByName(String name) {
    return (select(tags)
      ..where((t) => t.name.lower().equals(name.toLowerCase())))
    .getSingleOrNull();
  }

 /// ➕ INSERIR NOVA TAG
/// 
/// **Retorna:** ID da tag inserida (String)
/// 
/// **Uso:**
/// ```dart
/// final tagId = await tagsDao.insertTag(TagsCompanion.insert(
///   id: 'tag-urgente',
///   name: 'Urgente',
///   createdAt: DateTime.now(),
///   updatedAt: DateTime.now(),
/// ));
/// print('Tag criada com ID: $tagId'); // 'tag-urgente'
/// ```
Future<String> insertTag(TagsCompanion tag) async {
  await into(tags).insert(tag);
  // Retorna o ID que foi passado no Companion
  return tag.id.value;
}

  /// ➕ INSERIR OU ATUALIZAR TAG
  /// 
  /// Se ID já existe → atualiza
  /// Se ID não existe → insere
  /// 
  /// **Uso:**
  /// ```dart
  /// await tagsDao.upsertTag(TagsCompanion(
  ///   id: Value('tag-pessoal'),
  ///   name: Value('Pessoal'),
  ///   createdAt: Value(DateTime.now()),
  ///   updatedAt: Value(DateTime.now()),
  /// ));
  /// ```
  Future<void> upsertTag(TagsCompanion tag) {
    return into(tags).insertOnConflictUpdate(tag);
  }

  /// ✏️ ATUALIZAR TAG EXISTENTE
  /// 
  /// **Retorna:** true se atualizou, false se tag não existe
  /// 
  /// **Uso:**
  /// ```dart
  /// final updated = await tagsDao.updateTag(TagsCompanion(
  ///   id: Value('tag-trabalho'),
  ///   name: Value('Trabalho (Novo)'),
  ///   updatedAt: Value(DateTime.now()),
  /// ));
  /// ```
  Future<bool> updateTag(TagsCompanion tag) {
    return update(tags).replace(tag);
  }

  /// 🗑️ DELETAR TAG POR ID
  /// 
  /// **CASCADE:** Remove automaticamente relacionamentos em NoteTags
  /// 
  /// **Retorna:** Número de linhas deletadas (1 se sucesso, 0 se não existe)
  /// 
  /// **Uso:**
  /// ```dart
  /// final deleted = await tagsDao.deleteTag('tag-urgente');
  /// if (deleted > 0) {
  ///   print('Tag deletada com sucesso!');
  /// }
  /// ```
  Future<int> deleteTag(String id) {
    return (delete(tags)
      ..where((t) => t.id.equals(id)))
    .go();
  }

  /// 🗑️ DELETAR MÚLTIPLAS TAGS
  /// 
  /// **Uso:**
  /// ```dart
  /// await tagsDao.deleteTags(['tag1', 'tag2', 'tag3']);
  /// ```
  Future<int> deleteTags(List<String> ids) {
    return (delete(tags)
      ..where((t) => t.id.isIn(ids)))
    .go();
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔗 RELACIONAMENTOS (NOTAS ↔ TAGS)
  // ═══════════════════════════════════════════════════════════════

  /// 🏷️ BUSCAR TAGS DE UMA NOTA ESPECÍFICA
  /// 
  /// **Join:** tags INNER JOIN note_tags ON tags.id = note_tags.tag_id
  /// 
  /// **Uso:**
  /// ```dart
  /// final tagsOfNote = await tagsDao.getTagsForNote('nota123');
  /// print('Tags: ${tagsOfNote.map((t) => t.name).join(', ')}');
  /// ```
  Future<List<TagEntity>> getTagsForNote(String noteId) {
    final query = select(tags).join([
      innerJoin(
        noteTags,
        noteTags.tagId.equalsExp(tags.id),
      ),
    ])
    ..where(noteTags.noteId.equals(noteId))
    ..orderBy([OrderingTerm.asc(tags.name)]);

    return query.map((row) => row.readTable(tags)).get();
  }

  /// 📺 WATCH: Observar tags de uma nota
  /// 
  /// **Uso:**
  /// ```dart
  /// StreamBuilder<List<TagEntity>>(
  ///   stream: tagsDao.watchTagsForNote('nota123'),
  ///   builder: (context, snapshot) {
  ///     if (!snapshot.hasData) return Container();
  ///     return Wrap(
  ///       children: snapshot.data!.map((tag) => 
  ///         Chip(label: Text(tag.name))
  ///       ).toList(),
  ///     );
  ///   },
  /// )
  /// ```
  Stream<List<TagEntity>> watchTagsForNote(String noteId) {
    final query = select(tags).join([
      innerJoin(
        noteTags,
        noteTags.tagId.equalsExp(tags.id),
      ),
    ])
    ..where(noteTags.noteId.equals(noteId))
    ..orderBy([OrderingTerm.asc(tags.name)]);

    return query.map((row) => row.readTable(tags)).watch();
  }

  /// ➕ ADICIONAR TAG A UMA NOTA
  /// 
  /// **Uso:**
  /// ```dart
  /// await tagsDao.addTagToNote(
  ///   noteId: 'nota123',
  ///   tagId: 'tag-urgente',
  /// );
  /// ```
  Future<void> addTagToNote({
    required String noteId,
    required String tagId,
  }) {
    return into(noteTags).insert(
      NoteTagsCompanion(
        noteId: Value(noteId),
        tagId: Value(tagId),
      ),
      mode: InsertMode.insertOrIgnore, // Ignora se já existe
    );
  }

  /// ➖ REMOVER TAG DE UMA NOTA
  /// 
  /// **Uso:**
  /// ```dart
  /// final removed = await tagsDao.removeTagFromNote(
  ///   noteId: 'nota123',
  ///   tagId: 'tag-urgente',
  /// );
  /// if (removed > 0) {
  ///   print('Tag removida da nota!');
  /// }
  /// ```
  Future<int> removeTagFromNote({
    required String noteId,
    required String tagId,
  }) {
    return (delete(noteTags)
      ..where((nt) =>
          nt.noteId.equals(noteId) &
          nt.tagId.equals(tagId)))
    .go();
  }

  /// 🗑️ REMOVER TODAS AS TAGS DE UMA NOTA
  /// 
  /// **Uso:**
  /// ```dart
  /// await tagsDao.removeAllTagsFromNote('nota123');
  /// ```
  Future<int> removeAllTagsFromNote(String noteId) {
    return (delete(noteTags)
      ..where((nt) => nt.noteId.equals(noteId)))
    .go();
  }

  /// 🔄 SUBSTITUIR TAGS DE UMA NOTA
  /// 
  /// Remove todas as tags antigas e adiciona as novas.
  /// 
  /// **Uso:**
  /// ```dart
  /// await tagsDao.setTagsForNote(
  ///   noteId: 'nota123',
  ///   tagIds: ['tag-trabalho', 'tag-urgente'],
  /// );
  /// ```
  Future<void> setTagsForNote({
    required String noteId,
    required List<String> tagIds,
  }) async {
    await transaction(() async {
      // 1. Remove todas as tags antigas
      await removeAllTagsFromNote(noteId);

      // 2. Adiciona as novas tags
      if (tagIds.isNotEmpty) {
        await batch((batch) {
          for (final tagId in tagIds) {
            batch.insert(
              noteTags,
              NoteTagsCompanion(
                noteId: Value(noteId),
                tagId: Value(tagId),
              ),
              mode: InsertMode.insertOrIgnore,
            );
          }
        });
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // 📊 ESTATÍSTICAS E CONTADORES
  // ═══════════════════════════════════════════════════════════════

  /// 🔢 CONTAR TOTAL DE TAGS
  Future<int> countAllTags() async {
    final count = countAll();
    final query = selectOnly(tags)..addColumns([count]);
    return await query.map((row) => row.read(count)!).getSingle();
  }

  /// 📝 CONTAR QUANTAS NOTAS TÊM UMA TAG ESPECÍFICA
  /// 
  /// **Uso:**
  /// ```dart
  /// final count = await tagsDao.countNotesWithTag('tag-urgente');
  /// print('$count notas com tag "Urgente"');
  /// ```
  Future<int> countNotesWithTag(String tagId) async {
    final count = countAll();
    final query = selectOnly(noteTags)
      ..addColumns([count])
      ..where(noteTags.tagId.equals(tagId));
    return await query.map((row) => row.read(count)!).getSingle();
  }

  /// 🏷️ BUSCAR TAGS COM CONTAGEM DE NOTAS
  /// 
  /// **Retorna:** Map<TagEntity, int> (tag → quantidade de notas)
  /// 
  /// **Uso:**
  /// ```dart
  /// final tagsWithCount = await tagsDao.getTagsWithNoteCounts();
  /// for (final entry in tagsWithCount.entries) {
  ///   print('${entry.key.name}: ${entry.value} notas');
  /// }
  /// ```
  Future<Map<TagEntity, int>> getTagsWithNoteCounts() async {
    final result = <TagEntity, int>{};
    final allTags = await getAllTags();

    for (final tag in allTags) {
      final noteCount = await countNotesWithTag(tag.id);
      result[tag] = noteCount;
    }

    return result;
  }

  /// 🗑️ DELETAR TAGS SEM NOTAS (limpeza)
  /// 
  /// Remove tags que não estão sendo usadas em nenhuma nota.
  /// 
  /// **Retorna:** Número de tags deletadas
  /// 
  /// **Uso:**
  /// ```dart
  /// final deleted = await tagsDao.deleteUnusedTags();
  /// print('$deleted tags não usadas foram removidas');
  /// ```
  Future<int> deleteUnusedTags() async {
    final allTags = await getAllTags();
    final tagsToDelete = <String>[];

    for (final tag in allTags) {
      final noteCount = await countNotesWithTag(tag.id);
      if (noteCount == 0) {
        tagsToDelete.add(tag.id);
      }
    }

    if (tagsToDelete.isEmpty) return 0;

    return await deleteTags(tagsToDelete);
  }
}
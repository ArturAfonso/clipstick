import 'package:drift/drift.dart';
import 'package:clipstick/core/database/database.dart';
import 'package:clipstick/data/database/tables/notes_table.dart';
import 'package:clipstick/data/database/tables/note_tags_table.dart';
import 'package:clipstick/data/database/tables/tags_table.dart';

// 🤖 Este arquivo será gerado pelo build_runner
part 'notes_dao.g.dart';

/// 📝 DATA ACCESS OBJECT PARA NOTAS
/// 
/// Centraliza todas as operações CRUD e queries relacionadas a notas.
/// 
/// **Operações disponíveis:**
/// - CRUD básico (Create, Read, Update, Delete)
/// - Buscar notas fixadas/não fixadas
/// - Buscar notas por tag
/// - Buscar texto (search)
/// - Atualizar posições em lote
/// - Streams reativos (watch)
@DriftAccessor(tables: [Notes, NoteTags, Tags])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  
  /// ✅ CONSTRUTOR
  /// 
  /// Recebe a instância do banco de dados.
  NotesDao(super.db);

  // ═══════════════════════════════════════════════════════════════
  // 📋 OPERAÇÕES BÁSICAS (CRUD)
  // ═══════════════════════════════════════════════════════════════

  /// ✅ BUSCAR TODAS AS NOTAS (ordenadas por position)
  /// 
  /// **Retorna:** Lista de NoteEntity ordenada por position ASC
  /// 
  /// **Uso:**
  /// ```dart
  /// final allNotes = await notesDao.getAllNotes();
  /// print('Total: ${allNotes.length} notas');
  /// ```
  Future<List<NoteEntity>> getAllNotes() {
    return (select(notes)
      ..orderBy([
        (n) => OrderingTerm.asc(n.position),
      ]))
    .get();
  }


  

  /// 📺 WATCH: Observar TODAS as notas (Stream reativo)
  /// 
  /// **Retorna:** Stream que emite nova lista quando banco muda
  /// 
  /// **Uso com StreamBuilder:**
  /// ```dart
  /// StreamBuilder<List<NoteEntity>>(
  ///   stream: notesDao.watchAllNotes(),
  ///   builder: (context, snapshot) {
  ///     if (!snapshot.hasData) return CircularProgressIndicator();
  ///     return ListView(children: snapshot.data!.map(...).toList());
  ///   },
  /// )
  /// ```
  Stream<List<NoteEntity>> watchAllNotes() {
    return (select(notes)
      ..orderBy([
        (n) => OrderingTerm.asc(n.position),
      ]))
    .watch();
  }

  /// 🔍 BUSCAR NOTA POR ID
  /// 
  /// **Retorna:** NoteEntity ou null se não encontrar
  /// 
  /// **Uso:**
  /// ```dart
  /// final note = await notesDao.getNoteById('550e8400-...');
  /// if (note != null) {
  ///   print('Encontrou: ${note.title}');
  /// }
  /// ```
  Future<NoteEntity?> getNoteById(String id) {
    return (select(notes)
      ..where((n) => n.id.equals(id)))
    .getSingleOrNull();
  }

  /// ➕ INSERIR OU ATUALIZAR NOTA
  /// 
  /// Se ID já existe → atualiza
  /// Se ID não existe → insere
  /// 
  /// **Uso:**
  /// ```dart
  /// await notesDao.upsertNote(NotesCompanion(
  ///   id: Value('abc123'),
  ///   title: Value('Minha Nota'),
  ///   content: Value('Conteúdo aqui'),
  ///   color: Value(Color(0xFFFF5733)),
  ///   position: Value(0),
  ///   isPinned: Value(false),
  ///   createdAt: Value(DateTime.now()),
  ///   updatedAt: Value(DateTime.now()),
  /// ));
  /// ```
  Future<void> upsertNote(NotesCompanion note) {
    return into(notes).insertOnConflictUpdate(note);
  }

  /// ✏️ ATUALIZAR NOTA EXISTENTE
  /// 
  /// **Retorna:** true se atualizou, false se nota não existe
  /// 
  /// **Uso:**
  /// ```dart
  /// final updated = await notesDao.updateNote(NotesCompanion(
  ///   id: Value('abc123'),
  ///   title: Value('Título Atualizado'),
  ///   updatedAt: Value(DateTime.now()),
  /// ));
  /// ```
  Future<bool> updateNote(NotesCompanion note) {
    return update(notes).replace(note);
  }


/// 🔄 ATUALIZAR VÁRIAS NOTAS EM LOTE (todos os campos principais)
Future<void> updateNotesBatch(List<NoteEntity> notesToUpdate) async {
  await batch((batch) {
    for (final note in notesToUpdate) {
      batch.update(
        notes,
        NotesCompanion(
          title: Value(note.title),
          content: Value(note.content),
          color: Value(note.color),
          position: Value(note.position),
          isPinned: Value(note.isPinned),
          updatedAt: Value(DateTime.now()),
        ),
        where: (n) => n.id.equals(note.id),
      );
    }
  });
}


  /// 🗑️ DELETAR NOTA POR ID
  /// 
  /// **CASCADE:** Remove automaticamente relacionamentos em NoteTags
  /// 
  /// **Retorna:** Número de linhas deletadas (1 se sucesso, 0 se não existe)
  /// 
  /// **Uso:**
  /// ```dart
  /// final deleted = await notesDao.deleteNote('abc123');
  /// if (deleted > 0) {
  ///   print('Nota deletada com sucesso!');
  /// }
  /// ```
  Future<int> deleteNote(String id) {
    return (delete(notes)
      ..where((n) => n.id.equals(id)))
    .go();
  }

  /// 🗑️ DELETAR MÚLTIPLAS NOTAS
  /// 
  /// **Uso:**
  /// ```dart
  /// await notesDao.deleteNotes(['id1', 'id2', 'id3']);
  /// ```
  Future<int> deleteNotes(List<String> ids) {
    return (delete(notes)
      ..where((n) => n.id.isIn(ids)))
    .go();
  }

  // ═══════════════════════════════════════════════════════════════
  // 📌 OPERAÇÕES COM NOTAS FIXADAS
  // ═══════════════════════════════════════════════════════════════

  /// 📌 BUSCAR NOTAS FIXADAS (ordenadas por position)
  /// 
  /// **Uso:**
  /// ```dart
  /// final pinnedNotes = await notesDao.getPinnedNotes();
  /// ```
  Future<List<NoteEntity>> getPinnedNotes() {
    return (select(notes)
      ..where((n) => n.isPinned.equals(true))
      ..orderBy([
        (n) => OrderingTerm.asc(n.position),
      ]))
    .get();
  }

  /// 📋 BUSCAR NOTAS NÃO FIXADAS (ordenadas por position)
  /// 
  /// **Uso:**
  /// ```dart
  /// final otherNotes = await notesDao.getUnpinnedNotes();
  /// ```
  Future<List<NoteEntity>> getUnpinnedNotes() {
    return (select(notes)
      ..where((n) => n.isPinned.equals(false))
      ..orderBy([
        (n) => OrderingTerm.asc(n.position),
      ]))
    .get();
  }

  /// 📺 WATCH: Observar notas fixadas
  Stream<List<NoteEntity>> watchPinnedNotes() {
    return (select(notes)
      ..where((n) => n.isPinned.equals(true))
      ..orderBy([
        (n) => OrderingTerm.asc(n.position),
      ]))
    .watch();
  }

  /// 📺 WATCH: Observar notas não fixadas
  Stream<List<NoteEntity>> watchUnpinnedNotes() {
    return (select(notes)
      ..where((n) => n.isPinned.equals(false))
      ..orderBy([
        (n) => OrderingTerm.asc(n.position),
      ]))
    .watch();
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔢 OPERAÇÕES COM POSIÇÕES (para drag & drop)
  // ═══════════════════════════════════════════════════════════════

  /// 🔄 ATUALIZAR POSIÇÕES EM LOTE
  /// 
  /// Usado após reordenação (drag & drop).
  /// 
  /// **Uso:**
  /// ```dart
  /// await notesDao.updatePositions([
  ///   NoteEntity(..., position: 0),
  ///   NoteEntity(..., position: 1),
  ///   NoteEntity(..., position: 2),
  /// ]);
  /// ```
  Future<void> updatePositions(List<NoteEntity> notesWithNewPositions) async {
    await batch((batch) {
      for (final note in notesWithNewPositions) {
        batch.update(
          notes,
          NotesCompanion(
            position: Value(note.position),
            updatedAt: Value(DateTime.now()),
          ),
          where: (n) => n.id.equals(note.id),
        );
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // 🏷️ OPERAÇÕES COM TAGS
  // ═══════════════════════════════════════════════════════════════

  /// 🏷️ BUSCAR NOTAS COM TAG ESPECÍFICA
  /// 
  /// **Join:** notes INNER JOIN note_tags ON notes.id = note_tags.note_id
  /// 
  /// **Uso:**
  /// ```dart
  /// final workNotes = await notesDao.getNotesWithTag('tag-trabalho');
  /// ```
  Future<List<NoteEntity>> getNotesWithTag(String tagId) {
    final query = select(notes).join([
      innerJoin(
        noteTags,
        noteTags.noteId.equalsExp(notes.id),
      ),
    ])
    ..where(noteTags.tagId.equals(tagId))
    ..orderBy([OrderingTerm.asc(notes.position)]);

    return query.map((row) => row.readTable(notes)).get();
  }

  /// 📺 WATCH: Observar notas com tag específica
  Stream<List<NoteEntity>> watchNotesWithTag(String tagId) {
    final query = select(notes).join([
      innerJoin(
        noteTags,
        noteTags.noteId.equalsExp(notes.id),
      ),
    ])
    ..where(noteTags.tagId.equals(tagId))
    ..orderBy([OrderingTerm.asc(notes.position)]);

    return query.map((row) => row.readTable(notes)).watch();
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔍 BUSCA (SEARCH)
  // ═══════════════════════════════════════════════════════════════

  /// 🔍 BUSCAR NOTAS POR TEXTO (título ou conteúdo)
  /// 
  /// Busca case-insensitive em título e conteúdo.
  /// 
  /// **Uso:**
  /// ```dart
  /// final results = await notesDao.searchNotes('reunião');
  /// ```
  Future<List<NoteEntity>> searchNotes(String query) {
    final lowerQuery = query.toLowerCase();
    
    return (select(notes)
      ..where((n) =>
          n.title.lower().contains(lowerQuery) |
          n.content.lower().contains(lowerQuery))
      ..orderBy([
        (n) => OrderingTerm.desc(n.updatedAt), // Mais recentes primeiro
      ]))
    .get();
  }

  /// 📺 WATCH: Observar resultados de busca
  Stream<List<NoteEntity>> watchSearchNotes(String query) {
    final lowerQuery = query.toLowerCase();
    
    return (select(notes)
      ..where((n) =>
          n.title.lower().contains(lowerQuery) |
          n.content.lower().contains(lowerQuery))
      ..orderBy([
        (n) => OrderingTerm.desc(n.updatedAt),
      ]))
    .watch();
  }

  // ═══════════════════════════════════════════════════════════════
  // 📊 ESTATÍSTICAS E CONTADORES
  // ═══════════════════════════════════════════════════════════════

  /// 🔢 CONTAR TOTAL DE NOTAS
  Future<int> countAllNotes() async {
    final count = countAll();
    final query = selectOnly(notes)..addColumns([count]);
    return await query.map((row) => row.read(count)!).getSingle();
  }

  /// 📌 CONTAR NOTAS FIXADAS
  Future<int> countPinnedNotes() async {
    final count = countAll();
    final query = selectOnly(notes)
      ..addColumns([count])
      ..where(notes.isPinned.equals(true));
    return await query.map((row) => row.read(count)!).getSingle();
  }

  /// 📋 CONTAR NOTAS NÃO FIXADAS
  Future<int> countUnpinnedNotes() async {
    final count = countAll();
    final query = selectOnly(notes)
      ..addColumns([count])
      ..where(notes.isPinned.equals(false));
    return await query.map((row) => row.read(count)!).getSingle();
  }

  Future<void> insertNotesBatch(List<NoteEntity> notesToInsert) async {
  await batch((batch) {
    for (final note in notesToInsert) {
      batch.insert(
        notes,
        NotesCompanion.insert(
          id: note.id,
          title: note.title as Value<String>,
          content: note.content,
          color: note.color,
          position: note.position,
          isPinned: note.isPinned as Value<bool>,
          createdAt: note.createdAt ?? DateTime.now(),
          updatedAt: note.updatedAt ?? DateTime.now(),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  });
}
}
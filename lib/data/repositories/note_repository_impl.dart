import 'package:clipstick/core/database/database.dart';
import 'package:clipstick/data/models/note_model.dart';
import 'package:clipstick/data/repositories/note_repository.dart';
import 'package:drift/drift.dart';

/// 📝 IMPLEMENTAÇÃO DO REPOSITÓRIO DE NOTAS (USANDO DRIFT)
/// 
/// Conecta a camada de domínio (NoteModel) com a camada de dados (Drift).
/// 
/// **Responsabilidades:**
/// - Converter NoteEntity (Drift) ↔ NoteModel (UI)
/// - Delegar operações para NotesDao
/// - Gerenciar tags das notas
class NoteRepositoryImpl implements NoteRepository {
  final AppDatabase _database;

  NoteRepositoryImpl(this._database);

  // ═══════════════════════════════════════════════════════════════
  // 🔄 CONVERSORES (Entity ↔ Model)
  // ═══════════════════════════════════════════════════════════════

  /// 🔄 CONVERTE NoteEntity (Drift) → NoteModel (UI)
  Future<NoteModel> _entityToModel(NoteEntity entity) async {
    // Buscar tags da nota
    final tagEntities = await _database.tagsDao.getTagsForNote(entity.id);
    final tagIds = tagEntities.map((t) => t.id).toList();

    return NoteModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      color: entity.color,
      position: entity.position,
      isPinned: entity.isPinned,
      tags: tagIds.isEmpty ? null : tagIds,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// 🔄 CONVERTE NoteModel (UI) → NotesCompanion (Drift)
  NotesCompanion _modelToCompanion(NoteModel model) {
    return NotesCompanion(
      id: Value(model.id),
      title: Value(model.title),
      content: Value(model.content),
      color: Value(model.color),
      position: Value(model.position),
      isPinned: Value(model.isPinned),
      createdAt: Value(model.createdAt ?? DateTime.now()),
      updatedAt: Value(model.updatedAt ?? DateTime.now()),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 📋 OPERAÇÕES BÁSICAS (CRUD)
  // ═══════════════════════════════════════════════════════════════

  @override
  Future<List<NoteModel>> getAllNotes() async {
    final entities = await _database.notesDao.getAllNotes();
    return Future.wait(entities.map(_entityToModel));
  }

  @override
  Stream<List<NoteModel>> watchAllNotes() {
    return _database.notesDao.watchAllNotes().asyncMap((entities) async {
      return Future.wait(entities.map(_entityToModel));
    });
  }

  @override
  Future<NoteModel?> getNoteById(String id) async {
    final entity = await _database.notesDao.getNoteById(id);
    if (entity == null) return null;
    return _entityToModel(entity);
  }

  @override
  Future<void> createNote(NoteModel note) async {
    // 1. Inserir nota
    await _database.notesDao.upsertNote(_modelToCompanion(note));

    // 2. Adicionar tags (se houver)
    if (note.tags != null && note.tags!.isNotEmpty) {
      await _database.tagsDao.setTagsForNote(
        noteId: note.id,
        tagIds: note.tags!,
      );
    }
  }

  @override
Future<void> addNotesBatch(List<NoteModel> notes) async {
  final entities = notes.map((model) => NoteEntity(
    id: model.id,
    title: model.title,
    content: model.content,
    color: model.color,
    position: model.position,
    isPinned: model.isPinned,
    createdAt: model.createdAt ?? DateTime.now(),
    updatedAt: model.updatedAt ?? DateTime.now(),
  )).toList();

  await _database.notesDao.insertNotesBatch(entities);
}

  @override
  Future<void> updateNote(NoteModel note) async {
    // 1. Atualizar nota
    await _database.notesDao.upsertNote(_modelToCompanion(note));

    // 2. Atualizar tags
    await _database.tagsDao.setTagsForNote(
      noteId: note.id,
      tagIds: note.tags ?? [],
    );
  }


//atualziar varias notas de uma bvez
@override
Future<void> updateNotesBatch(List<NoteModel> notes) async {
  // Atualiza os campos principais das notas
  final entities = notes.map((model) => NoteEntity(
    id: model.id,
    title: model.title,
    content: model.content,
    color: model.color,
    position: model.position,
    isPinned: model.isPinned,
    createdAt: model.createdAt ?? DateTime.now(),
    updatedAt: DateTime.now(),
  )).toList();

  await _database.notesDao.updateNotesBatch(entities);

  // Atualiza as tags de cada nota
  for (final note in notes) {
    await _database.tagsDao.setTagsForNote(
      noteId: note.id,
      tagIds: note.tags ?? [],
    );
  }
}

  @override
  Future<void> deleteNote(String id) async {
    await _database.notesDao.deleteNote(id);
  }

  @override
  Future<void> deleteNotes(List<String> ids) async {
    await _database.notesDao.deleteNotes(ids);
  }

  // ═══════════════════════════════════════════════════════════════
  // 📌 OPERAÇÕES COM NOTAS FIXADAS
  // ═══════════════════════════════════════════════════════════════

  @override
  Future<List<NoteModel>> getPinnedNotes() async {
    final entities = await _database.notesDao.getPinnedNotes();
    return Future.wait(entities.map(_entityToModel));
  }

  @override
  Future<List<NoteModel>> getUnpinnedNotes() async {
    final entities = await _database.notesDao.getUnpinnedNotes();
    return Future.wait(entities.map(_entityToModel));
  }

  @override
  Stream<List<NoteModel>> watchPinnedNotes() {
    return _database.notesDao.watchPinnedNotes().asyncMap((entities) async {
      return Future.wait(entities.map(_entityToModel));
    });
  }

  @override
  Stream<List<NoteModel>> watchUnpinnedNotes() {
    return _database.notesDao.watchUnpinnedNotes().asyncMap((entities) async {
      return Future.wait(entities.map(_entityToModel));
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔢 OPERAÇÕES COM POSIÇÕES
  // ═══════════════════════════════════════════════════════════════


   @override
 Future<void> updateNotesPositions (List<NoteModel> notes) async {
  final entities = notes.map((model) => NoteEntity(
    id: model.id,
    title: model.title,
    content: model.content,
    color: model.color,
    position: model.position,
    isPinned: model.isPinned,
    createdAt: model.createdAt ?? DateTime.now(),
    updatedAt: DateTime.now(),
  )).toList();

  await _database.notesDao.updatePositions(entities);
}


  // ═══════════════════════════════════════════════════════════════
  // 🏷️ OPERAÇÕES COM TAGS
  // ═══════════════════════════════════════════════════════════════

  @override
  Future<List<NoteModel>> getNotesWithTag(String tagId) async {
    final entities = await _database.notesDao.getNotesWithTag(tagId);
    return Future.wait(entities.map(_entityToModel));
  }

  @override
  Stream<List<NoteModel>> watchNotesWithTag(String tagId) {
    return _database.notesDao.watchNotesWithTag(tagId).asyncMap((entities) async {
      return Future.wait(entities.map(_entityToModel));
    });
  }

  @override
  Future<void> addTagToNote({required String noteId, required String tagId}) async {
    await _database.tagsDao.addTagToNote(noteId: noteId, tagId: tagId);
  }

  @override
  Future<void> removeTagFromNote({required String noteId, required String tagId}) async {
    await _database.tagsDao.removeTagFromNote(noteId: noteId, tagId: tagId);
  }

  @override
  Future<void> setTagsForNote({required String noteId, required List<String> tagIds}) async {
    await _database.tagsDao.setTagsForNote(noteId: noteId, tagIds: tagIds);
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔍 BUSCA
  // ═══════════════════════════════════════════════════════════════

  @override
  Future<List<NoteModel>> searchNotes(String query) async {
    final entities = await _database.notesDao.searchNotes(query);
    return Future.wait(entities.map(_entityToModel));
  }

  @override
  Stream<List<NoteModel>> watchSearchNotes(String query) {
    return _database.notesDao.watchSearchNotes(query).asyncMap((entities) async {
      return Future.wait(entities.map(_entityToModel));
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // 📊 ESTATÍSTICAS
  // ═══════════════════════════════════════════════════════════════

  @override
  Future<int> countAllNotes() => _database.notesDao.countAllNotes();

  @override
  Future<int> countPinnedNotes() => _database.notesDao.countPinnedNotes();

  @override
  Future<int> countUnpinnedNotes() => _database.notesDao.countUnpinnedNotes();
}
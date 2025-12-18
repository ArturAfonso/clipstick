import 'package:drift/drift.dart';
import 'package:clipstick/core/database/database.dart';
import 'package:clipstick/data/database/tables/notes_table.dart';
import 'package:clipstick/data/database/tables/note_tags_table.dart';
import 'package:clipstick/data/database/tables/tags_table.dart';


part 'notes_dao.g.dart';












@DriftAccessor(tables: [Notes, NoteTags, Tags])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  
   NotesDao(super.db);

   Future<List<NoteEntity>> getAllNotes() {
    return (select(notes)
      ..orderBy([
        (n) => OrderingTerm.asc(n.position),
      ]))
    .get();
  }


  
  Stream<List<NoteEntity>> watchAllNotes() {
    return (select(notes)
      ..orderBy([
        (n) => OrderingTerm.asc(n.position),
      ]))
    .watch();
  }

  
  Future<NoteEntity?> getNoteById(String id) {
    return (select(notes)
      ..where((n) => n.id.equals(id)))
    .getSingleOrNull();
  }

  
  Future<void> upsertNote(NotesCompanion note) {
    return into(notes).insertOnConflictUpdate(note);
  }

  
  Future<bool> updateNote(NotesCompanion note) {
    return update(notes).replace(note);
  }



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
  Future<int> deleteNote(String id) {
    return (delete(notes)
      ..where((n) => n.id.equals(id)))
    .go();
  }  
  Future<int> deleteNotes(List<String> ids) {
    return (delete(notes)
      ..where((n) => n.id.isIn(ids)))
    .go();
  }
 
  Future<List<NoteEntity>> getPinnedNotes() {
    return (select(notes)
      ..where((n) => n.isPinned.equals(true))
      ..orderBy([
        (n) => OrderingTerm.asc(n.position),
      ]))
    .get();
  }

  Future<List<NoteEntity>> getUnpinnedNotes() {
    return (select(notes)
      ..where((n) => n.isPinned.equals(false))
      ..orderBy([
        (n) => OrderingTerm.asc(n.position),
      ]))
    .get();
  }

  Stream<List<NoteEntity>> watchPinnedNotes() {
    return (select(notes)
      ..where((n) => n.isPinned.equals(true))
      ..orderBy([
        (n) => OrderingTerm.asc(n.position),
      ]))
    .watch();
  }

  
  Stream<List<NoteEntity>> watchUnpinnedNotes() {
    return (select(notes)
      ..where((n) => n.isPinned.equals(false))
      ..orderBy([
        (n) => OrderingTerm.asc(n.position),
      ]))
    .watch();
  }
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

  Future<List<NoteEntity>> searchNotes(String query) {
    final lowerQuery = query.toLowerCase();
    
    return (select(notes)
      ..where((n) =>
          n.title.lower().contains(lowerQuery) |
          n.content.lower().contains(lowerQuery))
      ..orderBy([
        (n) => OrderingTerm.desc(n.updatedAt), 
      ]))
    .get();
  }

  
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

  
   Future<int> countAllNotes() async {
    final count = countAll();
    final query = selectOnly(notes)..addColumns([count]);
    return await query.map((row) => row.read(count)!).getSingle();
  }

  
  Future<int> countPinnedNotes() async {
    final count = countAll();
    final query = selectOnly(notes)
      ..addColumns([count])
      ..where(notes.isPinned.equals(true));
    return await query.map((row) => row.read(count)!).getSingle();
  }

  
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
          title:  Value(note.title),
          content: note.content,
          color: note.color,
          position: note.position,
          isPinned: Value(note.isPinned),
          createdAt: note.createdAt ,
          updatedAt: note.updatedAt ,
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  });
}
}
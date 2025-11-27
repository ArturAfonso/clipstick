import 'package:drift/drift.dart';
import 'package:clipstick/core/database/database.dart';
import 'package:clipstick/data/database/tables/tags_table.dart';
import 'package:clipstick/data/database/tables/note_tags_table.dart';
import 'package:clipstick/data/database/tables/notes_table.dart';


part 'tags_dao.g.dart';


@DriftAccessor(tables: [Tags, NoteTags, Notes])
class TagsDao extends DatabaseAccessor<AppDatabase> with _$TagsDaoMixin {
   TagsDao(super.db);

   Future<List<TagEntity>> getAllTags() {
    return (select(tags)
      ..orderBy([
        (t) => OrderingTerm.asc(t.name),
      ]))
    .get();
  }

  Stream<List<TagEntity>> watchAllTags() {
    return (select(tags)
      ..orderBy([
        (t) => OrderingTerm.asc(t.name),
      ]))
    .watch();
  }

 Future<TagEntity?> getTagById(String id) {
    return (select(tags)
      ..where((t) => t.id.equals(id)))
    .getSingleOrNull();
  }

  Future<TagEntity?> getTagByName(String name) {
    return (select(tags)
      ..where((t) => t.name.lower().equals(name.toLowerCase())))
    .getSingleOrNull();
  }

 
Future<String> insertTag(TagsCompanion tag) async {
  await into(tags).insert(tag);
  
  return tag.id.value;
}

  Future<void> upsertTag(TagsCompanion tag) {
    return into(tags).insertOnConflictUpdate(tag);
  }
 
  Future<bool> updateTag(TagsCompanion tag) {
    return update(tags).replace(tag);
  }

   
  Future<int> deleteTag(String id) {
    return (delete(tags)
      ..where((t) => t.id.equals(id)))
    .go();
  }

  Future<int> deleteTags(List<String> ids) {
    return (delete(tags)
      ..where((t) => t.id.isIn(ids)))
    .go();
  }

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


 Future<void> addTagToNote({
    required String noteId,
    required String tagId,
  }) {
    return into(noteTags).insert(
      NoteTagsCompanion(
        noteId: Value(noteId),
        tagId: Value(tagId),
      ),
      mode: InsertMode.insertOrIgnore, 
    );
  }


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

   Future<int> removeAllTagsFromNote(String noteId) {
    return (delete(noteTags)
      ..where((nt) => nt.noteId.equals(noteId)))
    .go();
  }

  
  
  Future<void> setTagsForNote({
    required String noteId,
    required List<String> tagIds,
  }) async {
    await transaction(() async {
      
      await removeAllTagsFromNote(noteId);

      
      if (tagIds.isNotEmpty) {
         final validTags = await (select(tags)
          ..where((t) => t.id.isIn(tagIds))
        ).get();
        
        
        final existingTagIds = validTags.map((t) => t.id).toSet();

        await batch((batch) {
          for (final tagId in tagIds) {
            
            if (existingTagIds.contains(tagId)) {
              batch.insert(
                noteTags,
                NoteTagsCompanion(
                  noteId: Value(noteId),
                  tagId: Value(tagId),
                ),
                mode: InsertMode.insertOrIgnore,
              );
            }
          }
        });
      }
    });
  }

   Future<int> countAllTags() async {
    final count = countAll();
    final query = selectOnly(tags)..addColumns([count]);
    return await query.map((row) => row.read(count)!).getSingle();
  }
 Future<int> countNotesWithTag(String tagId) async {
    final count = countAll();
    final query = selectOnly(noteTags)
      ..addColumns([count])
      ..where(noteTags.tagId.equals(tagId));
    return await query.map((row) => row.read(count)!).getSingle();
  }

  Future<Map<TagEntity, int>> getTagsWithNoteCounts() async {
    final result = <TagEntity, int>{};
    final allTags = await getAllTags();

    for (final tag in allTags) {
      final noteCount = await countNotesWithTag(tag.id);
      result[tag] = noteCount;
    }

    return result;
  }

  
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
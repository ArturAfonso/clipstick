import 'package:drift/drift.dart';
import 'package:clipstick/data/database/tables/notes_table.dart';
import 'package:clipstick/data/database/tables/tags_table.dart';


@DataClassName('NoteTagRelation')
class NoteTags extends Table {
   
  TextColumn get noteId => text()
    .references(Notes, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId => text()
    .references(Tags, #id, onDelete: KeyAction.cascade)();
  
  @override
  Set<Column> get primaryKey => {noteId, tagId};
  
}
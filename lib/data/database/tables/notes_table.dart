import 'package:drift/drift.dart';
import '../converters/color_converter.dart';

@DataClassName('NoteEntity')
class Notes extends Table {

  TextColumn get id => text()();

  TextColumn get title => text().withDefault(const Constant(''))();

  TextColumn get content => text()();

  IntColumn get color => integer().map(const ColorConverter())();

  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();

  IntColumn get position => integer()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

}
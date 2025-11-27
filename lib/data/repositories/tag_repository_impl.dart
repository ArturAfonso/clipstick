import 'package:clipstick/core/database/database.dart';
import 'package:clipstick/data/models/tag_model.dart';
import 'package:clipstick/data/repositories/tag_repository.dart';
import 'package:drift/drift.dart';

class TagRepositoryImpl implements TagRepository {
  final AppDatabase _database;

  TagRepositoryImpl(this._database);

  
  TagModel _entityToModel(TagEntity entity) {
    return TagModel(
      id: entity.id,
      name: entity.name,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  
  TagsCompanion _modelToCompanion(TagModel model) {
    return TagsCompanion(
      id: Value(model.id),
      name: Value(model.name),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  @override
  Future<List<TagModel>> getAllTags() async {
    final entities = await _database.tagsDao.getAllTags();
    return entities.map(_entityToModel).toList();
  }

  @override
  Stream<List<TagModel>> watchAllTags() {
    return _database.tagsDao.watchAllTags().map((entities) {
      return entities.map(_entityToModel).toList();
    });
  }

  @override
  Future<TagModel?> getTagById(String id) async {
    final entity = await _database.tagsDao.getTagById(id);
    if (entity == null) return null;
    return _entityToModel(entity);
  }

  @override
  Future<TagModel?> getTagByName(String name) async {
    final entity = await _database.tagsDao.getTagByName(name);
    if (entity == null) return null;
    return _entityToModel(entity);
  }

  @override
  Future<String> createTag(TagModel tag) async {
    return await _database.tagsDao.insertTag(_modelToCompanion(tag));
  }

  @override
  Future<void> updateTag(TagModel tag) async {
    await _database.tagsDao.upsertTag(_modelToCompanion(tag));
  }

  @override
  Future<void> deleteTag(String id) async {
    await _database.tagsDao.deleteTag(id);
  }

  @override
  Future<void> deleteTags(List<String> ids) async {
    await _database.tagsDao.deleteTags(ids);
  }

  
  
  

  @override
  Future<List<TagModel>> getTagsForNote(String noteId) async {
    final entities = await _database.tagsDao.getTagsForNote(noteId);
    return entities.map(_entityToModel).toList();
  }

  @override
  Stream<List<TagModel>> watchTagsForNote(String noteId) {
    return _database.tagsDao.watchTagsForNote(noteId).map((entities) {
      return entities.map(_entityToModel).toList();
    });
  }

  @override
  Future<int> countAllTags() => _database.tagsDao.countAllTags();

  @override
  Future<int> countNotesWithTag(String tagId) {
    return _database.tagsDao.countNotesWithTag(tagId);
  }

  @override
  Future<Map<TagModel, int>> getTagsWithNoteCounts() async {
    final entityMap = await _database.tagsDao.getTagsWithNoteCounts();
    
    
    final modelMap = <TagModel, int>{};
    entityMap.forEach((entity, count) {
      modelMap[_entityToModel(entity)] = count;
    });
    
    return modelMap;
  }

  @override
  Future<int> deleteUnusedTags() => _database.tagsDao.deleteUnusedTags();
}
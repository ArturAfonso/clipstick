import 'package:clipstick/data/models/tag_model.dart';



abstract class TagRepository {
  
  Future<List<TagModel>> getAllTags();

  
  Stream<List<TagModel>> watchAllTags();

  
  Future<TagModel?> getTagById(String id);

  
  Future<TagModel?> getTagByName(String name);

  
  Future<String> createTag(TagModel tag);

  
  Future<void> updateTag(TagModel tag);

  
  Future<void> deleteTag(String id);

  
  Future<void> deleteTags(List<String> ids);

  
  
  

  
  Future<List<TagModel>> getTagsForNote(String noteId);

  
  Stream<List<TagModel>> watchTagsForNote(String noteId);

  
  
  

  
  Future<int> countAllTags();

  
  Future<int> countNotesWithTag(String tagId);

  
  Future<Map<TagModel, int>> getTagsWithNoteCounts();

  
  Future<int> deleteUnusedTags();
}
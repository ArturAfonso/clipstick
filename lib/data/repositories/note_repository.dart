import 'package:clipstick/data/models/note_model.dart';


abstract class NoteRepository {
    Future<List<NoteModel>> getAllNotes();
  Stream<List<NoteModel>> watchAllNotes();
  Future<NoteModel?> getNoteById(String id);
  Future<void> createNote(NoteModel note);
   Future<void> addNotesBatch(List<NoteModel> notes);
  Future<void> updateNote(NoteModel note);
  
Future<void> updateNotesBatch(List<NoteModel> notes);
 
  Future<void> deleteNote(String id);
  
  Future<void> deleteNotes(List<String> ids);
  Future<List<NoteModel>> getPinnedNotes();
 Future<List<NoteModel>> getUnpinnedNotes();
 Stream<List<NoteModel>> watchPinnedNotes();
 Stream<List<NoteModel>> watchUnpinnedNotes();
 
Future<void> updateNotesPositions(List<NoteModel> notes);
      
  Future<List<NoteModel>> getNotesWithTag(String tagId);
  
  Stream<List<NoteModel>> watchNotesWithTag(String tagId);
  Future<void> addTagToNote({required String noteId, required String tagId});
  Future<void> removeTagFromNote({required String noteId, required String tagId});
  
  Future<void> setTagsForNote({required String noteId, required List<String> tagIds});
  Future<List<NoteModel>> searchNotes(String query);

  
  Stream<List<NoteModel>> watchSearchNotes(String query);
  Future<int> countAllNotes();
 Future<int> countPinnedNotes();

  Future<int> countUnpinnedNotes();
}
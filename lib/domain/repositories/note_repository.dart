import '../entities/note.dart';

abstract class NoteRepository {
  /// Busca todas as notas salvas localmente
  Future<List<Note>> getAllNotes();

  /// Salva uma nova nota ou atualiza uma existente
  Future<void> saveNote(Note note);

  /// Remove uma nota pelo ID
  Future<void> deleteNote(String id);

  /// Busca uma nota específica pelo ID
  Future<Note?> getNoteById(String id);

  /// Busca notas por título ou conteúdo
  Future<List<Note>> searchNotes(String query);
}

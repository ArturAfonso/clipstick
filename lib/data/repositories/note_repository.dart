import 'package:clipstick/data/models/note_model.dart';

/// 📝 CONTRATO (INTERFACE) PARA REPOSITÓRIO DE NOTAS
/// 
/// Define todas as operações que devem ser implementadas
/// para manipular notas, independente da fonte de dados.
/// 
/// **Por que usar interface?**
/// - ✅ Facilita testes (mock)
/// - ✅ Permite trocar implementação (SQLite → Firebase → API)
/// - ✅ Segue princípio de Inversão de Dependência (SOLID)
/// 
/// **Implementações:**
/// - NoteRepositoryImpl (usa Drift/SQLite)
/// - NoteRepositoryMock (para testes)
/// - NoteRepositoryFirebase (futuro)
abstract class NoteRepository {
  
  // ═══════════════════════════════════════════════════════════════
  // 📋 OPERAÇÕES BÁSICAS (CRUD)
  // ═══════════════════════════════════════════════════════════════

  /// ✅ BUSCAR TODAS AS NOTAS (ordenadas por position)
  Future<List<NoteModel>> getAllNotes();

  /// 📺 WATCH: Stream de todas as notas
  Stream<List<NoteModel>> watchAllNotes();

  /// 🔍 BUSCAR NOTA POR ID
  Future<NoteModel?> getNoteById(String id);

  /// ➕ CRIAR NOVA NOTA
  Future<void> createNote(NoteModel note);

  /// ✏️ ATUALIZAR NOTA EXISTENTE
  Future<void> updateNote(NoteModel note);

  /// 🗑️ DELETAR NOTA
  Future<void> deleteNote(String id);

  /// 🗑️ DELETAR MÚLTIPLAS NOTAS
  Future<void> deleteNotes(List<String> ids);

  // ═══════════════════════════════════════════════════════════════
  // 📌 OPERAÇÕES COM NOTAS FIXADAS
  // ═══════════════════════════════════════════════════════════════

  /// 📌 BUSCAR NOTAS FIXADAS
  Future<List<NoteModel>> getPinnedNotes();

  /// 📋 BUSCAR NOTAS NÃO FIXADAS
  Future<List<NoteModel>> getUnpinnedNotes();

  /// 📺 WATCH: Stream de notas fixadas
  Stream<List<NoteModel>> watchPinnedNotes();

  /// 📺 WATCH: Stream de notas não fixadas
  Stream<List<NoteModel>> watchUnpinnedNotes();

  // ═══════════════════════════════════════════════════════════════
  // 🔢 OPERAÇÕES COM POSIÇÕES (drag & drop)
  // ═══════════════════════════════════════════════════════════════

  /// 🔄 ATUALIZAR POSIÇÕES EM LOTE
  Future<void> updatePositions(List<NoteModel> notes);

  // ═══════════════════════════════════════════════════════════════
  // 🏷️ OPERAÇÕES COM TAGS
  // ═══════════════════════════════════════════════════════════════

  /// 🏷️ BUSCAR NOTAS COM TAG ESPECÍFICA
  Future<List<NoteModel>> getNotesWithTag(String tagId);

  /// 📺 WATCH: Stream de notas com tag específica
  Stream<List<NoteModel>> watchNotesWithTag(String tagId);

  /// ➕ ADICIONAR TAG A NOTA
  Future<void> addTagToNote({required String noteId, required String tagId});

  /// ➖ REMOVER TAG DE NOTA
  Future<void> removeTagFromNote({required String noteId, required String tagId});

  /// 🔄 SUBSTITUIR TAGS DE NOTA
  Future<void> setTagsForNote({required String noteId, required List<String> tagIds});

  // ═══════════════════════════════════════════════════════════════
  // 🔍 BUSCA (SEARCH)
  // ═══════════════════════════════════════════════════════════════

  /// 🔍 BUSCAR NOTAS POR TEXTO
  Future<List<NoteModel>> searchNotes(String query);

  /// 📺 WATCH: Stream de busca
  Stream<List<NoteModel>> watchSearchNotes(String query);

  // ═══════════════════════════════════════════════════════════════
  // 📊 ESTATÍSTICAS
  // ═══════════════════════════════════════════════════════════════

  /// 🔢 CONTAR TOTAL DE NOTAS
  Future<int> countAllNotes();

  /// 📌 CONTAR NOTAS FIXADAS
  Future<int> countPinnedNotes();

  /// 📋 CONTAR NOTAS NÃO FIXADAS
  Future<int> countUnpinnedNotes();
}
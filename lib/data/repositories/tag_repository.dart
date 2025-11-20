import 'package:clipstick/data/models/tag_model.dart';

/// 🏷️ CONTRATO (INTERFACE) PARA REPOSITÓRIO DE TAGS
/// 
/// Define todas as operações que devem ser implementadas
/// para manipular tags, independente da fonte de dados.
/// 
/// **Por que usar interface?**
/// - ✅ Facilita testes (mock)
/// - ✅ Permite trocar implementação (SQLite → Firebase → API)
/// - ✅ Segue princípio de Inversão de Dependência (SOLID)
/// 
/// **Implementações:**
/// - TagRepositoryImpl (usa Drift/SQLite)
/// - TagRepositoryMock (para testes)
/// - TagRepositoryFirebase (futuro)
abstract class TagRepository {
  
  // ═══════════════════════════════════════════════════════════════
  // 📋 OPERAÇÕES BÁSICAS (CRUD)
  // ═══════════════════════════════════════════════════════════════

  /// ✅ BUSCAR TODAS AS TAGS (ordenadas por nome)
  Future<List<TagModel>> getAllTags();

  /// 📺 WATCH: Stream de todas as tags
  Stream<List<TagModel>> watchAllTags();

  /// 🔍 BUSCAR TAG POR ID
  Future<TagModel?> getTagById(String id);

  /// 🔍 BUSCAR TAG POR NOME (case-insensitive)
  Future<TagModel?> getTagByName(String name);

  /// ➕ CRIAR NOVA TAG
  Future<String> createTag(TagModel tag);

  /// ✏️ ATUALIZAR TAG EXISTENTE
  Future<void> updateTag(TagModel tag);

  /// 🗑️ DELETAR TAG
  Future<void> deleteTag(String id);

  /// 🗑️ DELETAR MÚLTIPLAS TAGS
  Future<void> deleteTags(List<String> ids);

  // ═══════════════════════════════════════════════════════════════
  // 🔗 RELACIONAMENTOS (NOTAS ↔ TAGS)
  // ═══════════════════════════════════════════════════════════════

  /// 🏷️ BUSCAR TAGS DE UMA NOTA
  Future<List<TagModel>> getTagsForNote(String noteId);

  /// 📺 WATCH: Stream de tags de uma nota
  Stream<List<TagModel>> watchTagsForNote(String noteId);

  // ═══════════════════════════════════════════════════════════════
  // 📊 ESTATÍSTICAS
  // ═══════════════════════════════════════════════════════════════

  /// 🔢 CONTAR TOTAL DE TAGS
  Future<int> countAllTags();

  /// 📝 CONTAR QUANTAS NOTAS TÊM UMA TAG
  Future<int> countNotesWithTag(String tagId);

  /// 🏷️ BUSCAR TAGS COM CONTAGEM DE NOTAS
  Future<Map<TagModel, int>> getTagsWithNoteCounts();

  /// 🗑️ DELETAR TAGS SEM NOTAS (limpeza)
  Future<int> deleteUnusedTags();
}
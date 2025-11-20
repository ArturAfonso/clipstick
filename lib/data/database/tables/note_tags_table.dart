import 'package:drift/drift.dart';
import 'package:clipstick/data/database/tables/notes_table.dart';
import 'package:clipstick/data/database/tables/tags_table.dart';

/// 🔗 TABELA DE RELACIONAMENTO NOTES ↔ TAGS
/// 
/// Implementa relacionamento Muitos-para-Muitos (N:N):
/// - Uma nota pode ter VÁRIAS tags
/// - Uma tag pode estar em VÁRIAS notas
/// 
/// **Exemplo:**
/// ```
/// Nota "Reunião Cliente" → Tags: ["Trabalho", "Urgente"]
/// Nota "Estudar Flutter" → Tags: ["Pessoal", "Estudos"]
/// Tag "Trabalho" → Notas: ["Reunião Cliente", "Apresentação"]
/// ```
/// 
/// **Colunas:**
/// - noteId: Referência para Notes.id
/// - tagId: Referência para Tags.id
/// - Chave primária composta (noteId + tagId)
/// 
/// **SQL Gerado:**
/// ```sql
/// CREATE TABLE note_tags (
///   note_id TEXT NOT NULL,
///   tag_id TEXT NOT NULL,
///   PRIMARY KEY (note_id, tag_id),
///   FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE,
///   FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
/// );
/// ```
/// 
/// **Comportamento CASCADE:**
/// - Se deletar uma nota → remove automaticamente todas as linhas em note_tags
/// - Se deletar uma tag → remove automaticamente todas as linhas em note_tags
@DataClassName('NoteTagRelation')
class NoteTags extends Table {
  
  /// 🔑 REFERÊNCIA PARA NOTES
  /// 
  /// - Foreign Key para Notes.id
  /// - ON DELETE CASCADE: Se deletar a nota, remove este relacionamento
  /// - Tipo TEXT (UUID da nota)
  /// 
  /// **Exemplo:**
  /// ```dart
  /// noteId = "550e8400-e29b-41d4-a716-446655440000"
  /// ```
  TextColumn get noteId => text()
    .references(Notes, #id, onDelete: KeyAction.cascade)();

  /// 🏷️ REFERÊNCIA PARA TAGS
  /// 
  /// - Foreign Key para Tags.id
  /// - ON DELETE CASCADE: Se deletar a tag, remove este relacionamento
  /// - Tipo TEXT (UUID da tag)
  /// 
  /// **Exemplo:**
  /// ```dart
  /// tagId = "tag-550e8400-e29b-41d4-a716-446655440000"
  /// ```
  TextColumn get tagId => text()
    .references(Tags, #id, onDelete: KeyAction.cascade)();

  /// ✅ CHAVE PRIMÁRIA COMPOSTA
  /// 
  /// - Combinação de (noteId, tagId) deve ser única
  /// - Impede duplicatas (mesma nota com mesma tag duas vezes)
  /// - Otimiza queries de relacionamento
  /// 
  /// **Exemplo de validação:**
  /// ```sql
  /// -- ✅ PERMITIDO:
  /// INSERT INTO note_tags VALUES ('nota1', 'tag1');
  /// INSERT INTO note_tags VALUES ('nota1', 'tag2');
  /// INSERT INTO note_tags VALUES ('nota2', 'tag1');
  /// 
  /// -- ❌ ERRO (duplicata):
  /// INSERT INTO note_tags VALUES ('nota1', 'tag1'); -- Já existe!
  /// ```
  @override
  Set<Column> get primaryKey => {noteId, tagId};

  /// 🚀 ÍNDICES PARA PERFORMANCE (JÁ CRIADOS AUTOMATICAMENTE)
  /// 
  /// Drift cria automaticamente índices nas Foreign Keys:
  /// - Índice em `note_id` (buscar tags de uma nota)
  /// - Índice em `tag_id` (buscar notas de uma tag)
  /// 
  /// **Queries otimizadas:**
  /// ```dart
  /// // ✅ RÁPIDO: Buscar tags da nota "abc"
  /// SELECT * FROM note_tags WHERE note_id = 'abc';
  /// 
  /// // ✅ RÁPIDO: Buscar notas com tag "urgente"
  /// SELECT * FROM note_tags WHERE tag_id = 'urgente';
  /// ```
}
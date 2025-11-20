import 'package:drift/drift.dart';

/// 🏷️ TABELA DE TAGS
/// 
/// Define a estrutura da tabela `tags` no SQLite.
/// 
/// **Colunas:**
/// - id: Identificador único (UUID)
/// - name: Nome da tag (ex: "Trabalho", "Pessoal")
/// - createdAt: Data de criação
/// - updatedAt: Data da última edição
/// 
/// **SQL Gerado:**
/// ```sql
/// CREATE TABLE tags (
///   id TEXT PRIMARY KEY NOT NULL,
///   name TEXT NOT NULL,
///   created_at INTEGER NOT NULL,
///   updated_at INTEGER NOT NULL
/// );
/// ```
/// 
/// **Relacionamento:**
/// - Uma tag pode estar em VÁRIAS notas (N:N)
/// - O relacionamento é feito pela tabela `NoteTags` (criamos a seguir)
@DataClassName('TagEntity')
class Tags extends Table {
  
  /// 🔑 PRIMARY KEY - Identificador único da tag
  /// 
  /// Será gerado usando UUID (ex: "tag-550e8400-e29b-41d4-a716-446655440000")
  TextColumn get id => text()();

  /// 🏷️ NOME DA TAG
  /// 
  /// - Não pode ser vazio
  /// - Exemplos: "Trabalho", "Urgente", "Ideias"
  /// - Tipo TEXT no SQLite
  TextColumn get name => text()();

  /// 📅 DATA DE CRIAÇÃO
  /// 
  /// - Armazenada como UNIX timestamp (milliseconds)
  /// - Drift converte automaticamente para DateTime
  DateTimeColumn get createdAt => dateTime()();

  /// 🕐 DATA DA ÚLTIMA EDIÇÃO
  /// 
  /// - Atualizada quando o nome da tag for modificado
  /// - Útil para auditoria e sincronização futura
  DateTimeColumn get updatedAt => dateTime()();

  /// ✅ DEFINE A PRIMARY KEY
  /// 
  /// - Garante que cada tag tenha um ID único
  /// - Impede duplicatas
  @override
  Set<Column> get primaryKey => {id};

  /// 🚀 ÍNDICE PARA PERFORMANCE (OPCIONAL)
  /// 
  /// Descomentar se precisar de busca rápida por nome.
  /// 
  /// ```dart
  /// @override
  /// List<Index> get indexes => [
  ///   // Índice único para evitar tags com mesmo nome
  ///   Index('idx_tag_name', [name], unique: true),
  /// ];
  /// ```
  /// 
  /// **ATENÇÃO:** Se usar `unique: true`, não poderá criar duas tags
  /// com o mesmo nome (ex: "Trabalho" e "trabalho" serão diferentes).
  /// Para case-insensitive, precisa normalizar antes de inserir.
}
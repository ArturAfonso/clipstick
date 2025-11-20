import 'package:drift/drift.dart';
import '../converters/color_converter.dart';

/// 📝 TABELA DE NOTAS
/// 
/// Define a estrutura da tabela `notes` no SQLite.
/// 
/// **Colunas:**
/// - id: Identificador único (UUID)
/// - title: Título da nota (pode ser vazio)
/// - content: Conteúdo da nota
/// - color: Cor de fundo (usando ColorConverter)
/// - isPinned: Se está fixada no topo
/// - position: Ordem de exibição
/// - createdAt: Data de criação
/// - updatedAt: Data da última edição
/// 
/// **SQL Gerado:**
/// ```sql
/// CREATE TABLE notes (
///   id TEXT PRIMARY KEY NOT NULL,
///   title TEXT NOT NULL DEFAULT '',
///   content TEXT NOT NULL,
///   color INTEGER NOT NULL,
///   is_pinned INTEGER NOT NULL DEFAULT 0,
///   position INTEGER NOT NULL,
///   created_at INTEGER NOT NULL,
///   updated_at INTEGER NOT NULL
/// );
/// ```
@DataClassName('NoteEntity')
class Notes extends Table {
  
  /// 🔑 PRIMARY KEY - Identificador único da nota
  /// 
  /// Será gerado usando UUID (ex: "550e8400-e29b-41d4-a716-446655440000")
  TextColumn get id => text()();

  /// 📌 TÍTULO DA NOTA
  /// 
  /// - Pode ser vazio (default: '')
  /// - Tipo TEXT no SQLite
  TextColumn get title => text().withDefault(const Constant(''))();

  /// 📄 CONTEÚDO DA NOTA
  /// 
  /// - Não pode ser nulo
  /// - Armazena o texto completo da nota
  TextColumn get content => text()();

  /// 🎨 COR DE FUNDO
  /// 
  /// - Usa ColorConverter para converter Color ↔ int
  /// - Armazenado como INTEGER no SQLite (ex: 4294934323)
  /// - Ao ler, Drift converte automaticamente para Color
  /// 
  /// **Exemplo:**
  /// ```dart
  /// Color(0xFFFF5733) → 4294934323 (toSql)
  /// 4294934323 → Color(0xFFFF5733) (fromSql)
  /// ```
  IntColumn get color => integer().map(const ColorConverter())();

  /// 📌 SE ESTÁ FIXADA NO TOPO
  /// 
  /// - Default: false (0)
  /// - SQLite armazena como INTEGER (0 = false, 1 = true)
  /// - Drift converte automaticamente para bool
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();

  /// 🔢 POSIÇÃO NA LISTA
  /// 
  /// - Define a ordem de exibição
  /// - Menor número = aparece primeiro
  /// - Importante para drag & drop
  IntColumn get position => integer()();

  /// 📅 DATA DE CRIAÇÃO
  /// 
  /// - Armazenada como UNIX timestamp (milliseconds)
  /// - Drift converte automaticamente para DateTime
  /// 
  /// **SQLite:** 1699999999999 (int)
  /// **Dart:**    DateTime(2023, 11, 15, 10, 46, 39)
  DateTimeColumn get createdAt => dateTime()();

  /// 🕐 DATA DA ÚLTIMA EDIÇÃO
  /// 
  /// - Atualizada sempre que a nota for modificada
  /// - Útil para sincronização futura
  DateTimeColumn get updatedAt => dateTime()();

  /// ✅ DEFINE A PRIMARY KEY
  /// 
  /// - Garante que cada nota tenha um ID único
  /// - Impede duplicatas
  @override
  Set<Column> get primaryKey => {id};

  /// 🚀 ÍNDICES PARA PERFORMANCE (OPCIONAL)
  /// 
  /// Descomentar se tiver muitas notas (>1000) e precisar de busca rápida.
  /// 
  /// ```dart
  /// @override
  /// List<Index> get indexes => [
  ///   // Índice para busca por isPinned + position (usado no grid/list)
  ///   Index('idx_pinned_position', [isPinned, position]),
  ///   
  ///   // Índice para busca por data (futuro: "notas recentes")
  ///   Index('idx_updated_at', [updatedAt]),
  /// ];
  /// ```
}
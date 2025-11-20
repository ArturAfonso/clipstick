import 'dart:convert';

/// 🏷️ MODELO DE TAG (ETIQUETA)
/// 
/// Representa uma tag que pode ser associada a múltiplas notas.
/// 
/// **Exemplo:**
/// ```dart
/// final tag = TagModel(
///   id: 'tag-trabalho',
///   name: 'Trabalho',
///   createdAt: DateTime.now(),
/// );
/// ```
class TagModel {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TagModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 📝 COPIAR COM ALTERAÇÕES
  TagModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TagModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 🗺️ CONVERTER PARA MAP
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// 🗺️ CRIAR A PARTIR DE MAP
  factory TagModel.fromMap(Map<String, dynamic> map) {
    return TagModel(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  /// 📄 CONVERTER PARA JSON
  String toJson() => json.encode(toMap());

  /// 📄 CRIAR A PARTIR DE JSON
  factory TagModel.fromJson(String source) {
    return TagModel.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'TagModel(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant TagModel other) {
    if (identical(this, other)) return true;
    return other.id == id &&
        other.name == name &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
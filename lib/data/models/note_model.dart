// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';


class NoteModel {
  final String id;
  final String title;
  final String content;
  final Color color;
  final int position;
  final bool isPinned;
  final List<String>? tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.position,
    this.isPinned = false,
    this.tags,
    this.createdAt,
    this.updatedAt,
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    Color? color,
    int? position,
    bool? isPinned,
    List<String>? tags, 
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      position: position ?? this.position,
      isPinned: isPinned ?? this.isPinned,
      tags: tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

    static NoteModel empty() {
    return NoteModel(
      id: '',
      title: '',
      content: '',
      color: Colors.white,
      isPinned: false,
      position: 0,
      tags: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'content': content,
      'color': color,
      'position': position,
      'isPinned': isPinned,
      'tags': tags,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      color: Color(map['color'] as int),
      position: map['position'] as int,
      isPinned: map['isPinned'] as bool? ?? false,
      tags: map['tags'] != null 
        ? List<String>.from(map['tags'] as List) // Converter para List<String>
        : null,
      createdAt: map['createdAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory NoteModel.fromJson(String source) => NoteModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NoteModel(id: $id, title: $title, content: $content, color: $color, position: $position, isPinned: $isPinned,tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant NoteModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.title == title &&
      other.content == content &&
      other.color == color &&
      other.position == position &&
      other.isPinned == isPinned &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      title.hashCode ^
      content.hashCode ^
      color.hashCode ^
      position.hashCode ^
      isPinned.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }

  bool hasTag(String tagId) {
    return tags?.contains(tagId) ?? false;
  }
 NoteModel addTag(String tagId) {
    final currentTags = tags ?? [];
    if (currentTags.contains(tagId)) {
      return this; 
    }
    return copyWith(
      tags: [...currentTags, tagId],
      updatedAt: DateTime.now(),
    );
  }

   NoteModel removeTag(String tagId) {
    if (tags == null || !tags!.contains(tagId)) {
      return this; 
    }
    return copyWith(
      tags: tags!.where((t) => t != tagId).toList(),
      updatedAt: DateTime.now(),
    );
  }

 NoteModel clearTags() {
    return copyWith(
      tags: [],
      updatedAt: DateTime.now(),
    );
  }
}

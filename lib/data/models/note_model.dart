import 'package:flutter/material.dart';

//TODO: lembrar de criar uma classe melhor para notas, esta é temporaria.

class NoteModel {
  final String id;
  final String title;
  final String content;
  final Color color;
  final int position;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.position,
    this.createdAt,
    this.updatedAt,
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    Color? color,
    int? position,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
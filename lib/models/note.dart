import 'package:blog_note_android/models/note_category.dart';

abstract class Note {
  final int? id;
  final String title;
  final NoteCategory category;
  final DateTime createdAt;

  const Note({
    this.id,
    required this.title,
    required this.createdAt,
    this.category = NoteCategory.purple,
  });

  // Métodos que CADA tipo de nota debe implementar obligatoriamente
  Map<String, dynamic> toJson();
  String getPreview(); // Resumen corto para mostrar en la lista
}
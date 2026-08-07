import 'package:blog_note_android/models/note.dart';
import 'package:blog_note_android/models/note_category.dart';

class TextNote extends Note {
  final String content;

  const TextNote({
    super.id,
    required super.title,
    required super.createdAt,
    super.category,
    super.isFavorite,
    required this.content,
  });

  factory TextNote.fromJson(Map<String, dynamic> json) {
    return TextNote(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
      category: NoteCategory.fromString(json['category'] ?? 'purple'),
      isFavorite: (json['is_favorite'] ?? 0) == 1,
      content: json['content']
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'type': 'text',
      'category': category.name, // Para saber qué tipo es al leer de BD
      'is_favorite': isFavorite ? 1 : 0
    };
  }

  @override
  String getPreview() => content.length > 60
      ? '${content.substring(0, 60)}...'
      : content;
}
import 'package:blog_note_android/models/note.dart';

class TextNote extends Note {
  final String content;

  const TextNote({
    super.id,
    required super.title,
    required super.createdAt,
    required this.content,
  });

  factory TextNote.fromJson(Map<String, dynamic> json) {
    return TextNote(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
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
      'type': 'text', // Para saber qué tipo es al leer de BD
    };
  }

  @override
  String getPreview() => content.length > 60
      ? '${content.substring(0, 60)}...'
      : content;
}
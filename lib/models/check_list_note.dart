import 'package:blog_note_android/models/item_check.dart';
import 'package:blog_note_android/models/note.dart';
import 'package:blog_note_android/models/note_category.dart';

class ChecklistNote extends Note {
  final List<ItemCheck> items;

  const ChecklistNote({
    super.id,
    required super.title,
    required super.createdAt,
    super.category,
    super.isFavorite,
    required this.items,
  });

  factory ChecklistNote.fromJson(Map<String, dynamic> json) {
    return ChecklistNote(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
      category: NoteCategory.fromString(json['category'] ?? 'purple'),
      isFavorite: (json['is_favorite'] ?? 0) == 1,
      items: (json['items'] as List<dynamic>)
          .map((i) => ItemCheck.fromJson(i))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'items': items.map((i) => i.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'type': 'checklist',
      'category': category.name, // Para saber qué tipo es al leer de BD
      'is_favorite': isFavorite ? 1 : 0
    };
  }

  @override
  String getPreview() {
    final done = items.where((i) => i.isDone).length;
    return '$done/${items.length} completados';
  }
}
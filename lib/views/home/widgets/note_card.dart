import 'package:blog_note_android/models/check_list_note.dart';
import 'package:blog_note_android/models/note.dart';
import 'package:blog_note_android/models/text_note.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const NoteCard({
    super.key,
    required this.note,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: note.category.lightColor, // ← fondo suave
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // ← mismo radio que el Card
        ),
        onTap: onTap,
        leading: Icon(
          note is TextNote ? Icons.note : Icons.checklist,
          color: note.category.color,
        ),
        title: Text(
          note.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.getPreview(),
              maxLines: 1,                        // ← solo una línea
              overflow: TextOverflow.ellipsis,    // ← agrega ... si no cabe
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM yyyy – HH:mm').format(note.createdAt),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        // Agrega en el trailing del ListTile:
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (note.isFavorite)
              const Icon(Icons.star, color: Colors.amber, size: 18),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

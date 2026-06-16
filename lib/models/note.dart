abstract class Note {
  final int? id;
  final String title;
  final DateTime createdAt;

  const Note({
    this.id,
    required this.title,
    required this.createdAt,
  });

  // Métodos que CADA tipo de nota debe implementar obligatoriamente
  Map<String, dynamic> toJson();
  String getPreview(); // Resumen corto para mostrar en la lista
}
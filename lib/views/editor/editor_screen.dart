
import 'package:blog_note_android/models/check_list_note.dart';
import 'package:blog_note_android/models/item_check.dart';
import 'package:blog_note_android/models/note.dart';
import 'package:blog_note_android/models/text_note.dart';
import 'package:blog_note_android/viewmodels/note_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditorScreen extends StatefulWidget {
   final Note? note;
   final String type;        // ← agrega este parámetro

  const EditorScreen({
    super.key,
    this.note,
    this.type = 'text',     // por defecto texto
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  late String _type;                    // 'text' o 'checklist'
  List<ItemCheck> _items = [];          // items del checklist
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final note = widget.note;

    if (note != null) {
      // Modo edición — precarga los valores
      _titleController.text = note.title;
      if (note is TextNote) {
        _type = 'text';
        _contentController.text = note.content;
      } else if (note is ChecklistNote) {
        _type = 'checklist';
        _items = List.from(note.items); // copia para no mutar el original
      } else {
        _type = 'text';
      }
    } else {
      _type = widget.type;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────
  // Guardar
  // ─────────────────────────────────────────

  Future<void> _save() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título no puede estar vacío')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final Note note;

    if (_type == 'text') {
      note = TextNote(
        id: widget.note?.id,
        title: title,
        content: _contentController.text.trim(),
        createdAt: widget.note?.createdAt ?? DateTime.now(),
      );
    } else {
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agrega al menos un item')),
        );
        setState(() => _isSaving = false);
        return;
      }
      note = ChecklistNote(
        id: widget.note?.id,
        title: title,
        items: _items,
        createdAt: widget.note?.createdAt ?? DateTime.now(),
      );
    }

    await context.read<NoteViewModel>().saveNote(note);

    if (mounted) Navigator.pop(context);
  }

  // ─────────────────────────────────────────
  // Items del checklist
  // ─────────────────────────────────────────

  void _addItem() {
    setState(() {
      _items.add(ItemCheck(content: '', isDone: false));
    });
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  void _toggleItem(int index, bool value) {
    setState(() {
      _items[index] = ItemCheck(
        id: _items[index].id,
        content: _items[index].content,
        isDone: value,
      );
    });
  }

  void _updateItemContent(int index, String value) {
    _items[index] = ItemCheck(
      id: _items[index].id,
      content: value,
      isDone: _items[index].isDone,
    );
  }

  // ─────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar nota' : 'Nueva nota'),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.save),
                  tooltip: 'Guardar',
                  onPressed: _save,
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo título
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 20),

            // Contenido según el tipo
            if (_type == 'text') _buildTextContent(),
            if (_type == 'checklist') _buildChecklistContent(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Widgets internos
  // ─────────────────────────────────────────

  Widget _buildTextContent() {
    return TextField(
      controller: _contentController,
      decoration: const InputDecoration(
        labelText: 'Contenido',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      maxLines: 10,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildChecklistContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        // Lista de items
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            return Row(
              children: [
                // Checkbox
                Checkbox(
                  value: _items[index].isDone,
                  onChanged: (value) => _toggleItem(index, value ?? false),
                ),
                // Campo de texto del item
                Expanded(
                  child: TextFormField(
                    initialValue: _items[index].content,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un item...',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => _updateItemContent(index, value),
                  ),
                ),
                // Botón eliminar item
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                  onPressed: () => _removeItem(index),
                ),
              ],
            );
          },
        ),

        // Botón agregar item
        TextButton.icon(
          onPressed: _addItem,
          icon: const Icon(Icons.add),
          label: const Text('Agregar item'),
        ),
      ],
    );
  }
}
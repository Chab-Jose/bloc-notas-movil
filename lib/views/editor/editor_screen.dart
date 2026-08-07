import 'package:blog_note_android/models/check_list_note.dart';
import 'package:blog_note_android/models/item_check.dart';
import 'package:blog_note_android/models/note.dart';
import 'package:blog_note_android/models/note_category.dart';
import 'package:blog_note_android/models/text_note.dart';
import 'package:blog_note_android/viewmodels/note_viewmodel.dart';
import 'package:blog_note_android/views/editor/painters/notebook_lines_painter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditorScreen extends StatefulWidget {
  final Note? note;
  final String type; // ← agrega este parámetro

  const EditorScreen({
    super.key,
    this.note,
    this.type = 'text', // por defecto texto
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _newItemController = TextEditingController();
  NoteCategory _category = NoteCategory.purple; // categoría por defecto

  late String _type; // 'text' o 'checklist'
  List<ItemCheck> _items = []; // items del checklist
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final note = widget.note;

    if (note != null) {
      // Modo edición — precarga los valores
      _titleController.text = note.title;
      _category = note.category;
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
      _category = NoteCategory.purple; // categoría por defecto
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _newItemController.dispose();
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
        category: _category
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
        category: _category
      );
    }

    await context.read<NoteViewModel>().saveNote(note);

    if (mounted) Navigator.pop(context);
  }

  // ─────────────────────────────────────────
  // Items del checklist
  // ─────────────────────────────────────────

  void _addItem() {
    final content = _newItemController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El item no puede estar vacío')),
      );
      return;
    }

    setState(() {
      _items.add(ItemCheck(content: content, isDone: false));
      _newItemController.clear();
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
      backgroundColor: _category.lightColor, // ← fondo dinámico
      appBar: AppBar(
        backgroundColor: _category.lightColor, // ← appbar mismo color
        title: Text(isEditing ? 'Editar nota' : 'Nueva nota'),
        actions: [
          // ── Selector de categoría ──
          DropdownButtonHideUnderline(
            child: DropdownButton<NoteCategory>(
              value: _category,
              icon: Icon(Icons.circle, color: _category.color, size: 28),
              dropdownColor: _category.lightColor,
              onChanged: (cat) {
                if (cat != null) setState(() => _category = cat);
              },
              items: NoteCategory.values.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Row(
                    children: [
                      Icon(Icons.circle, color: cat.color, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        cat.label,
                        style: TextStyle(
                          color: cat.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Botón guardar ──
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
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300), // ← transición suave
        color: _category.lightColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Título',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textCapitalization: TextCapitalization.sentences,
            ),

            const Divider(),
            const SizedBox(height: 12),

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
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const lineHeight = 28.0;
          return Stack(
            children: [
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: NotebookLinesPainter(
                  lineHeight: lineHeight,
                  lineColor: _category.color.withValues(alpha: 0.3), // ← usa color de categoría
                ),
              ),
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontSize: 16, height: lineHeight / 16),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 8, top: 4),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChecklistContent() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Input para agregar nuevo item ──
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newItemController,
                  decoration: const InputDecoration(
                    hintText: 'Escribe un item...',
                    border: InputBorder.none,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _addItem(), // agregar con teclado Enter
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.indigo),
                onPressed: _addItem,
              ),
            ],
          ),

          const Divider(),

          // ── Lista de items ──
          Expanded(
            child: _items.isEmpty
                ? const Center(
                    child: Text(
                      'No hay items aún',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        // Palomita o círculo vacío
                        leading: GestureDetector(
                          onTap: () => _toggleItem(index, !item.isDone),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              item.isDone
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              key: ValueKey(item.isDone),
                              color: item.isDone ? Colors.indigo : Colors.grey,
                            ),
                          ),
                        ),
                        // Texto con tachado y negrita si está hecho
                        title: GestureDetector(
                          onTap: () => _toggleItem(index, !item.isDone),
                          child: Text(
                            item.content,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: item.isDone
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              decoration: item.isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationThickness: 2,
                              color: item.isDone ? Colors.grey : Colors.black,
                            ),
                          ),
                        ),
                        // Botón eliminar
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _removeItem(index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

}

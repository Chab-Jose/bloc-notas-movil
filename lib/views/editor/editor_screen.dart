import 'package:blog_note_android/models/check_list_note.dart';
import 'package:blog_note_android/models/item_check.dart';
import 'package:blog_note_android/models/note.dart';
import 'package:blog_note_android/models/note_category.dart';
import 'package:blog_note_android/models/text_note.dart';
import 'package:blog_note_android/viewmodels/note_viewmodel.dart';
import 'package:blog_note_android/views/editor/painters/notebook_lines_painter.dart';
import 'package:blog_note_android/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

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
  bool _isFavorite = false; // estado de favorito
  int? _editingIndex; // índice del item que se está editando
  String? _editingError;
  bool _showItemError = false;
  final _editingController = TextEditingController(); // para editar item
  final _formKey = GlobalKey<FormState>();
  final _itemFormKey =
      GlobalKey<FormState>(); // ← key solo para el input del item

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
      _isFavorite = note.isFavorite;
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
    _editingController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────
  // Guardar
  // ─────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_type == 'checklist' && _items.isEmpty) {
      showSnackBar(context, 'El checklist no puede estar vacío');
      setState(() => _isSaving = false);
      return;
    }

    setState(() => _isSaving = true);

    final Note note;
    final title = _titleController.text.trim();

    if (_type == 'text') {
      note = TextNote(
        id: widget.note?.id,
        title: title,
        content: _contentController.text.trim(),
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        category: _category,
        isFavorite: _isFavorite,
      );
    } else {
      note = ChecklistNote(
        id: widget.note?.id,
        title: title,
        items: _items,
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        category: _category,
        isFavorite: _isFavorite,
      );
    }

    await context.read<NoteViewModel>().saveNote(note);

    if (mounted) Navigator.pop(context);
  }

  Future<void> _copyToClipboard() async {
    final title = _titleController.text;
    final body = _type == 'text' ? _contentController.text : _itemsToText();

    await Clipboard.setData(ClipboardData(text: '$title\n\n$body'));
    if (mounted) showSnackBar(context, 'Copiado al portapapeles');
  }

  Future<void> _shareNote() async {
    final title = _titleController.text;
    final body = _type == 'text' ? _contentController.text : _itemsToText();

    await Share.share('$title\n\n$body', subject: title);
  }

  // ── Para checklist ──
  String _itemsToText() {
    return _items
        .map((item) {
          final check = item.isDone ? '✅' : '⬜';
          return '$check ${item.content}';
        })
        .join('\n');
  }

  String _formatDate() {
    final date = widget.note?.createdAt ?? DateTime.now();
    return DateFormat('dd MMM yyyy').format(date);
  }

  // ─────────────────────────────────────────
  // Items del checklist
  // ─────────────────────────────────────────

  void _addItem() {
    setState(() => _showItemError = true);

    if (!_itemFormKey.currentState!.validate()) return; // ← valida el form

    final content = _newItemController.text.trim();

    setState(() {
      _items.add(ItemCheck(content: content, isDone: false));
      _newItemController.clear();
      _showItemError = false;
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

  void _startEditing(int index) {
    setState(() {
      _editingIndex = index;
      _editingError = null;
      _editingController.text =
          _items[index].content; // ← precarga el texto actual
      _editingController.selection = TextSelection.fromPosition(
        TextPosition(
          offset: _editingController.text.length,
        ), // ← cursor al final
      );
    });
  }

  void _confirmEdit(int index) {
    final newContent = _editingController.text.trim();

    if (newContent.isEmpty) {
      setState(() => _editingError = 'El item no puede estar vacío');
      return;
    }

    setState(() {
      _items[index] = ItemCheck(
        id: _items[index].id,
        content: newContent,
        isDone: _items[index].isDone,
      );
      _editingIndex = null;
      _editingError = null;
      _editingController.clear();
    });
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
        backgroundColor: _category.lightColor,
        titleSpacing: 0, // ← elimina el espacio entre la flecha y el título
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEditing ? 'Editar nota' : 'Nueva nota',
              overflow: TextOverflow.ellipsis,
            ),
            // ── Estrella de favorito ──
            if (_isFavorite)
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.star,
                    key: ValueKey(_isFavorite),
                    color: Colors.amber,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          // ── Compartir ──
          PopupMenuButton<String>(
            icon: const Icon(Icons.share),
            onSelected: (value) {
              if (value == 'copy') _copyToClipboard();
              if (value == 'share') _shareNote();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 18),
                    SizedBox(width: 8),
                    Text('Copiar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, size: 18),
                    SizedBox(width: 8),
                    Text('Compartir'),
                  ],
                ),
              ),
            ],
          ),

          // ── Menú de opciones (favorito + categoría) ──
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'favorite') {
                setState(() => _isFavorite = !_isFavorite);
              }
            },
            itemBuilder: (_) => [
              // Favorito
              PopupMenuItem<String>(
                value: 'favorite',
                child: Row(
                  children: [
                    Icon(
                      _isFavorite ? Icons.star : Icons.star_border,
                      color: _isFavorite ? Colors.amber : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(_isFavorite ? 'Quitar favorito' : 'Marcar favorito'),
                  ],
                ),
              ),
              // Separador
              const PopupMenuDivider(),
              // Categorías
              ...NoteCategory.values.map(
                (cat) => PopupMenuItem<String>(
                  value: 'cat_${cat.name}',
                  onTap: () => setState(() => _category = cat),
                  child: Row(
                    children: [
                      Icon(Icons.circle, color: cat.color, size: 16),
                      const SizedBox(width: 8),
                      Text(cat.label),
                      if (_category == cat)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.check, size: 16),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Guardar ──
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
        duration: const Duration(milliseconds: 300),
        color: _category.lightColor,
        child: Column(
          children: [
            // ── Título ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _titleController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  decoration: const InputDecoration(
                    hintText: 'Título',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El título no puede estar vacío';
                    }
                    return null;
                  },
                ),
              ),
            ),

            // ── Separador con fecha ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: _category.color.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(),
                    style: TextStyle(
                      fontSize: 11,
                      color: _category.color.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Divider(
                      color: _category.color.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Contenido ──
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
                  lineColor: _category.color.withValues(
                    alpha: 0.3,
                  ), // ← usa color de categoría
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
                  style: TextStyle(
                    fontSize: 16,
                    height: lineHeight / 16,
                    color: Colors.black87,
                  ),
                  cursorColor: _category.color,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.fromLTRB(
                      20,
                      4,
                      20,
                      0,
                    ), // ← más padding horizontal
                    isDense: true,
                    hintText: 'Escribe tu nota aquí...',
                    hintStyle: TextStyle(
                      color: Colors.grey.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
            child: Form(
              key: _itemFormKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _newItemController,
                      autovalidateMode: _showItemError
                          ? AutovalidateMode
                                .onUserInteraction // ← muestra error solo si intentó agregar
                          : AutovalidateMode.disabled,
                      onTapOutside: (_) {
                        setState(() => _showItemError = false);
                        FocusScope.of(
                          context,
                        ).unfocus(); // ← quita el foco del teclado
                      },
                      decoration: const InputDecoration(
                        hintText: 'Escribe un item...',
                        border: InputBorder.none,
                        errorStyle: TextStyle(fontSize: 12),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onFieldSubmitted: (_) => _addItem(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El item no puede estar vacío';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    // ← dentro del Row
                    icon: const Icon(Icons.add_circle, color: Colors.indigo),
                    onPressed: _addItem,
                  ),
                ], // ← cierra children del Row
              ), // ← cierra Row
            ), // ← cierra Form
          ),

          // ── Input para agregar nuevo item ──
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
                      final isEditing = _editingIndex == index;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
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
                        title: isEditing
                            ? TextField(
                                autofocus: true,
                                controller: _editingController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  errorText: _editingError,
                                  suffixIcon: IconButton(
                                    icon: const Icon(
                                      Icons.check,
                                      color: Colors.indigo,
                                    ),
                                    onPressed: () => _confirmEdit(index),
                                  ),
                                ),
                                onSubmitted: (_) => _confirmEdit(index),
                              )
                            : GestureDetector(
                                onTap: () => _toggleItem(index, !item.isDone),
                                onDoubleTap: () {
                                  if (!item.isDone) _startEditing(index);
                                },
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
                                    color: item.isDone
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                ),
                              ),
                        trailing: isEditing
                            ? IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                onPressed: () =>
                                    setState(() => _editingIndex = null),
                              )
                            : IconButton(
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
        ], // ← cierra children del Column
      ), // ← cierra Column
    ); // ← cierra Expanded
  }
}

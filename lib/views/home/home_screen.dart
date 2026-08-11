import 'package:blog_note_android/models/check_list_note.dart';
import 'package:blog_note_android/models/note.dart';
import 'package:blog_note_android/models/note_category.dart';
import 'package:blog_note_android/models/text_note.dart';
import 'package:blog_note_android/viewmodels/note_viewmodel.dart';
import 'package:blog_note_android/views/editor/editor_screen.dart';
import 'package:blog_note_android/views/home/widgets/note_card.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/material.dart';
import 'package:blog_note_android/models/note_category.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filter = 'all'; // 'all', 'text', 'checklist'
  bool _ascending = false; // false = más reciente primero
  NoteCategory? _categoryFilter; // null = todas las categorías
  bool _onlyFavorites = false; // false = mostrar todas, true = solo favoritos
  String _searchQuery = ''; // Para búsqueda de notas
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    // Carga las notas al abrir la pantalla
    Future.microtask(() => context.read<NoteViewModel>().loadAll());
  }

  // Filtra y ordena la lista según el estado actual
  List<Note> _applyFilters(List<Note> notes) {
    List<Note> result = notes;

    // Filtro por tipo
    if (_filter == 'text') {
      result = result.whereType<TextNote>().toList();
    } else if (_filter == 'checklist') {
      result = result.whereType<ChecklistNote>().toList();
    }
    // Filtro por categoría ← nuevo
    if (_categoryFilter != null) {
      result = result.where((n) => n.category == _categoryFilter).toList();
    }

    // Filtro por búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result
          .where(
            (n) =>
                n.title.toLowerCase().contains(query) ||
                n.getPreview().toLowerCase().contains(query),
          )
          .toList();
    }

    // En _applyFilters agrega:
    if (_onlyFavorites) {
      result = result.where((n) => n.isFavorite).toList();
    }

    // Orden por fecha
    result.sort(
      (a, b) => _ascending
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt),
    );

    return result;
  }

  void _confirmDelete(BuildContext context, Note note, NoteViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar nota'),
        content: Text('¿Seguro que quieres eliminar "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              vm.deleteNote(note);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NoteViewModel>();
    final notes = _applyFilters(vm.notes);

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar notas...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              )
            : const Text('Mis Notas'),
        leading: _showSearch
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _showSearch = false;
                  _searchQuery = '';
                }),
              )
            : null,
        actions: [
          // ── Botón buscar ──
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() => _showSearch = true),
          ),

          // ── Favoritos ──
          IconButton(
            icon: Icon(
              _onlyFavorites ? Icons.star : Icons.star_border,
              color: _onlyFavorites ? Colors.amber : Colors.grey,
            ),
            tooltip: _onlyFavorites ? 'Mostrar todas' : 'Solo favoritos',
            onPressed: () => setState(() => _onlyFavorites = !_onlyFavorites),
          ),

          // ── Filtro por categoría ──
          PopupMenuButton<String>(
            icon: Icon(
              Icons.circle,
              color: _categoryFilter?.color ?? Colors.grey,
            ),
            tooltip: 'Filtrar por categoría',
            onSelected: (value) => setState(() {
              _categoryFilter = value == 'all'
                  ? null
                  : NoteCategory.values.firstWhere((c) => c.name == value);
            }),
            itemBuilder: (_) => [
              PopupMenuItem<String>(
                value: 'all',
                child: Row(
                  children: [
                    const Icon(
                      Icons.circle_outlined,
                      color: Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text('Todas'),
                    if (_categoryFilter == null)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.check, size: 16),
                      ),
                  ],
                ),
              ),
              ...NoteCategory.values.map(
                (cat) => PopupMenuItem<String>(
                  value: cat.name,
                  child: Row(
                    children: [
                      Icon(Icons.circle, color: cat.color, size: 16),
                      const SizedBox(width: 8),
                      Text(cat.label),
                      if (_categoryFilter == cat)
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

          // ── Ordenar por fecha ──
          IconButton(
            icon: Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
            tooltip: _ascending
                ? 'Más antiguas primero'
                : 'Más recientes primero',
            onPressed: () => setState(() => _ascending = !_ascending),
          ),

          // ── Filtro por tipo ──
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'all', child: Text('Todas')),
              PopupMenuItem(value: 'text', child: Text('Solo texto')),
              PopupMenuItem(value: 'checklist', child: Text('Solo checklist')),
            ],
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.errorMessage != null
          ? Center(child: Text(vm.errorMessage!))
          : notes.isEmpty
          ? const Center(child: Text('No hay notas aún'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteCard(
                  note: note,
                  onDelete: () => _confirmDelete(context, note, vm),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditorScreen(note: note)),
                  ),
                );
              },
            ),

      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        spacing: 12,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.note, color: Colors.white),
            label: 'Nota de texto',
            backgroundColor: Colors.indigo,
            labelBackgroundColor: Colors.indigo,
            labelStyle: const TextStyle(color: Colors.white),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditorScreen()),
            ),
          ),
          SpeedDialChild(
            child: const Icon(Icons.checklist, color: Colors.white),
            label: 'Checklist',
            backgroundColor: Colors.teal,
            labelBackgroundColor: Colors.teal,
            labelStyle: const TextStyle(color: Colors.white),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EditorScreen(type: 'checklist'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

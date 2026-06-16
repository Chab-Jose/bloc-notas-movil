import 'package:blog_note_android/models/check_list_note.dart';
import 'package:blog_note_android/models/note.dart';
import 'package:blog_note_android/models/text_note.dart';
import 'package:blog_note_android/viewmodels/note_viewmodel.dart';
import 'package:blog_note_android/views/editor/editor_screen.dart';
import 'package:blog_note_android/views/home/widgets/note_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filter = 'all'; // 'all', 'text', 'checklist'
  bool _ascending = false; // false = más reciente primero

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

  void _showTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Qué tipo de nota?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('Nota de texto'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditorScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.checklist),
              title: const Text('Checklist'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditorScreen(type: 'checklist'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NoteViewModel>();
    final notes = _applyFilters(vm.notes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Notas'),
        actions: [
          // Botón ordenar por fecha
          IconButton(
            icon: Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
            tooltip: _ascending
                ? 'Más antiguas primero'
                : 'Más recientes primero',
            onPressed: () => setState(() => _ascending = !_ascending),
          ),

          // Menú filtrar por tipo
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

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTypeDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

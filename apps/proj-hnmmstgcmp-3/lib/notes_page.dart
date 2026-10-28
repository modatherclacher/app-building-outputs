import 'package:flutter/material.dart';

import 'note.dart';
import 'note_edit_page.dart';
import 'notes_store.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key, required this.store});

  final NotesStore store;

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _searchController = TextEditingController();

  NotesStore get _store => widget.store;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openEditor({Note? note}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => NoteEditPage(store: _store, note: note),
      ),
    );
  }

  Future<void> _confirmDelete(Note note) async {
    final bool? deleted = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This note will be removed from this device.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (deleted ?? false) {
      _store.delete(note);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Notes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: ListenableBuilder(
              listenable: _store,
              builder: (BuildContext context, Widget? child) {
                return TextField(
                  controller: _searchController,
                  onChanged: _store.search,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search notes',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    suffixIcon: _store.isSearching
                        ? IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              _store.search('');
                            },
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _store,
        builder: (BuildContext context, Widget? child) {
          final List<Note> notes = _store.notes;
          if (notes.isEmpty) {
            return _EmptyState(searching: _store.isSearching);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
            itemCount: notes.length,
            itemBuilder: (BuildContext context, int index) {
              final Note note = notes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(
                    note.title.isEmpty ? 'Untitled' : note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: note.body.isEmpty
                      ? null
                      : Text(
                          note.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                  trailing: Text(
                    MaterialLocalizations.of(context)
                        .formatMediumDate(note.modified),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  onTap: () => _openEditor(note: note),
                  onLongPress: () => _confirmDelete(note),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New note',
        onPressed: _openEditor,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.searching});

  final bool searching;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            searching ? Icons.search_off : Icons.sticky_note_2_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            searching ? 'No matching notes' : 'No notes yet',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            searching
                ? 'Try a different keyword.'
                : 'Tap + to write your first note.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

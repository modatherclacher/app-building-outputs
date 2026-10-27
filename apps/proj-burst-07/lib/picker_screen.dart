import 'package:flutter/material.dart';

import 'picker_state.dart';

class PickerScreen extends StatefulWidget {
  const PickerScreen({super.key, required this.state});

  final PickerState state;

  @override
  State<PickerScreen> createState() => _PickerScreenState();
}

class _PickerScreenState extends State<PickerScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitName() {
    if (widget.state.addName(_nameController.text)) {
      _nameController.clear();
      return;
    }
    _showSnackBar('Enter a non-empty name that is not already in the list.');
  }

  Future<void> _editName(int index) async {
    final controller = TextEditingController(text: widget.state.names[index]);
    final updated = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || updated == null) return;
    if (!widget.state.editName(index, updated)) {
      _showSnackBar('Enter a non-empty name that is not already in the list.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(title: const Text('Random Picker')),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _ResultPanel(state: state),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _PickControls(state: state),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    'Names (${state.nameCount})',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: state.names.isEmpty
                      ? const _EmptyListHint()
                      : _NameList(
                          names: state.names,
                          onEdit: _editName,
                          onRemove: state.removeName,
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: _AddNameRow(
                    controller: _nameController,
                    onSubmit: _submitName,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.state});

  final PickerState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (state.results.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.casino_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.canPick
                      ? 'Draw a random subset — results appear here.'
                      : 'Add names below to get started.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Picked ${state.results.length} of ${state.nameCount}',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Clear results',
                  onPressed: state.clearResults,
                  icon: const Icon(Icons.clear_all),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < state.results.length; i++)
                  Chip(
                    avatar: Text('${i + 1}'),
                    label: Text(state.results[i]),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PickControls extends StatelessWidget {
  const _PickControls({required this.state});

  final PickerState state;

  @override
  Widget build(BuildContext context) {
    final canPick = state.canPick;
    return Row(
      children: [
        IconButton(
          tooltip: 'Fewer names',
          onPressed: state.pickCount > 1
              ? () => state.setPickCount(state.pickCount - 1)
              : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text(
          canPick ? '${state.pickCount} of ${state.nameCount}' : 'No names yet',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          tooltip: 'More names',
          onPressed: canPick && state.pickCount < state.nameCount
              ? () => state.setPickCount(state.pickCount + 1)
              : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: canPick ? state.pick : null,
          icon: const Icon(Icons.shuffle),
          label: const Text('Pick'),
        ),
      ],
    );
  }
}

class _EmptyListHint extends StatelessWidget {
  const _EmptyListHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_outlined, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text('No names yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Add a few names below, then pick a random subset.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NameList extends StatelessWidget {
  const _NameList({
    required this.names,
    required this.onEdit,
    required this.onRemove,
  });

  final List<String> names;
  final void Function(int) onEdit;
  final void Function(int) onRemove;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: names.length,
      padding: const EdgeInsets.only(bottom: 8),
      itemBuilder: (context, index) {
        final name = names[index];
        return ListTile(
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text(name),
          onTap: () => onEdit(index),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => onEdit(index),
              ),
              IconButton(
                tooltip: 'Remove',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => onRemove(index),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AddNameRow extends StatelessWidget {
  const _AddNameRow({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            decoration: const InputDecoration(
              hintText: 'Add a name',
              prefixIcon: Icon(Icons.person_add_alt),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          tooltip: 'Add name',
          onPressed: onSubmit,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

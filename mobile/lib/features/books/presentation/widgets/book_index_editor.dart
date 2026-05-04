import 'package:flutter/material.dart';

import '../../../../core/theme/stripe_colors.dart';
import '../../../../models/book_index_draft.dart';

typedef AddChildCallback = void Function(String parentId);
typedef RemoveNodeCallback = void Function(String nodeId);

class BookIndexEditor extends StatelessWidget {
  const BookIndexEditor({
    super.key,
    required this.nodes,
    required this.onAddRoot,
    required this.onAddChild,
    required this.onRemoveNode,
  });

  final List<BookIndexDraft> nodes;
  final VoidCallback onAddRoot;
  final AddChildCallback onAddChild;
  final RemoveNodeCallback onRemoveNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Índices',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton.icon(
              onPressed: onAddRoot,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar índice'),
            ),
          ],
        ),
        if (nodes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Nenhum índice adicionado.'),
          ),
        ...nodes.map(
          (node) => _BookIndexDraftTile(
            draft: node,
            depth: 0,
            onAddChild: onAddChild,
            onRemoveNode: onRemoveNode,
          ),
        ),
      ],
    );
  }
}

class _BookIndexDraftTile extends StatelessWidget {
  const _BookIndexDraftTile({
    required this.draft,
    required this.depth,
    required this.onAddChild,
    required this.onRemoveNode,
  });

  final BookIndexDraft draft;
  final int depth;
  final AddChildCallback onAddChild;
  final RemoveNodeCallback onRemoveNode;

  @override
  Widget build(BuildContext context) {
    final left = 8.0 + (depth * 12);

    return Container(
      margin: EdgeInsets.only(left: left, bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: StripeColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          TextFormField(
            initialValue: draft.titulo,
            decoration: const InputDecoration(labelText: 'Título do índice'),
            onChanged: (value) => draft.titulo = value,
            validator: (value) {
              if ((value ?? '').trim().isEmpty) {
                return 'Título obrigatório.';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: draft.pagina,
            decoration: const InputDecoration(labelText: 'Página'),
            keyboardType: TextInputType.number,
            onChanged: (value) => draft.pagina = value,
            validator: (value) {
              final page = int.tryParse((value ?? '').trim());
              if (page == null || page <= 0) {
                return 'Página inválida.';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => onAddChild(draft.id),
                icon: const Icon(Icons.subdirectory_arrow_right),
                label: const Text('Aninhar'),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => onRemoveNode(draft.id),
                icon: const Icon(Icons.delete_outline),
                color: StripeColors.errorRuby,
              ),
            ],
          ),
          if (draft.filhos.isNotEmpty)
            ...draft.filhos.map(
              (child) => _BookIndexDraftTile(
                draft: child,
                depth: depth + 1,
                onAddChild: onAddChild,
                onRemoveNode: onRemoveNode,
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../models/book_index_node.dart';
import '../../../../core/theme/stripe_colors.dart';

class BookIndexTree extends StatelessWidget {
  const BookIndexTree({
    super.key,
    required this.indices,
  });

  final List<BookIndexNode> indices;

  @override
  Widget build(BuildContext context) {
    if (indices.isEmpty) {
      return const Text('Sem índices cadastrados.');
    }

    return Column(
      children: indices
          .map((node) => _BookIndexTile(node: node))
          .toList(growable: false),
    );
  }
}

class _BookIndexTile extends StatelessWidget {
  const _BookIndexTile({required this.node});

  final BookIndexNode node;

  @override
  Widget build(BuildContext context) {
    final hasChildren = node.subindices.isNotEmpty;
    final title = '${node.titulo} (p. ${node.pagina})';

    if (!hasChildren) {
      return ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: Text(title),
      );
    }

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 8),
      collapsedIconColor: StripeColors.label,
      iconColor: StripeColors.purple,
      title: Text(title),
      children: node.subindices
          .map((child) => Padding(
                padding: const EdgeInsets.only(left: 12),
                child: _BookIndexTile(node: child),
              ))
          .toList(growable: false),
    );
  }
}

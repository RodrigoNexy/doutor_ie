import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../models/book.dart';
import '../../../models/book_index_draft.dart';
import 'widgets/book_index_editor.dart';

class BookFormPage extends ConsumerStatefulWidget {
  const BookFormPage({
    super.key,
    this.existingBook,
  });

  final Book? existingBook;

  bool get isEdit => existingBook != null;

  @override
  ConsumerState<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends ConsumerState<BookFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _paginasController = TextEditingController();
  bool _saving = false;
  int _draftCounter = 0;
  final List<BookIndexDraft> _indices = <BookIndexDraft>[];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingBook;
    if (existing != null) {
      _tituloController.text = existing.titulo;
      _paginasController.text = existing.numeroPaginas.toString();
      for (final node in existing.indices) {
        _indices.add(BookIndexDraft.fromNode(node, _nextId()));
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _paginasController.dispose();
    super.dispose();
  }

  String _nextId() {
    _draftCounter += 1;
    return 'draft_$_draftCounter';
  }

  void _addRoot() {
    setState(() {
      _indices.add(BookIndexDraft.empty(_nextId()));
    });
  }

  void _addChild(String parentId) {
    final parent = _findById(parentId, _indices);
    if (parent == null) {
      return;
    }
    setState(() {
      parent.filhos.add(BookIndexDraft.empty(_nextId()));
    });
  }

  void _removeNode(String nodeId) {
    setState(() {
      _removeById(nodeId, _indices);
    });
  }

  BookIndexDraft? _findById(String id, List<BookIndexDraft> nodes) {
    for (final node in nodes) {
      if (node.id == id) {
        return node;
      }
      final inChild = _findById(id, node.filhos);
      if (inChild != null) {
        return inChild;
      }
    }
    return null;
  }

  bool _removeById(String id, List<BookIndexDraft> nodes) {
    for (var i = 0; i < nodes.length; i += 1) {
      if (nodes[i].id == id) {
        nodes.removeAt(i);
        return true;
      }
      if (_removeById(id, nodes[i].filhos)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _saving = true);
    try {
      final titulo = _tituloController.text.trim();
      final paginas = int.parse(_paginasController.text.trim());
      final remote = ref.read(booksRemoteDataSourceProvider);

      if (widget.isEdit) {
        await remote.update(
          bookId: widget.existingBook!.id,
          titulo: titulo,
          numeroPaginas: paginas,
          indices: _indices,
        );
      } else {
        await remote.create(
          titulo: titulo,
          numeroPaginas: paginas,
          indices: _indices,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Editar livro' : 'Novo livro'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              widget.isEdit ? 'Atualize o livro' : 'Cadastrar novo livro',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D1D1F),
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isEdit
                  ? 'Altere os campos abaixo para atualizar os dados.'
                  : 'Preencha os dados e monte a estrutura de índices.',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8A8A8D),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F1F3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Dados do livro',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _tituloController,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Título obrigatório.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _paginasController,
                    decoration: const InputDecoration(
                      labelText: 'Número de páginas',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final pages = int.tryParse((value ?? '').trim());
                      if (pages == null || pages <= 0) {
                        return 'Número de páginas inválido.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F1F3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: BookIndexEditor(
                nodes: _indices,
                onAddRoot: _addRoot,
                onAddChild: _addChild,
                onRemoveNode: _removeNode,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving
                        ? null
                        : () => Navigator.of(context).maybePop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1D1D1F),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.isEdit ? 'Salvar' : 'Criar livro'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

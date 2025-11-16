import 'package:clipstick/features/tags/presentation/widgets/notecard_widget.dart';
import 'package:clipstick/features/tags/presentation/widgets/notelistitem.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/tag_model.dart';
import '../../../../data/models/note_model.dart';
import '../../../home/presentation/cubit/view_mode_cubit.dart';

class TagViewScreen extends StatefulWidget {
  final TagModel tag;
  final List<NoteModel>? allNotes; // 🆕 RECEBE TODAS AS NOTAS

  const TagViewScreen({
    super.key,
    required this.tag,
    this.allNotes, // 🆕 OPCIONAL (por enquanto)
  });

  @override
  State<TagViewScreen> createState() => _TagViewScreenState();
}

class _TagViewScreenState extends State<TagViewScreen> {
  late TagModel _currentTag;
  List<NoteModel> _notesWithTag = [];

  @override
  void initState() {
    super.initState();
    _currentTag = widget.tag;
    _loadNotesWithTag();
  }

  // 📥 CARREGAR NOTAS COM ESTE MARCADOR (ATUALIZADO)
  void _loadNotesWithTag() {
    setState(() {
      if (widget.allNotes != null) {
        // ✅ FILTRA NOTAS QUE CONTÊM ESTE MARCADOR
        _notesWithTag = widget.allNotes!.where((note) {
          return note.tags != null && note.tags!.contains(_currentTag.id);
        }).toList();

        // ✅ ORDENA: Fixadas primeiro, depois por posição
        _notesWithTag.sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return a.position.compareTo(b.position);
        });
      } else {
        // TODO: Buscar do banco de dados quando implementar persistência
        _notesWithTag = [];
      }
    });
  }

  // ✏️ RENOMEAR MARCADOR
  void _showRenameDialog() {
    Get.dialog(
      _RenameTagDialog(
        currentName: _currentTag.name,
        onRename: (newName) {
          _renameTag(newName);
        },
      ),
    );
  }

  // ✏️ EXECUTAR RENOMEAÇÃO
  void _renameTag(String newName) {
    setState(() {
      _currentTag = _currentTag.copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );
    });

    HapticFeedback.mediumImpact();

    Get.snackbar(
      'Marcador Renomeado',
      '"${widget.tag.name}" → "$newName" ✏️',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );

    // TODO: Atualizar no banco de dados
  }

  // 🗑️ CONFIRMAR EXCLUSÃO DO MARCADOR
  void _showDeleteDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Excluir Marcador?',
          style: AppTextStyles.headingSmall.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ao excluir um marcador você apenas vai removê-lo de todas as notas que possuíam esse marcador.',
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: 12),
            Text(
              'As notas NÃO serão excluídas.',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _deleteTag();
            },
            child: Text(
              'Excluir',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🗑️ EXECUTAR EXCLUSÃO
  void _deleteTag() {
    HapticFeedback.heavyImpact();

    Get.back();

    Get.snackbar(
      'Marcador Excluído',
      '"${_currentTag.name}" foi removido de todas as notas 🗑️',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      colorText: Theme.of(context).colorScheme.onErrorContainer,
    );

    // TODO: Remover marcador de todas as notas no banco de dados
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ViewModeCubit(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          title: Row(
            children: [
              Icon(
                Icons.label,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  _currentTag.name,
                  style: AppTextStyles.headingMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Get.snackbar(
                  'Em Breve',
                  'Função de busca será implementada',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              tooltip: 'Buscar',
            ),

            BlocBuilder<ViewModeCubit, ViewModeState>(
              builder: (context, viewMode) {
                return IconButton(
                  icon: Icon(
                    viewMode == ViewMode.grid
                      ? Icons.view_list
                      : Icons.grid_view,
                  ),
                  onPressed: () {
                    context.read<ViewModeCubit>().toggleViewMode();
                    HapticFeedback.selectionClick();
                  },
                  tooltip: viewMode == ViewMode.grid
                    ? 'Visualização em Lista'
                    : 'Visualização em Grade',
                );
              },
            ),

            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              tooltip: 'Mais opções',
              onSelected: (value) {
                if (value == 'rename') {
                  _showRenameDialog();
                } else if (value == 'delete') {
                  _showDeleteDialog();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'rename',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Renomear marcador',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Excluir marcador',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_notesWithTag.isEmpty) {
      return _buildEmptyState(context);
    }

    return BlocBuilder<ViewModeCubit, ViewModeState>(
      builder: (context, viewMode) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: viewMode == ViewMode.grid
            ? _buildGridView()
            : _buildListView(),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: _notesWithTag.length,
      itemBuilder: (context, index) {
        return NoteCard(
          note: _notesWithTag[index],
          onTap: () {
            // TODO: Abrir nota para edição
          },
          onLongPress: () {
            // TODO: Entrar em modo seleção
          },
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: _notesWithTag.length,
      itemBuilder: (context, index) {
        return NoteListItem(
          note: _notesWithTag[index],
          onTap: () {
            // TODO: Abrir nota para edição
          },
          onLongPress: () {
            // TODO: Entrar em modo seleção
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.label_off_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: 16),
          Text(
            'Nenhuma nota com este marcador',
            style: AppTextStyles.headingSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Adicione o marcador "${_currentTag.name}"\nem suas notas para vê-las aqui',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// WIDGET DO DIALOG (sem mudanças)
class _RenameTagDialog extends StatefulWidget {
  final String currentName;
  final Function(String newName) onRename;

  const _RenameTagDialog({
    required this.currentName,
    required this.onRename,
  });

  @override
  State<_RenameTagDialog> createState() => _RenameTagDialogState();
}

class _RenameTagDialogState extends State<_RenameTagDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleRename() {
    final newName = _controller.text.trim();
    if (newName.isNotEmpty && newName != widget.currentName) {
      Get.back();
      widget.onRename(newName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Renomear Marcador',
        style: AppTextStyles.headingSmall,
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          labelText: 'Nome do marcador',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _handleRename(),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _handleRename,
          child: Text('Renomear'),
        ),
      ],
    );
  }
}
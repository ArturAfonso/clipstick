import 'dart:ui';

import 'package:clipstick/data/models/note_model.dart';
import 'package:clipstick/data/models/tag_model.dart';
import 'package:clipstick/features/home/presentation/cubit/view_mode_cubit.dart';
import 'package:clipstick/features/home/presentation/widgets/color_picker_dialog.dart';
import 'package:clipstick/features/tags/presentation/screens/edit_tags_screen.dart';
import 'package:clipstick/features/tags/presentation/screens/tag_screen_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import '../widgets/create_note_sheet.dart';
import '../widgets/edit_note_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _gridViewKey = GlobalKey();
  // ✅ LISTA DE NOTAS COMO ESTADO LOCAL
  late List<NoteModel> _notes;

    // 🆕 LISTA CENTRALIZADA DE TAGS
  late List<TagModel> _availableTags;

  // 🆕 CONTROLE DE SELEÇÃO
  final Set<String> _selectedNoteIds = {};
  bool _isDragging = false;
  int? _longPressedIndex;

  // 🆕 GETTERS PARA SEPARAR NOTAS FIXADAS E OUTRAS
  List<NoteModel> get _pinnedNotes =>
      _notes.where((note) => note.isPinned).toList()..sort((a, b) => a.position.compareTo(b.position));

  List<NoteModel> get _otherNotes =>
      _notes.where((note) => !note.isPinned).toList()..sort((a, b) => a.position.compareTo(b.position));

  bool get _hasPinnedNotes => _pinnedNotes.isNotEmpty;

  // 🆕 MÉTODO PARA TOGGLE PIN
  void _togglePinSelectedNotes() {
    if (_selectedNoteIds.isEmpty) return;

    // ✅ Verifica se todos selecionados estão fixados
    final allPinned = _selectedNoteIds.every((id) => _notes.firstWhere((n) => n.id == id).isPinned);

    // ✅ Salva quantidade antes de limpar
    final count = _selectedNoteIds.length;

    setState(() {
      // Toggle: se todos fixados, desfixar. Senão, fixar todos
      for (final noteId in _selectedNoteIds) {
        final index = _notes.indexWhere((n) => n.id == noteId);
        if (index != -1) {
          _notes[index] = _notes[index].copyWith(isPinned: !allPinned);
        }
      }
    });

    // ✅ Limpa seleção
    _clearSelection();

    // ✅ Feedback háptico
    HapticFeedback.mediumImpact();

    // ✅ Notificação
    Get.snackbar(
      count > 1 ? (allPinned ? 'Notas Desfixadas' : 'Notas Fixadas') : (allPinned ? 'Nota Desfixada' : 'Nota Fixada'),
      '$count nota${count > 1 ? 's' : ''} ${allPinned ? 'desfixada' : 'fixada'}${count > 1 ? 's' : ''} 📌',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  @override
  void initState() {
    super.initState();
    _notes = _getSampleNotes();
    _availableTags = _getSampleTags();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

   // 🆕 MÉTODO PARA CARREGAR TAGS DE EXEMPLO
  List<TagModel> _getSampleTags() {
    return [
      TagModel(
        id: '1',
        name: 'Trabalho',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TagModel(
        id: '2',
        name: 'Pessoal',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TagModel(
        id: '3',
        name: 'Ideias',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // 🆕 MÉTODOS DE SELEÇÃO
  bool get _isSelectionMode => _selectedNoteIds.isNotEmpty;

  bool _isNoteSelected(String noteId) {
    return _selectedNoteIds.contains(noteId);
  }

  void _toggleNoteSelection(String noteId) {
    setState(() {
      if (_selectedNoteIds.contains(noteId)) {
        _selectedNoteIds.remove(noteId);
      } else {
        _selectedNoteIds.add(noteId);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedNoteIds.clear();
    });
  }

  void _deleteSelectedNotes() {
    final count = _selectedNoteIds.length;
    setState(() {
      _notes.removeWhere((note) => _selectedNoteIds.contains(note.id));
      _selectedNoteIds.clear();
    });

    Get.snackbar(
      'Notas Excluídas',
      '$count nota${count > 1 ? 's' : ''} excluída${count > 1 ? 's' : ''} com sucesso! 🗑️',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  // 🆕 INTERCEPTAR BOTÃO VOLTAR DO CELULAR
  Future<bool> _onWillPop() async {
    if (_isSelectionMode) {
      _clearSelection();
      return false; // Não sai do app, apenas cancela seleção
    }
    return true; // Permite sair do app
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // 🆕 APPBAR COM TRANSIÇÃO ANIMADA
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: SafeArea(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                // ✅ ANIMAÇÃO DE ESCALA DO CENTRO
                return ScaleTransition(
                  scale: animation,
                  alignment: Alignment.center,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: _isSelectionMode
                  ? _buildSelectionAppBar(context) // 🆕 AppBar de seleção
                  : _buildNormalAppBar(context), // ✅ AppBar normal
            ),
          ),
        ),
        /* AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.all(8),
              ),
              icon: Icon(Icons.auto_awesome_mosaic_outlined, color: Theme.of(context).colorScheme.onSecondary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Text('Minhas notas', style: AppTextStyles.headingMedium),
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSecondary),
              onPressed: () {
                // TODO: Implementar busca
              },
            ),
      
            // 🎯 BOTÃO ÚNICO COM ANIMAÇÃO
            BlocBuilder<ViewModeCubit, ViewModeState>(
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: IconButton(
                    key: ValueKey(state.isGridView), // ✅ Key para AnimatedSwitcher
                    icon: Icon(
                      state.isGridView ? Icons.view_list : Icons.grid_view,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    onPressed: () {
                      if (state.isGridView) {
                        context.read<ViewModeCubit>().setListView();
                      } else {
                        context.read<ViewModeCubit>().setGridView();
                      }
                    },
                    tooltip: state.isGridView ? 'Visualização em Lista' : 'Visualização em Grade',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.all(8),
                    ),
                  ),
                );
              },
            ),
      
            SizedBox(width: 8),
          ],
        ) */

        // 📱 DRAWER
        drawer: _buildDrawer(context),

        // 📝 BODY - CONTEÚDO PRINCIPAL
        body: Stack(
          children: [
            BlocBuilder<ViewModeCubit, ViewModeState>(
              builder: (context, state) {
                return _buildNotesView(context, state);
              },
            ),

            /*   // 🆕 BANNER FLUTUANTE DE SELEÇÃO
            if (_isSelectionMode)
              _buildSelectionBanner(context), */
          ],
        ),
        floatingActionButton: _isSelectionMode
            ? null
            : FloatingActionButton(
                onPressed: () {
                  _showCreateNoteSheet(context);
                },
                tooltip: 'Criar nova nota',
                child: Icon(Icons.add),
              ),
      ),
    );
  }

  // ✅ APPBAR NORMAL
  Widget _buildNormalAppBar(BuildContext context) {
    return AppBar(
      key: ValueKey('normal_appbar'), // ✅ Key para AnimatedSwitcher
      leading: Builder(
        builder: (context) => IconButton(
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.all(8),
          ),
          icon: Icon(Icons.auto_awesome_mosaic_outlined, color: Theme.of(context).colorScheme.onSecondary),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Text('Minhas notas', style: AppTextStyles.headingMedium),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSecondary),
          onPressed: () {
            // TODO: Implementar busca
          },
        ),

        BlocBuilder<ViewModeCubit, ViewModeState>(
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: animation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: IconButton(
                key: ValueKey(state.isGridView),
                icon: Icon(
                  state.isGridView ? Icons.view_list : Icons.grid_view,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                onPressed: () {
                  if (state.isGridView) {
                    context.read<ViewModeCubit>().setListView();
                  } else {
                    context.read<ViewModeCubit>().setGridView();
                  }
                },
                tooltip: state.isGridView ? 'Visualização em Lista' : 'Visualização em Grade',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.all(8),
                ),
              ),
            );
          },
        ),

        SizedBox(width: 8),
      ],
    );
  }

  // 🆕 APPBAR DE SELEÇÃO COM MENU DE MAIS OPÇÕES (ATUALIZADO)
Widget _buildSelectionAppBar(BuildContext context) {
  final allPinned = _selectedNoteIds.every((id) => _notes.firstWhere((n) => n.id == id).isPinned);

  return AppBar(
    key: ValueKey('selection_appbar'),
    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    leading: IconButton(
      icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onPrimaryContainer),
      onPressed: _clearSelection,
      tooltip: 'Cancelar seleção',
    ),
    title: Text(
      '${_selectedNoteIds.length} selecionada${_selectedNoteIds.length > 1 ? 's' : ''}',
      style: AppTextStyles.bodyLarge.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    ),
    actions: [
      // 📌 BOTÃO PIN
      IconButton(
        icon: Icon(
          allPinned ? Icons.push_pin : Icons.push_pin_outlined,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        onPressed: _togglePinSelectedNotes,
        tooltip: allPinned ? 'Desfixar' : 'Fixar',
      ),

      // 🏷️ BOTÃO TAGS
      IconButton(
        icon: Icon(
          Icons.label_outline,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        onPressed: _showTagSelectionDialog,
        tooltip: 'Adicionar marcadores',
      ),

      // 🎨 BOTÃO MUDAR COR
      IconButton(
        icon: Icon(Icons.palette_outlined),
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        onPressed: _changeColorOfSelectedNotes,
        tooltip: 'Alterar cor',
      ),

      // 🗑️ BOTÃO DELETAR
      IconButton(
        icon: Icon(Icons.delete_outline),
        color: Theme.of(context).colorScheme.error,
        onPressed: () => _showDeleteConfirmationDialog(context),
        tooltip: 'Excluir selecionadas',
      ),

      // 📁 MAIS OPÇÕES (ATUALIZADO!)
      PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        tooltip: 'Mais opções',
        onSelected: (value) {
          switch (value) {
            case 'copy':
              _duplicateSelectedNotes();
              break;
            case 'share':
              _shareSelectedNotes();
              break;
          }
        },
        itemBuilder: (context) => [
          // 📋 FAZER CÓPIA
          PopupMenuItem(
            value: 'copy',
            child: Row(
              children: [
                Icon(
                  Icons.content_copy,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                SizedBox(width: 12),
                Text(
                  'Fazer cópia',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),

          // 🔗 COMPARTILHAR
          PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                Icon(
                  Icons.share,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                SizedBox(width: 12),
                Text(
                  'Compartilhar',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),

      SizedBox(width: 8),
    ],
  );
}


// 📋 DUPLICAR NOTAS SELECIONADAS
void _duplicateSelectedNotes() {
  if (_selectedNoteIds.isEmpty) return;

  final count = _selectedNoteIds.length;
  final List<NoteModel> newNotes = [];

  setState(() {
    for (final noteId in _selectedNoteIds) {
      final originalNote = _notes.firstWhere((n) => n.id == noteId);
      
      // ✅ Cria nova nota com ID único e título modificado
      final duplicatedNote = NoteModel(
        id: Uuid().v4(), // 🆕 ID ÚNICO
        title: originalNote.title.isEmpty 
          ? 'Sem título (cópia)' 
          : '${originalNote.title} (cópia)',
        content: originalNote.content,
        color: originalNote.color,
        isPinned: false, // ✅ Cópia não é fixada
        position: _notes.length + newNotes.length, // ✅ Adiciona no final
        tags: originalNote.tags != null 
          ? List<String>.from(originalNote.tags!) // ✅ Copia tags
          : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      newNotes.add(duplicatedNote);
    }

    // ✅ Adiciona todas as novas notas
    _notes.addAll(newNotes);
  });

  _clearSelection();

  HapticFeedback.mediumImpact();

  Get.snackbar(
    'Cópia${count > 1 ? 's' : ''} Criada${count > 1 ? 's' : ''}',
    '$count nota${count > 1 ? 's' : ''} duplicada${count > 1 ? 's' : ''} com sucesso! 📋',
    snackPosition: SnackPosition.BOTTOM,
    duration: Duration(seconds: 2),
  );

  // TODO: Salvar no banco de dados
}




// ...existing code...

// 🔗 COMPARTILHAR NOTAS SELECIONADAS
void _shareSelectedNotes() async {
  if (_selectedNoteIds.isEmpty) return;

  final count = _selectedNoteIds.length;
  final StringBuffer textToShare = StringBuffer();

  // ✅ Monta o texto para compartilhar
  for (int i = 0; i < _selectedNoteIds.length; i++) {
    final noteId = _selectedNoteIds.elementAt(i);
    final note = _notes.firstWhere((n) => n.id == noteId);

    // ✅ Formato: "Título: Conteúdo"
    if (note.title.isNotEmpty) {
      textToShare.write('${note.title}: ');
    }
    textToShare.writeln(note.content);

    // ✅ Adiciona separador entre notas (exceto na última)
    if (i < _selectedNoteIds.length - 1) {
      textToShare.writeln('\n---\n');
    }
  }

  HapticFeedback.selectionClick();

  try {
    // ✅ Compartilha usando Share Plus
    final result = await Share.share(
      textToShare.toString(),
      subject: count > 1 
        ? 'ClipStick - $count notas' 
        : 'ClipStick - ${_notes.firstWhere((n) => n.id == _selectedNoteIds.first).title}',
    );

    // ✅ Feedback após compartilhar
    if (result.status == ShareResultStatus.success) {
      Get.snackbar(
        'Compartilhado!',
        '$count nota${count > 1 ? 's' : ''} compartilhada${count > 1 ? 's' : ''} 🔗',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
      _clearSelection();
    }
  } catch (e) {
    Get.snackbar(
      'Erro ao Compartilhar',
      'Não foi possível compartilhar as notas',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      colorText: Theme.of(context).colorScheme.onErrorContainer,
    );
  }
}


// 🏷️ MOSTRAR DIALOG DE SELEÇÃO DE TAGS (ATUALIZADO)
void _showTagSelectionDialog() async {
  if (_selectedNoteIds.isEmpty) return;

  // TODO: Carregar tags reais do banco de dados
 final availableTags = _availableTags;

  // ✅ Se não há tags cadastradas, mostra mensagem
  if (availableTags.isEmpty) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.label_off_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 12),
            Text(
              'Nenhum Marcador',
              style: AppTextStyles.headingSmall,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.label_off_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            SizedBox(height: 16),
            Text(
              'Você ainda não possui marcadores cadastrados.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Crie seu primeiro marcador para organizar suas notas!',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Agora Não'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back(); // Fecha dialog
              Get.to(() => EditTagsScreen()); // Vai para tela de criar tags
            },
            icon: Icon(Icons.add),
            label: Text('Criar Marcador'),
          ),
        ],
      ),
    );
    return;
  }

  // ✅ Pega tags atuais das notas selecionadas
  final Set<String> currentTags = {};
  for (final noteId in _selectedNoteIds) {
    final note = _notes.firstWhere((n) => n.id == noteId);
    if (note.tags != null) {
      currentTags.addAll(note.tags!);
    }
  }

  // ✅ Controla seleção local no dialog
  final Set<String> selectedTagIds = Set.from(currentTags);

  await Get.dialog(
    StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.label,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Selecionar Marcadores',
                  style: AppTextStyles.headingSmall,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ℹ️ INFORMAÇÃO
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_selectedNoteIds.length} nota${_selectedNoteIds.length > 1 ? 's' : ''} selecionada${_selectedNoteIds.length > 1 ? 's' : ''}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // 📋 LISTA DE TAGS
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableTags.length,
                    itemBuilder: (context, index) {
                      final tag = availableTags[index];
                      final isSelected = selectedTagIds.contains(tag.id);

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setDialogState(() {
                            if (value == true) {
                              selectedTagIds.add(tag.id);
                            } else {
                              selectedTagIds.remove(tag.id);
                            }
                          });
                          HapticFeedback.selectionClick();
                        },
                        title: Text(
                          tag.name,
                          style: AppTextStyles.bodyMedium,
                        ),
                        secondary: Icon(
                          Icons.label,
                          color: isSelected 
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        ),
                        activeColor: Theme.of(context).colorScheme.primary,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      );
                    },
                  ),
                ),

                // 💡 DICA
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Selecione um ou mais marcadores',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // ❌ CANCELAR
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancelar'),
            ),

            // ✅ CONFIRMAR
            ElevatedButton(
              onPressed: () {
                Get.back();
                _applyTagsToSelectedNotes(selectedTagIds.toList());
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    ),
  );
}


 
// 🏷️ APLICAR TAGS NAS NOTAS SELECIONADAS
void _applyTagsToSelectedNotes(List<String> tagIds) {
  if (_selectedNoteIds.isEmpty) return;

  final count = _selectedNoteIds.length;

  setState(() {
    for (final noteId in _selectedNoteIds) {
      final index = _notes.indexWhere((n) => n.id == noteId);
      if (index != -1) {
         // ✅ ATUALIZA TAGS DA NOTA
        // Se lista vazia, remove todas as tags (null)
        // Se tem tags, aplica a nova lista
        _notes[index] = _notes[index].copyWith(
          tags: tagIds.isEmpty ? [] : tagIds, // 🆕 USA LISTA VAZIA EM VEZ DE NULL
          updatedAt: DateTime.now(),
        );
      }
    }
  });

  _clearSelection();

  HapticFeedback.mediumImpact();

  // ✅ Notificação customizada
  if (tagIds.isEmpty) {
    Get.snackbar(
      'Marcadores Removidos',
      '$count nota${count > 1 ? 's' : ''} sem marcadores 🏷️',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  } else {
    Get.snackbar(
      'Marcadores Aplicados',
      '${tagIds.length} marcador${tagIds.length > 1 ? 'es' : ''} adicionado${tagIds.length > 1 ? 's' : ''} a $count nota${count > 1 ? 's' : ''} 🏷️',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  // TODO: Salvar no banco de dados
}

// 📭 ESTADO VAZIO (SEM TAGS)
Widget _buildEmptyTagsState(BuildContext context) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.label_off_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        ),
        SizedBox(height: 12),
        Text(
          'Nenhum marcador criado',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {
            Get.back();
            Get.to(() => EditTagsScreen());
          },
          icon: Icon(Icons.add),
          label: Text('Criar primeiro marcador'),
        ),
      ],
    ),
  );
}



  // 🗑️ DIÁLOGO DE CONFIRMAÇÃO DE EXCLUSÃO
  void _showDeleteConfirmationDialog(BuildContext context) {
    final count = _selectedNoteIds.length;

    Get.dialog(
      AlertDialog(
        title: Text('Excluir $count nota${count > 1 ? 's' : ''}?'),
        content: Text(
          count > 1
              ? 'Tem certeza que deseja excluir as $count notas selecionadas? Esta ação não pode ser desfeita.'
              : 'Tem certeza que deseja excluir esta nota? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancelar')),
          TextButton(
            onPressed: () {
              Get.back();
              _deleteSelectedNotes();
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesView(BuildContext context, ViewModeState state) {
    if (_notes.isEmpty) {
      return _buildEmptyState(context, state);
    }

    return state.isGridView ? _buildGridView(context) : _buildListView(context);
  }

  // 📝 DADOS DE EXEMPLO
  List<NoteModel> _getSampleNotes() {
    return [
      NoteModel(
        id: '1',
        title: 'Lista de compras',
        content: 'Leite, pão, ovos, frutas, café, açúcar',
        color: AppColors.lightNoteYellow,
        position: 0,
        isPinned: true, createdAt: null, updatedAt: null, // 🆕 FIXADO
      ),
      NoteModel(
        id: '2',
        title: 'Ideias para o projeto',
        content: 'Implementar dark mode, adicionar sincronização na nuvem, melhorar performance',
        color: AppColors.lightNotePink,
        position: 1,
        isPinned: false,
      ),
      NoteModel(
        id: '3',
        title: 'Treino da semana',
        content: 'Segunda: Peito e tríceps\nQuarta: Costas e bíceps\nSexta: Pernas',
        color: AppColors.lightNoteGreen,
        position: 2,
        isPinned: true, // 🆕 FIXADO
      ),
      NoteModel(
        id: '4',
        title: 'Livros para ler',
        content: 'Clean Code, Design Patterns, Refactoring',
        color: AppColors.lightNoteBlue,
        position: 3,
        isPinned: false,
      ),
      NoteModel(
        id: '5',
        title: 'Receita de bolo',
        content: '3 ovos, 2 xícaras de açúcar, 2 xícaras de farinha, 1 xícara de leite, 4kg de caju, 2kg de castanha, tres paes',
        color: AppColors.lightNoteOrange,
        position: 4,
        isPinned: false,
      ),
    ];
  }

  // 🌟 TELA VAZIA
  Widget _buildEmptyState(BuildContext context, ViewModeState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sticky_note_2_outlined, size: 120, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          SizedBox(height: 24),
          Text(
            'Bem-vindo ao ClipStick!',
            style: AppTextStyles.headingMedium.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Suas notas auto adesivas digitais.\nModo atual: ${state.isGridView ? "Grade 📊" : "Lista 📋"}\nArraste e solte para reordenar suas notas!',
              style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Get.snackbar('Nova Nota', 'Funcionalidade em breve! ✨', snackPosition: SnackPosition.BOTTOM);
            },
            icon: Icon(Icons.add),
            label: Text('Criar primeira nota'),
          ),
        ],
      ),
    );
  }

  // 📊 GRID VIEW COM SEÇÕES (FIXADOS + OUTROS)
  Widget _buildGridView(BuildContext context) {
    // ✅ Se não tem notas fixadas, usa layout simples
    if (!_hasPinnedNotes) {
      return _buildSimpleGridView(context);
    }

    // ✅ Se tem fixadas, usa layout com seções
    return _buildSectionedGridView(context);
  }

  // 📊 GRID VIEW SIMPLES (SEM FIXADOS)
  Widget _buildSimpleGridView(BuildContext context) {
    final generatedChildren = List.generate(_notes.length, (index) => _buildGridNoteCard(context, _notes[index]));

    return Padding(
      padding: EdgeInsets.all(16),
      child: ReorderableBuilder(
        scrollController: _scrollController,
        enableLongPress: true,
        longPressDelay: Duration(milliseconds: 500),
        enableDraggable: true,
        enableScrollingWhileDragging: true,
        automaticScrollExtent: 80.0,
        fadeInDuration: Duration(milliseconds: 300),
        releasedChildDuration: Duration(milliseconds: 200),
        positionDuration: Duration(milliseconds: 250),
        dragChildBoxDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 3),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
              offset: Offset(0, 6),
            ),
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, spreadRadius: 2, offset: Offset(0, 4)),
          ],
        ),
        onReorder: (ReorderedListFunction reorderedListFunction) {
          setState(() {
            _notes = reorderedListFunction(_notes) as List<NoteModel>;
            for (int i = 0; i < _notes.length; i++) {
              _notes[i] = _notes[i].copyWith(position: i);
            }
            _isDragging = true;
          });
        },
        onDragStarted: (index) {
          setState(() {
            _longPressedIndex = index;
            _isDragging = false;
          });
          HapticFeedback.mediumImpact();
        },
        onDragEnd: (index) {
          HapticFeedback.lightImpact();
          Future.delayed(Duration(milliseconds: 100), () {
            if (!_isDragging && _longPressedIndex != null) {
              final noteId = _notes[_longPressedIndex!].id;
              setState(() {
                _toggleNoteSelection(noteId);
                _longPressedIndex = null;
              });
              HapticFeedback.selectionClick();
            }
            setState(() {
              _isDragging = false;
              _longPressedIndex = null;
            });
          });
        },
        builder: (children) {
          return GridView(
            key: _gridViewKey,
            controller: _scrollController,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            children: children,
          );
        },
        children: generatedChildren,
      ),
    );
  }

  // 📊 GRID VIEW COM SEÇÕES (FIXADOS + OUTROS) - CORRIGIDO
  Widget _buildSectionedGridView(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📌 SEÇÃO DE FIXADOS
          if (_pinnedNotes.isNotEmpty) ...[
            _buildSectionHeader(context, '📌 FIXADOS', _pinnedNotes.length),
            SizedBox(height: 12),
            _buildReorderableGridSection(
              context,
              _pinnedNotes,
              isPinnedSection: true, // ✅ Flag para identificar seção
            ),
            SizedBox(height: 24),
          ],

          // 📋 SEÇÃO DE OUTRAS NOTAS
          if (_otherNotes.isNotEmpty) ...[
            _buildSectionHeader(context, '📋 OUTRAS NOTAS', _otherNotes.length),
            SizedBox(height: 12),
            _buildReorderableGridSection(
              context,
              _otherNotes,
              isPinnedSection: false, // ✅ Flag para identificar seção
            ),
          ],
        ],
      ),
    );
  }

  // 📊 GRID REORDENÁVEL DE UMA SEÇÃO (COM DRAG & DROP)
  Widget _buildReorderableGridSection(BuildContext context, List<NoteModel> notes, {required bool isPinnedSection}) {
    final generatedChildren = List.generate(notes.length, (index) => _buildGridNoteCard(context, notes[index]));

    return ReorderableBuilder(
      enableLongPress: true,
      longPressDelay: Duration(milliseconds: 500),
      enableDraggable: true,
      enableScrollingWhileDragging: false, // ✅ Desabilita scroll automático (já está em SingleChildScrollView)
      automaticScrollExtent: 0, // ✅ Desabilita scroll automático

      fadeInDuration: Duration(milliseconds: 300),
      releasedChildDuration: Duration(milliseconds: 200),
      positionDuration: Duration(milliseconds: 250),

      dragChildBoxDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 3),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 5,
            offset: Offset(0, 6),
          ),
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, spreadRadius: 2, offset: Offset(0, 4)),
        ],
      ),

      onReorder: (ReorderedListFunction reorderedListFunction) {
        setState(() {
          // ✅ Reordena apenas dentro da seção correspondente
          if (isPinnedSection) {
            // Reordena fixados
            final reorderedPinned = reorderedListFunction(_pinnedNotes) as List<NoteModel>;

            // Atualiza posições dentro da lista completa
            for (int i = 0; i < reorderedPinned.length; i++) {
              final noteIndex = _notes.indexWhere((n) => n.id == reorderedPinned[i].id);
              if (noteIndex != -1) {
                _notes[noteIndex] = reorderedPinned[i].copyWith(position: i);
              }
            }
          } else {
            // Reordena outras notas
            final reorderedOthers = reorderedListFunction(_otherNotes) as List<NoteModel>;

            // Atualiza posições dentro da lista completa
            final pinnedCount = _pinnedNotes.length;
            for (int i = 0; i < reorderedOthers.length; i++) {
              final noteIndex = _notes.indexWhere((n) => n.id == reorderedOthers[i].id);
              if (noteIndex != -1) {
                _notes[noteIndex] = reorderedOthers[i].copyWith(position: pinnedCount + i);
              }
            }
          }

          _isDragging = true;
        });
      },

      onDragStarted: (index) {
        setState(() {
          // ✅ Mapeia índice local para índice global
          final noteId = notes[index].id;
          _longPressedIndex = _notes.indexWhere((n) => n.id == noteId);
          _isDragging = false;
        });
        HapticFeedback.mediumImpact();
      },

      onDragEnd: (index) {
        HapticFeedback.lightImpact();
        Future.delayed(Duration(milliseconds: 100), () {
          if (!_isDragging && _longPressedIndex != null) {
            final noteId = _notes[_longPressedIndex!].id;
            setState(() {
              _toggleNoteSelection(noteId);
              _longPressedIndex = null;
            });
            HapticFeedback.selectionClick();
          }
          setState(() {
            _isDragging = false;
            _longPressedIndex = null;
          });
        });
      },

      builder: (children) {
        return GridView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          children: children,
        );
      },

      children: generatedChildren,
    );
  }

  // 🏷️ HEADER DE SEÇÃO
  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(width: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  // 📊 GRID DE UMA SEÇÃO
  Widget _buildGridSection(BuildContext context, List<NoteModel> notes) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return _buildGridNoteCard(context, notes[index]);
      },
    );
  }

  // 📋 LIST VIEW COM DRAG & DROP - VERSÃO PREMIUM
  Widget _buildListView(BuildContext context) {
    return ReorderableListView.builder(
      padding: EdgeInsets.all(16),
      // ✅ CUSTOMIZAR O VISUAL AO ARRASTAR - VERSÃO PREMIUM
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            final double animValue = Curves.easeInOut.transform(animation.value);
            final double elevation = lerpDouble(2, 12, animValue)!;
            final double scale = lerpDouble(1.0, 1.08, animValue)!;
            final double rotation = lerpDouble(0, 0.02, animValue)!; // ✅ ROTAÇÃO SUTIL

            return Transform.rotate(
              angle: rotation,
              child: Transform.scale(
                scale: scale,
                child: Material(
                  elevation: elevation,
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    color: _notes[index].color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        width: 2, // ✅ BORDA DESTACADA AO ARRASTAR
                      ),
                    ),
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: child,
        );
      },
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final NoteModel item = _notes.removeAt(oldIndex);
          _notes.insert(newIndex, item);

          for (int i = 0; i < _notes.length; i++) {
            _notes[i] = _notes[i].copyWith(position: i);
          }
        });
      },
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return _buildListNoteCard(context, note);
      },
    );
  }

  // 🎯 CARD PARA GRID VIEW COM VISUAL DE SELEÇÃO
  Widget _buildGridNoteCard(BuildContext context, NoteModel note) {
    final isSelected = _isNoteSelected(note.id);

    return GestureDetector(
      key: Key(note.id), // ✅ KEY MOVIDA PARA O WIDGET MAIS EXTERNO!
      // ✅ TAP SIMPLES: Abre nota OU adiciona à seleção
      onTap: () {
        if (_isSelectionMode) {
          // Se já está em modo seleção, adiciona/remove da seleção
          _toggleNoteSelection(note.id);
          HapticFeedback.selectionClick();
        } else {
          // Abre a nota para editar
          _openNote(context, note);
        }
      },

      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,

        // ✅ DECORAÇÃO QUANDO SELECIONADO
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent, width: 3),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 3,
                  ),
                ]
              : [],
        ),

        child: Card(
          margin: EdgeInsets.zero,
          color: note.color,
          elevation: isSelected ? 4 : 2,
          shadowColor: Theme.of(context).colorScheme.shadow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // ✅ ÍCONE DE CHECK QUANDO SELECIONADO
                    if (isSelected)
                      Container(
                        padding: EdgeInsets.all(4),
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                        child: Icon(Icons.check, size: 14, color: Theme.of(context).colorScheme.onPrimary),
                      ),

                    Expanded(
                      child: Text(
                        note.title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // ✅ ÍCONE DE DRAG (só aparece se NÃO estiver selecionado)
                    if (!isSelected)
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(Icons.drag_indicator, size: 14, color: Theme.of(context).colorScheme.primary),
                      ),
                  ],
                ),
                SizedBox(height: 8),
                Expanded(
                  child: Text(
                    note.content,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Visibility(
                visible: note.tags != null && note.tags!.isNotEmpty,
                child: Column(children: [
                   SizedBox(height: 8),
               _buildTagsRow(context, note),
                ],),
              )
               
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🆕 WIDGET PARA EXIBIR TAGS NO CARD
Widget _buildTagsRow(BuildContext context, NoteModel note) {
  // ✅ Se não tem tags, retorna espaço vazio
  if (note.tags == null || note.tags!.isEmpty) {
    return SizedBox(height: 20); // Mantém altura para consistência
  }

  // ✅ Busca nomes das tags
  final tagNames = note.tags!.map((tagId) {
    final tag = _availableTags.firstWhere(
      (t) => t.id == tagId,
      orElse: () => TagModel(
        id: tagId,
        name: 'Tag',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return tag.name;
  }).toList();

  return Wrap(
    spacing: 4,
    runSpacing: 4,
    children: [
      // ✅ Mostra até 2 tags
      ...tagNames.take(2).map((tagName) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.label,
                size: 10,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              SizedBox(width: 3),
              Text(
                tagName,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 9,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }),

      // ✅ Indicador "+N" se houver mais de 2 tags
      if (tagNames.length > 2)
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '+${tagNames.length - 2}',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 9,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
    ],
  );
}

  // 🎯 CARD PARA LIST VIEW (Draggable)
  Widget _buildListNoteCard(BuildContext context, NoteModel note) {
    return Card(
      key: ValueKey(note.id),
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Theme.of(context).colorScheme.shadow,
      color: note.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        /*  leading: Container(width: 6, height: 60, decoration: BoxDecoration(color: note.color,
        borderRadius: BorderRadius.circular(3),),), */
        title: Text(
          note.title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 8),
          child: Column(
            children: [
              Text(
                note.content,
                style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (note.tags != null && note.tags!.isNotEmpty)
               SizedBox(height: 12),
            _buildTagsRow(context, note),
            ],
          ),
          
        ),
     
        onTap: () => _openNote(context, note),
      ),
    );
  }

  // 📖 FUNÇÃO PARA ABRIR NOTA PARA EDIÇÃO
  void _openNote(BuildContext context, NoteModel note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => EditNoteSheet(note: note),
      ),
    ).then((result) {
      // ✅ Recebe resultado do BottomSheet
      if (result != null) {
        if (result == 'delete') {
          // TODO: Implementar delete
          setState(() {
            _notes.removeWhere((n) => n.id == note.id);
          });
        } else if (result is NoteModel) {
          // TODO: Implementar update
          setState(() {
            final index = _notes.indexWhere((n) => n.id == note.id);
            if (index != -1) {
              _notes[index] = result;
            }
          });
        }
      }
    });
  }

  // 🎨 DIÁLOGO DE TEMAS
  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Escolher Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.brightness_auto),
              title: Text('Automático'),
              subtitle: Text('Segue o sistema'),
              onTap: () {
                Get.changeThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.light_mode),
              title: Text('Claro'),
              onTap: () {
                Get.changeThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.dark_mode),
              title: Text('Escuro'),
              onTap: () {
                Get.changeThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ℹ️ DIÁLOGO SOBRE O APP
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'ClipStick',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(Icons.sticky_note_2, size: 48, color: Theme.of(context).colorScheme.primary),
      children: [
        Text(
          'ClipStick é seu mural digital de notas rápidas. '
          'Registre ideias, listas e lembretes em cartões coloridos '
          'que mantêm tudo claro, leve e organizado.',
        ),
      ],
    );
  }

  // 📝 FUNÇÃO PARA MOSTRAR BOTTOMSHEET DE CRIAR NOTA
  void _showCreateNoteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => CreateNoteSheet(),
      ),
    );
  }

  void _changeColorOfSelectedNotes() async {
    if (_selectedNoteIds.isEmpty) return;

    // ✅ Pega a cor da primeira nota selecionada como inicial
    final firstSelectedNote = _notes.firstWhere((n) => _selectedNoteIds.contains(n.id));

    // ✅ Abre o dialog de seleção de cor
    final Color? selectedColor = await Get.dialog<Color>(
      ColorPickerDialog(
        initialColor: firstSelectedNote.color,
        isMultipleSelection: _selectedNoteIds.length > 1,
        selectedCount: _selectedNoteIds.length,
      ),
    );

    // ✅ Se selecionou uma cor, aplica
    if (selectedColor != null) {
      final count = _selectedNoteIds.length;

      setState(() {
        for (final noteId in _selectedNoteIds) {
          final index = _notes.indexWhere((n) => n.id == noteId);
          if (index != -1) {
            _notes[index] = _notes[index].copyWith(color: selectedColor);
          }
        }
      });

      _clearSelection();

      HapticFeedback.mediumImpact();

      Get.snackbar(
        'Cor Alterada',
        '$count nota${count > 1 ? 's' : ''} atualizada${count > 1 ? 's' : ''} 🎨',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
        backgroundColor: selectedColor,
        colorText: _getContrastColor(selectedColor),
      );
    }
  }

  // 🎨 CALCULAR COR DE CONTRASTE (helper)
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // 🆕 ADICIONAR SEÇÃO DE MARCADORES NO DRAWER
  Widget _buildTagsSection(BuildContext context) {
  // TODO: Carregar tags reais do estado/banco
   // ✅ USA A LISTA CENTRALIZADA (removido o hardcode)
  final tags = _availableTags;
  final hasTags = tags.isNotEmpty;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // 🏷️ HEADER DA SEÇÃO
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MARCADORES',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            if (hasTags)
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.to(() => EditTagsScreen());
                },
                child: Text(
                  'Editar',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),

      // 📋 LISTA DE MARCADORES
      ...tags.map((tag) => _buildTagItem(
        context,
        tag,
        _getIconForTag(tag.name), // 🆕 FUNÇÃO PARA ÍCONE DINÂMICO
      )),

      SizedBox(height: 8),

      // ➕ BOTÃO CRIAR NOVO MARCADOR
      ListTile(
        leading: Icon(
          Icons.add_circle_outline,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          'Criar Novo Marcador',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () {
          Get.back();
          Get.to(() => EditTagsScreen());
        },
      ),

      Divider(height: 24),
    ],
  );
}

// 🏷️ ITEM DE MARCADOR (ATUALIZADO COM PASSAGEM DE NOTAS)
Widget _buildTagItem(BuildContext context, TagModel tag, IconData icon) {
  // ✅ CONTA QUANTAS NOTAS TÊM ESTE MARCADOR
  final noteCount = _notes.where((note) {
    return note.tags != null && note.tags!.contains(tag.id);
  }).length;

  return ListTile(
    leading: Icon(
      icon,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      size: 20,
    ),
    title: Text(
      tag.name,
      style: AppTextStyles.bodyMedium,
    ),
    // ✅ MOSTRA CONTADOR DE NOTAS
    trailing: noteCount > 0
      ? Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$noteCount',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        )
      : null,
    onTap: () {
      Get.back(); // Fecha drawer
      // ✅ PASSA A LISTA DE NOTAS PARA A TELA DO MARCADOR
      Get.to(() => TagViewScreen(
        tag: tag,
        allNotes: _notes, // 🆕 PASSA TODAS AS NOTAS
      ));
    },
  );
}

// 🆕 FUNÇÃO AUXILIAR PARA ÍCONES DINÂMICOS
IconData _getIconForTag(String tagName) {
  switch (tagName.toLowerCase()) {
    case 'trabalho':
      return Icons.work_outline;
    case 'pessoal':
      return Icons.person_outline;
    case 'ideias':
      return Icons.lightbulb_outline;
    case 'estudo':
      return Icons.school_outlined;
    case 'compras':
      return Icons.shopping_cart_outlined;
    default:
      return Icons.label_outline;
  }
}

  @override
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 🎨 HEADER DO DRAWER
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.sticky_note_2, size: 48, color: Colors.white),
                SizedBox(height: 16),
                Text('ClipStick', style: AppTextStyles.headingMedium.copyWith(color: Colors.white)),
                SizedBox(height: 4),
                Text(
                  'Suas notas organizadas',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),

          // 📋 OPÇÕES DO MENU
          ListTile(
            leading: Icon(Icons.home_outlined),
            title: Text('Início'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: Icon(Icons.note_add_outlined),
            title: Text('Nova Nota'),
            onTap: () {
              Navigator.pop(context);
              Get.snackbar('Nova Nota', 'Funcionalidade em breve!', snackPosition: SnackPosition.BOTTOM);
            },
          ),
           Divider(),

         _buildTagsSection(context),

          Divider(),

          ListTile(
            leading: Icon(Icons.palette_outlined),
            title: Text('Temas'),
            onTap: () {
              Navigator.pop(context);
              _showThemeDialog(context);
            },
          ),

          ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text('Configurações'),
            onTap: () {
              Navigator.pop(context);
              Get.snackbar('Configurações', 'Funcionalidade em breve!', snackPosition: SnackPosition.BOTTOM);
            },
          ),

          Divider(),

          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Sobre'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }
}

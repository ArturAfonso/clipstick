import 'dart:ui';

import 'package:clipstick/core/theme/note_colors_helper.dart';
import 'package:clipstick/core/theme/themetoggle_button.dart';
import 'package:clipstick/data/models/note_model.dart';
import 'package:clipstick/data/models/tag_model.dart';
import 'package:clipstick/features/home/presentation/cubit/home_cubit.dart';
import 'package:clipstick/features/home/presentation/cubit/home_state.dart';
import 'package:clipstick/features/home/presentation/cubit/view_mode_cubit.dart';
import 'package:clipstick/features/home/presentation/widgets/color_picker_dialog.dart';
import 'package:clipstick/features/tags/presentation/cubit/tags_cubit.dart';
import 'package:clipstick/features/tags/presentation/cubit/tags_state.dart';
import 'package:clipstick/features/tags/presentation/screens/edit_tags_screen.dart';
import 'package:clipstick/features/tags/presentation/screens/tag_screen_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:reorderables/reorderables.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import '../widgets/create_note_sheet.dart';
import '../widgets/edit_note_sheet.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _gridViewKey = GlobalKey();

  // 🆕 CONTROLE DE SELEÇÃO
  final Set<String> _selectedNoteIds = {};
  bool _isDragging = false;
  int? _longPressedIndex;

  // 🆕 MÉTODO PARA TOGGLE PIN
  Future<void> _togglePinSelectedNotes() async {
    if (_selectedNoteIds.isEmpty) return;

    // Pegue as notas do estado atual do Cubit
    final noteState = context.read<HomeCubit>().state;
    if (noteState is! HomeLoaded) return;

    final notes = noteState.notes;
    // Verifica se todos selecionados estão fixados
    final allPinned = _selectedNoteIds.every((id) => notes.firstWhere((n) => n.id == id).isPinned);

    // Cria as notas atualizadas (toggle pin)
    final updatedNotes = notes
        .where((n) => _selectedNoteIds.contains(n.id))
        .map((note) => note.copyWith(isPinned: !allPinned, updatedAt: DateTime.now()))
        .toList();

    // Atualiza em lote via Cubit
    await context.read<HomeCubit>().updateNotesBatch(updatedNotes);

    _clearSelection();

    HapticFeedback.mediumImpact();

    final count = _selectedNoteIds.length;
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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _deleteSelectedNotes() async {
    if (_selectedNoteIds.isEmpty) return;

    final count = _selectedNoteIds.length;

    // Chama o Cubit para deletar as notas selecionadas
    await context.read<HomeCubit>().deleteNotesBatch(_selectedNoteIds.toList());

    _clearSelection();

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
            child: Material(
              elevation: 0.5,
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
        ),
        // 📱 DRAWER
        drawer: _buildDrawer(context),

        // 📝 BODY - CONTEÚDO PRINCIPAL
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, noteState) {
            if (noteState is HomeError) {
              return Center(child: Text(noteState.message));
            }
            if (noteState is HomeLoading) {
              return Center(child: CircularProgressIndicator());
            }
            List<NoteModel> notesFromDatabase = [];
            if (noteState is HomeLoaded) {
              notesFromDatabase = noteState.notes;
            }

            return BlocBuilder<ViewModeCubit, ViewModeState>(
              builder: (context, state) {
                return _buildNotesView(context, state, notesFromDb: notesFromDatabase);
              },
            );
          },
        ),
        floatingActionButton: _isSelectionMode
            ? null
            : BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoaded && state.notes.isEmpty) {
                    return Container();
                  }
                  return FloatingActionButton(
                    onPressed: () {
                      _showCreateNoteSheet(context);
                    },
                    tooltip: 'Criar nova nota',
                    child: Icon(Icons.add),
                  );
                },
              ),
      ),
    );
  }

  // ✅ APPBAR NORMAL
  Widget _buildNormalAppBar(BuildContext context) {
    return AppBar(
      elevation: 10,
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
      title: Text('Minhas notas', style: AppTextStyles.headingMedium.copyWith(fontWeight: FontWeight.bold)),
      actions: [
        /*   IconButton(
          icon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSecondary),
          onPressed: () {
            // TODO: Implementar busca
          },
        ),
 */
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
                  context.read<ViewModeCubit>().toggleViewMode();
                  /*  if (state.isGridView) {
                    context.read<ViewModeCubit>().setListView();
                  } else {
                    context.read<ViewModeCubit>().setGridView();
                  } */
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
    // Pegue as notas do estado atual do Cubit
    final noteState = context.read<HomeCubit>().state;
    if (noteState is! HomeLoaded) return Container();

    final notes = noteState.notes;
    final allPinned = _selectedNoteIds.every((id) => notes.firstWhere((n) => n.id == id).isPinned);

    return AppBar(
      elevation: 10,
      key: ValueKey('selection_appbar'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      surfaceTintColor: Theme.of(context).colorScheme.primary,
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
            color: Theme.of(context).colorScheme.surface,
          ),
          onPressed: _togglePinSelectedNotes,
          tooltip: allPinned ? 'Desfixar' : 'Fixar',
        ),

        // 🏷️ BOTÃO TAGS
        IconButton(
          icon: Icon(MdiIcons.tagOutline, color: Theme.of(context).colorScheme.surface),
          onPressed: _showTagSelectionDialog,
          tooltip: 'Adicionar marcadores',
        ),

        // 🎨 BOTÃO MUDAR COR
        IconButton(
          icon: Icon(Icons.palette_outlined),
          color: Theme.of(context).colorScheme.surface,
          onPressed: _changeColorOfSelectedNotes,
          tooltip: 'Alterar cor',
        ),

        // 🗑️ BOTÃO DELETAR
        IconButton(
          icon: Icon(FontAwesomeIcons.trashCan, size: 20),
          color: Theme.of(context).colorScheme.surface,
          onPressed: () => _showDeleteConfirmationDialog(context),
          tooltip: 'Excluir selecionadas',
        ),

        // 📁 MAIS OPÇÕES (ATUALIZADO!)
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.secondary),
          color: Theme.of(context).colorScheme.onSecondary,
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
                  Icon(Icons.content_copy, size: 20, color: Theme.of(context).colorScheme.onPrimary),
                  SizedBox(width: 12),
                  Text(
                    'Fazer cópia',
                    style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ],
              ),
            ),

            // 🔗 COMPARTILHAR
            PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, size: 20, color: Theme.of(context).colorScheme.onPrimary),
                  SizedBox(width: 12),
                  Text(
                    'Compartilhar',
                    style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onPrimary),
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
  Future<void> _duplicateSelectedNotes() async {
    if (_selectedNoteIds.isEmpty) return;

    // Pegue as notas do estado atual do Cubit
    final noteState = context.read<HomeCubit>().state;
    if (noteState is! HomeLoaded) return;

    final notes = noteState.notes;
    final List<NoteModel> newNotes = [];

    for (final noteId in _selectedNoteIds) {
      final originalNote = notes.firstWhere((n) => n.id == noteId);

      // Cria nova nota com ID único e título modificado
      final duplicatedNote = NoteModel(
        id: Uuid().v4(),
        title: originalNote.title.isEmpty ? 'Sem título (cópia)' : '${originalNote.title} (cópia)',
        content: originalNote.content,
        color: originalNote.color,
        isPinned: false,
        position: notes.length + newNotes.length, // Adiciona no final
        tags: originalNote.tags != null ? List<String>.from(originalNote.tags!) : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      newNotes.add(duplicatedNote);
    }

    // Salva todas as novas notas no banco de dados via Cubit
    await context.read<HomeCubit>().addNotesBatch(newNotes);

    _clearSelection();

    HapticFeedback.mediumImpact();

    final count = _selectedNoteIds.length;
    Get.snackbar(
      'Cópia${count > 1 ? 's' : ''} Criada${count > 1 ? 's' : ''}',
      '$count nota${count > 1 ? 's' : ''} duplicada${count > 1 ? 's' : ''} com sucesso! 📋',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  // 🔗 COMPARTILHAR NOTAS SELECIONADAS
  void _shareSelectedNotes() async {
    if (_selectedNoteIds.isEmpty) return;

    final noteState = context.read<HomeCubit>().state;
    if (noteState is! HomeLoaded) return;

    final notes = noteState.notes;
    final count = _selectedNoteIds.length;
    final StringBuffer textToShare = StringBuffer();

    // Monta o texto para compartilhar
    for (int i = 0; i < _selectedNoteIds.length; i++) {
      final noteId = _selectedNoteIds.elementAt(i);
      final note = notes.firstWhere((n) => n.id == noteId, orElse: () => NoteModel.empty());

      if (note.title.isNotEmpty) {
        textToShare.write('${note.title}: ');
      }
      textToShare.writeln(note.content);

      if (i < _selectedNoteIds.length - 1) {
        textToShare.writeln('\n---\n');
      }
    }

    HapticFeedback.selectionClick();

    try {
      final result = await Share.share(
        textToShare.toString(),
        subject: count > 1
            ? 'ClipStick - $count notas'
            : 'ClipStick - ${notes.firstWhere((n) => n.id == _selectedNoteIds.first, orElse: () => NoteModel.empty()).title}',
      );

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

  // Importe seu arquivo de tema se precisar das cores específicas
  // import 'theme/app_theme.dart';

  void _showTagSelectionDialog() async {
    if (_selectedNoteIds.isEmpty) return;

    await Get.dialog(
      BlocBuilder<TagsCubit, TagsState>(
        builder: (context, tagState) {
          // --- 1. ESTADO DE CARREGAMENTO ---
          if (tagState is TagsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- 2. ESTADO CARREGADO ---
          if (tagState is TagsLoaded) {
            final availableTags = tagState.tags;
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;
            // Tenta pegar as cores customizadas, senão usa null
            // final noteColors = theme.extension<NoteColors>();

            // --- 2.1 CASO LISTA VAZIA (Mantive sua lógica, ajustei levemente o visual) ---
            if (availableTags.isEmpty) {
              return Dialog(
                backgroundColor: colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.label_off_outlined, size: 48, color: colorScheme.onSurface.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text('Nenhum Marcador', style: AppTextStyles.headingSmall),
                      const SizedBox(height: 8),
                      Text(
                        'Crie seu primeiro marcador para organizar suas notas!',
                        style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Agora Não'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Get.back();
                                Get.to(() => EditTagsScreen());
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.add),
                              label: const Text('Criar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }

            // --- LÓGICA DE PREPARAÇÃO DOS DADOS (Mantida igual) ---
            final noteState = context.read<HomeCubit>().state;
            List<NoteModel> notes = [];
            if (noteState is HomeLoaded) {
              notes = noteState.notes;
            }

            final Set<String> currentTags = {};
            for (final noteId in _selectedNoteIds) {
              final note = notes.firstWhere((n) => n.id == noteId, orElse: () => NoteModel.empty());
              if (note.tags != null) {
                currentTags.addAll(note.tags!);
              }
            }

            final Set<String> selectedTagIds = Set.from(currentTags);

            // --- 3. DIÁLOGO PRINCIPAL COM VISUAL NOVO ---
            return StatefulBuilder(
              builder: (context, setDialogState) {
                return Dialog(
                  backgroundColor: colorScheme.surface,
                  surfaceTintColor: Colors.transparent, // Remove o tint padrão do Material 3
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  insetPadding: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- CABEÇALHO ---
                        Row(
                          children: [
                            Icon(MdiIcons.tagOutline, size: 24, color: colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(child: Text('Selecionar Marcadores', style: AppTextStyles.headingMedium)),
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // --- CONTADOR (Pílula Cinza) ---
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: colorScheme.onSurface.withOpacity(0.1),
                                child: Text(
                                  "${_selectedNoteIds.length}",
                                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "notas selecionadas",
                                style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // --- LISTA DE MARCADORES (Estilo Pílula) ---
                        Flexible(
                          child: SingleChildScrollView(
                            child: Column(
                              children: availableTags.map((tag) {
                                final isSelected = selectedTagIds.contains(tag.id);

                                // TODO: Se seu TagModel tiver cor, use tag.color.
                                // Se não, estou usando uma cor padrão.
                                final tagColor = colorScheme.tertiary;

                                return GestureDetector(
                                  onTap: () {
                                    setDialogState(() {
                                      if (isSelected) {
                                        selectedTagIds.remove(tag.id);
                                      } else {
                                        selectedTagIds.add(tag.id);
                                      }
                                    });
                                    HapticFeedback.selectionClick();
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? colorScheme.surfaceContainerHighest : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected ? colorScheme.primary : colorScheme.outline,
                                        width: isSelected ? 2.0 : 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Bolinha colorida da Tag
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(color: tagColor, shape: BoxShape.circle),
                                        ),
                                        const SizedBox(width: 12),
                                        // Nome da Tag
                                        Expanded(
                                          child: Text(
                                            tag.name,
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        // Check Icon ou Círculo vazio
                                        if (isSelected)
                                          Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: colorScheme.primary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.check, size: 14, color: colorScheme.onPrimary),
                                          )
                                        else
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: colorScheme.outline),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Texto de ajuda
                        Text(
                          "Selecione um ou mais marcadores",
                          style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
                        ),

                        const SizedBox(height: 16),

                        // --- BOTÕES DE AÇÃO (Lado a Lado) ---
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Get.back(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  foregroundColor: colorScheme.onSurface,
                                ),
                                child: const Text("Cancelar"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                  _applyTagsToSelectedNotes(selectedTagIds.toList());
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text("Confirmar", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          // Default Loading
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // 🏷️ APLICAR TAGS NAS NOTAS SELECIONADAS
  Future<void> _applyTagsToSelectedNotes(List<String> tagIds) async {
    if (_selectedNoteIds.isEmpty) return;

    // Pegue as notas do estado atual do Cubit
    final noteState = context.read<HomeCubit>().state;
    if (noteState is! HomeLoaded) return;

    final notes = noteState.notes;
    final updatedNotes = notes
        .where((n) => _selectedNoteIds.contains(n.id))
        .map((note) => note.copyWith(tags: tagIds.isEmpty ? [] : tagIds, updatedAt: DateTime.now()))
        .toList();

    // Atualiza em lote via Cubit
    await context.read<HomeCubit>().updateNotesBatch(updatedNotes);

    _clearSelection();

    HapticFeedback.mediumImpact();

    final count = _selectedNoteIds.length;
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
  }

  // 📭 ESTADO VAZIO (SEM TAGS)
  Widget _buildEmptyTagsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.label_off_outlined, size: 48, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
          SizedBox(height: 12),
          Text(
            'Nenhum marcador criado',
            style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
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

  Widget _buildNotesView(BuildContext context, ViewModeState state, {required List<NoteModel> notesFromDb}) {
    if (notesFromDb.isEmpty) {
      return _buildEmptyState(context, state);
    }

    return state.isGridView
        ? _buildGridView(context, notesFromDb: notesFromDb)
        : _buildListView(context, notesFromDb: notesFromDb);
  }

  // 🌟 TELA VAZIA
  Widget _buildEmptyState(BuildContext context, ViewModeState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.noteSticky, size: 120, color: Theme.of(context).colorScheme.primary),
          SizedBox(height: 24),
          Text(
            'Bem-vindo ao ClipStick!',
            style: AppTextStyles.headingMedium.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Suas notas auto adesivas digitais.\nApós criar suas primeiras notas, você pode organizá-las como quiser pressionando-as e as arrastando!',
              style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              //Get.snackbar('Nova Nota', 'Funcionalidade em breve! ✨', snackPosition: SnackPosition.BOTTOM);

              _showCreateNoteSheet(context);
            },
            icon: Icon(Icons.add),
            label: Text('Criar primeira nota'),
          ),
        ],
      ),
    );
  }

  // 📊 GRID VIEW COM SEÇÕES (FIXADOS + OUTROS)
  Widget _buildGridView(BuildContext context, {required List<NoteModel> notesFromDb}) {
    final pinnedNotes = notesFromDb.where((n) => n.isPinned).toList();
    final otherNotes = notesFromDb.where((n) => !n.isPinned).toList();
    if (pinnedNotes.isEmpty) {
      return _buildSimpleGridView(context, notesFromDb: notesFromDb);
    }

    return _buildSectionedGridView(context, pinnedNotes: pinnedNotes, otherNotes: otherNotes);
  }

  Widget _buildListView(BuildContext context, {required List<NoteModel> notesFromDb}) {
    final pinnedNotes = notesFromDb.where((n) => n.isPinned).toList();
    final otherNotes = notesFromDb.where((n) => !n.isPinned).toList();
    // ✅ Se não tem notas fixadas, usa layout simples
    if (pinnedNotes.isEmpty) {
      return _buildSIMPLEListView(context, notesFromDb: notesFromDb);
    }

    // ✅ Se tem fixadas, usa layout com seções
    return _buildSECTIONEDListView(context, pinnedNotes: pinnedNotes, otherNotes: otherNotes);
  }

  // 📊 GRID VIEW SIMPLES (SEM FIXADOS)
  // ✅ SUBSTITUIR O MÉTODO _buildSimpleGridView
  Widget _buildSimpleGridView(BuildContext context, {required List<NoteModel> notesFromDb}) {
    final generatedChildren = List.generate(
      notesFromDb.length,
      (index) => _buildGridNoteCard(context, notesFromDb[index]),
    );

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 5),
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
          final reorderedNotes = reorderedListFunction(notesFromDb) as List<NoteModel>;
          context.read<HomeCubit>().reorderNotes(List<NoteModel>.from(reorderedNotes));
          setState(() {
            _isDragging = true; // <-- Marque que houve drag real!
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
              // Use notesFromDb para pegar o noteId
              final noteId = notesFromDb[_longPressedIndex!].id;
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
  Widget _buildSectionedGridView(
    BuildContext context, {
    required List<NoteModel> pinnedNotes,
    required List<NoteModel> otherNotes,
  }) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📌 SEÇÃO DE FIXADOS
          if (pinnedNotes.isNotEmpty) ...[
            _buildSectionHeader(context, '📌 FIXADOS', pinnedNotes.length),
            SizedBox(height: 12),
            _buildReorderableGridSection(
              context,
              pinnedNotes,
              isPinnedSection: true, // ✅ Flag para identificar seção
            ),
            SizedBox(height: 24),
          ],

          // 📋 SEÇÃO DE OUTRAS NOTAS
          if (otherNotes.isNotEmpty) ...[
            _buildSectionHeader(context, '📋 OUTRAS NOTAS', otherNotes.length),
            SizedBox(height: 12),
            _buildReorderableGridSection(
              context,
              otherNotes,
              isPinnedSection: false, // ✅ Flag para identificar seção
            ),
          ],
        ],
      ),
    );
  }

  //gpt
  Widget _buildSECTIONEDListView(
    BuildContext context, {
    required List<NoteModel> pinnedNotes,
    required List<NoteModel> otherNotes,
  }) {
    // Helper para criar cada item com gesture + aparência similar ao proxyDecorator
    Widget buildDraggableItem(BuildContext ctx, NoteModel note, int sectionIndex, int indexInSection) {
      // Variáveis locais por item — recreated a cada build, correto
      Offset? pointerDownPos;
      bool tapLock = false;
      bool didMove = false;
      late DateTime pointerDownTime;
      const double moveThreshold = 6.0; // px
      const int longPressThresholdMs = 220; // ms (ajuste se quiser)

      final isSelected = _isNoteSelected(note.id);

      return Listener(
        behavior: HitTestBehavior.opaque,

        onPointerDown: (PointerDownEvent ev) {
          pointerDownPos = ev.position;
          didMove = false;
          pointerDownTime = DateTime.now();
          // marcaremos longPressedIndex quando o long press for confirmado por tempo
          // mas NÃO chamaremos seleção aqui.
          _longPressedIndex = indexInSection;
        },

        onPointerMove: (PointerMoveEvent ev) {
          if (pointerDownPos != null) {
            final distance = (ev.position - pointerDownPos!).distance;
            if (!didMove && distance > moveThreshold) {
              didMove = true;
              // sinalizamos que houve movimento real (arrasto)
              _isDragging = true;
              _longPressedIndex = null;
            }
          }
        },

        onPointerUp: (PointerUpEvent ev) {
          final pressDuration = DateTime.now().difference(pointerDownTime).inMilliseconds;

          // Caso: não houve movimento e o tempo excedeu o threshold -> é long press sem mover => selecionar
          if (!didMove && pressDuration >= longPressThresholdMs) {
            // Toggle selection (long press sem movimento)
            final noteId = note.id;
            setState(() {
              _toggleNoteSelection(noteId);
              _longPressedIndex = null;
            });
            HapticFeedback.selectionClick();
          } else {
            // Caso: tap rápido (pressDuration < threshold) -> abrir nota
            if (!didMove && pressDuration < longPressThresholdMs) {
              if (_isSelectionMode) {
                setState(() => _toggleNoteSelection(note.id));
              } else {
                // TAP NORMAL → ABRIR NOTA (com proteção contra duplo disparo)
                if (!tapLock) {
                  tapLock = true;
                  _openNote(context, note);

                  // libera após um pequeno intervalo
                  Future.delayed(Duration(milliseconds: 120), () {
                    tapLock = false;
                  });
                }
              }
            }

            // Reset flags
            Future.delayed(Duration(milliseconds: 100), () {
              _isDragging = false;
              _longPressedIndex = null;
            });
          }

          pointerDownPos = null;
          didMove = false;
        },

        onPointerCancel: (ev) {
          pointerDownPos = null;
          didMove = false;
          Future.delayed(Duration(milliseconds: 100), () {
            _isDragging = false;
            _longPressedIndex = null;
          });
        },

        // Mantemos o visual do item por baixo do Listener
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: _buildListNoteCard(context, note, isSelected),
        ),
      );
    }

    // Gera os children para cada seção
    final pinnedChildren = List<Widget>.generate(
      pinnedNotes.length,
      (i) => KeyedSubtree(key: ValueKey(pinnedNotes[i].id), child: buildDraggableItem(context, pinnedNotes[i], 0, i)),
    );

    final otherChildren = List<Widget>.generate(
      otherNotes.length,
      (i) => KeyedSubtree(key: ValueKey(otherNotes[i].id), child: buildDraggableItem(context, otherNotes[i], 1, i)),
    );

    return SingleChildScrollView(
      //  controller: _scrollController,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- FIXADOS ----------
          if (pinnedNotes.isNotEmpty) ...[
            _buildSectionHeader(context, '📌 FIXADOS', pinnedNotes.length),
            SizedBox(height: 12),

            ReorderableColumn(
              // mantém  o layout como lista vertical
              crossAxisAlignment: CrossAxisAlignment.start,
              needsLongPressDraggable: true, // exige long press para arrastar (comportamento do grid)
              children: pinnedChildren,
              onReorder: (oldIndex, newIndex) {
                // 1. Reordena apenas a seção de fixados
                final reorderedPinned = List<NoteModel>.from(pinnedNotes);
                final movedNote = reorderedPinned.removeAt(oldIndex);
                reorderedPinned.insert(newIndex, movedNote);

                // 2. Junta com as outras notas
                final newOrder = [...reorderedPinned, ...otherNotes];

                // 3. Atualiza posições
                for (int i = 0; i < newOrder.length; i++) {
                  newOrder[i] = newOrder[i].copyWith(position: i);
                }

                // 4. Salva no banco via Cubit
                context.read<HomeCubit>().reorderNotes(newOrder);

                HapticFeedback.lightImpact();
              },
            ),

            SizedBox(height: 24),
          ],

          // ---------- OUTRAS NOTAS ----------
          if (otherNotes.isNotEmpty) ...[
            _buildSectionHeader(context, '📋 OUTRAS NOTAS', otherNotes.length),
            SizedBox(height: 12),

            ReorderableColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              needsLongPressDraggable: true,
              children: otherChildren,
              onReorder: (oldIndex, newIndex) {
                // 1. Reordena apenas a seção de não fixados
                final reorderedOthers = List<NoteModel>.from(otherNotes);
                final movedNote = reorderedOthers.removeAt(oldIndex);
                reorderedOthers.insert(newIndex, movedNote);

                // 2. Junta com as fixadas
                final newOrder = [...pinnedNotes, ...reorderedOthers];

                // 3. Atualiza posições
                for (int i = 0; i < newOrder.length; i++) {
                  newOrder[i] = newOrder[i].copyWith(position: i);
                }

                // 4. Salva no banco via Cubit
                context.read<HomeCubit>().reorderNotes(newOrder);

                HapticFeedback.lightImpact();
              },
            ),
          ],
        ],
      ),
    );
  }

  // 📊 GRID REORDENÁVEL DE UMA SEÇÃO (COM DRAG & DROP)
  // ✅ SUBSTITUIR O MÉTODO _buildReorderableGridSection
  Widget _buildReorderableGridSection(
    BuildContext context,
    List<NoteModel> tratedNotes, {
    required bool isPinnedSection,
  }) {
    final generatedChildren = List.generate(
      tratedNotes.length,
      (index) => _buildGridNoteCard(context, tratedNotes[index]),
    );

    return ReorderableBuilder(
      enableLongPress: true,
      longPressDelay: Duration(milliseconds: 500),
      enableDraggable: true,
      enableScrollingWhileDragging: false,
      automaticScrollExtent: 0,
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
        // 1. Reordena apenas a seção (fixadas ou não)
        final reorderedSection = reorderedListFunction(tratedNotes) as List<NoteModel>;

        // 2. Monte a lista global reordenada (fixadas + não fixadas)
        final homeCubit = context.read<HomeCubit>();
        final state = homeCubit.state;
        if (state is HomeLoaded) {
          final allNotes = List<NoteModel>.from(state.notes);

          // Separe as outras notas
          final otherSection = isPinnedSection
              ? allNotes.where((n) => !n.isPinned).toList()
              : allNotes.where((n) => n.isPinned).toList();

          // Junte as seções na ordem correta
          final newOrder = isPinnedSection
              ? [...reorderedSection, ...otherSection]
              : [...otherSection, ...reorderedSection];

          // Atualize as posições
          for (int i = 0; i < newOrder.length; i++) {
            newOrder[i] = newOrder[i].copyWith(position: i);
          }

          // 3. Chame o Cubit para salvar no banco
          homeCubit.reorderNotes(newOrder);
        }

        // Marque que houve drag real para evitar seleção indevida no onDragEnd
        setState(() {
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
            // Use a lista da seção (tratedNotes) para pegar o noteId
            final noteId = tratedNotes[_longPressedIndex!].id;
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

  // 📋 LIST VIEW COM DRAG & DROP - VERSÃO PREMIUM
  // ✅ SUBSTITUIR O MÉTODO _buildSIMPLEListView
  Widget _buildSIMPLEListView(BuildContext context, {required List<NoteModel> notesFromDb}) {
    List<Widget> children = List.generate(notesFromDb.length, (index) {
      final note = notesFromDb[index];
      final isSelected = _isNoteSelected(note.id);

      // Controle de toque e seleção
      Offset? pointerDownPos;
      bool didMove = false;
      DateTime? pointerDownTime;
      const double moveThreshold = 6.0;
      const int longPressThresholdMs = 220;

      return Listener(
        key: ValueKey(note.id),
        behavior: HitTestBehavior.opaque,
        onPointerDown: (ev) {
          pointerDownPos = ev.position;
          didMove = false;
          pointerDownTime = DateTime.now();
          _longPressedIndex = index;
        },
        onPointerMove: (ev) {
          if (pointerDownPos != null) {
            final distance = (ev.position - pointerDownPos!).distance;
            if (!didMove && distance > moveThreshold) {
              didMove = true;
              _isDragging = true;
              _longPressedIndex = null;
            }
          }
        },
        onPointerUp: (ev) {
          if (pointerDownTime == null) return;
          final pressDuration = DateTime.now().difference(pointerDownTime!).inMilliseconds;
          if (!didMove && pressDuration >= longPressThresholdMs) {
            // Long press sem mover: ativa seleção
            setState(() {
              _toggleNoteSelection(note.id);
              _longPressedIndex = null;
            });
            HapticFeedback.selectionClick();
          } else if (!didMove && pressDuration < longPressThresholdMs) {
            // Tap rápido: abre nota
            if (_isSelectionMode) {
              setState(() => _toggleNoteSelection(note.id));
            } else {
              _openNote(context, note);
            }
          }
          Future.delayed(Duration(milliseconds: 100), () {
            _isDragging = false;
            _longPressedIndex = null;
          });
          pointerDownPos = null;
          didMove = false;
          pointerDownTime = null;
        },
        onPointerCancel: (ev) {
          pointerDownTime = null;
          pointerDownPos = null;
          didMove = false;
          Future.delayed(Duration(milliseconds: 100), () {
            _isDragging = false;
            _longPressedIndex = null;
          });
        },
        child: _buildListNoteCard(context, note, isSelected, key: ValueKey(note.id)),
      );
    });

    return Padding(
      padding: EdgeInsets.all(16),
      child: ReorderableColumn(
        needsLongPressDraggable: true,
        children: children,
        onReorder: (oldIndex, newIndex) {
          final reorderedNotes = List<NoteModel>.from(notesFromDb);
          final item = reorderedNotes.removeAt(oldIndex);
          reorderedNotes.insert(newIndex, item);

          for (int i = 0; i < reorderedNotes.length; i++) {
            reorderedNotes[i] = reorderedNotes[i].copyWith(position: i);
          }

          context.read<HomeCubit>().reorderNotes(reorderedNotes);

          setState(() {
            _isDragging = true;
          });
        },
      ),
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
                    /*  if (!isSelected)
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(Icons.drag_indicator, size: 14, color: Theme.of(context).colorScheme.primary),
                      ), */
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
                  child: Column(children: [SizedBox(height: 8), _buildTagsRow(context, note)]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🆕 WIDGET PARA EXIBIR TAGS NO CARD
  Widget _buildTagsRow(BuildContext context, NoteModel note) {
    if (note.tags == null || note.tags!.isEmpty) {
      return SizedBox(height: 20);
    }

    return BlocBuilder<TagsCubit, TagsState>(
      builder: (context, tagState) {
        List<String> tagNames = [];
        if (tagState is TagsLoaded) {
          tagNames = note.tags!.map((tagId) {
            final tag = tagState.tags.firstWhere(
              (t) => t.id == tagId,
              orElse: () => TagModel(id: tagId, name: 'Tag', createdAt: DateTime.now(), updatedAt: DateTime.now()),
            );
            return tag.name;
          }).toList();
        }

        return Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            ...tagNames.take(2).map((tagName) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2), width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      MdiIcons.tagOutline,
                      size: 10,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    SizedBox(width: 3),
                    Text(
                      tagName,
                      style: AppTextStyles.bodySmall.copyWith(
                        //fontSize: 9,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
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
      },
    );
  }

  // 🎯 CARD PARA LIST VIEW (Draggable)
  Widget _buildListNoteCard(BuildContext context, NoteModel note, bool isSelected, {Key? key}) {
    final cardElevation = isSelected ? 6.0 : 2.0;
    var realceColor = NoteColorsHelper.getAvailableColors(context).contains(note.color);
    print(realceColor);
    var listaColors = NoteColorsHelper.getAvailableColors(context);
    print(listaColors.first);
    print(note.color);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AnimatedContainer(
        key: key ?? ValueKey(note.id),
        duration: Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3) : null,
        ),
        child: Card(
          key: key ?? ValueKey(note.id),
          //margin: EdgeInsets.only(bottom: 12),
          elevation: cardElevation,
          shadowColor: Theme.of(context).colorScheme.shadow,
          color: note.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.all(10),

            title: Text(
              note.title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color:  Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.content,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (note.tags != null && note.tags!.isNotEmpty) SizedBox(height: 12),
                  _buildTagsRow(context, note),
                ],
              ),
            ),
          ),
        ),
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
      if (result != null) {
        final homeCubit = context.read<HomeCubit>();
        if (result == 'delete') {
          // Chama o Cubit para deletar a nota
          homeCubit.deleteNote(note.id);
        } else if (result is NoteModel) {
          // Chama o Cubit para atualizar a nota
          homeCubit.updateNote(result);
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
                //Get.changeThemeMode(ThemeMode.system);

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

    // Pegue as notas do estado atual do Cubit
    final noteState = context.read<HomeCubit>().state;
    if (noteState is! HomeLoaded) return;

    final notes = noteState.notes;
    final selectedNotes = notes.where((n) => _selectedNoteIds.contains(n.id)).toList();

    if (selectedNotes.isEmpty) return;

    // Cor inicial da primeira selecionada
    final firstSelectedNote = selectedNotes.first;

    // Abre o dialog de seleção de cor
    final Color? selectedColor = await Get.dialog<Color>(
      ColorPickerDialog(
        initialColor: firstSelectedNote.color,
        isMultipleSelection: _selectedNoteIds.length > 1,
        selectedCount: _selectedNoteIds.length,
      ),
    );

    if (selectedColor != null) {
      final count = _selectedNoteIds.length;

      // Cria as notas atualizadas
      final updatedNotes = selectedNotes
          .map((note) => note.copyWith(color: selectedColor, updatedAt: DateTime.now()))
          .toList();

      // Chama o Cubit para atualizar em lote
      await context.read<HomeCubit>().updateNotesBatch(updatedNotes);

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
    final ScrollController tagsScrollController = ScrollController();
    return BlocBuilder<TagsCubit, TagsState>(
      builder: (context, tagState) {
        if (tagState is TagsLoading) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (tagState is TagsLoaded) {
          final tags = tagState.tags;
          final hasTags = tags.isNotEmpty;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🏷️ HEADER DA SEÇÃO
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(MdiIcons.tagOutline),
                    SizedBox(width: 10),
                    Text(
                      'MARCADORES',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface /* .withOpacity(0.6) */,
                      ),
                    ),
                  ],
                ),
              ),

              // 📋 LISTA DE MARCADORES
              if (hasTags)
                if (tags.length > 4)
                  SizedBox(
                    height: Get.size.height / 3,
                    child: Scrollbar(
                      controller: tagsScrollController,
                      thumbVisibility: true,
                      child: ListView.builder(
                        controller: tagsScrollController,
                        shrinkWrap: false,
                        itemCount: tags.length,
                        itemBuilder: (context, index) {
                          final tag = tags[index];
                          return _buildTagItem(context, tag);
                        },
                      ),
                    ),
                  )
                else
                  ...tags.map(
                    (tag) => _buildTagItem(
                      context,
                      tag,
                      //_getIconForTag(tag.name),
                    ),
                  ),

              SizedBox(height: 8),

              // ➕ BOTÃO CRIAR NOVO MARCADOR
              ListTile(
                leading: Icon(
                  tags.isEmpty ? MdiIcons.tagPlusOutline : MdiIcons.tagSearchOutline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  !hasTags ? 'Criar Novo Marcador' : 'Gerenciar Marcadores',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,

                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Get.back();
                  Get.to(() => EditTagsScreen());
                },
              ),

              // Divider(height: 24),
            ],
          );
        }
        // Estado inicial ou erro
        return SizedBox.shrink();
      },
    );
  }

  // 🏷️ ITEM DE MARCADOR (ATUALIZADO COM PASSAGEM DE NOTAS)
  Widget _buildTagItem(BuildContext context, TagModel tag /*  IconData icon */) {
    // Busca as notas do estado atual do Cubit
    final noteState = context.read<HomeCubit>().state;
    List<NoteModel> notes = [];
    if (noteState is HomeLoaded) {
      notes = noteState.notes;
    }

    // Conta quantas notas têm este marcador
    final noteCount = notes.where((note) {
      return note.tags != null && note.tags!.contains(tag.id);
    }).length;

    return ListTile(
      leading: Icon(MdiIcons.tagOutline, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), size: 18),
      title: Text(tag.name, style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface)),
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
        // Passa a lista de notas atual para a tela do marcador
        Get.to(() => TagViewScreen(tag: tag));
      },
    );
  }

  // 🆕 FUNÇÃO AUXILIAR PARA ÍCONES DINÂMICOS
  /* IconData _getIconForTag(String tagName) {
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
 */
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 🎨 HEADER DO DRAWER
          SizedBox(
            height: 120,
            child: DrawerHeader(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12), // metade do tamanho
                    child: Image.asset('assets/clipstick-logo.png', width: 54, height: 54, fit: BoxFit.cover),
                  ),
                  SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ClipStick',
                        style: AppTextStyles.headingMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Suas notas organizadas',
                        style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          _buildTagsSection(context),

          Divider(),

          ThemeToggleButton(),

          /*   ListTile(
            leading: Icon(Icons.palette_outlined),
            title: Text('Temas'),
            onTap: () {
              Navigator.pop(context);
              _showThemeDialog(context);
            },
          ), */
          ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text('Configurações'),
            onTap: () {
              Navigator.pop(context);
              Get.snackbar('Configurações', 'Funcionalidade em breve!', snackPosition: SnackPosition.BOTTOM);
            },
          ),
          ListTile(
            leading: Icon(MdiIcons.databaseArrowDownOutline),
            title: Text('Backup Local'),
            onTap: () {
              Navigator.pop(context);
              Get.snackbar('Configurações', 'Funcionalidade em breve!', snackPosition: SnackPosition.BOTTOM);
            },
          ),
          ListTile(
            leading: Icon(Icons.login_outlined),
            title: Text('Entrar'),
            onTap: () {
              Navigator.pop(context);
              Get.snackbar('Configurações', 'Funcionalidade em breve!', snackPosition: SnackPosition.BOTTOM);
            },
          ),
          ListTile(
            leading: Icon(Icons.person_add_outlined),
            title: Text('Cadastrar'),
            onTap: () {
              Navigator.pop(context);
              Get.snackbar('Configurações', 'Funcionalidade em breve!', snackPosition: SnackPosition.BOTTOM);
            },
          ),

          // Divider(),
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

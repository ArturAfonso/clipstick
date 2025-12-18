// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:clipstick/config/app_config.dart';
import 'package:clipstick/core/utils/utillity.dart';
import 'package:clipstick/data/models/note_model.dart';
import 'package:clipstick/features/home/presentation/cubit/home_cubit.dart';
import 'package:clipstick/features/home/presentation/cubit/home_state.dart';
import 'package:clipstick/features/home/presentation/cubit/view_mode_cubit.dart';
import 'package:clipstick/features/home/presentation/tutorial/home_tutorial_controller.dart';
import 'package:clipstick/features/home/presentation/widgets/appbar_widget.dart';
import 'package:clipstick/features/home/presentation/widgets/home_drawer_wiedget.dart';
import 'package:clipstick/features/home/presentation/widgets/buildgride_notes_card.dart';
import 'package:clipstick/features/home/presentation/widgets/buildlist_notes_card_widget.dart';
import 'package:clipstick/features/home/presentation/widgets/color_picker_dialog.dart';
import 'package:clipstick/features/home/presentation/widgets/empty_state_widget.dart';
import 'package:clipstick/features/home/presentation/widgets/section_header_widget.dart';
import 'package:clipstick/features/tags/presentation/cubit/tags_cubit.dart';
import 'package:clipstick/features/tags/presentation/cubit/tags_state.dart';
import 'package:clipstick/features/tags/presentation/screens/edit_tags_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:reorderables/reorderables.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
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
   final HomeTutorialController _tutorialController = HomeTutorialController();
  final GlobalKey _gridViewKey = GlobalKey();

  

  // Suas GlobalKeys existentes
  final GlobalKey _drawerKey = GlobalKey();
  final GlobalKey _addButtonKey = GlobalKey();
  final GlobalKey _viewModeKey = GlobalKey();

  final Set<String> _selectedNoteIds = {};
  bool _isDragging = false;
  int? _longPressedIndex;

  Future<void> _togglePinSelectedNotes() async {
    if (_selectedNoteIds.isEmpty) return;

    final noteState = context.read<HomeCubit>().state;
    if (noteState is! HomeLoaded) return;

    final notes = noteState.notes;

    final allPinned = _selectedNoteIds.every((id) => notes.firstWhere((n) => n.id == id).isPinned);

    final updatedNotes = notes
        .where((n) => _selectedNoteIds.contains(n.id))
        .map(
          (note) => note.copyWith(
            isPinned: !allPinned,
            updatedAt: DateTime.now(),
            color: note.color,
            content: note.content,
            title: note.title,
            position: note.position,
            tags: note.tags,
            createdAt: note.createdAt,
            id: note.id,
          ),
        )
        .toList();

    await context.read<HomeCubit>().updateNotesBatch(updatedNotes);

    HapticFeedback.mediumImpact();

    //final count = _selectedNoteIds.length;

  /*   Utils.normalSucess(
      title: count > 1
          ? (allPinned ? 'Notas Desfixadas' : 'Notas Fixadas')
          : (allPinned ? 'Nota Desfixada' : 'Nota Fixada'),
      message: '$count nota${count > 1 ? 's' : ''} ${allPinned ? 'desfixada' : 'fixada'}${count > 1 ? 's' : ''} 📌',
    ); */
    _clearSelection();
  }

  @override
  void initState() {
    super.initState();
    _myBannerHome.load();
   _checkAndShowTutorial();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _myBannerHome.dispose();
    super.dispose();
  }

   Future<void> _checkAndShowTutorial() async {
    final shouldShow = await _tutorialController.shouldShowTutorial();
    
    if (shouldShow) {
     
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tutorialController.showTutorial(
          context: context,
          drawerKey: _drawerKey,
          addButtonKey: _addButtonKey,
          viewModeKey: _viewModeKey,
          onFinish: () {
            debugPrint("Tutorial concluído!");
          },
        );
      });
    }
  }


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

    var result = await context.read<HomeCubit>().deleteNotesBatch(_selectedNoteIds.toList());
    if (result) {
      Utils.normalSucess(
        title: count > 1 ? 'Notas Excluídas' : 'Nota Excluída',
        message: '$count nota${count > 1 ? 's' : ''} excluída${count > 1 ? 's' : ''} com sucesso! 🗑️',
      );
    } else {
      Utils.normalException(title: 'Erro ao Excluir', message: 'Não foi possível excluir as notas selecionadas.');
    }

    _clearSelection();
  }

  Future<bool> _onWillPop() async {
    if (_isSelectionMode) {
      _clearSelection();
      return false;
    }
    return true;
  }

  final BannerAd _myBannerHome = BannerAd(
    adUnitId: AppConfig.getAdmobBannerUnitId(), //'ca-app-pub-3940256099942544/9214589741', // Test Ad Unit ID
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(
      onAdOpened: (Ad ad) {
        debugPrint("Ad was opened.");
      },
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        debugPrint('Ad failed to load: $error');
        ad.dispose();
      },
      onAdClosed: (Ad ad) {
        // Called when an ad removes an overlay that covers the screen.
        debugPrint("Ad was closed.");
      },
      onAdImpression: (Ad ad) {
        // Called when an impression occurs on the ad.
        debugPrint("Ad recorded an impression.");
      },
      onAdClicked: (Ad ad) {
        // Called when an a click event occurs on the ad.
        debugPrint("Ad was clicked.");
      },
      onAdWillDismissScreen: (Ad ad) {
        // iOS only. Called before dismissing a full screen view.
        debugPrint("Ad will be dismissed.");
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: HomeAppbar(
            viewModeKey: _viewModeKey,
            drawerKey: _drawerKey,
            isSelectionMode: _isSelectionMode, 
            buildContext: context,
            selectedNoteIds: _selectedNoteIds,
            onClearSelection: _clearSelection,
            togglePinSelectedNotes: _togglePinSelectedNotes,
            showTagSelectionDialog: _showTagSelectionDialog,
            changeColorOfSelectedNotes: _changeColorOfSelectedNotes,
            showDeleteConfirmationDialog: () => _showDeleteConfirmationDialog(context),
            duplicateSelectedNotes: _duplicateSelectedNotes,
            shareSelectedNotes: _shareSelectedNotes,
            
            ),
        
          drawer: HomeDrawer(),
        
          body: Column(
            children: [
              Expanded(
                child: BlocBuilder<HomeCubit, HomeState>(
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
              ),
            
            ],
          ),
          bottomNavigationBar:  AppConfig.getAdmobBannerUnitId() != '' ? SizedBox(
            width: _myBannerHome.size.width.toDouble(),
            height: _myBannerHome.size.height.toDouble(),
            child: AdWidget(ad: _myBannerHome),
          ) : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
      ),
    );
  }

  

  

  Future<void> _duplicateSelectedNotes() async {
    if (_selectedNoteIds.isEmpty) return;

    final noteState = context.read<HomeCubit>().state;
    if (noteState is! HomeLoaded) return;

    final notes = noteState.notes;
    final List<NoteModel> newNotes = [];

    for (final noteId in _selectedNoteIds) {
      final originalNote = notes.firstWhere((n) => n.id == noteId);
      final duplicatedNote = NoteModel(
        id: Uuid().v4(),
        title: originalNote.title.isEmpty ? 'Sem título (cópia)' : '${originalNote.title} (cópia)',
        content: originalNote.content,
        color: originalNote.color,
        isPinned: false,
        position: notes.length + newNotes.length,
        tags: originalNote.tags != null ? List<String>.from(originalNote.tags!) : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      newNotes.add(duplicatedNote);
    }

    var result = await context.read<HomeCubit>().addNotesBatch(newNotes);
    final count = _selectedNoteIds.length;
    if (result) {
      Utils.normalSucess(
        title: count > 1 ? 'Cópias Criadas' : 'Cópia Criada',
        message: '$count nota${count > 1 ? 's' : ''} duplicada${count > 1 ? 's' : ''} com sucesso! 📋',
      );
      _clearSelection();

      HapticFeedback.mediumImpact();
    } else {
      Utils.normalException(
        title: 'Erro ao Duplicar',
        message: count > 1
            ? 'Não foi possível duplicar as notas selecionadas.'
            : 'Não foi possível duplicar a nota selecionada.',
      );
      _clearSelection();

      HapticFeedback.mediumImpact();
    }
  }

  void _shareSelectedNotes() async {
    if (_selectedNoteIds.isEmpty) return;

    final noteState = context.read<HomeCubit>().state;
    if (noteState is! HomeLoaded) return;

    final notes = noteState.notes;
    final count = _selectedNoteIds.length;
    final StringBuffer textToShare = StringBuffer();
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
       /*  Utils.normalSucess(
          title: 'Compartilhado!',
          message: '$count nota${count > 1 ? 's' : ''} compartilhada${count > 1 ? 's' : ''} 🔗',
        ); */
        _clearSelection();
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      Utils.normalException(title: 'Erro ao Compartilhar', message: 'Não foi possível compartilhar as notas.');
      _clearSelection();
      HapticFeedback.mediumImpact();
    }
  }

  void _showTagSelectionDialog() async {
    if (_selectedNoteIds.isEmpty) return;

    await Get.dialog(
      BlocBuilder<TagsCubit, TagsState>(
        builder: (context, tagState) {
          if (tagState is TagsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (tagState is TagsLoaded) {
            final availableTags = tagState.tags;
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;

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
            return StatefulBuilder(
              builder: (context, setDialogState) {
                return Dialog(
                  backgroundColor: colorScheme.surface,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  insetPadding: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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

                        Flexible(
                          child: SingleChildScrollView(
                            child: Column(
                              children: availableTags.map((tag) {
                                final isSelected = selectedTagIds.contains(tag.id);

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
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(color: tagColor, shape: BoxShape.circle),
                                        ),
                                        const SizedBox(width: 12),

                                        Expanded(
                                          child: Text(
                                            tag.name,
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                            ),
                                          ),
                                        ),

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

                        Text(
                          "Selecione um ou mais marcadores",
                          style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
                        ),

                        const SizedBox(height: 16),

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

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<void> _applyTagsToSelectedNotes(List<String> tagIds) async {
    if (_selectedNoteIds.isEmpty) return;

    final noteState = context.read<HomeCubit>().state;
    if (noteState is! HomeLoaded) return;

    final notes = noteState.notes;
    final updatedNotes = notes
        .where((n) => _selectedNoteIds.contains(n.id))
        .map(
          (note) => note.copyWith(
            tags: tagIds.isEmpty ? [] : tagIds,
            updatedAt: DateTime.now(),
            color: note.color,
            content: note.content,
            title: note.title,
            position: note.position,
            createdAt: note.createdAt,
            id: note.id,
            isPinned: note.isPinned,
          ),
        )
        .toList();

    var result = await context.read<HomeCubit>().updateNotesBatch(updatedNotes);
   // final count = _selectedNoteIds.length;

    if (result) {
      if (tagIds.isEmpty) {
       /*  Utils.normalSucess(
          title: 'Marcadores Removidos',
          message: '$count nota${count > 1 ? 's' : ''} sem marcadores 🏷️',
        ); */
      } else {
        /* Utils.normalSucess(
          title: 'Marcadores Aplicados',
          message:
              '${tagIds.length} marcador${tagIds.length > 1 ? 'es' : ''} adicionado${tagIds.length > 1 ? 's' : ''} a $count nota${count > 1 ? 's' : ''} 🏷️',
        ); */
      }
    } else {
      Utils.normalException(message: 'Não foi possível aplicar esta ação às notas selecionadas.');
    }

    _clearSelection();

    HapticFeedback.mediumImpact();
  }

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
      return buildEmptyState(context, state, () => _showCreateNoteSheet(context), _addButtonKey);
    }

    return state.isGridView
        ? _buildGridView(context, notesFromDb: notesFromDb)
        : _buildListView(context, notesFromDb: notesFromDb);
  }

  

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
    if (pinnedNotes.isEmpty) {
      return _buildSIMPLEListView(context, notesFromDb: notesFromDb);
    }

    return _buildSECTIONEDListView(context, pinnedNotes: pinnedNotes, otherNotes: otherNotes);
  }

  Widget _buildSimpleGridView(BuildContext context, {required List<NoteModel> notesFromDb}) {
    final generatedChildren = List.generate(
      notesFromDb.length,
      (index) => buildGridNoteCard(context, note: notesFromDb[index], 
      isNoteSelected: _isNoteSelected(notesFromDb[index].id),
       onTap: () {
        if (_isSelectionMode) {
          _toggleNoteSelection(notesFromDb[index].id);
          HapticFeedback.selectionClick();
        } else {
          _openNote(context, notesFromDb[index]);
        }
      }
       
       ),
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
          if (pinnedNotes.isNotEmpty) ...[
            sectionHeader(context, 'FIXADAS', pinnedNotes.length),
            SizedBox(height: 12),
            _buildReorderableGridSection(context, pinnedNotes, isPinnedSection: true),
            SizedBox(height: 24),
          ],

          if (otherNotes.isNotEmpty) ...[
            sectionHeader(context, 'OUTRAS', otherNotes.length),
            SizedBox(height: 12),
            _buildReorderableGridSection(context, otherNotes, isPinnedSection: false),
          ],
        ],
      ),
    );
  }

  Widget _buildSECTIONEDListView(
    BuildContext context, {
    required List<NoteModel> pinnedNotes,
    required List<NoteModel> otherNotes,
  }) {
    Widget buildDraggableItem(BuildContext ctx, NoteModel note, int sectionIndex, int indexInSection) {
      Offset? pointerDownPos;
      bool tapLock = false;
      bool didMove = false;
      late DateTime pointerDownTime;
      const double moveThreshold = 6.0;
      const int longPressThresholdMs = 220;

      final isSelected = _isNoteSelected(note.id);

      return Listener(
        behavior: HitTestBehavior.opaque,

        onPointerDown: (PointerDownEvent ev) {
          pointerDownPos = ev.position;
          didMove = false;
          pointerDownTime = DateTime.now();
          _longPressedIndex = indexInSection;
        },

        onPointerMove: (PointerMoveEvent ev) {
          if (pointerDownPos != null) {
            final distance = (ev.position - pointerDownPos!).distance;
            if (!didMove && distance > moveThreshold) {
              didMove = true;
              _isDragging = true;
              _longPressedIndex = null;
            }
          }
        },

        onPointerUp: (PointerUpEvent ev) {
          final pressDuration = DateTime.now().difference(pointerDownTime).inMilliseconds;
          if (!didMove && pressDuration >= longPressThresholdMs) {
            final noteId = note.id;
            setState(() {
              _toggleNoteSelection(noteId);
              _longPressedIndex = null;
            });
            HapticFeedback.selectionClick();
          } else {
            if (!didMove && pressDuration < longPressThresholdMs) {
              if (_isSelectionMode) {
                setState(() => _toggleNoteSelection(note.id));
              } else {
                if (!tapLock) {
                  tapLock = true;
                  _openNote(context, note);
                  Future.delayed(Duration(milliseconds: 120), () {
                    tapLock = false;
                  });
                }
              }
            }
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
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: buildListNoteCard(context, note, isSelected),
        ),
      );
    }

    final pinnedChildren = List<Widget>.generate(
      pinnedNotes.length,
      (i) => KeyedSubtree(key: ValueKey(pinnedNotes[i].id), child: buildDraggableItem(context, pinnedNotes[i], 0, i)),
    );

    final otherChildren = List<Widget>.generate(
      otherNotes.length,
      (i) => KeyedSubtree(key: ValueKey(otherNotes[i].id), child: buildDraggableItem(context, otherNotes[i], 1, i)),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pinnedNotes.isNotEmpty) ...[
            sectionHeader(context, 'FIXADOS', pinnedNotes.length),
            SizedBox(height: 12),

            ReorderableColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              needsLongPressDraggable: true,
              children: pinnedChildren,
              onReorder: (oldIndex, newIndex) {
                final reorderedPinned = List<NoteModel>.from(pinnedNotes);
                final movedNote = reorderedPinned.removeAt(oldIndex);
                reorderedPinned.insert(newIndex, movedNote);

                final newOrder = [...reorderedPinned, ...otherNotes];

                for (int i = 0; i < newOrder.length; i++) {
                  newOrder[i] = newOrder[i].copyWith(position: i);
                }

                context.read<HomeCubit>().reorderNotes(newOrder);

                HapticFeedback.lightImpact();
              },
            ),

            SizedBox(height: 24),
          ],

          if (otherNotes.isNotEmpty) ...[
            sectionHeader(context, 'OUTRAS', otherNotes.length),
            SizedBox(height: 12),

            ReorderableColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              needsLongPressDraggable: true,
              children: otherChildren,
              onReorder: (oldIndex, newIndex) {
                final reorderedOthers = List<NoteModel>.from(otherNotes);
                final movedNote = reorderedOthers.removeAt(oldIndex);
                reorderedOthers.insert(newIndex, movedNote);
                final newOrder = [...pinnedNotes, ...reorderedOthers];
                for (int i = 0; i < newOrder.length; i++) {
                  newOrder[i] = newOrder[i].copyWith(position: i);
                }

                context.read<HomeCubit>().reorderNotes(newOrder);

                HapticFeedback.lightImpact();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReorderableGridSection(
    BuildContext context,
    List<NoteModel> tratedNotes, {
    required bool isPinnedSection,
  }) {
    final generatedChildren = List.generate(
      tratedNotes.length,
      (index) => buildGridNoteCard(
        context, 
        note: tratedNotes[index], 
        isNoteSelected: _isNoteSelected( tratedNotes[index].id), 
        onTap: () {
        if (_isSelectionMode) {
          _toggleNoteSelection(tratedNotes[index].id);
          HapticFeedback.selectionClick();
        } else {
          _openNote(context, tratedNotes[index]);
        }
      }
        ),
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
        final reorderedSection = reorderedListFunction(tratedNotes) as List<NoteModel>;

        final homeCubit = context.read<HomeCubit>();
        final state = homeCubit.state;
        if (state is HomeLoaded) {
          final allNotes = List<NoteModel>.from(state.notes);
          final otherSection = isPinnedSection
              ? allNotes.where((n) => !n.isPinned).toList()
              : allNotes.where((n) => n.isPinned).toList();

          final newOrder = isPinnedSection
              ? [...reorderedSection, ...otherSection]
              : [...otherSection, ...reorderedSection];
          for (int i = 0; i < newOrder.length; i++) {
            newOrder[i] = newOrder[i].copyWith(position: i);
          }
          homeCubit.reorderNotes(newOrder);
        }
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

  

  Widget _buildSIMPLEListView(BuildContext context, {required List<NoteModel> notesFromDb}) {
    List<Widget> children = List.generate(notesFromDb.length, (index) {
      final note = notesFromDb[index];
      final isSelected = _isNoteSelected(note.id);

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
            setState(() {
              _toggleNoteSelection(note.id);
              _longPressedIndex = null;
            });
            HapticFeedback.selectionClick();
          } else if (!didMove && pressDuration < longPressThresholdMs) {
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
        child: buildListNoteCard(context, note, isSelected, key: ValueKey(note.id)),
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

  

  

 

  void _openNote(BuildContext context, NoteModel note) {
    BannerAd? myBannerEditNote = BannerAd(
      adUnitId: AppConfig.getAdmobBannerUnitId(),
      size: AdSize.largeBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          debugPrint("Modal banner failed: $error");
          ad.dispose();
        },
      ),
    )..load();

    showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => EditNoteSheet(
              note: note, bannerAd: myBannerEditNote,
            
              
              ),
          ),
        )
        .then((result) {
          if (result != null) {
            final homeCubit = context.read<HomeCubit>();
            if (result == 'delete') {
              homeCubit.deleteNote(note.id);
            } else if (result is NoteModel) {
              homeCubit.loadNotes();
            }
          }
        })
        .whenComplete(() {
          myBannerEditNote?.dispose();
          myBannerEditNote = null;
        });
  }

 

  void _showCreateNoteSheet(BuildContext context) {
    BannerAd? myBannerCreateNote = BannerAd(
      adUnitId: AppConfig.getAdmobBannerUnitId(),
      size: AdSize.largeBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          debugPrint("Modal banner failed: $error");
          ad.dispose();
        },
      ),
    )..load();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => CreateNoteSheet(bannerAd: myBannerCreateNote),
      ),
    ).whenComplete(() {
      myBannerCreateNote?.dispose();
      myBannerCreateNote = null;
    });
  }

  void _changeColorOfSelectedNotes() async {
    if (_selectedNoteIds.isEmpty) return;

    final noteState = context.read<HomeCubit>().state;
    if (noteState is! HomeLoaded) return;

    final notes = noteState.notes;
    final selectedNotes = notes.where((n) => _selectedNoteIds.contains(n.id)).toList();

    if (selectedNotes.isEmpty) return;

    final firstSelectedNote = selectedNotes.first;

    final Color? selectedColor = await Get.dialog<Color>(
      ColorPickerDialog(
        initialColor: firstSelectedNote.color,
        isMultipleSelection: _selectedNoteIds.length > 1,
        selectedCount: _selectedNoteIds.length,
      ),
    );

    if (selectedColor != null) {
     // final count = _selectedNoteIds.length;

      final updatedNotes = selectedNotes
          .map(
            (note) => note.copyWith(
              content: note.content,
              title: note.title,
              position: note.position,
              createdAt: note.createdAt,
              id: note.id,
              isPinned: note.isPinned,
              tags: note.tags,

              color: selectedColor,
              updatedAt: DateTime.now(),
            ),
          )
          .toList();

      var result = await context.read<HomeCubit>().updateNotesBatch(updatedNotes);

      if (result) {
      /*   Utils.normalSucess(
          title: count > 1 ? "Cores alteradas" : "Cor alterada",
          message: '$count nota${count > 1 ? 's' : ''} atualizada${count > 1 ? 's' : ''} 🎨',
        ); */
      } else {
        Utils.normalException(message: 'Não foi possível aplicar esta ação às notas selecionadas.');
      }

      _clearSelection();

      HapticFeedback.mediumImpact();

    }
  }

 

  

  

  

  

  




  

  
}

// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:clipstick/config/app_config.dart';
import 'package:clipstick/core/database/database.dart';
import 'package:clipstick/core/routes/app_routes.dart';
import 'package:clipstick/core/theme/app_colors.dart';
import 'package:clipstick/core/theme/note_colors_helper.dart';
import 'package:clipstick/core/theme/themetoggle_button.dart';
import 'package:clipstick/core/utils/utillity.dart';
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
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:reorderables/reorderables.dart';
import 'package:restart_app/restart_app.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import '../widgets/create_note_sheet.dart';
import '../widgets/edit_note_sheet.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:clipstick/core/di/service_locator.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite3;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _gridViewKey = GlobalKey();

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

    final count = _selectedNoteIds.length;

    Utils.normalSucess(
      title: count > 1
          ? (allPinned ? 'Notas Desfixadas' : 'Notas Fixadas')
          : (allPinned ? 'Nota Desfixada' : 'Nota Fixada'),
      message: '$count nota${count > 1 ? 's' : ''} ${allPinned ? 'desfixada' : 'fixada'}${count > 1 ? 's' : ''} 📌',
    );
    _clearSelection();
  }

  @override
  void initState() {
    super.initState();
    _myBannerHome.load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _myBannerHome.dispose();
    super.dispose();
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
      child: Scaffold(
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
                  return ScaleTransition(
                    scale: animation,
                    alignment: Alignment.center,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: _isSelectionMode ? _buildSelectionAppBar(context) : _buildNormalAppBar(context),
              ),
            ),
          ),
        ),

        drawer: _buildDrawer(context),

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
            /*   SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(bottom: 90.0,),
              child: SizedBox(
                 width: _myBanner.size.width.toDouble() ,
                height: _myBanner.size.height.toDouble(), 
                child: AdWidget(ad: _myBanner),
              ),
            ), 
            */
          ],
        ),
        bottomNavigationBar: SizedBox(
          width: _myBannerHome.size.width.toDouble(),
          height: _myBannerHome.size.height.toDouble(),
          child: AdWidget(ad: _myBannerHome),
        ),
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
    );
  }

  Widget _buildNormalAppBar(BuildContext context) {
    return AppBar(
      elevation: 10,
      key: ValueKey('normal_appbar'),
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

  Widget _buildSelectionAppBar(BuildContext context) {
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
        IconButton(
          icon: Icon(
            allPinned ? Icons.push_pin : Icons.push_pin_outlined,
            color: Theme.of(context).colorScheme.surface,
          ),
          onPressed: _togglePinSelectedNotes,
          tooltip: allPinned ? 'Desfixar' : 'Fixar',
        ),

        IconButton(
          icon: Icon(MdiIcons.tagOutline, color: Theme.of(context).colorScheme.surface),
          onPressed: _showTagSelectionDialog,
          tooltip: 'Adicionar marcadores',
        ),

        IconButton(
          icon: Icon(Icons.palette_outlined),
          color: Theme.of(context).colorScheme.surface,
          onPressed: _changeColorOfSelectedNotes,
          tooltip: 'Alterar cor',
        ),

        IconButton(
          icon: Icon(FontAwesomeIcons.trashCan, size: 20),
          color: Theme.of(context).colorScheme.surface,
          onPressed: () => _showDeleteConfirmationDialog(context),
          tooltip: 'Excluir selecionadas',
        ),

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
        Utils.normalSucess(
          title: 'Compartilhado!',
          message: '$count nota${count > 1 ? 's' : ''} compartilhada${count > 1 ? 's' : ''} 🔗',
        );
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
    final count = _selectedNoteIds.length;

    if (result) {
      if (tagIds.isEmpty) {
        Utils.normalSucess(
          title: 'Marcadores Removidos',
          message: '$count nota${count > 1 ? 's' : ''} sem marcadores 🏷️',
        );
      } else {
        Utils.normalSucess(
          title: 'Marcadores Aplicados',
          message:
              '${tagIds.length} marcador${tagIds.length > 1 ? 'es' : ''} adicionado${tagIds.length > 1 ? 's' : ''} a $count nota${count > 1 ? 's' : ''} 🏷️',
        );
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
      return _buildEmptyState(context, state);
    }

    return state.isGridView
        ? _buildGridView(context, notesFromDb: notesFromDb)
        : _buildListView(context, notesFromDb: notesFromDb);
  }

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
              _showCreateNoteSheet(context);
            },
            icon: Icon(Icons.add),
            label: Text('Criar primeira nota'),
          ),
        ],
      ),
    );
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
            _buildSectionHeader(context, 'FIXADAS', pinnedNotes.length),
            SizedBox(height: 12),
            _buildReorderableGridSection(context, pinnedNotes, isPinnedSection: true),
            SizedBox(height: 24),
          ],

          if (otherNotes.isNotEmpty) ...[
            _buildSectionHeader(context, 'OUTRAS', otherNotes.length),
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
          child: _buildListNoteCard(context, note, isSelected),
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
            _buildSectionHeader(context, 'FIXADOS', pinnedNotes.length),
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
            _buildSectionHeader(context, 'OUTRAS', otherNotes.length),
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

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Row(
      children: [
        Expanded(child: Divider(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              //fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Divider(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        /* SizedBox(width: 8),
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
        ), */
      ],
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

  Widget _buildGridNoteCard(BuildContext context, NoteModel note) {
    final isSelected = _isNoteSelected(note.id);

    return GestureDetector(
      key: Key(note.id),
      onTap: () {
        if (_isSelectionMode) {
          _toggleNoteSelection(note.id);
          HapticFeedback.selectionClick();
        } else {
          _openNote(context, note);
        }
      },

      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,

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
                          color: AppColors.getTextColor(note.color),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Expanded(
                  child: Text(
                    note.content,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.getTextColor(note.color)),
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
                    Icon(MdiIcons.tagOutline, size: 10, color: AppColors.getTextColor(note.color).withOpacity(0.6)),
                    SizedBox(width: 3),
                    Text(
                      tagName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.getTextColor(note.color).withOpacity(0.7),
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

  Widget _buildListNoteCard(BuildContext context, NoteModel note, bool isSelected, {Key? key}) {
    final cardElevation = isSelected ? 6.0 : 2.0;
    var realceColor = NoteColorsHelper.getAvailableColors(context).contains(note.color);
    debugPrint(realceColor.toString());
    var listaColors = NoteColorsHelper.getAvailableColors(context);
    debugPrint(listaColors.first.toString());
    debugPrint(note.color.toString());
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
                color: AppColors.getTextColor(note.color),
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
                      color: AppColors.getTextColor(note.color).withOpacity(0.8),
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
            builder: (context, scrollController) => EditNoteSheet(note: note, bannerAd: myBannerEditNote),
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
      final count = _selectedNoteIds.length;

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
        Utils.normalSucess(
          title: count > 1 ? "Cores alteradas" : "Cor alterada",
          message: '$count nota${count > 1 ? 's' : ''} atualizada${count > 1 ? 's' : ''} 🎨',
        );
      } else {
        Utils.normalException(message: 'Não foi possível aplicar esta ação às notas selecionadas.');
      }

      _clearSelection();

      HapticFeedback.mediumImpact();

    }
  }

 

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
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

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
                  ...tags.map((tag) => _buildTagItem(context, tag)),

              SizedBox(height: 8),

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
            ],
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget _buildTagItem(BuildContext context, TagModel tag) {
    final noteState = context.read<HomeCubit>().state;
    List<NoteModel> notes = [];
    if (noteState is HomeLoaded) {
      notes = noteState.notes;
    }

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
        Get.back();
        Get.to(() => TagViewScreen(tag: tag));
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 16, bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('assets/clipstick-logo.png', width: 54, height: 54, fit: BoxFit.cover),
                ),
                SizedBox(width: 8),
                Column(
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
          Divider(height: 1, thickness: 1, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)),

          _buildTagsSection(context),

          Divider(height: 1, thickness: 1, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)),

          ThemeToggleButton(),
          //funcionalidade sera implementada no futuro
          /* ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text('Configurações'),
            onTap: () {
              Navigator.pop(context);
              },
          ), */
          //funcionalidade sera implementada no futuro
          ListTile(
            leading: Icon(MdiIcons.databaseArrowUpOutline),
            title: Text('Fazer Backup Local'),
            onTap: () {
              Navigator.pop(context);
              backupDatabase();
             
            },
          ),
          ListTile(
            leading: Icon(MdiIcons.databaseArrowDownOutline),
            title: Text('Restaurar Backup'),
            onTap: () {
              Navigator.pop(context);
              restoreDatabaseComInstrucao();
              
            },
          ),

          //funcionalidade sera implementada no futuro
          /*  ListTile(
            leading: Icon(Icons.login_outlined),
            title: Text('Entrar'),
            onTap: () {
              Navigator.pop(context);
             
            },
          ), */
          //funcionalidade sera implementada no futuro
          /* ListTile(
            leading: Icon(Icons.person_add_outlined),
            title: Text('Cadastrar'),
            onTap: () {
              Navigator.pop(context);
              
            },
          ), */
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

  Future<void> showLoadingDialog(BuildContext context, {String? message}) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              if (message != null) ...[SizedBox(height: 16), Text(message, style: TextStyle(color: Colors.white))],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> backupDatabase() async {
    final dbDir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbDir.path, 'clipstick.sqlite'));
    final dbBytes = await dbFile.readAsBytes();

    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Salvar backup do ClipStick',
      fileName: 'clipstick_backup.sqlite',
      type: FileType.custom,
      allowedExtensions: ['sqlite'],
      bytes: dbBytes,
    );

    await sl<AppDatabase>().close();

    showLoadingDialog(context, message: 'Realizando backup...').then((_) {
      print('Backup salvo em: $outputPath');
      Utils.normalSucess(message: 'Backup salvo em: $outputPath');
    });

    await Future.delayed(Duration(seconds: 2));

    //Navigator.of(context, rootNavigator: true).pop();

    await cleanupServiceLocator();
    await setupServiceLocator();
    Restart.restartApp();
  }

  Widget _itemInstrucao(String numero, String texto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
          child: Center(
            child: Text(
              numero,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(child: Text(texto, style: AppTextStyles.bodyMedium)),
      ],
    );
  }

  Future<void> restoreDatabaseComInstrucao() async {
    final bool? continuar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber),
              SizedBox(width: 8),
              Text('Dica'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Se não conseguir selecionar o arquivo:', style: AppTextStyles.bodyLarge),
              SizedBox(height: 12),
              _itemInstrucao('1', 'Toque no menu ☰ no canto superior'),
              SizedBox(height: 12),
              _itemInstrucao('2', 'Selecione o nome do seu dispositivo'),
              SizedBox(height: 12),
              _itemInstrucao('3', 'Navegue até a pasta do backup'),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.folder, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(child: Text('Geralmente em Downloads ou Documentos', style: TextStyle(fontSize: 12))),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancelar')),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text('Entendi')),
          ],
        );
      },
    );

    if (continuar != true) return;

    await restoreDatabase();
  }

  Future<void> restoreDatabase() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['sqlite'],
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        print('Restauração cancelada pelo usuário');
        return;
      }

      final backupFile = File(result.files.single.path!);

      if (!backupFile.path.toLowerCase().endsWith('.sqlite')) {
        Utils.normalException(message: "Selecione um arquivo com extensão .sqlite");
        return;
      }

      bool isValid = await isValidBackupSchema(backupFile);
      if (!isValid) {
        Utils.normalException(message: "Arquivo de backup inválido ou incompatível com esta versão do app.");
        return;
      }

      await sl<AppDatabase>().close();

      showLoadingDialog(context, message: 'Restaurando backup...');

      await Future.delayed(Duration(seconds: 1));

      // Copia o arquivo para o diretório do app
      final dbDir = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbDir.path, 'clipstick.sqlite'));

      // Copia o backup para o local do banco
      await backupFile.copy(dbFile.path);

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      print('Banco restaurado com sucesso!');
     
      Utils.normalSucess(message: 'Banco restaurado com sucesso!');

      await cleanupServiceLocator();
      await setupServiceLocator();
      Restart.restartApp();
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      print('Erro ao restaurar backup: $e');
      Utils.normalException(message: "Erro ao restaurar backup: ${e.toString()}");
    }
  }

  Future<bool> isValidBackupSchema(File backupFile) async {
    // Copia para um local temporário
    final tempDir = await getTemporaryDirectory();
    final tempDbFile = File('${tempDir.path}/temp_restore_check.sqlite');
    await backupFile.copy(tempDbFile.path);

    // Abre conexão direta
    final db = sqlite3.sqlite3.open(tempDbFile.path);

    try {
      final tables = db
          .select("SELECT name FROM sqlite_master WHERE type='table';")
          .map((row) => row['name'] as String)
          .toList();

      if (tables.contains('notes') && tables.contains('tags')) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      db.dispose();
      await tempDbFile.delete();
    }
  }
}

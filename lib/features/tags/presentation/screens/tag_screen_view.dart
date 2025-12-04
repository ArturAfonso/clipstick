// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:clipstick/config/app_config.dart';
import 'package:clipstick/core/utils/utillity.dart';
import 'package:clipstick/features/home/presentation/widgets/edit_note_sheet.dart';
import 'package:clipstick/features/tags/presentation/widgets/notelistitem.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/tag_model.dart';
import '../../../../data/models/note_model.dart';
import '../../../home/presentation/cubit/home_cubit.dart';
import '../../../home/presentation/cubit/home_state.dart';
import '../../../home/presentation/cubit/view_mode_cubit.dart';
import '../../presentation/cubit/tags_cubit.dart';

class TagViewScreen extends StatefulWidget {
  final TagModel tag;

  const TagViewScreen({super.key, required this.tag});

  @override
  State<TagViewScreen> createState() => _TagViewScreenState();
}

class _TagViewScreenState extends State<TagViewScreen> {
  late TagModel _currentTag;

  BannerAd? myBannerTagScreenView = BannerAd(
    adUnitId: AppConfig.getAdmobBannerUnitId(),
    size: AdSize.banner,
    request: const AdRequest(),
    listener: BannerAdListener(
      onAdFailedToLoad: (ad, error) {
        debugPrint("Modal banner failed: $error");
        ad.dispose();
      },
    ),
  );

  @override
  void initState() {
    super.initState();
    _currentTag = widget.tag;
    myBannerTagScreenView?.load();
  }

  @override
  void dispose() {
    myBannerTagScreenView?.dispose();
    super.dispose();
  }

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

  void _renameTag(String newName) async {
    var result = await context.read<TagsCubit>().updateTag(
      _currentTag.copyWith(name: newName, updatedAt: DateTime.now()),
      context,
    );

    if (result) {
      Utils.normalSucess(title: 'Marcador Renomeado', message: '"${widget.tag.name}" → "$newName" ✏️');
      setState(() {
        _currentTag = _currentTag.copyWith(name: newName, updatedAt: DateTime.now());
      });
    } else {
      Utils.normalException(
        title: 'Erro',
        message: 'Não foi possível renomear o marcador. Tente novamente mais tarde.',
      );
    }

    HapticFeedback.mediumImpact();
  }

  void _showDeleteDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Excluir Marcador?',
          style: AppTextStyles.headingSmall.copyWith(color: Theme.of(context).colorScheme.error),
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
          TextButton(onPressed: () => Get.back(), child: Text('Cancelar')),
          TextButton(
            onPressed: () {
              Get.back();
              _deleteTag();
            },
            child: Text(
              'Excluir',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteTag() async {
    final noteState = context.read<HomeCubit>().state;
    if (noteState is HomeLoaded) {
      final notesWithTag = noteState.notes
          .where((note) => note.tags != null && note.tags!.contains(_currentTag.id))
          .toList();

      final updatedNotes = notesWithTag.map((note) {
        final newTags = List<String>.from(note.tags ?? []);
        newTags.remove(_currentTag.id);
        return note.copyWith(tags: newTags, updatedAt: DateTime.now());
      }).toList();

      if (updatedNotes.isNotEmpty) {
        await context.read<HomeCubit>().updateNotesBatch(updatedNotes);
      }
    }

    var result = await context.read<TagsCubit>().deleteTag(_currentTag.id, context);

    if (result) {
      Utils.normalSucess(title: 'Marcador Excluído', message: '"${_currentTag.name}" foi removido de todas as notas 🗑️');
    } else {
      Utils.normalException(
        title: 'Erro',
        message: 'Não foi possível excluir o marcador. Tente novamente mais tarde.',
      );
    }

    HapticFeedback.heavyImpact();

    Get.back();


    Future.delayed(Duration(milliseconds: 400), () {
      if (mounted) Get.back();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ViewModeCubit(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: SafeArea(
            child: Material(
              elevation: 0.5,
              child: AppBar(
                backgroundColor: Theme.of(context).colorScheme.surface,

                leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Get.back()),
                title: Row(
                  children: [
                    Icon(MdiIcons.tagOutline, color: Theme.of(context).colorScheme.primary, size: 22),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentTag.name,
                        style: AppTextStyles.headingMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                actions: [
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
                            Icon(Icons.edit_outlined, size: 20, color: Theme.of(context).colorScheme.onSurface),
                            SizedBox(width: 12),
                            Text('Renomear marcador', style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.trashCan, size: 20),
                            SizedBox(width: 12),
                            Text('Excluir marcador', style: AppTextStyles.bodyMedium.copyWith()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, noteState) {
            List<NoteModel> notesWithTag = [];
            if (noteState is HomeLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (noteState is HomeLoaded) {
              notesWithTag =
                  noteState.notes.where((note) => note.tags != null && note.tags!.contains(_currentTag.id)).toList()
                    ..sort((a, b) {
                      if (a.isPinned && !b.isPinned) return -1;
                      if (!a.isPinned && b.isPinned) return 1;
                      return a.position.compareTo(b.position);
                    });

              if (notesWithTag.isEmpty) {
                return _buildEmptyState(context);
              }
            }

            return BlocBuilder<ViewModeCubit, ViewModeState>(
              builder: (context, viewMode) {
                return Padding(
                  padding: EdgeInsets.all(16),
                  child: /*  viewMode == ViewMode.grid
                      ? _buildGridView(notesWithTag)
                      : */ _buildListView(
                    notesWithTag,
                  ),
                );
              },
            );
          },
        ),
        bottomNavigationBar: myBannerTagScreenView == null
            ? SizedBox.shrink()
            : SizedBox(
                width: myBannerTagScreenView!.size.width.toDouble(),
                height: myBannerTagScreenView!.size.height.toDouble(),
                child: AdWidget(ad: myBannerTagScreenView!),
              ),
      ),
    );
  }

  /*  Widget _buildGridView(List<NoteModel> notes) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return NoteCard(
          note: notes[index],
          onTap: () {
            
          },
          onLongPress: () {
            
          },
        );
      },
    );
  } */

  Widget _buildListView(List<NoteModel> notes) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return NoteListItem(
          note: notes[index],
          onTap: () {
            _openNote(context, notes[index]);
          },
          onLongPress: () {},
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.label_off_outlined, size: 80, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
          SizedBox(height: 16),
          Text(
            'Nenhuma nota com este marcador',
            style: AppTextStyles.headingSmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          ),
          SizedBox(height: 8),
          Text(
            'Adicione o marcador "${_currentTag.name}"\nem suas notas para vê-las aqui',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
          ),
        ],
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
}

class _RenameTagDialog extends StatefulWidget {
  final String currentName;
  final Function(String newName) onRename;

  const _RenameTagDialog({required this.currentName, required this.onRename});

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
      title: Text('Renomear Marcador', style: AppTextStyles.headingSmall),
      content: TextField(
        controller: _controller,
        autofocus: true,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          labelText: 'Nome do marcador',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _handleRename(),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('Cancelar')),
        ElevatedButton(onPressed: _handleRename, child: Text('Renomear')),
      ],
    );
  }
}

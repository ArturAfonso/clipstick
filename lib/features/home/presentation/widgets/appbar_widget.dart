import 'package:clipstick/core/theme/app_text_styles.dart';
import 'package:clipstick/features/home/presentation/cubit/home_cubit.dart';
import 'package:clipstick/features/home/presentation/cubit/home_state.dart';
import 'package:clipstick/features/home/presentation/cubit/view_mode_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppbar({
    super.key,
    required bool isSelectionMode,
    required this.buildContext,
    required Set<String> selectedNoteIds,
    required this.onClearSelection,
    required this.togglePinSelectedNotes,
    required this.showTagSelectionDialog,
    required this.changeColorOfSelectedNotes,
    required this.showDeleteConfirmationDialog,
    required this.duplicateSelectedNotes,
    required this.shareSelectedNotes,
    required this.keyButton1,
  }) : _isSelectionMode = isSelectionMode,
       _selectedNoteIds = selectedNoteIds;

  final bool _isSelectionMode;
  final BuildContext buildContext;
  final Set<String> _selectedNoteIds;
  final VoidCallback onClearSelection;
  final VoidCallback togglePinSelectedNotes;
  final VoidCallback showTagSelectionDialog;
  final VoidCallback changeColorOfSelectedNotes;
  final VoidCallback showDeleteConfirmationDialog;
  final VoidCallback duplicateSelectedNotes;
  final VoidCallback shareSelectedNotes;
   final GlobalKey keyButton1 ;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
       
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
        onPressed: onClearSelection,
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
          onPressed: togglePinSelectedNotes,
          tooltip: allPinned ? 'Desfixar' : 'Fixar',
        ),

        IconButton(
          icon: Icon(MdiIcons.tagOutline, color: Theme.of(context).colorScheme.surface),
          onPressed: showTagSelectionDialog,
          tooltip: 'Adicionar marcadores',
        ),

        IconButton(
          icon: Icon(Icons.palette_outlined),
          color: Theme.of(context).colorScheme.surface,
          onPressed: changeColorOfSelectedNotes,
          tooltip: 'Alterar cor',
        ),

        IconButton(
          icon: Icon(FontAwesomeIcons.trashCan, size: 20),
          color: Theme.of(context).colorScheme.surface,
          onPressed: showDeleteConfirmationDialog,
          tooltip: 'Excluir selecionadas',
        ),

        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.secondary),
          color: Theme.of(context).colorScheme.onSecondary,
          tooltip: 'Mais opções',
          onSelected: (value) {
            switch (value) {
              case 'copy':
                duplicateSelectedNotes();
                break;
              case 'share':
                shareSelectedNotes();
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
                 key: keyButton1,
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
}

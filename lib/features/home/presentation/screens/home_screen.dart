import 'dart:ui';

import 'package:clipstick/data/models/note_model.dart';
import 'package:clipstick/features/home/presentation/cubit/view_mode_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
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

  // 🆕 CONTROLE DE SELEÇÃO
  final Set<String> _selectedNoteIds = {};
   bool _isDragging = false;
  int? _longPressedIndex;

  @override
  void initState() {
    super.initState();
    _notes = _getSampleNotes();
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
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: _isSelectionMode
              ? _buildSelectionAppBar(context) // 🆕 AppBar de seleção
              : _buildNormalAppBar(context),    // ✅ AppBar normal
          ),
        ),
      ), /* AppBar(
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
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // 🎨 HEADER DO DRAWER
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
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
      
              ListTile(
                leading: Icon(Icons.folder_outlined),
                title: Text('Categorias'),
                onTap: () {
                  Navigator.pop(context);
                  Get.snackbar('Categorias', 'Funcionalidade em breve!', snackPosition: SnackPosition.BOTTOM);
                },
              ),
      
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
        ),
      
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


// 🆕 APPBAR DE SELEÇÃO
Widget _buildSelectionAppBar(BuildContext context) {
  return AppBar(
    key: ValueKey('selection_appbar'), // ✅ Key para AnimatedSwitcher
    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    leading: IconButton(
      icon: Icon(
        Icons.close,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
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
      // 🗑️ BOTÃO DELETAR
      IconButton(
        icon: Icon(Icons.delete_outline),
        color: Theme.of(context).colorScheme.error,
        onPressed: () => _showDeleteConfirmationDialog(context),
        tooltip: 'Excluir selecionadas',
      ),
      
      // 🎨 BOTÃO MUDAR COR
      IconButton(
        icon: Icon(Icons.palette_outlined),
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        onPressed: () {
          Get.snackbar(
            'Alterar Cor',
            'Funcionalidade em breve! 🎨',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        tooltip: 'Alterar cor',
      ),
      
      // 📁 MAIS OPÇÕES
      IconButton(
        icon: Icon(Icons.more_vert),
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        onPressed: () {
          Get.snackbar(
            'Mais Opções',
            'Funcionalidade em breve!',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        tooltip: 'Mais opções',
      ),
      
      SizedBox(width: 8),
    ],
  );
}

  // 🆕 BANNER FLUTUANTE DE SELEÇÃO
  Widget _buildSelectionBanner(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedSlide(
        duration: Duration(milliseconds: 300),
        offset: _isSelectionMode ? Offset.zero : Offset(0, -1),
        curve: Curves.easeOut,
        child: Material(
          elevation: 4,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: SafeArea(
            bottom: false,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // ❌ BOTÃO FECHAR
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: _clearSelection,
                    tooltip: 'Cancelar seleção',
                    style: IconButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  
                  SizedBox(width: 8),
                  
                  // 📊 CONTADOR DE SELECIONADOS
                  Expanded(
                    child: Text(
                      '${_selectedNoteIds.length} selecionada${_selectedNoteIds.length > 1 ? 's' : ''}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  
                  // 🗑️ BOTÃO DELETAR
                  IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: () => _showDeleteConfirmationDialog(context),
                    tooltip: 'Excluir selecionadas',
                    style: IconButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      backgroundColor: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
                    ),
                  ),
                  
                  SizedBox(width: 8),
                  
                  // 🎨 BOTÃO MUDAR COR (PLACEHOLDER PARA FUTURO)
                  IconButton(
                    icon: Icon(Icons.palette_outlined),
                    onPressed: () {
                      Get.snackbar(
                        'Alterar Cor',
                        'Funcionalidade em breve! 🎨',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    tooltip: 'Alterar cor',
                    style: IconButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  
                  // 📁 MAIS OPÇÕES (PLACEHOLDER PARA FUTURO)
                  IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () {
                      Get.snackbar(
                        'Mais Opções',
                        'Funcionalidade em breve!',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    tooltip: 'Mais opções',
                    style: IconButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _deleteSelectedNotes();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
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
      ),
      NoteModel(
        id: '2',
        title: 'Ideias para o projeto',
        content: 'Implementar dark mode, adicionar sincronização na nuvem, melhorar performance',
        color: AppColors.lightNotePink,
        position: 1,
      ),
      NoteModel(
        id: '3',
        title: 'Treino da semana',
        content: 'Segunda: Peito e tríceps\nQuarta: Costas e bíceps\nSexta: Pernas',
        color: AppColors.lightNoteGreen,
        position: 2,
      ),
      NoteModel(
        id: '4',
        title: 'Livros para ler',
        content: 'Clean Code, Design Patterns, Refactoring',
        color: AppColors.lightNoteBlue,
        position: 3,
      ),
      NoteModel(
        id: '5',
        title: 'Receita de bolo',
        content: '3 ovos, 2 xícaras de açúcar, 2 xícaras de farinha, 1 xícara de leite',
        color: AppColors.lightNoteOrange,
        position: 4,
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

  

  // 📊 GRID VIEW COM REORDERABLE BUILDER (v5.5.2)
  Widget _buildGridView(BuildContext context) {
    final generatedChildren = List.generate(
      _notes.length,
      (index) => _buildGridNoteCard(context, _notes[index]),
    );

    return Padding(
      padding: EdgeInsets.all(16),
      child: ReorderableBuilder(
        scrollController: _scrollController,
        
        enableLongPress: true,
        longPressDelay: Duration(milliseconds: 500), // ✅ Aumentar para 500ms
        enableDraggable: true,
        enableScrollingWhileDragging: true,
        automaticScrollExtent: 80.0,
        
        fadeInDuration: Duration(milliseconds: 300),
        releasedChildDuration: Duration(milliseconds: 200),
        positionDuration: Duration(milliseconds: 250),
        
        dragChildBoxDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
              offset: Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        
        onReorder: (ReorderedListFunction reorderedListFunction) {
          setState(() {
            _notes = reorderedListFunction(_notes) as List<NoteModel>;
            
            for (int i = 0; i < _notes.length; i++) {
              _notes[i] = _notes[i].copyWith(position: i);
            }
            
            // ✅ Marca que houve reordenação (arrastou)
            _isDragging = true;
          });
        },
        
        // ✅ GUARDA QUAL CARD FOI PRESSIONADO
        onDragStarted: (index) {
          setState(() {
            _longPressedIndex = index;
            _isDragging = false; // Reseta flag
          });
          HapticFeedback.mediumImpact();
          print('Começou long press em: ${_notes[index].title}');
        },
        
        // ✅ VERIFICA SE FOI DRAG OU SELEÇÃO
        onDragEnd: (index) {
          HapticFeedback.lightImpact();
          
          // ✅ Se não houve reordenação (soltou no mesmo lugar), SELECIONA
          Future.delayed(Duration(milliseconds: 100), () {
            if (!_isDragging && _longPressedIndex != null) {
              // Foi long press SEM arrastar = SELEÇÃO
              final noteId = _notes[_longPressedIndex!].id;
              setState(() {
                _toggleNoteSelection(noteId);
                _longPressedIndex = null;
              });
              HapticFeedback.selectionClick(); // Feedback diferente
              print('SELECIONOU: ${_notes[index].title}');
            } else {
              // Foi drag and drop = REORDENAR
              print('REORDENOU para posição: $index');
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
        border: Border.all(
          color: isSelected 
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
          width: 3,
        ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 14,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
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
                      child: Icon(
                        Icons.drag_indicator,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
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
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hoje',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Icon(
                    Icons.more_horiz,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
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
          child: Text(
            note.content,
            style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        /*  trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.drag_handle, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            SizedBox(height: 4),
            Text('Hoje', style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          ],
        ), */
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
}

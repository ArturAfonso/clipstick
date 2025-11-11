import 'dart:ui';

import 'package:clipstick/data/models/note_model.dart';
import 'package:clipstick/features/home/presentation/cubit/view_mode_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import '../widgets/create_note_sheet.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
  builder: (context) => IconButton(
    style: IconButton.styleFrom(
      overlayColor: Theme.of(context).colorScheme.primary,
      highlightColor: Theme.of(context).colorScheme.primary,
      backgroundColor:Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(8),
    ),
    icon: Icon(
  Icons.auto_awesome_mosaic_outlined,
  color: Theme.of(context).colorScheme.onSecondary,
), 
    onPressed: () => Scaffold.of(context).openDrawer(),
  ),
),
        title: Text(
          'Minhas notas',
          style: AppTextStyles.headingMedium,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSecondary),
            onPressed: () {
              // TODO: Implementar busca
             
            },
          ),
           BlocBuilder<ViewModeCubit, ViewModeState>(
            builder: (context, state) {
              return Container(
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.grid_view,
                        color: state.isGridView 
                          ? Theme.of(context).colorScheme.onPrimary //  BRANCO (onPrimary)
        : Theme.of(context).colorScheme.onSecondary,
     ),
                      onPressed: () {
                        context.read<ViewModeCubit>().setGridView();
                       
                      },
                      tooltip: 'Visualização em Grade',
                      // 🎨 BACKGROUND QUANDO ATIVO
                      style: IconButton.styleFrom(
                        backgroundColor: state.isGridView 
                           ? Theme.of(context).colorScheme.primary //  PRETO/ESCURO (primary)
        : Colors.transparent,
                           shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), 
                ),
                            padding: EdgeInsets.all(8),
                      ),
                    ),
                    IconButton(
                icon: Icon(
                  Icons.list,
                  color: state.isListView 
                    ? Theme.of(context).colorScheme.onPrimary //  BRANCO (onPrimary)
        : Theme.of(context).colorScheme.onSurfaceVariant, //  CINZA (muted-foreground)
   ),
                onPressed: () {
                  context.read<ViewModeCubit>().setListView();
                 
                },
                tooltip: 'Visualização em Lista',
                // 🎨 BACKGROUND QUANDO ATIVO
                style: IconButton.styleFrom(
                  backgroundColor: state.isListView 
                     ? Theme.of(context).colorScheme.primary //  PRETO/ESCURO (primary)
        : Colors.transparent,
                     shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                            padding: EdgeInsets.all(8),
                ),
              )
                  ],
                ),
              );
            },
          ),
          
        ],
      ),
      
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
                  Icon(
                    Icons.sticky_note_2,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ClipStick',
                    style: AppTextStyles.headingMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Suas notas organizadas',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
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
                Get.snackbar(
                  'Nova Nota',
                  'Funcionalidade em breve!',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            
            ListTile(
              leading: Icon(Icons.folder_outlined),
              title: Text('Categorias'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Categorias',
                  'Funcionalidade em breve!',
                  snackPosition: SnackPosition.BOTTOM,
                );
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
                Get.snackbar(
                  'Configurações',
                  'Funcionalidade em breve!',
                  snackPosition: SnackPosition.BOTTOM,
                );
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
      body: BlocBuilder<ViewModeCubit, ViewModeState>(
        builder: (context, state) {
          return _buildNotesView(context, state);
        },
      ), 
         floatingActionButton: FloatingActionButton(
  onPressed: () {
    _showCreateNoteSheet(context); 
  },
  tooltip: 'Criar nova nota',
  child: Icon(Icons.add),
),
    );
  }

  Widget _buildNotesView(BuildContext context, ViewModeState state) {
    if (_notes.isEmpty) {
      return _buildEmptyState(context, state);
    }
    
    if (state.isGridView) {
      return _buildGridView(context);
    } else {
      return _buildListView(context);
    }
  }

  // 📝 DADOS DE EXEMPLO
  List<NoteModel> _getSampleNotes() {
    return [
      NoteModel(id: '1', title: 'Lista de compras', content: 'Leite, pão, ovos, frutas, café, açúcar', color: AppColors.lightNoteYellow, position: 0),
      NoteModel(id: '2', title: 'Ideias para o projeto', content: 'Implementar dark mode, adicionar sincronização na nuvem, melhorar performance', color: AppColors.lightNotePink, position: 1),
      NoteModel(id: '3', title: 'Treino da semana', content: 'Segunda: Peito e tríceps\nQuarta: Costas e bíceps\nSexta: Pernas', color: AppColors.lightNoteGreen, position: 2),
      NoteModel(id: '4', title: 'Livros para ler', content: 'Clean Code, Design Patterns, Refactoring', color: AppColors.lightNoteBlue, position: 3),
      NoteModel(id: '5', title: 'Receita de bolo', content: '3 ovos, 2 xícaras de açúcar, 2 xícaras de farinha, 1 xícara de leite', color: AppColors.lightNoteOrange, position: 4),
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
          Text('Bem-vindo ao ClipStick!', style: AppTextStyles.headingMedium.copyWith(color: Theme.of(context).colorScheme.primary)),
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
            onPressed: () { Get.snackbar('Nova Nota', 'Funcionalidade em breve! ✨', snackPosition: SnackPosition.BOTTOM); },
            icon: Icon(Icons.add),
            label: Text('Criar primeira nota'),
          ),
        ],
      ),
    );
  }

// 📊 GRID VIEW COM REORDERABLE BUILDER - MÉTODO CORRETO
  Widget _buildGridView(BuildContext context) {
    // ✅ GERAR OS WIDGETS DOS CARDS
    final generatedChildren = List.generate(
      _notes.length,
      (index) => _buildGridNoteCard(context, _notes[index]),
    );

    return Padding(
      padding: EdgeInsets.all(16),
      child: ReorderableBuilder(
        scrollController: _scrollController,
        onReorder: (ReorderedListFunction reorderedListFunction) {
          setState(() {
            // ✅ REORDENAR A LISTA DE NOTAS
            _notes = reorderedListFunction(_notes) as List<NoteModel>;
            
            // ✅ ATUALIZAR POSIÇÕES
            for (int i = 0; i < _notes.length; i++) {
              _notes[i] = _notes[i].copyWith(position: i);
            }
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
                  elevation: 0, // ✅ Elevation já vem do Material acima
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



// 🎯 CARD PARA GRID VIEW (Draggable)
  Widget _buildGridNoteCard(BuildContext context, NoteModel note) {
    return Card(
      key: Key(note.id), // ✅ CHAVE OBRIGATÓRIA PARA REORDER
      color: note.color.withOpacity(0.3),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openNote(context, note),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                  Icon(Icons.drag_indicator, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                ],
              ),
              SizedBox(height: 8),
              Expanded(
                child: Text(
                  note.content,
                  style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Hoje', style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                  Icon(Icons.more_horiz, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                ],
              ),
            ],
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
      color:  note.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        
        contentPadding: EdgeInsets.all(16),
       /*  leading: Container(width: 6, height: 60, decoration: BoxDecoration(color: note.color,
        borderRadius: BorderRadius.circular(3),),), */
        title: Text(note.title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, 
        color: Theme.of(context).colorScheme.onSurface,), 
        maxLines: 1, overflow: TextOverflow.ellipsis,),
        subtitle: Padding(padding: EdgeInsets.only(top: 8), child: Text(note.content, style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)), maxLines: 2, overflow: TextOverflow.ellipsis)),
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

   // 📖 FUNÇÃO PARA ABRIR NOTA
  void _openNote(BuildContext context, NoteModel note) {
    Get.snackbar(note.title, 'Abrir nota: ${note.content.substring(0, 30)}...', snackPosition: SnackPosition.BOTTOM);
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
      applicationIcon: Icon(
        Icons.sticky_note_2,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
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
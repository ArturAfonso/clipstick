import 'package:clipstick/features/home/presentation/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/note_model.dart';
import 'color_picker_widget.dart';
// ignore_for_file: deprecated_member_use

class EditNoteSheet extends StatefulWidget {
  final NoteModel note; 
   final BannerAd? bannerAd;
  
   const EditNoteSheet({
    super.key,
    required this.note,
    this.bannerAd,
  });

  @override
  State<EditNoteSheet> createState() => _EditNoteSheetState();
}

class _EditNoteSheetState extends State<EditNoteSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late Color _selectedColor;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isInitialized) {
      
      _titleController = TextEditingController(text: widget.note.title);
      _contentController = TextEditingController(text: widget.note.content);
      _selectedColor = widget.note.color;
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedNote = widget.note.copyWith(
        title: _titleController.text,
        content: _contentController.text,
        color: _selectedColor,
        updatedAt: DateTime.now(),
        createdAt: widget.note.createdAt,
        id: widget.note.id,
        isPinned: widget.note.isPinned,
        position: widget.note.position,
        tags: widget.note.tags,
        
      );

      
      context.read<HomeCubit>().updateNote(updatedNote);

      Get.back(); 
      Get.snackbar(
        'Nota Atualizada',
        '${_titleController.text} foi atualizada com sucesso! ✏️',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _selectedColor.withOpacity(0.9),
        colorText: Theme.of(context).colorScheme.onSurface,
        duration: Duration(seconds: 2),
      );
    }
  }

  void _deleteNote() {
    Get.dialog(
      AlertDialog(
        title: Text('Excluir nota?'),
        content: Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              
              context.read<HomeCubit>().deleteNote(widget.note.id);

              Get.back(); 
              Get.back(); 

              Get.snackbar(
                'Nota Excluída',
                '${widget.note.title} foi excluída! 🗑️',
                snackPosition: SnackPosition.BOTTOM,
                duration: Duration(seconds: 2),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Editar nota',
                          style: AppTextStyles.headingMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Row(
                          children: [
                            
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: _deleteNote,
                              tooltip: 'Excluir nota',
                            ),
                            
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => Get.back(),
                              tooltip: 'Fechar',
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    
                    Text(
                      'Título',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Digite o título da nota',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      style: AppTextStyles.bodyMedium,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, digite um título';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 20),

                    
                    Text(
                      'Conteúdo',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        hintText: 'Digite o conteúdo da nota',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      style: AppTextStyles.bodyMedium,
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, digite o conteúdo';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 20),

                    
                    Text(
                      'Cor da nota',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 12),
                    ColorPickerWidget(
                      selectedColor: _selectedColor,
                      onColorSelected: (color) {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                    ),

                    SizedBox(height: 32),

                    
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                       
                        child: Text(
                          'Salvar alterações',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                     widget.bannerAd != null
                       ? Container(
                           alignment: Alignment.center,
                           margin: EdgeInsets.only(top: 8),
                           child: SizedBox(
                             width: widget.bannerAd!.size.width.toDouble(),
                             height: widget.bannerAd!.size.height.toDouble(),
                             child: AdWidget(ad: widget.bannerAd!),
                           ),
                         )
                       : SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
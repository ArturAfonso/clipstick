import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'color_picker_widget.dart';
import '../../../../core/theme/note_colors_helper.dart';

class CreateNoteSheet extends StatefulWidget {
  const CreateNoteSheet({super.key});

  @override
  State<CreateNoteSheet> createState() => _CreateNoteSheetState();
}

class _CreateNoteSheetState extends State<CreateNoteSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late Color _selectedColor;
  bool _isInitialized = false;

 @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    
    if (!_isInitialized) {
      _selectedColor = NoteColorsHelper.getDefaultColor(context);
      _isInitialized = true;
    }
  }


  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _createNote() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementar criação de nota com Cubit
      Get.back(); // Fecha o BottomSheet
      Get.snackbar(
        'Nota Criada',
        '${_titleController.text} foi criada com sucesso! 📝',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _selectedColor.withOpacity(0.9),
        colorText: Theme.of(context).colorScheme.onSurface,
        duration: Duration(seconds: 2),
      );
      
      // TODO: Chamar o Cubit para adicionar a nota
      // context.read<HomeCubit>().addNote(
      //   title: _titleController.text,
      //   content: _contentController.text,
      //   color: _selectedColor,
      // );
    }
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
          // 🎯 HANDLE DO BOTTOMSHEET (linha pra arrastar)
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 📝 CONTEÚDO DO FORMULÁRIO
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
                    // 🎨 HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nova nota',
                          style: AppTextStyles.headingMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Get.back(),
                          tooltip: 'Fechar',
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // 📝 CAMPO TÍTULO
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

                    // 📄 CAMPO CONTEÚDO
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

                    // 🎨 SELETOR DE COR
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

                    // ✅ BOTÃO CRIAR NOTA
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _createNote,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Criar nota',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
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
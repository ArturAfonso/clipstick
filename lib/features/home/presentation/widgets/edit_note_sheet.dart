import 'package:clipstick/core/utils/utillity.dart';
import 'package:clipstick/features/home/presentation/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/note_model.dart';
import 'color_picker_widget.dart';
// ignore_for_file: deprecated_member_use

class EditNoteSheet extends StatefulWidget {
  final NoteModel note;
  final BannerAd? bannerAd;


  const EditNoteSheet({super.key, required this.note,
   this.bannerAd, });

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

  Future<void> _openLinksInContent() async {
  final content = _contentController.text;
  
  // Regex simples para detectar URLs
  final urlRegex = RegExp(
    r'https?://[^\s]+',
    caseSensitive: false,
  );
  
  final matches = urlRegex.allMatches(content);
  
  if (matches.isEmpty) {
    Utils.normalException(
      title: 'Nenhum link encontrado',
      message: 'Não há links nesta nota.',
    );
    return;
  }
  
  // Se houver apenas um link, abre diretamente
  if (matches.length == 1) {
    final url = matches.first.group(0)!;
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Utils.normalException(
        title: 'Erro',
        message: 'Não foi possível abrir o link',
      );
    }
    return;
  }
  
  // Se houver múltiplos links, mostra um diálogo para escolher
  Get.dialog(
    AlertDialog(
      title: Text('Escolha um link para abrir'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: matches.map((match) {
            final url = match.group(0)!;
            return ListTile(
              title: Text(
                url,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () async {
                Get.back();
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  Utils.normalException(
                    title: 'Erro',
                    message: 'Não foi possível abrir o link',
                  );
                }
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Cancelar'),
        ),
      ],
    ),
  );
}

  Future<void> _saveChanges() async {
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

      var result = await context.read<HomeCubit>().updateNote(updatedNote);
      if (result) {
        Get.back();

      /*   Utils.normalSucess(
          title: 'Nota Atualizada',
          message: '${_titleController.text} foi atualizada com sucesso! ✏️',
        ); */
      } else {
       Utils.normalException(title: 'Erro ao Atualizar', message: 'Não foi possível atualizar esta nota.');

      }
    }
  }

  void _deleteNote() {
    Get.dialog(
      AlertDialog(
        title: Text('Excluir nota?'),
        content: Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancelar')),
          TextButton(
            onPressed: () async {
              var result = await context.read<HomeCubit>().deleteNote(widget.note.id);
              Get.back();
              Get.back();

              if (result) {
                Utils.normalSucess(title: 'Nota Excluída', message: '${widget.note.title} excluída com sucesso! 🗑️');
              } else {
                Utils.normalException(title: 'Erro ao Excluir', message: 'Não foi possível excluir esta nota.');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _copyContentToClipboard() async {
  final content = _contentController.text;
  if (content.trim().isEmpty) return;

  await Clipboard.setData(ClipboardData(text: content));
  Utils.normalSucess(
    title: 'Conteúdo copiado!',
    message: 'O conteúdo da nota foi copiado para a área de transferência.',
  );
}


   void _shareNote(NoteModel note) async {
  final StringBuffer textToShare = StringBuffer();
  
  if (note.title.isNotEmpty) {
    textToShare.write('${note.title}: ');
  }
  textToShare.write(note.content);

  HapticFeedback.selectionClick();

  try {
    final result = await Share.share(
      textToShare.toString(),
      subject: 'ClipStick - ${note.title}',
    );

    if (result.status == ShareResultStatus.success) {
      HapticFeedback.mediumImpact();
    }
  } catch (e) {
    Utils.normalException(
      title: 'Erro ao Compartilhar',
      message: 'Não foi possível compartilhar a nota.',
    );
    HapticFeedback.mediumImpact();
  }
}
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
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
                            style: AppTextStyles.headingMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                          ),
                          Row(
                            children: [
                                      
                                IconButton(icon: Icon(Icons.share_outlined), 
                                onPressed: () => _shareNote(widget.note), tooltip: 'Compartilhar'),
                              IconButton(
                                icon: Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: _deleteNote,
                                tooltip: 'Excluir nota',
                              ),
      
                              IconButton(icon: Icon(Icons.close), onPressed: () => Get.back(), tooltip: 'Fechar'),
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
      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Conteúdo',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Row(
                            children: [
                               IconButton(
      icon: Icon(Icons.link),
      onPressed: _openLinksInContent,
      tooltip: 'Abrir links',
    ),
                               IconButton(icon: Icon(Icons.copy_outlined),
                                onPressed: _copyContentToClipboard, tooltip: 'Copiar conteúdo'),

                        
                            ],
                          )
                        ],
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
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
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
      ),
    );
  }
}

import 'package:clipstick/config/app_config.dart';
import 'package:clipstick/core/utils/utillity.dart';
import 'package:clipstick/data/models/note_model.dart';
import 'package:clipstick/features/home/presentation/cubit/home_cubit.dart';
import 'package:clipstick/features/home/presentation/tutorial/first_note_tutorial_controller.dart';
import 'package:clipstick/features/home/presentation/tutorial/first_note_tutorial_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'color_picker_widget.dart';
import '../../../../core/theme/note_colors_helper.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
// ignore_for_file: deprecated_member_use

class CreateNoteSheet extends StatefulWidget {
  final BannerAd? bannerAd;
  const CreateNoteSheet({super.key, required this.bannerAd});

  @override
  State<CreateNoteSheet> createState() => _CreateNoteSheetState();
}

class _CreateNoteSheetState extends State<CreateNoteSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late Color _selectedColor;
  bool _isInitialized = false;

   // Speech to text
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';

  @override
  initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _selectedColor = NoteColorsHelper.getNeutralColor(context);
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _speech.stop();
    super.dispose();
  }

   Future<void> _startListening() async {
  // Verifica permissão de microfone
  var status = await Permission.microphone.status;
  if (!status.isGranted) {
    status = await Permission.microphone.request();
    if (!status.isGranted) {
      Utils.normalException(
        title: 'Permissão negada',
        message: 'É necessário permitir o acesso ao microfone para usar esta função.',
      );
      return;
    }
  }

  bool available = await _speech.initialize(
    onStatus: (status) {
      if (status == 'done' || status == 'notListening') {
        setState(() => _isListening = false);
      }
    },
    onError: (error) {
      setState(() => _isListening = false);
      Utils.normalException(
        title: 'Erro no reconhecimento',
        message: 'Não foi possível reconhecer a fala. Tente novamente.',
      );
    },
  );

  if (available) {
    setState(() {
      _isListening = true;
      _lastWords = ''; // Limpa as palavras anteriores
    });
    
    // Guarda a posição inicial do cursor
    final initialCursorPosition = _contentController.selection.baseOffset == -1 
        ? _contentController.text.length 
        : _contentController.selection.baseOffset;
    final textBeforeCursor = _contentController.text.substring(0, initialCursorPosition);
    final textAfterCursor = _contentController.text.substring(initialCursorPosition);
    
    _speech.listen(
      onResult: (result) {
        setState(() {
          // Atualiza apenas se houver mudança no texto reconhecido
          if (result.recognizedWords != _lastWords) {
            _lastWords = result.recognizedWords;
            
            // Reconstrói o texto: antes do cursor + texto reconhecido + depois do cursor
            _contentController.text = textBeforeCursor + _lastWords + textAfterCursor;
            
            // Move cursor para depois do texto reconhecido
            _contentController.selection = TextSelection.fromPosition(
              TextPosition(offset: textBeforeCursor.length + _lastWords.length),
            );
          }
        });
      },
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: 3),
      partialResults: true,
      localeId: 'pt_BR',
      cancelOnError: true,
    );
  } else {
    Utils.normalException(
      title: 'Não disponível',
      message: 'O reconhecimento de voz não está disponível neste dispositivo.',
    );
  }
}

   void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _createNote() async {
    if (_formKey.currentState!.validate()) {
      final newNote = NoteModel(
        id: UniqueKey().toString(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        color: _selectedColor,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPinned: false,
        position: 0,
        tags: [],
      );

      var result = await context.read<HomeCubit>().addNote(newNote);

      if (result) {
        Get.back();
      //  Utils.normalSucess(title: 'Nota Criada', message: '${_titleController.text} foi criada com sucesso! 📝');
       final tutorialController = FirstNoteTutorialController();
final shouldShow = await tutorialController.shouldShowTutorial();


        if (shouldShow) {
  final result = await Get.to(() => FirstNoteTutorialScreen(
    gifReorder: AppConfig.tutorialGifReorder,
    gifSetTag: AppConfig.tutorialGifSetTag,
    gifPin: AppConfig.tutorialGifPin,
  ));
  if (result == true) {
    await tutorialController.markTutorialAsCompleted();
  }
}
      } else {
        Utils.normalException(title: 'Erro', message: 'Não foi possível criar a nota. Tente novamente mais tarde.');  
      }
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
                            'Nova nota',
                            style: AppTextStyles.headingMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                          ),
                          IconButton(icon: Icon(Icons.close), onPressed: () => Get.back(), tooltip: 'Fechar'),
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
                        children: [
                          Text(
                            'Conteúdo',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          
                        ],
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        
                        controller: _contentController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                            onPressed: _isListening ? _stopListening : _startListening,
                            tooltip: _isListening ? 'Parar de ouvir' : 'Iniciar ditado',
                          ),
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
                          onPressed: _createNote,
      
                          child: Text(
                            'Criar nota',
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

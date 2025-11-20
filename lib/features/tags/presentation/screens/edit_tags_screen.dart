import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/tag_model.dart';
import '../widgets/tag_input_field.dart';
import '../widgets/tag_item_widget.dart';

class EditTagsScreen extends StatefulWidget {
  const EditTagsScreen({super.key});

  @override
  State<EditTagsScreen> createState() => _EditTagsScreenState();
}

class _EditTagsScreenState extends State<EditTagsScreen> {
  final TextEditingController _newTagController = TextEditingController();
  final FocusNode _newTagFocusNode = FocusNode();
  final List<TagModel> _tags = [];

  // 🆕 CONTROLE DE EDIÇÃO ÚNICA
  String? _editingTagId; // ID do marcador sendo editado

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  @override
  void dispose() {
    _newTagController.dispose();
    _newTagFocusNode.dispose();
    super.dispose();
  }

  // 📥 CARREGAR TAGS (TODO: Implementar persistência)
  void _loadTags() {
    // TODO: Carregar do banco de dados
    // Por enquanto, dados de exemplo
    setState(() {
      _tags.addAll([
        TagModel(
          id: '1',
          name: 'Trabalho',
          createdAt: DateTime.now().subtract(Duration(days: 5)), updatedAt: DateTime.now(),
        ),
        TagModel(
          id: '2',
          name: 'Pessoal',
          createdAt: DateTime.now().subtract(Duration(days: 3)), updatedAt: DateTime.now(),
        ),
        TagModel(
          id: '3',
          name: 'Ideias',
          createdAt: DateTime.now().subtract(Duration(days: 1)), updatedAt: DateTime.now(),
        ),
      ]);
    });
  }

  // ➕ CRIAR NOVA TAG
  void _createTag() {
    final tagName = _newTagController.text.trim();
    
    if (tagName.isEmpty) return;

    // Verifica duplicatas
    if (_tags.any((tag) => tag.name.toLowerCase() == tagName.toLowerCase())) {
      Get.snackbar(
        'Marcador Duplicado',
        'Já existe um marcador com esse nome',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        colorText: Theme.of(context).colorScheme.onErrorContainer,
      );
      return;
    }

    final newTag = TagModel(
      id: Uuid().v4(),
      name: tagName, createdAt: DateTime.now(), updatedAt: DateTime.now(),
    );

    setState(() {
      _tags.add(newTag);
      _newTagController.clear();
    });

    _newTagFocusNode.unfocus();
    HapticFeedback.mediumImpact();

  /*   Get.snackbar(
      'Marcador Criado',
      '"$tagName" foi adicionado aos marcadores 🏷️',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    ); */

    // TODO: Salvar no banco de dados
  }


    // 🆕 INICIAR EDIÇÃO DE TAG
  void _startEditingTag(String tagId) {
    setState(() {
      _editingTagId = tagId; // ✅ Marca como editando
    });
  }

  // 🆕 FINALIZAR EDIÇÃO (SEM SALVAR)
  void _cancelEditingTag() {
    setState(() {
      _editingTagId = null; // ✅ Desmarca edição
    });
  }


  // ✏️ ATUALIZAR TAG
  void _updateTag(TagModel tag, String newName) {
    if (newName.trim().isEmpty) {
      // Se vazio, apenas cancela edição
      _cancelEditingTag();
      return;
    }

    // Verifica duplicatas (exceto a própria tag)
    if (_tags.any((t) => 
      t.id != tag.id && 
      t.name.toLowerCase() == newName.toLowerCase()
    )) {
      Get.snackbar(
        'Nome Duplicado',
        'Já existe um marcador com esse nome',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        colorText: Theme.of(context).colorScheme.onErrorContainer,
      );
      _cancelEditingTag();
      return;
    }

    setState(() {
      final index = _tags.indexWhere((t) => t.id == tag.id);
      if (index != -1) {
        _tags[index] = tag.copyWith(
          name: newName,
          updatedAt: DateTime.now(),
        );
      }
      _editingTagId = null; // ✅ Finaliza edição
    });

    HapticFeedback.lightImpact();

   /*  Get.snackbar(
      'Marcador Atualizado',
      '"${tag.name}" → "$newName" ✏️',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    ); */

    // TODO: Atualizar no banco de dados
  }

  // 🗑️ DELETAR TAG
  void _deleteTag(TagModel tag) {
    // Mostra dialog de confirmação
    Get.dialog(
      AlertDialog(
        title: Text(
          'Excluir Marcador',
          style: AppTextStyles.headingSmall,
        ),
        content: Text(
          'Tem certeza que deseja excluir o marcador "${tag.name}"?\n\nEsta ação não pode ser desfeita.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              
              setState(() {
                _tags.removeWhere((t) => t.id == tag.id);
                _editingTagId = null; // ✅ Limpa edição
              });

              HapticFeedback.heavyImpact();

            /*   Get.snackbar(
                'Marcador Excluído',
                '"${tag.name}" foi removido 🗑️',
                snackPosition: SnackPosition.BOTTOM,
                duration: Duration(seconds: 2),
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                colorText: Theme.of(context).colorScheme.onErrorContainer,
              ); */

              // TODO: Deletar do banco de dados
            },
            child: Text(
              'Excluir',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  // ❌ LIMPAR CAMPO DE NOVA TAG
  void _clearNewTag() {
    _newTagController.clear();
    _newTagFocusNode.unfocus();
    setState(() {});
  }

    // 🆕 INTERCEPTAR BOTÃO VOLTAR
  Future<bool> _onWillPop() async {
    // Se está editando algum marcador, finaliza edição
    if (_editingTagId != null) {
      _cancelEditingTag();
      return false; // ✅ Não fecha a tela, apenas cancela edição
    }
    return true; // ✅ Permite voltar
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        
        // 📱 APPBAR
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Gerenciar Marcadores',
            style: AppTextStyles.headingMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          actions: [
            // 📊 CONTADOR DE MARCADORES
            if (_tags.isNotEmpty)
              Center(
                child: Container(
                  margin: EdgeInsets.only(right: 16),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_tags.length}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
          ],
        ),
      
        // 📝 BODY
        body: Column(
          children: [
            // 🔝 CAMPO DE NOVA TAG (FIXO NO TOPO)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Novo Marcador',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  TagInputField(
                    controller: _newTagController,
                    focusNode: _newTagFocusNode,
                    onSave: _createTag,
                    onClear: _clearNewTag,
                  ),
                ],
              ),
            ),
      
            // 📋 LISTA DE TAGS
            Expanded(
              child: _tags.isEmpty
                ? _buildEmptyState(context)
                : _buildTagsList(context),
            ),
          ],
        ),
      ),
    );
  }

   // 📋 LISTA DE MARCADORES
  Widget _buildTagsList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _tags.length,
      itemBuilder: (context, index) {
        final tag = _tags[index];
        return TagItemWidget(
          key: ValueKey(tag.id),
          tag: tag,
          isEditing: _editingTagId == tag.id, // 🆕 PASSA ESTADO DE EDIÇÃO
          onStartEditing: () => _startEditingTag(tag.id), // 🆕 CALLBACK
          onCancelEditing: _cancelEditingTag, // 🆕 CALLBACK
          onDelete: () => _deleteTag(tag),
          onUpdate: (newName) => _updateTag(tag, newName),
        );
      },
    );
  }

  // 📭 ESTADO VAZIO
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.label_off_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: 16),
          Text(
            'Nenhum marcador criado',
            style: AppTextStyles.headingSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Crie seu primeiro marcador acima',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  
}
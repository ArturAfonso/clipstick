// ignore_for_file: use_build_context_synchronously

import 'package:clipstick/core/utils/utillity.dart';
import 'package:clipstick/features/home/presentation/cubit/home_cubit.dart';
import 'package:clipstick/features/home/presentation/cubit/home_state.dart';
import 'package:clipstick/features/tags/presentation/cubit/tags_cubit.dart';
import 'package:clipstick/features/tags/presentation/cubit/tags_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/tag_model.dart';
import '../widgets/tag_input_field.dart';
import '../widgets/tag_item_widget.dart';
// ignore_for_file: deprecated_member_use

class EditTagsScreen extends StatefulWidget {
  const EditTagsScreen({super.key});

  @override
  State<EditTagsScreen> createState() => _EditTagsScreenState();
}

class _EditTagsScreenState extends State<EditTagsScreen> {
  final TextEditingController _newTagController = TextEditingController();
  final FocusNode _newTagFocusNode = FocusNode();

  String? _editingTagId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _newTagController.dispose();
    _newTagFocusNode.dispose();
    super.dispose();
  }

  void _createTag(List<TagModel> tags) {
    final tagName = _newTagController.text.trim();
    if (tagName.isEmpty) return;

    if (tags.any((tag) => tag.name.toLowerCase() == tagName.toLowerCase())) {
      Utils.normalWarning(message: 'Já existe um marcador com esse nome');
      return;
    }

    final newTag = TagModel(id: Uuid().v4(), name: tagName, createdAt: DateTime.now(), updatedAt: DateTime.now());

    context.read<TagsCubit>().addTag(newTag);
    _newTagController.clear();
    _newTagFocusNode.unfocus();
    HapticFeedback.mediumImpact();
  }

  void _startEditingTag(String tagId) {
    setState(() {
      _editingTagId = tagId;
    });
  }

  void _cancelEditingTag() {
    setState(() {
      _editingTagId = null;
    });
  }

  void _updateTag(TagModel tag, String newName, List<TagModel> tags) {
    if (newName.trim().isEmpty) {
      _cancelEditingTag();
      return;
    }

    if (tags.any((t) => t.id != tag.id && t.name.toLowerCase() == newName.toLowerCase())) {
      Utils.normalWarning(message: 'Já existe um marcador com esse nome');
      _cancelEditingTag();
      return;
    }

    final updatedTag = tag.copyWith(name: newName, updatedAt: DateTime.now());
    context.read<TagsCubit>().updateTag(updatedTag, context);
    _editingTagId = null;
    HapticFeedback.lightImpact();
  }

  void _deleteTag(TagModel tag) {
    Get.dialog(
      AlertDialog(
        title: Text('Excluir Marcador', style: AppTextStyles.headingSmall),
        content: Text(
          'Tem certeza que deseja excluir o marcador "${tag.name}"?\nIsto nao exclui as notas associadas a ele.\n\nEsta ação não pode ser desfeita.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Get.back();
              final noteState = context.read<HomeCubit>().state;
              if (noteState is HomeLoaded) {
                final notesWithTag = noteState.notes
                    .where((note) => note.tags != null && note.tags!.contains(tag.id))
                    .toList();

                final updatedNotes = notesWithTag.map((note) {
                  final newTags = List<String>.from(note.tags ?? []);
                  newTags.remove(tag.id);
                  return note.copyWith(tags: newTags, updatedAt: DateTime.now());
                }).toList();

                if (updatedNotes.isNotEmpty) {
                  await context.read<HomeCubit>().updateNotesBatch(updatedNotes);
                }
              }

              var result = await context.read<TagsCubit>().deleteTag(tag.id, context);

              if (result) {
                Utils.normalSucess(
                title: 'Marcador Excluído',
                message: '"${tag.name}" foi removido de todas as notas 🗑️',
              );
              } else {
                Utils.normalException(
                  title: 'Erro',
                  message: 'Não foi possível excluir o marcador. Tente novamente mais tarde.',
                );  
              }

              HapticFeedback.heavyImpact();

              Get.back();

             

            /*   Future.delayed(Duration(milliseconds: 400), () {
                if (mounted) Get.back();
              }); */
              _editingTagId = null;
            },
            child: Text('Excluir', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _clearNewTag() {
    _newTagController.clear();
    _newTagFocusNode.unfocus();
    setState(() {});
  }

  Future<bool> _onWillPop() async {
    if (_editingTagId != null) {
      _cancelEditingTag();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,

        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Get.back()),
          title: Text(
            'Gerenciar Marcadores',
            style: AppTextStyles.headingMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          actions: [
            BlocBuilder<TagsCubit, TagsState>(
              builder: (context, state) {
                if (state is TagsLoaded && state.tags.isNotEmpty) {
                  return Center(
                    child: Container(
                      margin: EdgeInsets.only(right: 16),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${state.tags.length}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ],
        ),

        body: BlocBuilder<TagsCubit, TagsState>(
          builder: (context, state) {
            if (state is TagsLoading) {
              return Center(child: CircularProgressIndicator());
            }
            if (state is TagsLoaded) {
              final tags = state.tags;
              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2)),
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
                          onSave: () => _createTag(tags),
                          onClear: _clearNewTag,
                        ),
                      ],
                    ),
                  ),

                  Expanded(child: tags.isEmpty ? _buildEmptyState(context) : _buildTagsList(context, tags)),
                ],
              );
            }
            return _buildEmptyState(context);
          },
        ),
      ),
    );
  }

  Widget _buildTagsList(BuildContext context, List<TagModel> tags) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        return TagItemWidget(
          key: ValueKey(tag.id),
          tag: tag,
          isEditing: _editingTagId == tag.id,
          onStartEditing: () => _startEditingTag(tag.id),
          onCancelEditing: _cancelEditingTag,
          onDelete: () {
            _deleteTag(tag);
          },
          onUpdate: (newName) => _updateTag(tag, newName, tags),
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
            'Nenhum marcador criado',
            style: AppTextStyles.headingSmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          ),
          SizedBox(height: 8),
          Text(
            'Crie seu primeiro marcador acima',
            style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
          ),
        ],
      ),
    );
  }
}

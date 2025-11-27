import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/tag_model.dart';

class TagItemWidget extends StatefulWidget {
  final TagModel tag;
  final bool isEditing; 
  final VoidCallback onStartEditing; 
  final VoidCallback onCancelEditing; 
  final VoidCallback onDelete;
  final Function(String newName) onUpdate;

  const TagItemWidget({
    super.key,
    required this.tag,
    required this.isEditing, 
    required this.onStartEditing, 
    required this.onCancelEditing, 
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<TagItemWidget> createState() => _TagItemWidgetState();
}

class _TagItemWidgetState extends State<TagItemWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.tag.name);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  
  @override
  void didUpdateWidget(TagItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    
    if (widget.isEditing && !oldWidget.isEditing) {
      _focusNode.requestFocus();
    }
    
    
    if (!widget.isEditing && oldWidget.isEditing) {
      _controller.text = widget.tag.name;
      _focusNode.unfocus();
    }
  }

  void _saveEdit() {
    final newName = _controller.text.trim();
    
    
    widget.onUpdate(newName);
    
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: _buildEditingField(context),
      );
    }

    return InkWell(
      onTap: () {
        widget.onStartEditing(); 
        HapticFeedback.selectionClick();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.label_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.tag.name,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.edit_outlined,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditingField(BuildContext context) {
    final hasText = _controller.text.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNode.hasFocus
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: _focusNode.hasFocus ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.delete_outline, size: 20),
            color: Theme.of(context).colorScheme.error,
            onPressed: () {
              _focusNode.unfocus();
              widget.onDelete();
            },
            tooltip: 'Excluir marcador',
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Editar marcador...',
                border: InputBorder.none,
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _saveEdit(),
            ),
          ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: hasText
              ? IconButton(
                  key: ValueKey('save_button'),
                  icon: Icon(Icons.check, size: 20),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: _saveEdit,
                  tooltip: 'Salvar alterações',
                )
              : SizedBox(width: 48, key: ValueKey('empty_save')),
          ),
        ],
      ),
    );
  }
}
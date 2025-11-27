import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class TagInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSave;
  final VoidCallback onClear;
  final String? initialValue;
  final bool isEditing;

  const TagInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSave,
    required this.onClear,
    this.initialValue,
    this.isEditing = false,
  });

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      widget.controller.text = widget.initialValue!;
    }
  }

  bool get _hasText => widget.controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.focusNode.hasFocus
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: widget.focusNode.hasFocus ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          
          AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: _hasText
              ? IconButton(
                  key: ValueKey('clear_button'),
                  icon: Icon(Icons.close, size: 20),
                  color: Theme.of(context).colorScheme.error,
                  onPressed: () {
                    widget.controller.clear();
                    widget.onClear();
                    setState(() {});
                  },
                  tooltip: 'Cancelar',
                )
              : SizedBox(width: 48, key: ValueKey('empty')),
          ),

          
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: widget.isEditing 
                  ? 'Editar marcador...' 
                  : 'Novo marcador...',
                border: InputBorder.none,
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) {
                if (_hasText) {
                  widget.onSave();
                }
              },
            ),
          ),

          
          AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: _hasText
              ? IconButton(
                  key: ValueKey('save_button'),
                  icon: Icon(Icons.check, size: 20),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    if (_hasText) {
                      widget.onSave();
                    }
                  },
                  tooltip: 'Salvar',
                )
              : SizedBox(width: 48, key: ValueKey('empty_save')),
          ),
        ],
      ),
    );
  }
}
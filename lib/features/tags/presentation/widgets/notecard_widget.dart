import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/note_model.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const NoteCard({super.key, required this.note, required this.onTap, this.onLongPress, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    final noteColor = note.color;

    return Container(
      decoration: BoxDecoration(
        color: noteColor,
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🎯 HEADER: Pin + Título + Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 📌 ÍCONE DE FIXADO
                    if (note.isPinned)
                      Padding(
                        padding: EdgeInsets.only(right: 8, top: 2),
                        child: Icon(Icons.push_pin, size: 16, color: Theme.of(context).colorScheme.primary),
                      ),

                    // 📝 TÍTULO
                    Expanded(
                      child: Text(
                        note.title.isEmpty ? 'Sem título' : note.title,
                        style: AppTextStyles.headingSmall.copyWith(
                          color: _getTextColor(noteColor),
                          fontStyle: note.title.isEmpty ? FontStyle.italic : FontStyle.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // ✅ CHECKBOX (se selecionado)
                    if (isSelected) Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 24),
                  ],
                ),

                // 📄 CONTEÚDO
                if (note.content.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Expanded(
                    child: Text(
                      note.content,
                      style: AppTextStyles.bodyMedium.copyWith(color: _getTextColor(noteColor).withOpacity(0.8)),
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],

                // 🏷️ TAGS (se houver)
                if (note.tags != null && note.tags!.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: note.tags!.take(2).map((tagId) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getTextColor(noteColor).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _getTextColor(noteColor).withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.label, size: 10, color: _getTextColor(noteColor).withOpacity(0.7)),
                            SizedBox(width: 4),
                            Text(
                              tagId, // TODO: Substituir por tag.name
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 10,
                                color: _getTextColor(noteColor).withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  if (note.tags!.length > 2)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        '+${note.tags!.length - 2} mais',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 10,
                          color: _getTextColor(noteColor).withOpacity(0.6),
                        ),
                      ),
                    ),
                ],

                // 📅 DATA DE ATUALIZAÇÃO
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    _formatDate(note.updatedAt!),
                    style: AppTextStyles.bodySmall.copyWith(color: _getTextColor(noteColor).withOpacity(0.6)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🎨 CALCULAR COR DE TEXTO BASEADO NO FUNDO
  Color _getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // 📅 FORMATAR DATA
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}min atrás';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h atrás';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

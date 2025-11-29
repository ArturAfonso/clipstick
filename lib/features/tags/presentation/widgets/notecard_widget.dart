import 'package:clipstick/data/models/tag_model.dart';
import 'package:clipstick/features/tags/presentation/cubit/tags_cubit.dart';
import 'package:clipstick/features/tags/presentation/cubit/tags_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/note_model.dart';
// ignore_for_file: deprecated_member_use

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
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    if (note.isPinned)
                      Padding(
                        padding: EdgeInsets.only(right: 8, top: 2),
                        child: Icon(Icons.push_pin, size: 16, color: Theme.of(context).colorScheme.primary),
                      ),

                    
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

                    
                    if (isSelected) Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 24),
                  ],
                ),

                
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

                
                if (note.tags != null && note.tags!.isNotEmpty) ...[
                  
                  SizedBox(height: 12),
                  BlocBuilder<TagsCubit, TagsState>(
                    builder: (context, tagState) {
                      List<String> tagNames = [];
                      if (tagState is TagsLoaded) {
                        tagNames = note.tags!
                            .map((tagId) {
                              final tag = tagState.tags.firstWhere(
                                (t) => t.id == tagId,
                                orElse: () => TagModel(id: tagId, name: tagId, createdAt: DateTime.now(), updatedAt: DateTime.now()), 
                              );
                              return tag.name;
                            })
                            .toList();
                      } else {
                        tagNames = note.tags!;
                      }
                      return Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: tagNames.take(2).map((tagName) {
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
                                  tagName,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontSize: 10,
                                    color: _getTextColor(noteColor).withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
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

  
  Color _getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  
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

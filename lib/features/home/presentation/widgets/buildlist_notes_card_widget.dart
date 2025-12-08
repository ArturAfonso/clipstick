



 import 'package:clipstick/core/theme/app_colors.dart';
import 'package:clipstick/core/theme/app_text_styles.dart';
import 'package:clipstick/core/theme/note_colors_helper.dart';
import 'package:clipstick/data/models/note_model.dart';
import 'package:clipstick/features/home/presentation/widgets/build_tagsrow_widget.dart';
import 'package:flutter/material.dart';

Widget buildListNoteCard(BuildContext context, NoteModel note, bool isSelected, {Key? key}) {
    final cardElevation = isSelected ? 6.0 : 2.0;
    var realceColor = NoteColorsHelper.getAvailableColors(context).contains(note.color);
    debugPrint(realceColor.toString());
    var listaColors = NoteColorsHelper.getAvailableColors(context);
    debugPrint(listaColors.first.toString());
    debugPrint(note.color.toString());
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AnimatedContainer(
        key: key ?? ValueKey(note.id),
        duration: Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3) : null,
        ),
        child: Card(
          key: key ?? ValueKey(note.id),

          elevation: cardElevation,
          shadowColor: Theme.of(context).colorScheme.shadow,
          color: note.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.all(10),

            title: Text(
              note.title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(note.color),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.content,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.getTextColor(note.color).withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (note.tags != null && note.tags!.isNotEmpty) SizedBox(height: 12),
                  buildTagsRow(context, note),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
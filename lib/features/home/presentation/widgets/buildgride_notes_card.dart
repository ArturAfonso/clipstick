



// ignore_for_file: deprecated_member_use

import 'package:clipstick/core/theme/app_colors.dart';
import 'package:clipstick/core/theme/app_text_styles.dart';
import 'package:clipstick/data/models/note_model.dart';
import 'package:clipstick/features/home/presentation/widgets/build_tagsrow_widget.dart';
import 'package:flutter/material.dart';

Widget buildGridNoteCard(BuildContext context, {required NoteModel note, required bool isNoteSelected, required void Function()? onTap}) {
   // final isSelected = _isNoteSelected(note.id);

    return GestureDetector(
      key: Key(note.id),
      onTap: onTap,

      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isNoteSelected ? Theme.of(context).colorScheme.primary : Colors.transparent, width: 3),
          boxShadow: isNoteSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 3,
                  ),
                ]
              : [],
        ),

        child: Card(
          margin: EdgeInsets.zero,
          color: note.color,
          elevation: isNoteSelected ? 4 : 2,
          shadowColor: Theme.of(context).colorScheme.shadow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isNoteSelected)
                      Container(
                        padding: EdgeInsets.all(4),
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                        child: Icon(Icons.check, size: 14, color: Theme.of(context).colorScheme.onPrimary),
                      ),

                    Expanded(
                      child: Text(
                        note.title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextColor(note.color),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Expanded(
                  child: Text(
                    note.content,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.getTextColor(note.color)),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Visibility(
                  visible: note.tags != null && note.tags!.isNotEmpty,
                  child: Column(children: [SizedBox(height: 8), buildTagsRow(context, note)]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


// ignore_for_file: deprecated_member_use

import 'package:clipstick/core/theme/app_colors.dart';
import 'package:clipstick/core/theme/app_text_styles.dart';
import 'package:clipstick/data/models/note_model.dart';
import 'package:clipstick/data/models/tag_model.dart';
import 'package:clipstick/features/tags/presentation/cubit/tags_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../tags/presentation/cubit/tags_cubit.dart';

Widget buildTagsRow(BuildContext context, NoteModel note) {
    if (note.tags == null || note.tags!.isEmpty) {
      return SizedBox(height: 20);
    }

    return BlocBuilder<TagsCubit, TagsState>(
      builder: (context, tagState) {
        List<String> tagNames = [];
        if (tagState is TagsLoaded) {
          tagNames = note.tags!.map((tagId) {
            final tag = tagState.tags.firstWhere(
              (t) => t.id == tagId,
              orElse: () => TagModel(id: tagId, name: 'Tag', createdAt: DateTime.now(), updatedAt: DateTime.now()),
            );
            return tag.name;
          }).toList();
        }

        return Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            ...tagNames.take(2).map((tagName) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2), width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(MdiIcons.tagOutline, size: 10, color: AppColors.getTextColor(note.color).withOpacity(0.6)),
                    SizedBox(width: 3),
                    Text(
                      tagName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.getTextColor(note.color).withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (tagNames.length > 2)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+${tagNames.length - 2}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 9,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
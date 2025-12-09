


// ignore_for_file: deprecated_member_use

import 'package:clipstick/core/theme/app_text_styles.dart';
import 'package:clipstick/data/models/note_model.dart';
import 'package:clipstick/data/models/tag_model.dart';
import 'package:clipstick/features/home/presentation/cubit/home_cubit.dart';
import 'package:clipstick/features/home/presentation/cubit/home_state.dart';
import 'package:clipstick/features/tags/presentation/screens/tag_screen_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

Widget buildTagItem(BuildContext context, TagModel tag) {
    final noteState = context.read<HomeCubit>().state;
    List<NoteModel> notes = [];
    if (noteState is HomeLoaded) {
      notes = noteState.notes;
    }

    final noteCount = notes.where((note) {
      return note.tags != null && note.tags!.contains(tag.id);
    }).length;

    return ListTile(
      leading: Icon(MdiIcons.tagOutline, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), size: 18),
      title: Text(tag.name, style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface)),
      trailing: noteCount > 0
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$noteCount',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            )
          : null,
      onTap: () {
        Get.back();
        Get.to(() => TagViewScreen(tag: tag));
      },
    );
  }
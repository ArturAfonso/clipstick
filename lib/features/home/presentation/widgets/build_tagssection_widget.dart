import 'package:clipstick/core/theme/app_text_styles.dart';
import 'package:clipstick/features/home/presentation/widgets/buildtag_item_widget.dart';
import 'package:clipstick/features/tags/presentation/cubit/tags_state.dart';
import 'package:clipstick/features/tags/presentation/screens/edit_tags_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../tags/presentation/cubit/tags_cubit.dart';

Widget buildTagsSection(BuildContext context) {
    final ScrollController tagsScrollController = ScrollController();
    return BlocBuilder<TagsCubit, TagsState>(
      builder: (context, tagState) {
        if (tagState is TagsLoading) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (tagState is TagsLoaded) {
          final tags = tagState.tags;
          final hasTags = tags.isNotEmpty;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(MdiIcons.tagOutline),
                    SizedBox(width: 10),
                    Text(
                      'MARCADORES',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              if (hasTags)
                if (tags.length > 4)
                  SizedBox(
                    height: Get.size.height / 3,
                    child: Scrollbar(
                      controller: tagsScrollController,
                      thumbVisibility: true,
                      child: ListView.builder(
                        controller: tagsScrollController,
                        shrinkWrap: false,
                        itemCount: tags.length,
                        itemBuilder: (context, index) {
                          final tag = tags[index];
                          return buildTagItem(context, tag);
                        },
                      ),
                    ),
                  )
                else
                  ...tags.map((tag) => buildTagItem(context, tag)),

              SizedBox(height: 8),

              ListTile(
                leading: Icon(
                  tags.isEmpty ? MdiIcons.tagPlusOutline : MdiIcons.tagSearchOutline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  !hasTags ? 'Criar Novo Marcador' : 'Gerenciar Marcadores',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,

                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Get.back();
                  Get.to(() => EditTagsScreen());
                },
              ),
            ],
          );
        }
        return SizedBox.shrink();
      },
    );
  }



// ignore_for_file: deprecated_member_use

import 'package:clipstick/core/theme/app_text_styles.dart';
import 'package:clipstick/features/home/presentation/cubit/view_mode_cubit.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget buildEmptyState(BuildContext context, ViewModeState state, VoidCallback ontap, GlobalKey addButtonKey) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.noteSticky, size: 120, color: Theme.of(context).colorScheme.primary),
          SizedBox(height: 24),
          Text(
            'Bem-vindo ao ClipStick!',
            style: AppTextStyles.headingMedium.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Suas notas auto adesivas digitais.\nApós criar suas primeiras notas, você pode organizá-las como quiser pressionando-as e as arrastando!',
              style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            key: addButtonKey,
            onPressed: () {
              ontap();
            },
            icon: Icon(Icons.add),
            label: Text('Criar primeira nota'),
          ),
        ],
      ),
    );
  }
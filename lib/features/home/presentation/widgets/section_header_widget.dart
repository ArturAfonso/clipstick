

import 'package:clipstick/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

Widget sectionHeader(BuildContext context, String title, int count) {
    return Row(
      children: [
        Expanded(child: Divider(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              //fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Divider(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        /* SizedBox(width: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ), */
      ],
    );
  }
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/note_colors_helper.dart';

class ColorPickerWidget extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const ColorPickerWidget({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });


  @override
  Widget build(BuildContext context) {
     final availableColors = NoteColorsHelper.getAvailableColors(context);
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: availableColors.map((color) {
        final isSelected = color == selectedColor;
        
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
            ),
            child: isSelected
              ? Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 24,
                )
              : null,
          ),
        );
      }).toList(),
    );
  }
}
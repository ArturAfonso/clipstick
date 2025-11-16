import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import '../../../../core/theme/note_colors_helper.dart';

class ColorPickerWidget extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const ColorPickerWidget({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  // 🎨 ABRIR SELETOR DE COR PERSONALIZADA
  void _showCustomColorPicker(BuildContext context) {
    Color tempColor = selectedColor;
    
    Get.dialog(
      AlertDialog(
        title: Text('Escolher cor personalizada'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (color) {
              tempColor = color;
            },
            pickerAreaHeightPercent: 0.8,
            displayThumbColor: true,
            enableAlpha: false,
            labelTypes: [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              onColorSelected(tempColor);
              Get.back();
            },
            child: Text('Selecionar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableColors = NoteColorsHelper.getAvailableColors(context);
    final neutralColor = NoteColorsHelper.getNeutralColor(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // 🚫 OPÇÃO "SEM COR"
          _buildColorOption(
            context: context,
            color: neutralColor,
            isSelected: selectedColor == neutralColor,
            isNeutral: true,
          ),
          
          SizedBox(width: 12),

          // 🎨 CORES PADRÃO
          ...availableColors.map((color) => Padding(
            padding: EdgeInsets.only(right: 12),
            child: _buildColorOption(
              context: context,
              color: color,
              isSelected: selectedColor == color,
            ),
          )),

          // 🌈 OPÇÃO "COR PERSONALIZADA"
          _buildCustomColorOption(context),
        ],
      ),
    );
  }

  // 🎨 WIDGET PARA CADA OPÇÃO DE COR
  Widget _buildColorOption({
    required BuildContext context,
    required Color color,
    required bool isSelected,
    bool isNeutral = false,
  }) {
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
              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 3 : 1,
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
        child: isNeutral
          ? Icon(
              Icons.format_color_reset, // ✅ Ícone de "sem cor"
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: 24,
            )
          : isSelected
            ? Icon(
                Icons.check,
                color: _getContrastColor(color),
                size: 24,
              )
            : null,
      ),
    );
  }

  // 🌈 WIDGET PARA COR PERSONALIZADA
  Widget _buildCustomColorOption(BuildContext context) {
    final isCustomSelected = !NoteColorsHelper.getAvailableColors(context).contains(selectedColor) 
      && selectedColor != NoteColorsHelper.getNeutralColor(context);

    return GestureDetector(
      onTap: () => _showCustomColorPicker(context),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isCustomSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isCustomSelected ? 3 : 1,
          ),
          gradient: isCustomSelected
            ? null
            : LinearGradient(
                colors: [
                  Colors.red,
                  Colors.orange,
                  Colors.yellow,
                  Colors.green,
                  Colors.blue,
                  Colors.purple,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
          color: isCustomSelected ? selectedColor : null,
          boxShadow: /* isCustomSelected
            ? [
                BoxShadow(
                  color: selectedColor.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : */ null,
        ),
        child: Icon(
          Icons.palette,
          color: isCustomSelected 
            ? _getContrastColor(selectedColor)
            : Colors.white,
          size: 24,
        ),
      ),
    );
  }

  // 🎨 RETORNA COR DE CONTRASTE PARA O ÍCONE
  Color _getContrastColor(Color backgroundColor) {
    // Calcula luminância
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
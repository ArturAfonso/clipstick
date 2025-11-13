import 'package:clipstick/core/theme/note_colors_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ColorPickerDialog extends StatefulWidget {
  final Color? initialColor;
  final bool isMultipleSelection;
  final int selectedCount;

  const ColorPickerDialog({
    super.key,
    this.initialColor,
    this.isMultipleSelection = false,
    this.selectedCount = 1,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _selectedColor;


  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor ?? NoteColorsHelper.getDefaultColor(context);
  }


// 🎨 OBTÉM CORES DO HELPER (baseado no tema)
  List<Color> get _predefinedColors {
    return NoteColorsHelper.getAvailableColors(context);
  }
 

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎨 HEADER
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cor da Nota',
                        style: AppTextStyles.headingMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (widget.isMultipleSelection)
                        Text(
                          '${widget.selectedCount} nota${widget.selectedCount > 1 ? 's' : ''} selecionada${widget.selectedCount > 1 ? 's' : ''}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),

            SizedBox(height: 24),

            // 🎨 GRID DE CORES CIRCULARES
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 400),
              child: SingleChildScrollView(
                child: _buildColorGrid(context),
              ),
            ),

            SizedBox(height: 24),

            // ✅ BOTÃO APLICAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(result: _selectedColor),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor,
                  foregroundColor: _getContrastColor(_selectedColor),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Aplicar Cor',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // 🎨 GRID DE CORES (CIRCULAR)
  Widget _buildColorGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // ✅ 5 colunas
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: _predefinedColors.length + 2, // ✅ +1 sem cor +1 personalizado
      itemBuilder: (context, index) {
        // ❌ PRIMEIRO ITEM = SEM COR
        if (index == 0) {
          return _buildNoColorButton(context);
        }
        
        // 🎨 ÚLTIMO ITEM = BOTÃO PERSONALIZADO
        if (index == _predefinedColors.length + 1) {
          return _buildCustomColorButton(context);
        }

        // ✅ CORES NORMAIS
        final color = _predefinedColors[index - 1]; // -1 porque índice 0 é "sem cor"
        return _buildColorButton(context, color);
      },
    );
  }


// ❌ BOTÃO "SEM COR"
  Widget _buildNoColorButton(BuildContext context) {
    final neutralColor = NoteColorsHelper.getNeutralColor(context); // ✅ USA HELPER
    final isSelected = _selectedColor == neutralColor;

    return InkWell(
      onTap: () => setState(() => _selectedColor = neutralColor),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        decoration: BoxDecoration(
          color: neutralColor, // ✅ COR NEUTRA DO TEMA
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.withOpacity(0.3),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : [],
        ),
        child: Center(
          child: Icon(
            Icons.format_color_reset,
            color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
            size: 28,
          ),
        ),
      ),
    );
  }

  // 🎨 BOTÃO DE COR NORMAL
  Widget _buildColorButton(BuildContext context, Color color) {
    final isSelected = _selectedColor == color;

    return InkWell(
      onTap: () => setState(() => _selectedColor = color),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.withOpacity(0.3),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : [],
        ),
        child: isSelected
          ? Icon(
              Icons.check,
              color: _getContrastColor(color),
              size: 28,
            )
          : null,
      ),
    );
  }

   // 🌈 BOTÃO "PERSONALIZADO"
  Widget _buildCustomColorButton(BuildContext context) {
    return InkWell(
      onTap: () => _openCustomColorPicker(context),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
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
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.colorize,
            color: Colors.white,
            size: 28,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
  

   // 🎨 ABRE DIALOG DE COR PERSONALIZADA
  void _openCustomColorPicker(BuildContext context) async {
    final Color? customColor = await Get.dialog<Color>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🎨 HEADER
              Row(
                children: [
                  Icon(
                    Icons.colorize,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cor Personalizada',
                      style: AppTextStyles.headingMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // 🎨 COLOR WHEEL
              ColorPicker(
                pickerColor: _selectedColor,
                onColorChanged: (Color color) {
                  setState(() => _selectedColor = color);
                },
                pickerAreaHeightPercent: 0.8,
                displayThumbColor: true,
                enableAlpha: false,
                labelTypes: const [],
                paletteType: PaletteType.hueWheel,
              ),

              
           

              SizedBox(height: 24),

              // ✅ BOTÃO CONFIRMAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(result: _selectedColor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedColor,
                    foregroundColor: _getContrastColor(_selectedColor),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Confirmar Cor',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // ✅ Se selecionou uma cor personalizada, atualiza
    if (customColor != null) {
      setState(() => _selectedColor = customColor);
    }
  }

// 🎨 CALCULAR COR DE CONTRASTE
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

}
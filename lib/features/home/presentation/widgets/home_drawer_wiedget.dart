


// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';

import 'package:clipstick/core/database/database.dart';
import 'package:clipstick/core/di/service_locator.dart';
import 'package:clipstick/core/theme/app_text_styles.dart';
import 'package:clipstick/core/theme/themetoggle_button.dart';
import 'package:clipstick/core/utils/utillity.dart';
import 'package:clipstick/features/home/presentation/widgets/build_tagssection_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

import '../tutorial/drawer_tutorial_controller.dart';


class HomeDrawer extends StatefulWidget {
  final VoidCallback? onDrawerOpened; 
  const HomeDrawer({super.key, this.onDrawerOpened});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  final DrawerTutorialController _tutorialController = DrawerTutorialController();
  
  // GlobalKeys para os targets do tutorial
  final GlobalKey _tagsListKey = GlobalKey();
  final GlobalKey _createTagKey = GlobalKey();
  final GlobalKey _themeToggleKey = GlobalKey();
  final GlobalKey _backupRestoreKey = GlobalKey();

  @override
  void initState() {
    super.initState();
     // Chama o callback quando o widget é construído (drawer aberto)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDrawerOpened?.call();
      _checkAndShowTutorial();
    });
  }

  Future<void> _checkAndShowTutorial() async {
    final shouldShow = await _tutorialController.shouldShowTutorial();
    
    if (shouldShow) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tutorialController.showTutorial(
          context: context,
          tagsListKey: _tagsListKey,
          createTagKey: _createTagKey,
          themeToggleKey: _themeToggleKey,
          backupRestoreKey: _backupRestoreKey,
          onFinish: () {
            debugPrint("Tutorial do Drawer concluído!");
          },
        );
      });
    }
  }

  @override
  void dispose() {
    _tutorialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 16, bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('assets/clipstick-logo.png', width: 54, height: 54, fit: BoxFit.cover),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ClipStick',
                      style: AppTextStyles.headingMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Suas notas organizadas',
                      style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)),

          // Target 1: Lista de Marcadores (envolve a seção de tags)
          Container(
           
            child: buildTagsSection(context, createTagKey: _createTagKey, tagsListKey: _tagsListKey ),
          ),

          Divider(height: 1, thickness: 1, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)),

          // Target 3: Toggle de Tema
          Container(
            key: _themeToggleKey,
            child: ThemeToggleButton(),
          ),

          // Target 4: Backup & Restore (mesma key para ambos)
          Container(
            key: _backupRestoreKey,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(MdiIcons.databaseArrowUpOutline),
                  title: Text('Fazer Backup Local'),
                  onTap: () {
                   
                    _backupDatabase(context);
                  },
                ),
                ListTile(
                  leading: Icon(MdiIcons.databaseArrowDownOutline),
                  title: Text('Restaurar Backup'),
                  onTap: () {
                   
                    _restoreDatabaseComInstrucao(context);
                  },
                ),
              ],
            ),
          ),

          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Sobre'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  // ========================================
  // MÉTODOS AUXILIARES (mantém como está)
  // ========================================

  Future<void> _backupDatabase(BuildContext context) async {
  final navigatorContext = Navigator.of(context, rootNavigator: true).context;
  
  try {
    final dbDir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbDir.path, 'clipstick.sqlite'));
    final dbBytes = await dbFile.readAsBytes();

    // Gera nome com data legível
final now = DateTime.now();
final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}h${now.minute.toString().padLeft(2, '0')}';
final fileName = 'clipstick_backup_$dateStr.sqlite';

    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Salvar backup do ClipStick',
      fileName: fileName, // Nome único com timestamp
      type: FileType.custom,
      allowedExtensions: ['sqlite'],
      bytes: dbBytes,
    );

    if (outputPath == null) {
      debugPrint('Backup cancelado pelo usuário');
      return;
    }

    if (navigatorContext.mounted) {
      showLoadingDialog(navigatorContext, message: 'Realizando backup...');
    }

    await Future.delayed(Duration(seconds: 2));

    if (navigatorContext.mounted) {
      Navigator.of(navigatorContext, rootNavigator: true).pop();
    }

    debugPrint('Backup salvo em: $outputPath');
    Utils.normalSucess(message: 'Backup realizado com sucesso!');

  } catch (e, stack) {
    debugPrint('Erro ao realizar backup: $e\n$stack');
    
    if (navigatorContext.mounted) {
      Navigator.of(navigatorContext, rootNavigator: true).pop();
    }
    
    Utils.normalException(message: "Erro ao realizar backup: ${e.toString()}");
  } finally {
    // Descomente quando estiver pronto para produção
    // await cleanupServiceLocator();
    // await setupServiceLocator();
    // Restart.restartApp();
  }
}

  Future<void> _restoreDatabaseComInstrucao(BuildContext context) async {
    final bool? continuar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber),
              SizedBox(width: 8),
              Text('Dica'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Se não conseguir selecionar o arquivo:', style: AppTextStyles.bodyLarge),
              SizedBox(height: 12),
              _itemInstrucao('1', 'Toque no menu ☰ no canto superior'),
              SizedBox(height: 12),
              _itemInstrucao('2', 'Selecione o nome do seu dispositivo'),
              SizedBox(height: 12),
              _itemInstrucao('3', 'Navegue até a pasta do backup'),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.folder, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(child: Text('Geralmente em Downloads ou Documentos', style: TextStyle(fontSize: 12))),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancelar')),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text('Entendi')),
          ],
        );
      },
    );

    if (continuar != true) return;

    await _restoreDatabase(context);
  }

  Future<void> _restoreDatabase(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['sqlite'],
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        debugPrint('Restauração cancelada pelo usuário');
        return;
      }

      final backupFile = File(result.files.single.path!);

      if (!backupFile.path.toLowerCase().endsWith('.sqlite')) {
        Utils.normalException(message: "Selecione um arquivo com extensão .sqlite");
        return;
      }

      bool isValid = await _isValidBackupSchema(backupFile);
      if (!isValid) {
        Utils.normalException(message: "Arquivo de backup inválido ou incompatível com esta versão do app.");
        return;
      }

      await sl<AppDatabase>().close();

      showLoadingDialog(context, message: 'Restaurando backup...');

      await Future.delayed(Duration(seconds: 1));

      final dbDir = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbDir.path, 'clipstick.sqlite'));

      await backupFile.copy(dbFile.path);

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      debugPrint('Banco restaurado com sucesso!');
      Utils.normalSucess(message: 'Banco restaurado com sucesso!');

      await cleanupServiceLocator();
      await setupServiceLocator();
      Restart.restartApp();
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      debugPrint('Erro ao restaurar backup: $e');
      Utils.normalException(message: "Erro ao restaurar backup: ${e.toString()}");
    }
  }

  Future<void> showLoadingDialog(BuildContext context, {String? message}) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              if (message != null) ...[SizedBox(height: 16), Text(message, style: TextStyle(color: Colors.white))],
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'ClipStick',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(Icons.sticky_note_2, size: 48, color: Theme.of(context).colorScheme.primary),
      children: [
        Text(
          'ClipStick é seu mural digital de notas rápidas. '
          'Registre ideias, listas e lembretes em cartões coloridos '
          'que mantêm tudo claro, leve e organizado.',
        ),
      ],
    );
  }

  Widget _itemInstrucao(String numero, String texto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
          child: Center(
            child: Text(
              numero,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(child: Text(texto, style: AppTextStyles.bodyMedium)),
      ],
    );
  }

  Future<bool> _isValidBackupSchema(File backupFile) async {
    final tempDir = await getTemporaryDirectory();
    final tempDbFile = File('${tempDir.path}/temp_restore_check.sqlite');
    await backupFile.copy(tempDbFile.path);

    final db = sqlite3.sqlite3.open(tempDbFile.path);

    try {
      final tables = db
          .select("SELECT name FROM sqlite_master WHERE type='table';")
          .map((row) => row['name'] as String)
          .toList();

      if (tables.contains('notes') && tables.contains('tags')) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      db.dispose();
      await tempDbFile.delete();
    }
  }
}
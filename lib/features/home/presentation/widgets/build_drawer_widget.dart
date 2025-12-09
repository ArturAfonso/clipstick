


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

Widget buildDrawer(BuildContext context) {
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

          buildTagsSection(context),

          Divider(height: 1, thickness: 1, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)),

          ThemeToggleButton(),
          //funcionalidade sera implementada no futuro
          /* ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text('Configurações'),
            onTap: () {
              Navigator.pop(context);
              },
          ), */
          //funcionalidade sera implementada no futuro
          ListTile(
            leading: Icon(MdiIcons.databaseArrowUpOutline),
            title: Text('Fazer Backup Local'),
            onTap: () {
              Navigator.pop(context);
              backupDatabase(context);
             
            },
          ),
          ListTile(
            leading: Icon(MdiIcons.databaseArrowDownOutline),
            title: Text('Restaurar Backup'),
            onTap: () {
              Navigator.pop(context);
              restoreDatabaseComInstrucao(context);
              
            },
          ),

          //funcionalidade sera implementada no futuro
          /*  ListTile(
            leading: Icon(Icons.login_outlined),
            title: Text('Entrar'),
            onTap: () {
              Navigator.pop(context);
             
            },
          ), */
          //funcionalidade sera implementada no futuro
          /* ListTile(
            leading: Icon(Icons.person_add_outlined),
            title: Text('Cadastrar'),
            onTap: () {
              Navigator.pop(context);
              
            },
          ), */
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


  Future<void> backupDatabase(BuildContext context) async {
    final dbDir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbDir.path, 'clipstick.sqlite'));
    final dbBytes = await dbFile.readAsBytes();

    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Salvar backup do ClipStick',
      fileName: 'clipstick_backup.sqlite',
      type: FileType.custom,
      allowedExtensions: ['sqlite'],
      bytes: dbBytes,
    );

    await sl<AppDatabase>().close();

    showLoadingDialog(context, message: 'Realizando backup...').then((_) {
      debugPrint('Backup salvo em: $outputPath');
      Utils.normalSucess(message: 'Backup salvo em: $outputPath');
    });

    await Future.delayed(Duration(seconds: 2));

    //Navigator.of(context, rootNavigator: true).pop();

    await cleanupServiceLocator();
    await setupServiceLocator();
    Restart.restartApp();
  }

    Future<void> restoreDatabaseComInstrucao(BuildContext context) async {
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

    await restoreDatabase(context);
  }

  Future<void> restoreDatabase(BuildContext context) async {
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

      bool isValid = await isValidBackupSchema(backupFile);
      if (!isValid) {
        Utils.normalException(message: "Arquivo de backup inválido ou incompatível com esta versão do app.");
        return;
      }

      await sl<AppDatabase>().close();

      showLoadingDialog(context, message: 'Restaurando backup...');

      await Future.delayed(Duration(seconds: 1));

      // Copia o arquivo para o diretório do app
      final dbDir = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbDir.path, 'clipstick.sqlite'));

      // Copia o backup para o local do banco
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

  Future<bool> isValidBackupSchema(File backupFile) async {
    // Copia para um local temporário
    final tempDir = await getTemporaryDirectory();
    final tempDbFile = File('${tempDir.path}/temp_restore_check.sqlite');
    await backupFile.copy(tempDbFile.path);

    // Abre conexão direta
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
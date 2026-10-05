import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/backup_file.dart' as backup_file;
import '../../../../core/storage/project_backup_service.dart';
import '../../../../core/storage/project_storage_service.dart';
import '../../../../generated/app_localizations.dart';
import '../../providers/home_provider.dart';

enum _BackupAction { export, import }

class ProjectBackupActions extends ConsumerWidget {
  const ProjectBackupActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<_BackupAction>(
      tooltip: l10n.projectBackup,
      icon: const Icon(Icons.backup_outlined),
      onSelected: (action) {
        switch (action) {
          case _BackupAction.export:
            _export(context, ref);
          case _BackupAction.import:
            _import(context, ref);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _BackupAction.export,
          child: Text(l10n.exportLocalBackup),
        ),
        PopupMenuItem(
          value: _BackupAction.import,
          child: Text(l10n.importLocalBackup),
        ),
      ],
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final projects = await ref.read(projectsProvider.future);
      final contents = ProjectBackupService().exportProjects(projects);
      final saved = await backup_file.saveBackupFile(contents);
      if (!context.mounted || !saved) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupExported)));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupExportError('$error'))));
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final file = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: true,
      );
      if (file == null || file.files.length != 1) return;
      final bytes = file.files.single.bytes;
      if (bytes == null) throw const FormatException('Missing file contents.');
      final backupService = ProjectBackupService();
      final current = await ref.read(projectsProvider.future);
      final merged = backupService.prepareImport(
        encoded: utf8.decode(bytes),
        existing: current,
      );
      final currentIds = current.map((project) => project.id).toSet();
      final additions = merged
          .where((project) => !currentIds.contains(project.id))
          .toList();
      if (additions.isEmpty) {
        if (context.mounted) {
          _showMessage(context, l10n.backupImportNoNewProjects);
        }
        return;
      }
      if (!context.mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(l10n.backupImportConfirm(additions.length)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.backupCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.backupConfirm),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;

      final storage = ref.read(storageServiceProvider);
      for (final project in additions) {
        await storage.save(project);
      }
      ref.invalidate(projectsProvider);
      if (!context.mounted) return;
      _showMessage(context, l10n.backupImported(additions.length));
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, l10n.backupImportError('$error'));
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

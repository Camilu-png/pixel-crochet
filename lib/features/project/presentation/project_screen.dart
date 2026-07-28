import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/crochet_project.dart';
import '../../../core/storage/project_storage_service.dart';
import '../../../core/theme/context_extensions.dart';
import '../../../generated/app_localizations.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../home/providers/home_provider.dart';
import '../providers/project_provider.dart';
import 'widgets/pattern_image.dart';
import 'widgets/row_display.dart';

class ProjectScreen extends ConsumerWidget {
  const ProjectScreen({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final projectAsync = ref.watch(projectProvider(projectId));

    return projectAsync.when(
      data: (project) {
        if (project == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.project)),
            body: Center(child: Text(l10n.projectNotFound)),
          );
        }
        return _ProjectContent(
          project: project,
          l10n: l10n,
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.project)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.project)),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _ProjectContent extends ConsumerWidget {
  const _ProjectContent({
    required this.project,
    required this.l10n,
  });

  final CrochetProject project;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRow = project.rows.isNotEmpty
        ? project.rows[project.currentRowIndex]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Pattern image
                  SizedBox(
                    height: 300,
                    child: PatternImage(
                      project: project,
                      highlightRowIndex: project.currentRowIndex,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Progress indicator
                  LinearProgressIndicator(
                    value: project.progress,
                    backgroundColor: context.colors.brandLavenderLight,
                    color: context.colors.brandLavender,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${project.currentRowNumber} / ${project.totalRows} rows (${(project.progress * 100).toStringAsFixed(0)}%)',
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.brandDark,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Current row display
                  if (currentRow != null) RowDisplay(row: currentRow),

                  const SizedBox(height: 16),

                  // Row navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: project.currentRowIndex > 0
                            ? () => _navigateRow(ref, -1)
                            : null,
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: Text(l10n.previousRow),
                      ),
                      OutlinedButton.icon(
                        onPressed: !project.isCompleted
                            ? () => _navigateRow(ref, 1)
                            : null,
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: Text(l10n.nextRow),
                        iconAlignment: IconAlignment.end,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateRow(WidgetRef ref, int delta) {
    final newIndex = project.currentRowIndex + delta;
    if (newIndex >= 0 && newIndex < project.rows.length) {
      final updated = project.copyWith(currentRowIndex: newIndex);
      const ProjectStorageService().save(updated);
      ref.invalidate(projectProvider(project.id));
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: l10n.deleteProject,
        message: l10n.deleteProjectConfirm(project.name),
        confirmLabel: l10n.delete,
        onConfirm: () {
          ref.read(projectsProvider.notifier).deleteProject(project.id);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

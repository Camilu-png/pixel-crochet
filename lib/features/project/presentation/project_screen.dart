import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/crochet_project.dart';
import '../../../core/theme/context_extensions.dart';
import '../../../generated/app_localizations.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../providers/project_provider.dart';
import 'widgets/pattern_image.dart';
import 'widgets/row_display.dart';

class ProjectScreen extends ConsumerWidget {
  const ProjectScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final projectAsync = ref.watch(projectProvider(projectId));

    return projectAsync.when(
      data: (project) =>
          _ProjectContent(projectId: projectId, project: project),
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.project)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.project)),
        body: Center(
          child: Text(
            error is ProjectNotFoundException
                ? l10n.projectNotFound
                : l10n.errorOccurred('$error'),
          ),
        ),
      ),
    );
  }
}

class _ProjectContent extends ConsumerWidget {
  const _ProjectContent({required this.projectId, required this.project});

  final String projectId;
  final CrochetProject project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentRow = project.rows.isNotEmpty
        ? project.rows[project.currentRowIndex]
        : null;
    final notifier = ref.read(projectProvider(projectId).notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('home'),
        ),
        title: Text(project.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final imageHeight = (constraints.maxHeight * 0.6).clamp(150.0, 400.0);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: imageHeight,
                  child: PatternImage(
                    project: project,
                    highlightRowIndex: project.currentRowIndex,
                  ),
                ),

                const SizedBox(height: 16),

                LinearProgressIndicator(
                  value: project.progress,
                  backgroundColor: context.colors.brandLavenderLight,
                  color: context.colors.brandLavender,
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.rowLabel} ${project.currentRowNumber}/${project.totalRows} · ${(project.progress * 100).toStringAsFixed(0)}%',
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.brandDark,
                  ),
                ),

                const SizedBox(height: 16),

                if (currentRow != null)
                  RowDisplay(
                    row: currentRow,
                    completedBlocks:
                        project.completedBlocks[project.currentRowIndex] ??
                        const {},
                    onToggleBlock: notifier.toggleBlock,
                  ),

                const SizedBox(height: 16),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: project.currentRowIndex > 0
                          ? () => notifier.setCurrentRow(
                              project.currentRowIndex - 1,
                            )
                          : null,
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: Text(l10n.previousRow),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _goToRow(context, ref),
                      icon: const Icon(Icons.unfold_more, size: 16),
                      label: Text('${l10n.goToRow}…'),
                    ),
                    OutlinedButton.icon(
                      onPressed: project.currentRowIndex < project.totalRows - 1
                          ? () => notifier.setCurrentRow(
                              project.currentRowIndex + 1,
                            )
                          : null,
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: Text(l10n.nextRow),
                      iconAlignment: IconAlignment.end,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _goToRow(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(
      text: '${project.currentRowNumber}',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.goToRow),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '1 – ${project.totalRows}',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              final rowNumber = int.tryParse(text);
              if (rowNumber == null ||
                  rowNumber < 1 ||
                  rowNumber > project.totalRows) {
                return;
              }
              ref
                  .read(projectProvider(projectId).notifier)
                  .setCurrentRow(rowNumber - 1);
              Navigator.of(dialogContext).pop();
            },
            child: Text(l10n.goToRow),
          ),
        ],
      ),
    );

    controller.dispose();
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmDialog(
        title: l10n.deleteProject,
        message: l10n.deleteProjectConfirm(project.name),
        confirmLabel: l10n.delete,
        onConfirm: () {
          ref.read(projectProvider(projectId).notifier).delete();
          Navigator.of(dialogContext).pop();
          dialogContext.goNamed('home');
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  const ProjectScreen({super.key, required this.projectId});

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
        return _ProjectContent(project: project, l10n: l10n);
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

class _ProjectContent extends ConsumerStatefulWidget {
  const _ProjectContent({required this.project, required this.l10n});

  final CrochetProject project;
  final AppLocalizations l10n;

  @override
  ConsumerState<_ProjectContent> createState() => _ProjectContentState();
}

class _ProjectContentState extends ConsumerState<_ProjectContent> {
  late CrochetProject _project;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
  }

  @override
  void didUpdateWidget(_ProjectContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project.id != widget.project.id) {
      _project = widget.project;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final currentRow = _project.rows.isNotEmpty
        ? _project.rows[_project.currentRowIndex]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_project.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
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
                    project: _project,
                    highlightRowIndex: _project.currentRowIndex,
                  ),
                ),

                const SizedBox(height: 16),

                LinearProgressIndicator(
                  value: _project.progress,
                  backgroundColor: context.colors.brandLavenderLight,
                  color: context.colors.brandLavender,
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.rowLabel} ${_project.currentRowNumber}/${_project.totalRows} · ${(_project.progress * 100).toStringAsFixed(0)}%',
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.brandDark,
                  ),
                ),

                const SizedBox(height: 16),

                if (currentRow != null)
                  RowDisplay(
                    row: currentRow,
                    completedBlocks:
                        _project.completedBlocks[_project.currentRowIndex] ??
                            const {},
                    onToggleBlock: _toggleBlock,
                  ),

                const SizedBox(height: 16),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _project.currentRowIndex > 0
                          ? () => _navigateRow(-1)
                          : null,
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: Text(l10n.previousRow),
                    ),
                    OutlinedButton.icon(
                      onPressed: _goToRow,
                      icon: const Icon(Icons.unfold_more, size: 16),
                      label: Text('${l10n.goToRow}…'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _project.currentRowIndex < _project.totalRows - 1
                          ? () => _navigateRow(1)
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

  void _navigateRow(int delta) {
    final newIndex = _project.currentRowIndex + delta;
    if (newIndex >= 0 && newIndex < _project.rows.length) {
      final updated = _project.copyWith(currentRowIndex: newIndex);
      setState(() => _project = updated);
      ref.read(projectsProvider.notifier).updateProject(updated);
    }
  }

  void _goToRow() {
    final controller = TextEditingController(
      text: '${_project.currentRowNumber}',
    );
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(widget.l10n.goToRow),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '1 – ${_project.totalRows}',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(widget.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              final rowNumber = int.tryParse(text);
              if (rowNumber == null || rowNumber < 1 || rowNumber > _project.totalRows) {
                return;
              }
              final newIndex = rowNumber - 1;
              final updated = _project.copyWith(currentRowIndex: newIndex);
              setState(() => _project = updated);
              ref.read(projectsProvider.notifier).updateProject(updated);
              Navigator.of(dialogContext).pop();
            },
            child: Text(widget.l10n.goToRow),
          ),
        ],
      ),
    );
  }

  void _toggleBlock(int blockIndex) {
    final rowIndex = _project.currentRowIndex;
    final updated = _project.toggleBlock(rowIndex, blockIndex);
    setState(() => _project = updated);
    ref.read(storageServiceProvider).save(updated);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmDialog(
        title: widget.l10n.deleteProject,
        message: widget.l10n.deleteProjectConfirm(_project.name),
        confirmLabel: widget.l10n.delete,
        onConfirm: () {
          ref.read(projectsProvider.notifier).deleteProject(_project.id);
          Navigator.of(dialogContext).pop();
          dialogContext.goNamed('home');
        },
      ),
    );
  }
}

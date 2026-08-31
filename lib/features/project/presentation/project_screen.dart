import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/color_map.dart';
import '../../../core/models/crochet_project.dart';
import '../../../core/models/pattern_row.dart';
import '../../../core/models/color_block.dart';
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

    ref.listen<Object?>(projectSaveErrorProvider(projectId), (prev, next) {
      if (next == null) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.saveError('$next')),
            behavior: SnackBarBehavior.floating,
          ),
        );
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('home'),
        ),
        title: Text(project.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditSheet(context, ref, project),
          ),
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

  void _showEditSheet(
    BuildContext context,
    WidgetRef ref,
    CrochetProject project,
  ) {
    final nameController = TextEditingController(text: project.name);
    final usedColors = project.rows
        .expand((row) => row.colorBlocks)
        .map((block) => block.colorName)
        .toSet()
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _EditProjectSheet(
        project: project,
        nameController: nameController,
        usedColors: usedColors,
        onSave: (updatedProject) {
          ref
              .read(projectProvider(projectId).notifier)
              .updateProject(updatedProject);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }
}

class _EditProjectSheet extends StatefulWidget {
  const _EditProjectSheet({
    required this.project,
    required this.nameController,
    required this.usedColors,
    required this.onSave,
  });

  final CrochetProject project;
  final TextEditingController nameController;
  final List<String> usedColors;
  final ValueChanged<CrochetProject> onSave;

  @override
  State<_EditProjectSheet> createState() => _EditProjectSheetState();
}

class _EditProjectSheetState extends State<_EditProjectSheet> {
  late List<String> _currentColors;

  @override
  void initState() {
    super.initState();
    _currentColors = List<String>.from(widget.usedColors);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.editProject,
              style: context.text.titleLarge?.copyWith(
                color: context.colors.brandDark,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: widget.nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.projectName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: context.colors.brandIvory,
              ),
            ),
            if (_currentColors.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                l10n.usedColors,
                style: context.text.titleMedium?.copyWith(
                  color: context.colors.brandDark,
                ),
              ),
              const SizedBox(height: 12),
              ..._currentColors.asMap().entries.map((entry) {
                final index = entry.key;
                final colorName = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: getYarnColor(colorName),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: context.colors.brandDark.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          colorName,
                          style: context.text.bodyMedium?.copyWith(
                            color: context.colors.brandDark,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _changeColor(index),
                        child: Text(l10n.changeColor),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: Text(l10n.save)),
          ],
        ),
      ),
    );
  }

  Future<void> _changeColor(int index) async {
    final l10n = AppLocalizations.of(context)!;
    final oldColorName = _currentColors[index];

    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${l10n.changeColor}: $oldColorName'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 12,
              children: [
                Text(
                  l10n.yarnColors,
                  style: context.text.labelMedium?.copyWith(
                    color: context.colors.brandDark.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                ...yarnColors.entries.map(
                  (entry) => SizedBox(
                    width: 64,
                    child: InkWell(
                      onTap: () => Navigator.of(ctx).pop(entry.key),
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: entry.value,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: context.colors.brandDark.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.key,
                            style: const TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );

    if (selected == null || selected == oldColorName) return;

    setState(() {
      _currentColors[index] = selected;
    });
  }

  void _save() {
    final name = widget.nameController.text.trim();
    if (name.isEmpty) return;

    final colorTranslations = <String, String>{
      for (var i = 0; i < widget.usedColors.length; i++)
        if (widget.usedColors[i] != _currentColors[i])
          widget.usedColors[i]: _currentColors[i],
    };
    final updatedProject = colorTranslations.isEmpty
        ? widget.project.copyWith(name: name)
        : _replaceColorInProject(
            widget.project.copyWith(name: name),
            colorTranslations,
          );
    widget.onSave(updatedProject);
  }

  CrochetProject _replaceColorInProject(
    CrochetProject project,
    Map<String, String> colorTranslations,
  ) {
    final updatedRows = project.rows.map((row) {
      final updatedBlocks = row.colorBlocks.map((block) {
        final newColorName =
            colorTranslations[block.colorName] ?? block.colorName;
        return newColorName == block.colorName
            ? block
            : ColorBlock(colorName: newColorName, count: block.count);
      }).toList();
      return PatternRow(
        rowNumber: row.rowNumber,
        direction: row.direction,
        colorBlocks: updatedBlocks,
      );
    }).toList();
    return project.copyWith(rows: updatedRows);
  }
}

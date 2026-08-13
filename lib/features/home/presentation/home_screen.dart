import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/crochet_project.dart';
import '../../../generated/app_localizations.dart';
import '../../../core/theme/context_extensions.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../providers/home_provider.dart';
import 'widgets/project_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pattern,
                    size: 80,
                    color: context.colors.brandLavender.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.homeWelcome,
                    style: context.text.headlineMedium?.copyWith(
                      color: context.colors.brandDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.homeDescription,
                    style: context.text.bodyLarge?.copyWith(
                      color: context.colors.brandDark.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return ProjectCard(
                project: project,
                onTap: () => context.pushNamed(
                  'project',
                  pathParameters: {'id': project.id},
                ),
                onDelete: () => _confirmDelete(context, ref, l10n, project),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(l10n.errorOccurred('$error')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('import'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    CrochetProject project,
  ) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: l10n.deleteProject,
        message: l10n.deleteProjectConfirm(project.name),
        confirmLabel: l10n.delete,
        onConfirm: () {
          ref.read(projectsProvider.notifier).deleteProject(project.id);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

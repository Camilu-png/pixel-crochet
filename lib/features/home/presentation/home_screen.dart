import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/crochet_project.dart';
import '../../../generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/home_provider.dart';
import 'widgets/project_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final projectsAsync = ref.watch(projectsProvider);

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: projectsAsync.when(
                data: (projects) {
                  if (projects.isEmpty) {
                    return _EmptyPatternsView(
                      onImport: () => context.pushNamed('import'),
                      onBrowse: () => context.goNamed('more-patterns'),
                    );
                  }
                  return _PatternsGrid(projects: projects);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text(l10n.errorOccurred('$error')),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => context.pushNamed('import'),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class _PatternsGrid extends ConsumerWidget {
  const _PatternsGrid({required this.projects});

  final List<CrochetProject> projects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = columnsFor(MediaQuery.sizeOf(context).width);

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return TweenAnimationBuilder<double>(
          key: ValueKey(project.id),
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 260 + (index % 6) * 40),
          curve: Curves.easeOutCubic,
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, 12 * (1 - t)),
              child: child,
            ),
          ),
          child: ProjectCard(
            project: project,
            onTap: () => context.pushNamed(
              'project',
              pathParameters: {'id': project.id},
            ),
            onDelete: () =>
                ref.read(projectsProvider.notifier).deleteProject(project.id),
          ),
        );
      },
    );
  }
}

int columnsFor(double width) {
  if (width >= 1200) return 4;
  if (width >= 900) return 3;
  if (width >= 600) return 3;
  return 2;
}

class _EmptyPatternsView extends StatelessWidget {
  const _EmptyPatternsView({required this.onImport, required this.onBrowse});

  final VoidCallback onImport;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final texts = context.texts;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: brand.yarnGradient,
                  boxShadow: brand.softShadow,
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/favicon/favicon-96x96.png',
                  width: 68,
                  height: 68,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                l10n.welcomeTitle,
                textAlign: TextAlign.center,
                style: texts.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.welcomeSubtitle,
                textAlign: TextAlign.center,
                style: texts.bodyLarge?.copyWith(color: brand.inkMuted),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onImport,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(l10n.importFirstPattern),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onBrowse,
                icon: const Icon(Icons.storefront_outlined),
                label: Text(l10n.browsePatterns),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  Chip(label: Text(l10n.hintPng)),
                  Chip(label: Text(l10n.hintTxt)),
                  Chip(label: Text(l10n.hintKofi)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

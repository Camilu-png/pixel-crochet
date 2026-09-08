import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/crochet_project.dart';
import '../../../core/onboarding/onboarding_provider.dart';
import '../../../core/theme/context_extensions.dart';
import '../../../generated/app_localizations.dart';
import '../../../shared/widgets/onboarding_overlay.dart';
import '../../home/providers/home_provider.dart';
import '../data/pattern_parser.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  final _parser = const PatternParser();
  final _textController = TextEditingController();
  final _nameController = TextEditingController();
  final _fileImportKey = GlobalKey();
  final _imageImportKey = GlobalKey();
  final _pastePatternKey = GlobalKey();
  bool _isImporting = false;
  bool _showTutorial = false;
  CrochetProject? _parsedProject;

  @override
  void initState() {
    super.initState();
    _maybeShowOnboarding();
  }

  Future<void> _maybeShowOnboarding() async {
    final storage = ref.read(onboardingStorageProvider);
    if (await storage.hasSeen(OnboardingTip.import)) return;
    await storage.markAsSeen(OnboardingTip.import);
    if (!mounted) return;
    _launchTutorial();
  }

  void _launchTutorial() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _showTutorial = true);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return OnboardingOverlay(
      active: _showTutorial,
      doneLabel: l10n.onboardingGotIt,
      nextLabel: l10n.onboardingNext,
      onDismiss: () => setState(() => _showTutorial = false),
      steps: [
        OnboardingStep(
          icon: Icons.description_outlined,
          title: l10n.onboardingImportTitle,
          description: l10n.onboardingImportDesc,
          targetKey: _fileImportKey,
        ),
        OnboardingStep(
          icon: Icons.image_outlined,
          title: l10n.onboardingImportImageButtonTitle,
          description: l10n.onboardingImportImageButtonDesc,
          targetKey: _imageImportKey,
        ),
        OnboardingStep(
          icon: Icons.content_paste,
          title: l10n.onboardingImportPasteTitle,
          description: l10n.onboardingImportPasteDesc,
          targetKey: _pastePatternKey,
        ),
      ],
      child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.importPattern),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n.tutorial,
            onPressed: _launchTutorial,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.upload_file,
              size: 80,
              color: context.colors.brandLavender,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.importPatternDescription,
              style: context.text.headlineSmall?.copyWith(
                color: context.colors.brandDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.importPatternHint,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.brandDark.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (_parsedProject != null)
              _buildNameEditor(l10n)
            else if (_isImporting)
              const CircularProgressIndicator()
            else ...[
              // File picker option
              FilledButton.icon(
                key: _fileImportKey,
                onPressed: _pickFile,
                icon: const Icon(Icons.file_open),
                label: Text(l10n.selectFile),
              ),
              const SizedBox(height: 16),
              // Image import option
              OutlinedButton.icon(
                key: _imageImportKey,
                onPressed: () => context.pushNamed('import-image'),
                icon: const Icon(Icons.image),
                label: Text(l10n.importImage),
              ),
              const SizedBox(height: 16),
              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.or,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.brandDark.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              // Paste text option
              Column(
                key: _pastePatternKey,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.pastePattern,
                    style: context.text.titleMedium?.copyWith(
                      color: context.colors.brandDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _textController,
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText: l10n.pastePatternHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: context.colors.brandIvory,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _importFromText,
                    icon: const Icon(Icons.content_paste),
                    label: Text(l10n.importText),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildNameEditor(AppLocalizations l10n) {
    return Column(
      children: [
        Text(
          l10n.importPattern,
          style: context.text.titleMedium?.copyWith(
            color: context.colors.brandDark,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.projectName,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: context.colors.brandIvory,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_parsedProject!.totalRows} ${l10n.rows}',
          style: context.text.bodySmall?.copyWith(
            color: context.colors.brandDark.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _parsedProject = null),
                child: Text(l10n.cancel),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton.icon(
                onPressed: _confirmImport,
                icon: const Icon(Icons.file_download),
                label: Text(l10n.confirmImport),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result == null || result.files.isEmpty) return;

    setState(() => _isImporting = true);

    try {
      final file = result.files.first;
      final String content;
      if (file.bytes != null) {
        content = utf8.decode(file.bytes!);
      } else {
        throw const FormatException('filePathError');
      }
      final project = await _parser.parseAsync(content);
      _nameController.text = project.name;
      setState(() {
        _parsedProject = project;
        _isImporting = false;
      });
    } catch (e) {
      _showImportError(e);
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  Future<void> _importFromText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isImporting = true);

    try {
      final project = await _parser.parseAsync(text);
      _nameController.text = project.name;
      setState(() {
        _parsedProject = project;
        _isImporting = false;
      });
    } catch (e) {
      _showImportError(e);
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  void _showImportError(Object error) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final message = error is FormatException && error.message == 'filePathError'
        ? l10n.filePathError
        : l10n.importErrorDetail('$error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _confirmImport() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isImporting = true);

    try {
      final project = _parsedProject!.copyWith(name: name);
      await ref.read(projectsProvider.notifier).addProject(project);

      if (mounted) {
        context.goNamed('home');
      }
    } catch (e) {
      _showImportError(e);
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }
}

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/context_extensions.dart';
import '../../../generated/app_localizations.dart';
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
  bool _isImporting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.importPattern),
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
            if (_isImporting)
              const CircularProgressIndicator()
            else ...[
              // File picker option
              FilledButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.file_open),
                label: Text(l10n.selectFile),
              ),
              const SizedBox(height: 16),
              // Image import option
              OutlinedButton.icon(
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
          ],
        ),
      ),
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
      final path = result.files.first.path;
      if (path == null) {
        throw const FormatException('filePathError');
      }
      final file = File(path);
      final content = await file.readAsString();
      await _importPattern(content);
    } catch (e) {
      _showImportError(e);
    } finally {
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
      await _importPattern(text);
    } catch (e) {
      _showImportError(e);
    } finally {
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

  Future<void> _importPattern(String content) async {
    final project = _parser.parse(content);
    await ref.read(projectsProvider.notifier).addProject(project);

    if (mounted) {
      context.goNamed('home');
    }
  }
}

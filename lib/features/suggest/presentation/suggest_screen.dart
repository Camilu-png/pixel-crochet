import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_crochet/core/theme/app_colors.dart';
import 'package:pixel_crochet/shared/utils/open_url.dart';

import '../../../../generated/app_localizations.dart';

class SuggestScreen extends ConsumerStatefulWidget {
  const SuggestScreen({super.key});

  @override
  ConsumerState<SuggestScreen> createState() => _SuggestScreenState();
}

class _SuggestScreenState extends ConsumerState<SuggestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  String _subject = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_subject.isEmpty) {
      _subject = AppLocalizations.of(context)!.suggestSubjectDefault;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final texts = context.texts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.suggestTitle, style: texts.headlineMedium),
                    const SizedBox(height: 8),
                    Text(l10n.suggestSubtitle, style: texts.bodyMedium),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        avatar: const Icon(Icons.subject_rounded, size: 16),
                        label: Text(_subject),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.yourName,
                        hintText: l10n.suggestNameHint,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.requiredField
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _messageController,
                      minLines: 5,
                      maxLines: 8,
                      maxLength: 800,
                      decoration: InputDecoration(
                        labelText: l10n.yourSuggestion,
                        hintText: l10n.suggestMessageHint,
                        alignLabelWithHint: true,
                      ),
                      validator: (v) => (v == null || v.trim().length < 10)
                          ? l10n.tooShort
                          : null,
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => _submit(context),
                      icon: const Icon(Icons.send_rounded),
                      label: Text(l10n.suggestSend),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    final message = _messageController.text.trim();
    final subject = Uri.encodeComponent(_subject);
    final body = Uri.encodeComponent('Name: $name\n\nMessage: $message');

    final success = await openUrl(
      context,
      'mailto:${l10n.suggestEmail}?subject=$subject&body=$body',
    );
    if (success && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.suggestSuccess)));
      _formKey.currentState!.reset();
      _nameController.clear();
      _messageController.clear();
    }
  }
}

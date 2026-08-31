import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_crochet/core/theme/context_extensions.dart';
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
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_subjectController.text.isEmpty) {
      _subjectController.text = AppLocalizations.of(
        context,
      )!.suggestSubjectDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.suggestTitle,
            textAlign: TextAlign.center,
            style: context.text.headlineMedium?.copyWith(
              color: context.colors.brandDark,
            ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    labelText: l10n.suggestSubjectLabel,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.suggestNameLabel,
                    hintText: l10n.suggestNameHint,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.suggestValidationName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _messageController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: l10n.suggestMessageLabel,
                    hintText: l10n.suggestMessageHint,
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.suggestValidationMessage;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => _submit(context),
                  child: Text(l10n.suggestSend),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    final message = _messageController.text.trim();
    final subjectText = _subjectController.text.trim();
    final subject = Uri.encodeComponent(
      subjectText.isEmpty ? l10n.suggestSubjectDefault : subjectText,
    );
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

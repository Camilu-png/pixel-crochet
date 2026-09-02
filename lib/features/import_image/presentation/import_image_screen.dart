import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/color_map.dart';
import '../../../core/onboarding/onboarding_provider.dart';
import '../../../core/theme/context_extensions.dart';
import '../../../generated/app_localizations.dart';
import '../../../shared/widgets/onboarding_overlay.dart';
import '../../home/providers/home_provider.dart';
import '../data/image_processor.dart';

class ImportImageScreen extends ConsumerStatefulWidget {
  const ImportImageScreen({super.key});

  @override
  ConsumerState<ImportImageScreen> createState() => _ImportImageScreenState();
}

class _ImportImageScreenState extends ConsumerState<ImportImageScreen> {
  final _processor = ImageProcessor();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _nameController = TextEditingController();
  static const double _defaultPixelsPerStitch = 30;

  Uint8List? _imageBytes;
  ImageData? _imageData;
  List<List<Color>>? _matrix;
  List<DetectedColor>? _palette;
  GridInfo? _gridInfo;
  bool _isProcessing = false;
  bool _isImporting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _maybeShowOnboarding();
  }

  Future<void> _maybeShowOnboarding() async {
    final storage = ref.read(onboardingStorageProvider);
    if (await storage.hasSeen(OnboardingTip.importImage)) return;
    await storage.markAsSeen(OnboardingTip.importImage);
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => OnboardingOverlay(
          steps: [
            OnboardingStep(
              icon: Icons.image_outlined,
              title: l10n.onboardingImportImageTitle,
              description: l10n.onboardingImportImageDesc,
            ),
          ],
          doneLabel: l10n.onboardingGotIt,
        ),
      );
    });
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.importImage),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_imageBytes != null) _buildImagePreview(),
            if (_imageBytes != null) const SizedBox(height: 24),
            if (_imageBytes != null) _buildForm(l10n),
            if (_imageBytes != null) const SizedBox(height: 24),
            if (_errorMessage != null) _buildError(l10n),
            if (_gridInfo != null) _buildPreview(l10n),
            if (_imageBytes != null) const SizedBox(height: 24),
            if (_imageBytes != null) _buildActions(l10n),
            if (_imageBytes == null) _buildInitialState(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        Icon(
          Icons.image_outlined,
          size: 80,
          color: context.colors.brandLavender,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.importImageDescription,
          style: context.text.headlineSmall?.copyWith(
            color: context.colors.brandDark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: Text(l10n.selectImage),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 250),
        child: Image.memory(
          _imageBytes!,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    final imgW = _imageData?.width ?? 0;
    final imgH = _imageData?.height ?? 0;

    final sw = int.tryParse(_widthController.text) ?? 0;
    final sh = int.tryParse(_heightController.text) ?? 0;
    final total = sw * sh;
    final exceedsLimit = total > ImageProcessor.maxStitches;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 16),
        Text(
          '${l10n.dimensionsImage}:  $imgW × $imgH px',
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.brandDark,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _widthController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.stitchesWide,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: context.colors.brandIvory,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.stitchesHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: context.colors.brandIvory,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        if (sw > 0 && sh > 0) ...[
          const SizedBox(height: 8),
          Text(
            '${l10n.totalStitches}: $total',
            style: context.text.bodySmall?.copyWith(
              color: exceedsLimit
                  ? Colors.red
                  : context.colors.brandDark.withValues(alpha: 0.6),
            ),
          ),
          if (exceedsLimit)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.maxStitchesExceeded(ImageProcessor.maxStitches),
                style: context.text.bodySmall?.copyWith(color: Colors.red),
              ),
            ),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: (_isProcessing || exceedsLimit || sw < 1 || sh < 1)
              ? null
              : _previewPattern,
          icon: _isProcessing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.preview),
          label: Text(_isProcessing ? l10n.processing : l10n.previewPattern),
        ),
      ],
    );
  }

  Widget _buildPreview(AppLocalizations l10n) {
    final grid = _gridInfo!;
    final palette = _palette!;
    final total = grid.numCols * grid.numRows;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: context.colors.brandLavender.withValues(alpha: 0.3)),
        const SizedBox(height: 16),
        Text(
          l10n.patternPreview,
          style: context.text.titleMedium?.copyWith(
            color: context.colors.brandDark,
          ),
        ),
        const SizedBox(height: 12),
        _previewRow(l10n.dimensions, '${grid.numCols} × ${grid.numRows}'),
        const SizedBox(height: 8),
        _previewRow(l10n.totalStitches, total.toString()),
        const SizedBox(height: 16),
        Text(
          l10n.detectedColors(palette.length),
          style: context.text.titleSmall?.copyWith(
            color: context.colors.brandDark,
          ),
        ),
        const SizedBox(height: 8),
        ...palette.map((dc) => _buildColorRow(dc, l10n)),
      ],
    );
  }

  Widget _buildColorRow(DetectedColor dc, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: dc.color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: context.colors.brandDark.withValues(alpha: 0.2),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              dc.id,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.brandDark,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _changeColor(dc),
            child: Text(l10n.changeColor),
          ),
        ],
      ),
    );
  }

  Widget _previewRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.brandDark.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.brandDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: context.text.bodyMedium?.copyWith(
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isImporting ? null : () => context.pop(),
            child: Text(l10n.cancel),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton.icon(
            onPressed: (_gridInfo == null || _isImporting)
                ? null
                : _importPattern,
            icon: _isImporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.file_download),
            label: Text(l10n.confirmImport),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final ext = file.name.split('.').last.toLowerCase();
    if (!['png', 'jpg', 'jpeg'].contains(ext)) {
      setState(
        () => _errorMessage = AppLocalizations.of(context)!.imageFormatError,
      );
      return;
    }

    try {
      final Uint8List bytes;
      if (file.bytes != null) {
        bytes = file.bytes!;
      } else {
        return;
      }

      setState(() {
        _imageBytes = bytes;
        _errorMessage = null;
        _matrix = null;
        _palette = null;
        _gridInfo = null;
      });

      final data = await _processor.loadImageBytesAsync(bytes);
      if (!mounted) return;
      setState(() {
        _imageData = data;
        _nameController.text = file.name.split('.').first;
        _widthController.text = _suggestedStitches(data.width).toString();
        _heightController.text = _suggestedStitches(data.height).toString();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _localizedError(e, AppLocalizations.of(context)!);
        _imageData = null;
        _imageBytes = null;
      });
    }
  }

  int _suggestedStitches(int pixels) {
    return (pixels / _defaultPixelsPerStitch)
        .round()
        .clamp(1, ImageProcessor.maxStitches)
        .toInt();
  }

  Future<void> _previewPattern() async {
    final l10n = AppLocalizations.of(context)!;
    final sw = int.tryParse(_widthController.text) ?? 0;
    final sh = int.tryParse(_heightController.text) ?? 0;

    if (sw < 1 || sh < 1) {
      setState(() => _errorMessage = l10n.invalidStitchCount);
      return;
    }

    if (sw * sh > ImageProcessor.maxStitches) {
      setState(
        () => _errorMessage = l10n.maxStitchesExceeded(
          ImageProcessor.maxStitches,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _matrix = null;
      _palette = null;
      _gridInfo = null;
    });

    try {
      final data = _imageData!;
      final result = await _processor.processGridAsync(data, sw, sh);
      if (!mounted) return;
      setState(() {
        _matrix = result.matrix;
        _palette = result.palette;
        _gridInfo = result.grid;
        _isProcessing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _localizedError(e, l10n);
        _isProcessing = false;
      });
    }
  }

  Future<void> _changeColor(DetectedColor oldColor) async {
    final l10n = AppLocalizations.of(context)!;

    final options = <_ColorOption>[];

    for (final entry in yarnColors.entries) {
      options.add(_ColorOption(id: entry.key, color: entry.value));
    }

    for (final dc in _palette!) {
      if (dc.color.toARGB32() != oldColor.color.toARGB32()) {
        options.add(_ColorOption(id: dc.id, color: dc.color));
      }
    }

    final selected = await showDialog<_ColorOption>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${l10n.changeColor}: ${oldColor.id}'),
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
                ...options.map(
                  (opt) => SizedBox(
                    width: 64,
                    child: InkWell(
                      onTap: () => Navigator.of(ctx).pop(opt),
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: opt.color,
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
                            opt.id,
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

    if (selected == null) return;

    setState(() {
      _matrix = _processor.replaceColorsInMatrix(
        _matrix!,
        oldColor.color,
        selected.color,
      );
      _palette = _processor.detectPalette(_matrix!);
    });
  }

  Future<void> _importPattern() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() => _isImporting = true);

    try {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        setState(() => _isImporting = false);
        return;
      }

      final project = _processor.generateProject(name, _matrix!);

      await ref.read(projectsProvider.notifier).addProject(project);

      if (mounted) {
        context.pushReplacementNamed(
          'project',
          pathParameters: {'id': project.id},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.importErrorDetail('$e')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  String _localizedError(Object error, AppLocalizations l10n) {
    if (error is ImageProcessingException) {
      switch (error.code) {
        case 'corruptedImage':
          return l10n.corruptedImage;
        case 'imageTooLarge':
          return l10n.imageTooLarge;
        case 'invalidImageDimensions':
          return l10n.invalidImageDimensions;
      }
    }
    return '$error';
  }
}

class _ColorOption {
  const _ColorOption({required this.id, required this.color});

  final String id;
  final Color color;
}
